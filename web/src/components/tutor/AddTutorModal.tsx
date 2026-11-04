import { useState } from 'react';
import { supabase } from '../../lib/supabase';
import { X, Save, Loader2 } from 'lucide-react';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

const SUBJECTS = ['mtk', 'fis', 'kim', 'bio', 'ing'];
const JENJANG = ['sd', 'smp', 'sma', 'kuliah'];

export function AddTutorModal({ isOpen, onClose, onSuccess }: Props) {
  const [form, setForm] = useState({
    full_name: '',
    email: '',
    phone: '',
    university: '',
    bio: '',
    price_per_hour: 100000,
    subjects: [] as string[],
    jenjang_diajar: [] as string[],
  });
  const [saving, setSaving] = useState(false);

  if (!isOpen) return null;

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleCheckbox = (field: 'subjects' | 'jenjang_diajar', value: string) => {
    setForm((prev) => {
      const current = prev[field];
      const updated = current.includes(value)
        ? current.filter((v) => v !== value)
        : [...current, value];
      return { ...prev, [field]: updated };
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  setSaving(true);

  try {
    // Kredensial admin kini diproses di Edge Function (service role TIDAK ADA di browser)
    const { data: result, error: fnError } = await supabase.functions.invoke('create-tutor', {
      body: {
        email: form.email,
        full_name: form.full_name,
        phone: form.phone,
        university: form.university,
        bio: form.bio,
        price_per_hour: Number(form.price_per_hour),
        subjects: form.subjects,
        jenjang_diajar: form.jenjang_diajar,
      },
    });

    if (fnError) {
      throw new Error('Gagal membuat tutor: ' + fnError.message);
    }
    if (result && !result.ok) {
      throw new Error('Gagal membuat tutor: ' + (result.error ?? 'void'));
    }

    // Toast tidak memblokir; langsung lanjut ke onSuccess
    (window as any).showToast('Tutor berhasil ditambahkan!', 'success');
    onSuccess();
    onClose();

    setForm({
      full_name: '', email: '', phone: '', university: '', bio: '',
      price_per_hour: 100000, subjects: [], jenjang_diajar: []
    });

  } catch (err: any) {
    // TAMBAHIN AWAIT JUGA DI SINI
    await (window.alert as any)(err.message);
  } finally {
    setSaving(false);
  }
};

  return (
    <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4 overflow-y-auto">
      <div className="card shadow-2xl max-w-xl w-full p-6 my-4">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold text-[var(--ink)]">Tambah Tutor Manual</h3>
          <button onClick={onClose} className="p-1.5 rounded-lg text-[var(--mute)] hover:bg-[var(--hov)]">
            <X size={18} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-semibold mb-1">Nama Lengkap *</label>
              <input required name="full_name" value={form.full_name} onChange={handleChange} className="inp" placeholder="Alya Rahma" />
            </div>
            <div>
              <label className="block text-sm font-semibold mb-1">Email *</label>
              <input required type="email" name="email" value={form.email} onChange={handleChange} className="inp" placeholder="alya@email.com" />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-semibold mb-1">No. WhatsApp</label>
              <input name="phone" value={form.phone} onChange={handleChange} className="inp" placeholder="08xxxx" />
            </div>
            <div>
              <label className="block text-sm font-semibold mb-1">Universitas</label>
              <input name="university" value={form.university} onChange={handleChange} className="inp" placeholder="ITB" />
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold mb-1">Harga per Sesi (Rp)</label>
            <input type="number" name="price_per_hour" value={form.price_per_hour} onChange={handleChange} className="inp" />
          </div>

          <div>
            <label className="block text-sm font-semibold mb-2">Mata Pelajaran</label>
            <div className="flex flex-wrap gap-2">
              {SUBJECTS.map((s) => (
                <button
                  key={s} type="button" onClick={() => handleCheckbox('subjects', s)}
                  className={`px-3 py-1.5 rounded-lg text-sm font-bold border ${form.subjects.includes(s) ? 'bg-[var(--blue)] text-white border-[var(--blue)]' : 'bg-[var(--soft)] border-[var(--line)] text-[var(--mute)]'}`}
                >
                  {s.toUpperCase()}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold mb-2">Jenjang Diajar</label>
            <div className="flex flex-wrap gap-2">
              {JENJANG.map((j) => (
                <button
                  key={j} type="button" onClick={() => handleCheckbox('jenjang_diajar', j)}
                  className={`px-3 py-1.5 rounded-lg text-sm font-bold border ${form.jenjang_diajar.includes(j) ? 'bg-[var(--blue)] text-white border-[var(--blue)]' : 'bg-[var(--soft)] border-[var(--line)] text-[var(--mute)]'}`}
                >
                  {j.toUpperCase()}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold mb-1">Bio Singkat</label>
            <textarea name="bio" rows={2} value={form.bio} onChange={handleChange} className="inp resize-none" placeholder="Spesialis persiapan UTBK..." />
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-[var(--line)]">
            <button type="button" onClick={onClose} className="btn">Batal</button>
            <button type="submit" disabled={saving} className="btn btn-p">
              {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />}
              Simpan Tutor
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
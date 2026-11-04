import { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { Save, Loader2, Plus, X } from 'lucide-react';

export function OprecForm({ initialData, onSave }: { initialData: any; onSave: () => void }) {
  const [form, setForm] = useState({
    ...initialData,
    benefits: Array.isArray(initialData.benefits) ? initialData.benefits : [],
  });
  const [saving, setSaving] = useState(false);
  const [newBenefit, setNewBenefit] = useState('');

  // Sinkronisasi ke iFrame Preview
  useEffect(() => {
    localStorage.setItem('preview_data', JSON.stringify({ type: 'oprec', data: form }));
  }, [form]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const addBenefit = () => {
    if (!newBenefit.trim()) return;
    setForm({ ...form, benefits: [...form.benefits, newBenefit.trim()] });
    setNewBenefit('');
  };

  const removeBenefit = (index: number) => {
    setForm({ ...form, benefits: form.benefits.filter((_: any, i: number) => i !== index) });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    const { error } = await supabase
      .from('oprec_info')
      .update({
        title: form.title,
        description: form.description,
        benefits: form.benefits,
        cta_label: form.cta_label,
        cta_link: form.cta_link,
        is_active: form.is_active,
      })
      .eq('id', form.id);

    setSaving(false);
    if (error) alert(error.message);
    else {
      alert('Berhasil disimpan!');
      onSave();
    }
  };

  return (
    <form onSubmit={handleSubmit} className="card p-6 space-y-5 max-w-3xl">
      <h2 className="text-lg font-bold text-[var(--ink)] mb-4">Pengaturan Oprec Tutor</h2>

      <div>
        <label className="block text-sm font-semibold mb-1">Judul Oprec</label>
        <input name="title" value={form.title || ''} onChange={handleChange} className="inp" />
      </div>

      <div>
        <label className="block text-sm font-semibold mb-1">Deskripsi Singkat</label>
        <textarea name="description" rows={3} value={form.description || ''} onChange={handleChange} className="inp" />
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-semibold mb-1">Teks Tombol (CTA)</label>
          <input name="cta_label" value={form.cta_label || ''} onChange={handleChange} className="inp" placeholder="Daftar jadi tutor" />
        </div>
        <div>
          <label className="block text-sm font-semibold mb-1">Link Tujuan (GForm / WA)</label>
          <input name="cta_link" value={form.cta_link || ''} onChange={handleChange} className="inp" placeholder="https://forms.gle/..." />
        </div>
      </div>

      <div>
        <label className="block text-sm font-semibold mb-1">List Benefit (Keuntungan)</label>
        <div className="flex gap-2 mb-2">
          <input
            value={newBenefit}
            onChange={(e) => setNewBenefit(e.target.value)}
            className="inp flex-1"
            placeholder="Tambah benefit (misal: Jadwal fleksibel)"
            onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addBenefit())}
          />
          <button type="button" onClick={addBenefit} className="btn btn-p"><Plus size={16} /></button>
        </div>
        <ul className="space-y-2">
          {form.benefits.map((b: string, i: number) => (
            <li key={i} className="flex items-center justify-between bg-[var(--soft)] px-3 py-2 rounded-lg text-sm font-semibold">
              {b}
              <button type="button" onClick={() => removeBenefit(i)} className="text-red-500 hover:text-red-700">
                <X size={16} />
              </button>
            </li>
          ))}
        </ul>
      </div>

      <div className="flex items-center gap-2 mt-4">
        <input
          type="checkbox"
          id="is_active"
          checked={form.is_active || false}
          onChange={(e) => setForm({ ...form, is_active: e.target.checked })}
          className="w-4 h-4"
        />
        <label htmlFor="is_active" className="text-sm font-semibold cursor-pointer">Tampilkan Section Oprec di Landing Page</label>
      </div>

      <button type="submit" disabled={saving} className="btn btn-p mt-4">
        {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />} Simpan Perubahan
      </button>
    </form>
  );
}
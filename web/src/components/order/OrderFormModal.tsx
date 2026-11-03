import { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';

interface Props {
  isOpen: boolean;
  editData: any; // Tambahan buat nampung data edit
  onClose: () => void;
  onSuccess: () => void;
}

export function OrderFormModal({ isOpen, editData, onClose, onSuccess }: Props) {
  const [form, setForm] = useState({ name: '', whatsapp: '', subject: '', jenjang: '', notes: '' });
  const [saving, setSaving] = useState(false);

  // Kalau editData ada isinya, otomatis masukin ke form
  useEffect(() => {
    if (isOpen) {
      if (editData) {
        setForm({
          name: editData.name || '',
          whatsapp: editData.whatsapp || '',
          subject: editData.subject || '',
          jenjang: editData.jenjang || '',
          notes: editData.notes || ''
        });
      } else {
        setForm({ name: '', whatsapp: '', subject: '', jenjang: '', notes: '' });
      }
    }
  }, [isOpen, editData]);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);

    if (editData) {
      // Mode Edit: Update data
      await supabase.from('manual_orders').update(form).eq('id', editData.id);
    } else {
      // Mode Tambah: Insert data baru
      await supabase.from('manual_orders').insert([{ ...form, status: 'pending' }]);
    }

    setSaving(false);
    onSuccess();
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
      <form onSubmit={handleSubmit} className="card w-full max-w-md p-6">
        <h2 className="text-xl font-bold mb-4 text-[var(--ink)]">
          {editData ? 'Edit Orderan' : 'Tambah Orderan'}
        </h2>

        <div className="space-y-3">
          <input
            required placeholder="Nama Siswa"
            value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })}
            className="inp"
          />
          <input
            required placeholder="Nomor WhatsApp (08...)"
            value={form.whatsapp} onChange={(e) => setForm({ ...form, whatsapp: e.target.value })}
            className="inp"
          />
          <input
            required placeholder="Mata Pelajaran (Cth: Matematika)"
            value={form.subject} onChange={(e) => setForm({ ...form, subject: e.target.value })}
            className="inp"
          />
          <select
            required value={form.jenjang} onChange={(e) => setForm({ ...form, jenjang: e.target.value })}
            className="inp"
          >
            <option value="">Pilih Jenjang</option>
            <option value="SMP">SMP</option>
            <option value="SMA">SMA</option>
            <option value="Kuliah">Kuliah</option>
          </select>
          <textarea
            placeholder="Catatan tambahan (opsional)"
            value={form.notes} onChange={(e) => setForm({ ...form, notes: e.target.value })}
            className="inp"
          />
        </div>

        <div className="flex justify-end gap-2 mt-6">
          <button type="button" onClick={onClose} className="btn">Batal</button>
          <button type="submit" disabled={saving} className="btn btn-p">
            {saving ? 'Menyimpan...' : 'Simpan'}
          </button>
        </div>
      </form>
    </div>
  );
}
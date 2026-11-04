import { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';

interface Props {
  isOpen: boolean;
  type: string; // 'testimonials' | 'oprec_info' | 'universities'
  editData: any;
  onClose: () => void;
  onSuccess: () => void;
}

export function ContentFormModal({ isOpen, type, editData, onClose, onSuccess }: Props) {
  const [form, setForm] = useState<any>({});
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (isOpen) setForm(editData || {});
  }, [isOpen, editData]);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      if (editData) {
        const { error } = await supabase
          .from(type)
          .update(form)
          .eq('id', editData.id);
        if (error) throw error;
      } else {
        const { error } = await supabase
          .from(type)
          .insert([form]);
        if (error) throw error;
      }
      onSuccess();
      onClose();
    } catch (err: any) {
      await (window.alert as any)('Gagal menyimpan data: ' + (err?.message ?? err));
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
      <form onSubmit={handleSubmit} className="card w-full max-w-md p-6">
        <h2 className="text-xl font-bold mb-4 text-[var(--ink)]">
          {editData ? 'Edit Data' : 'Tambah Data'}
        </h2>
        <div className="space-y-3">
          {type === 'testimonials' && (
            <>
              <input required placeholder="Nama" value={form.name || ''} onChange={(e) => setForm({ ...form, name: e.target.value })} className="inp" />
              <input required placeholder="Keterangan (Cth: Kelas 12)" value={form.role || ''} onChange={(e) => setForm({ ...form, role: e.target.value })} className="inp" />
              <textarea required placeholder="Isi Testimoni" value={form.content || ''} onChange={(e) => setForm({ ...form, content: e.target.value })} className="inp" />
              <label className="flex items-center gap-2 text-sm font-semibold"><input type="checkbox" checked={form.is_published || false} onChange={(e) => setForm({ ...form, is_published: e.target.checked })} /> Tayangkan di Landing Page?</label>
            </>
          )}
          {type === 'oprec_info' && (
            <>
              <input required placeholder="Judul Oprec" value={form.title || ''} onChange={(e) => setForm({ ...form, title: e.target.value })} className="inp" />
              <textarea required placeholder="Deskripsi" value={form.description || ''} onChange={(e) => setForm({ ...form, description: e.target.value })} className="inp" />
              <label className="flex items-center gap-2 text-sm font-semibold"><input type="checkbox" checked={form.is_active || false} onChange={(e) => setForm({ ...form, is_active: e.target.checked })} /> Aktifkan Oprec?</label>
            </>
          )}
          {type === 'universities' && (
            <>
              <input required placeholder="Nama Universitas (Cth: UI)" value={form.name || ''} onChange={(e) => setForm({ ...form, name: e.target.value })} className="inp" />
              <label className="flex items-center gap-2 text-sm font-semibold"><input type="checkbox" checked={form.is_active || false} onChange={(e) => setForm({ ...form, is_active: e.target.checked })} /> Tampilkan di Landing Page?</label>
            </>
          )}
        </div>
        <div className="flex justify-end gap-2 mt-6">
          <button type="button" onClick={onClose} className="px-4 py-2 font-bold text-[var(--mute)]">Batal</button>
          <button type="submit" disabled={saving} className="bg-[var(--blue)] text-white font-bold py-2 px-4 rounded-lg">
            {saving ? 'Menyimpan...' : 'Simpan'}
          </button>
        </div>
      </form>
    </div>
  );
}
import { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { Save, Loader2, Upload } from 'lucide-react';

export function HeroForm({ initialData, onSave }: { initialData: any; onSave: () => void }) {
  const [form, setForm] = useState(initialData);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);

  // Sinkronisasi ke iFrame Preview
  useEffect(() => {
    localStorage.setItem('preview_data', JSON.stringify({ type: 'hero', data: form }));
  }, [form]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploading(true);
    const fileName = `hero-${Date.now()}.${file.name.split('.').pop()}`;

    // Pastikan bucket 'public-assets' udah ada
    const { error } = await supabase.storage.from('public-assets').upload(fileName, file);
    if (error) {
      await (window.alert as any)('Gagal upload: ' + error.message);
    } else {
      const { data } = supabase.storage.from('public-assets').getPublicUrl(fileName);
      setForm({ ...form, hero_image_url: data.publicUrl });
    }
    setUploading(false);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    const { error } = await supabase
      .from('landing_hero')
      .update({
        headline: form.headline,
        subheadline: form.subheadline,
        hero_image_url: form.hero_image_url,
        sticker_1_text: form.sticker_1_text,
        sticker_2_text: form.sticker_2_text,
        updated_at: new Date().toISOString(),
      })
      .eq('id', form.id);

    setSaving(false);
    if (error) await (window.alert as any)(error.message);
    else {
      (window as any).showToast('Data berhasil disimpan', 'success');
      onSave();
    }
  };

  return (
    <form onSubmit={handleSubmit} className="card p-6 space-y-5 max-w-3xl">
      <h2 className="text-lg font-bold text-[var(--ink)] mb-4">Pengaturan Hero Banner</h2>

      <div>
        <label className="block text-sm font-semibold mb-1">Headline Utama</label>
        <textarea name="headline" rows={2} value={form.headline || ''} onChange={handleChange} className="inp" />
      </div>
      <div>
        <label className="block text-sm font-semibold mb-1">Sub-headline</label>
        <textarea name="subheadline" rows={2} value={form.subheadline || ''} onChange={handleChange} className="inp" />
      </div>
      <div>
        <label className="block text-sm font-semibold mb-1">Gambar Visual (Mockup HP / Tutor)</label>
        <div className="flex items-center gap-4">
          {form.hero_image_url && (
            <img src={form.hero_image_url} alt="Hero" className="h-20 w-auto rounded-lg border object-cover" />
          )}
          <label className="btn cursor-pointer">
            {uploading ? <Loader2 size={16} className="animate-spin" /> : <Upload size={16} />}
            {uploading ? 'Mengunggah...' : 'Upload Gambar'}
            <input type="file" accept="image/*" className="hidden" onChange={handleUpload} disabled={uploading} />
          </label>
        </div>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-semibold mb-1">Teks Stiker Kiri</label>
          <input name="sticker_1_text" value={form.sticker_1_text || ''} onChange={handleChange} className="inp" />
        </div>
        <div>
          <label className="block text-sm font-semibold mb-1">Teks Stiker Kanan</label>
          <input name="sticker_2_text" value={form.sticker_2_text || ''} onChange={handleChange} className="inp" />
        </div>
      </div>
      <button type="submit" disabled={saving || uploading} className="btn btn-p">
        {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />} Simpan Perubahan
      </button>
    </form>
  );
}
import { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { supabase } from '../lib/supabase';
import { SortControl } from '../components/ui/SortControl';
import { sortItems, type SortDir } from '../lib/sortList';

import { ContentFormModal } from '../components/content/ContentFormModal';
import { HeroForm } from '../components/content/HeroForm';
import { OprecForm } from '../components/content/OprecForm';
import { TestimonialCard, UniversityCard } from '../components/content/ContentItemCards';
import { Plus, Eye, X } from 'lucide-react';

export function ContentManagementPage() {
  const [activeTab, setActiveTab] = useState('hero');
  const [data, setData] = useState<any[]>([]);
  const [sort, setSort] = useState<{ key: string; dir: SortDir }>({ key: 'created_at', dir: 'desc' });
  const [heroData, setHeroData] = useState<any>(null);
  const [oprecData, setOprecData] = useState<any>(null);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editData, setEditData] = useState<any>(null);

  // State untuk buka-tutup panel preview
  const [isPreviewOpen, setIsPreviewOpen] = useState(false);

  const fetchData = async () => {
    if (activeTab === 'hero') {
      const { data: res } = await supabase.from('landing_hero').select('*').limit(1).maybeSingle();
      const fallback = {
        id: '00000000-0000-0000-0000-000000000000',
        headline: 'Belajar sama kakak kampus yang benar-benar paham.',
        subheadline: 'Pilih tutor privat dari UI, ITB, UGM...',
        sticker_1_text: '🎯 Cocok 98%',
        sticker_2_text: 'Trial dulu, gratis!',
        hero_image_url: ''
      };
      setHeroData(res || fallback);
      return;
    }

    if (activeTab === 'oprec_info') {
      const { data: res } = await supabase.from('oprec_info').select('*').order('created_at', { ascending: false }).limit(1).maybeSingle();
      const fallback = {
        id: '00000000-0000-0000-0000-000000000000',
        title: 'Mahasiswa? Jadi Buddy, dibayar buat berbagi ilmu.',
        description: 'Open recruitment tutor batch baru dibuka.',
        benefits: [],
        cta_label: 'Daftar jadi tutor',
        cta_link: '#',
        is_active: true
      };
      setOprecData(res || fallback);
      return;
    }

    const { data: res } = await supabase
      .from(activeTab)
      .select('*')
      .order('created_at', { ascending: false });
    if (res) setData(res);
  };

  useEffect(() => {
    fetchData();
    localStorage.removeItem('preview_data');
  }, [activeTab]);

  const handleDelete = async (id: string) => {
    if (await (window.confirm as any)('Yakin mau hapus data ini?')) {
      try {
        const { error } = await supabase.from(activeTab).delete().eq('id', id);
        if (error) throw error;
        fetchData();
      } catch (err: any) {
        await (window.alert as any)('Gagal menghapus data: ' + (err?.message ?? err));
      }
    }
  };

  // Tayang/sembunyi: tersimpan langsung; tampilan diubah dulu, dikembalikan bila gagal.
  const visibleField = activeTab === 'testimonials' ? 'is_published' : 'is_active';
  const handleToggle = async (id: string, next: boolean) => {
    const previous = data;
    setData((rows) => rows.map((r) => (r.id === id ? { ...r, [visibleField]: next } : r)));
    const { error } = await supabase.from(activeTab).update({ [visibleField]: next }).eq('id', id);
    if (error) {
      setData(previous);
      await (window.alert as any)('Gagal mengubah tampilan: ' + error.message);
    }
  };

  const handleEdit = (item: any) => {
    setEditData(item);
    setIsModalOpen(true);
  };

  const handleAdd = () => {
    setEditData(null);
    setIsModalOpen(true);
  };

  const getAddLabel = () => {
    if (activeTab === 'testimonials') return 'Testimoni';
    if (activeTab === 'universities') return 'Universitas';
    return '';
  };

  return (
    <div className="relative">
      {/*
        KARENA KITA PAKAI FLOATING PREVIEW, FORM BISA FULL WIDTH
        Tapi kita batasi lebarnya biar enak dibaca.
      */}
      <div className="max-w-5xl mx-auto">
        <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4 mb-6">
          <div className="inline-flex flex-wrap p-1 rounded-xl border border-[var(--line)] bg-[var(--soft)]">
            {[
              { id: 'hero', label: 'Hero Banner' },
              { id: 'oprec_info', label: 'Oprec' },
              { id: 'testimonials', label: 'Testimoni' },
              { id: 'universities', label: 'Top Univ' },
            ].map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className="seg"
                aria-pressed={activeTab === tab.id}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {activeTab !== 'hero' && activeTab !== 'oprec_info' && (
            <button onClick={handleAdd} className="btn btn-p shrink-0">
              <Plus size={18} /> Tambah {getAddLabel()}
            </button>
          )}
        </div>

        <div key={activeTab} className="page-enter">
        {activeTab === 'hero' && heroData && (
          <HeroForm initialData={heroData} onSave={fetchData} />
        )}

        {activeTab === 'oprec_info' && oprecData && (
          <OprecForm initialData={oprecData} onSave={fetchData} />
        )}

        {(activeTab === 'testimonials' || activeTab === 'universities') && (
          data.length === 0 ? (
            <div className="card p-10 text-center text-[var(--mute)]">
              Belum ada data. Klik “Tambah {getAddLabel()}” untuk mulai.
            </div>
          ) : (
            <>
              <div className="flex flex-wrap items-center justify-between gap-3 mb-3">
                <p className="text-sm text-[var(--mute)]">
                  {data.filter((d) => d[visibleField]).length} dari {data.length} tampil di landing page. Geser sakelar untuk menampilkan atau menyembunyikan; pensil untuk mengubah isi.
                </p>
                <SortControl
                  options={[{ key: 'created_at', label: 'Tanggal dibuat' }, { key: 'name', label: 'Nama' }]}
                  sortKey={sort.key}
                  dir={sort.dir}
                  onChange={(key, dir) => setSort({ key, dir })}
                />
              </div>
              <div className={activeTab === 'testimonials' ? 'grid md:grid-cols-2 gap-4' : 'grid sm:grid-cols-2 lg:grid-cols-3 gap-3'}>
                {sortItems(data, (d: any) => d[sort.key], sort.dir).map((item) => {
                  const Card = activeTab === 'testimonials' ? TestimonialCard : UniversityCard;
                  return (
                    <Card
                      key={item.id}
                      item={item}
                      visible={!!item[visibleField]}
                      onToggle={(next) => handleToggle(item.id, next)}
                      onEdit={() => handleEdit(item)}
                      onDelete={() => handleDelete(item.id)}
                    />
                  );
                })}
              </div>
            </>
          )
        )}
        </div>
      </div>

      {/* Tombol dan layar preview dipasang di body supaya tetap menempel di layar, bukan ikut kontainer halaman */}
      {createPortal(
        <>
      <button
        onClick={() => setIsPreviewOpen(true)}
        className="fixed bottom-6 right-6 z-40 btn btn-p shadow-xl rounded-full !px-6 !py-3"
      >
        <Eye size={20} /> Live Preview
      </button>

      {/* MODAL FULL SCREEN PREVIEW */}
      {isPreviewOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex flex-col">
          <div className="flex items-center justify-between p-4 bg-[var(--ink)] text-white shrink-0">
            <h2 className="font-bold flex items-center gap-2">
              <Eye size={20} className="text-[var(--yel)]" /> Mode Live Preview
            </h2>
            <button
              onClick={() => setIsPreviewOpen(false)}
              className="btn bg-white/10 hover:bg-white/20 border-none text-red-400"
            >
              <X size={18} /> Tutup Preview
            </button>
          </div>
          <div className="flex-1 bg-white relative">
            <iframe
                src="/preview?layout=false"
                className="w-full h-full border-none"
                title="Landing Page Preview"
            />
          </div>
        </div>
      )}
        </>,
        document.body
      )}

      <ContentFormModal
        isOpen={isModalOpen}
        type={activeTab}
        editData={editData}
        onClose={() => setIsModalOpen(false)}
        onSuccess={fetchData}
      />
    </div>
  );
}
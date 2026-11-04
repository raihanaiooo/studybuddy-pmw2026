import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { ContentFormModal } from '../components/content/ContentFormModal';
import { HeroForm } from '../components/content/HeroForm';
import { OprecForm } from '../components/content/OprecForm';
import { Pencil, Trash2, Plus, Eye, X } from 'lucide-react';

export function ContentManagementPage() {
  const [activeTab, setActiveTab] = useState('hero');
  const [data, setData] = useState<any[]>([]);
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
      const { data: res } = await supabase.from('oprec_info').select('*').limit(1).maybeSingle();
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
      await supabase.from(activeTab).delete().eq('id', id);
      fetchData();
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

  const getInitials = (name: string) => {
    if (!name) return '?';
    return name.split(' ').map(w => w[0]).slice(0, 2).join('').toUpperCase();
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
      <div className="max-w-5xl">
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

        {activeTab === 'hero' && heroData && (
          <HeroForm initialData={heroData} onSave={fetchData} />
        )}

        {activeTab === 'oprec_info' && oprecData && (
          <OprecForm initialData={oprecData} onSave={fetchData} />
        )}

        {(activeTab === 'testimonials' || activeTab === 'universities') && (
          <div className="grid md:grid-cols-2 gap-4">
            {data.length === 0 ? (
              <div className="col-span-full p-10 text-center text-[var(--mute)]">
                Belum ada data untuk kategori ini.
              </div>
            ) : (
              data.map((item) => (
                <article key={item.id} className="card p-4 hover:border-[var(--blue)] transition-colors flex flex-col">
                  <div className="flex items-start gap-3">
                    {activeTab === 'universities' && item.logo_url ? (
                      <img src={item.logo_url} alt={item.name} className="w-8 h-8 rounded object-contain shrink-0" />
                    ) : (
                      <span className="w-8 h-8 rounded-full bg-[var(--blue)] text-white grid place-items-center font-bold text-xs shrink-0">
                        {getInitials(item.name)}
                      </span>
                    )}
                    <div className="min-w-0">
                      <h3 className="font-bold text-[var(--ink)] truncate">{item.name}</h3>
                      {activeTab === 'testimonials' && (
                        <p className="text-[var(--mute)] text-[13px] truncate">{item.role}</p>
                      )}
                    </div>

                    <span className={`badge ml-auto shrink-0 ${item.is_published || item.is_active ? 'b-done' : 'b-no'}`}>
                      <i></i>{item.is_published || item.is_active ? 'Tayang' : 'Draf'}
                    </span>
                  </div>
                  {item.content && (
                    <p className="mt-3 text-[var(--mute)] text-sm leading-relaxed line-clamp-3">“{item.content}”</p>
                  )}
                  <div className="mt-auto pt-4 border-t border-[var(--line)] flex gap-2">
                    <button onClick={() => handleEdit(item)} className="btn !py-1 text-[var(--blue)] border-none bg-blue-50 hover:bg-blue-100">
                      <Pencil size={14} /> Edit
                    </button>
                    <button onClick={() => handleDelete(item.id)} className="btn !py-1 text-red-600 border-none bg-red-50 hover:bg-red-100">
                      <Trash2 size={14} /> Hapus
                    </button>
                  </div>
                </article>
              ))
            )}
          </div>
        )}
      </div>

      {/* FLOATING TOMBOL PREVIEW */}
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
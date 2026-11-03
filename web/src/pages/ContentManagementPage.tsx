import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { ContentFormModal } from '../components/content/ContentFormModal';
import { Pencil, Trash2, Plus } from 'lucide-react';

export function ContentManagementPage() {
  const [activeTab, setActiveTab] = useState('testimonials');
  const [data, setData] = useState<any[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editData, setEditData] = useState<any>(null);

  const fetchData = async () => {
    const { data: res } = await supabase
      .from(activeTab)
      .select('*')
      .order('created_at', { ascending: false });
    if (res) setData(res);
  };

  useEffect(() => {
    fetchData();
  }, [activeTab]);

  const handleDelete = async (id: string) => {
    if (confirm('Yakin mau hapus data ini?')) {
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

  return (
    <div>
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div className="inline-flex p-1 rounded-xl border border-[var(--line)] bg-[var(--soft)]">
          {[
            { id: 'testimonials', label: 'Testimoni' },
            { id: 'oprec_info', label: 'Oprec' },
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

        <button onClick={handleAdd} className="btn btn-p">
          <Plus size={18} /> Tambah {activeTab === 'testimonials' ? 'Testimoni' : activeTab === 'oprec_info' ? 'Oprec' : 'Univ'}
        </button>
      </div>

      <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-4">
        {data.length === 0 ? (
          <div className="col-span-full p-10 text-center text-[var(--mute)]">
            Belum ada data untuk kategori ini.
          </div>
        ) : (
          data.map((item) => (
            <article key={item.id} className="card p-4 hover:border-[var(--blue)] transition-colors flex flex-col">

              {/* Header Card */}
              <div className="flex items-start gap-3">
                <span className="w-8 h-8 rounded-full bg-[var(--blue)] text-white grid place-items-center font-bold text-xs shrink-0">
                  {getInitials(item.name || item.title)}
                </span>
                <div className="min-w-0">
                  <h3 className="font-bold text-[var(--ink)] truncate">{item.name || item.title}</h3>
                  <p className="text-[var(--mute)] text-[13px] truncate">
                    {item.role || item.description || '—'}
                  </p>
                </div>

                <span className={`badge ml-auto shrink-0 ${item.is_published || item.is_active ? 'b-done' : 'b-no'}`}>
                  <i></i>
                  {item.is_published || item.is_active ? 'Tayang' : 'Draf'}
                </span>
              </div>

              {item.content && (
                <p className="mt-3 text-[var(--mute)] text-sm leading-relaxed line-clamp-3">
                  “{item.content}”
                </p>
              )}

              {/* Tombol Aksi */}
              <div className="mt-auto pt-4 border-t border-[var(--line)] flex gap-2">
                <button
                  onClick={() => handleEdit(item)}
                  className="btn !py-1 text-[var(--blue)] border-none bg-blue-50 hover:bg-blue-100"
                >
                  <Pencil size={14} /> Edit
                </button>
                <button
                  onClick={() => handleDelete(item.id)}
                  className="btn !py-1 text-red-600 border-none bg-red-50 hover:bg-red-100"
                >
                  <Trash2 size={14} /> Hapus
                </button>
              </div>

            </article>
          ))
        )}
      </div>

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
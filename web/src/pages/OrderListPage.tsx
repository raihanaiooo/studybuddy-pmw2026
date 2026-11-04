import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { OrderFormModal } from '../components/order/OrderFormModal';
import {
  MessageCircle,
  Pencil,
  Trash2,
  Download,
  Plus,
  Search,
} from 'lucide-react';

type FilterStatus = 'all' | 'pending' | 'follow_up' | 'done' | 'cancelled';
type FilterTab = 'all' | 'pending' | 'follow_up' | 'done';

const filterLabels: Record<FilterTab, string> = {
  all: 'Semua',
  pending: 'Pending',
  follow_up: 'Follow Up',
  done: 'Done',
};

export function OrderListPage() {
  const [orders, setOrders] = useState<any[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editData, setEditData] = useState<any>(null);

  const [filter, setFilter] = useState<FilterStatus>('all');
  const [search, setSearch] = useState('');

  const fetchOrders = async () => {
    const { data } = await supabase
      .from('manual_orders')
      .select('*')
      .order('created_at', { ascending: false });
    if (data) setOrders(data);
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  const updateStatus = async (id: string, status: string) => {
    await supabase.from('manual_orders').update({ status }).eq('id', id);
    fetchOrders();
  };

  const handleDelete = async (id: string) => {
    if (await (window.confirm as any)('Yakin mau hapus orderan ini?')) {
      await supabase.from('manual_orders').delete().eq('id', id);
      fetchOrders();
    }
  };

  const counts = {
    all: orders.length,
    pending: orders.filter((o) => o.status === 'pending').length,
    follow_up: orders.filter((o) => o.status === 'follow_up').length,
    done: orders.filter((o) => o.status === 'done').length,
  };

  const filteredOrders = orders.filter((o) => {
    const matchStatus = filter === 'all' || o.status === filter;
    const matchSearch = (o.name + o.subject)
      .toLowerCase()
      .includes(search.toLowerCase());
    return matchStatus && matchSearch;
  });

  const getInitials = (name: string) => {
    if (!name) return '?';
    return name
      .split(' ')
      .map((w) => w[0])
      .slice(0, 2)
      .join('')
      .toUpperCase();
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        <div>
          <h1 className="text-2xl font-extrabold text-[var(--ink)]">
            Orderan Manual
          </h1>
          <p className="text-sm text-[var(--mute)] mt-1">
            Kelola orderan yang masuk lewat WhatsApp / manual.
          </p>
        </div>
        <button
          type="button"
          onClick={() => {
            setEditData(null);
            setIsModalOpen(true);
          }}
          className="btn btn-p"
        >
          <Plus size={18} />
          Tambah Orderan
        </button>
      </div>

      {/* Filter Card */}
      <div className="card p-4 space-y-3">
        {/* Search + Export */}
        <div className="flex flex-col sm:flex-row gap-3 sm:items-center sm:justify-between">
          <div className="relative w-full sm:max-w-xs">
            <Search
              className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--mute)] pointer-events-none"
              size={18}
            />
            <input
              type="text"
              placeholder="Cari nama atau mapel..."
              className="inp pl-10"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          <button type="button" className="btn self-start sm:self-auto">
            <Download size={16} />
            Export
          </button>
        </div>

        {/* Pill filter */}
        <div className="flex flex-wrap gap-2">
          {(['all', 'pending', 'follow_up', 'done'] as FilterTab[]).map(
            (status) => (
              <button
                key={status}
                type="button"
                onClick={() => setFilter(status)}
                className={`px-4 py-2 rounded-xl text-sm font-bold transition-colors ${
                  filter === status
                    ? 'bg-[var(--blue)] text-white'
                    : 'bg-[var(--soft)] text-[var(--mute)] hover:bg-[var(--hov)]'
                }`}
              >
                {filterLabels[status]}
                <span
                  className={`ml-1.5 ${
                    filter === status ? 'text-white/80' : 'text-[var(--mute)]'
                  }`}
                >
                  {counts[status]}
                </span>
              </button>
            )
          )}
        </div>
      </div>

      {/* Tabel */}
      <div className="card overflow-hidden">
        <div className="overflow-x-auto">
          <table>
            <thead>
              <tr>
                <th>Nama siswa</th>
                <th>WhatsApp</th>
                <th>Mapel</th>
                <th>Status</th>
                <th className="text-right">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {filteredOrders.length === 0 ? (
                <tr>
                  <td
                    colSpan={5}
                    className="p-10 text-center text-[var(--mute)]"
                  >
                    Tidak ada orderan dengan filter ini.
                  </td>
                </tr>
              ) : (
                filteredOrders.map((o) => (
                  <tr key={o.id}>
                    <td>
                      <div className="flex items-center gap-3">
                        <span className="w-8 h-8 rounded-full bg-[var(--blue)] text-white grid place-items-center font-bold text-xs shrink-0">
                          {getInitials(o.name)}
                        </span>
                        <b className="text-[var(--ink)]">{o.name}</b>
                      </div>
                    </td>
                    <td className="whitespace-nowrap">{o.whatsapp}</td>
                    <td>
                      <span className="font-semibold">{o.subject}</span>
                      <span className="text-[var(--mute)] text-xs block">
                        {o.jenjang}
                      </span>
                    </td>
                    <td>
                      <select
                        value={o.status}
                        onChange={(e) => updateStatus(o.id, e.target.value)}
                        className="inp !w-auto !py-1 !text-[13px] font-semibold border-none bg-transparent"
                      >
                        <option value="pending">Pending</option>
                        <option value="follow_up">Follow Up</option>
                        <option value="done">Done</option>
                        <option value="cancelled">Dibatalkan</option>
                      </select>
                    </td>
                    <td className="text-right whitespace-nowrap">
                      <div className="flex items-center justify-end gap-2">
                        <a
                          href={`https://wa.me/${o.whatsapp
                            .replace(/\D/g, '')
                            .replace(/^0/, '62')}`}
                          target="_blank"
                          rel="noreferrer"
                          className="btn !py-1.5 !px-2.5 text-[#166534] hover:bg-[#DCFCE7] border-transparent shadow-none"
                          title="Chat WA"
                        >
                          <MessageCircle size={16} />
                        </a>
                        <button
                          type="button"
                          onClick={() => {
                            setEditData(o);
                            setIsModalOpen(true);
                          }}
                          className="btn !py-1.5 !px-2.5 text-[var(--blue)] hover:bg-[var(--hov)] border-transparent shadow-none"
                          title="Edit"
                        >
                          <Pencil size={16} />
                        </button>
                        <button
                          type="button"
                          onClick={() => handleDelete(o.id)}
                          className="btn !py-1.5 !px-2.5 text-[#991B1B] hover:bg-[#FEE2E2] border-transparent shadow-none"
                          title="Hapus"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal Form */}
      <OrderFormModal
        isOpen={isModalOpen}
        editData={editData}
        onClose={() => setIsModalOpen(false)}
        onSuccess={fetchOrders}
      />
    </div>
  );
}
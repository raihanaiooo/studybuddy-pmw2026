import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { AlertCircle, Loader2, Search } from 'lucide-react';
import { fetchOrders, type OrderRow } from '../../lib/api/orderAdmin';
import { formatRupiah, groupByBuddy, orderStatusLabel, paymentLabel } from '../../lib/orderView';
import { sortItems, type SortDir } from '../../lib/sortList';
import { SortControl } from '../../components/ui/SortControl';

type View = 'order' | 'buddy';
type StatusFilter = 'all' | 'progress' | 'done';

const STATUS_PILLS: Array<{ key: StatusFilter; label: string }> = [
  { key: 'all', label: 'Semua' },
  { key: 'progress', label: 'Berjalan' },
  { key: 'done', label: 'Selesai' },
];

function dateLabel(d: string) {
  return new Date(d + 'T00:00:00').toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
}

function payBadge(status: string | null) {
  const cls = status === 'lunas' ? 'b-done' : status === 'sebagian' ? 'b-pending' : 'b-no';
  return <span className={`badge ${cls}`}><i />{paymentLabel(status)}</span>;
}

export function OrderPage() {
  const navigate = useNavigate();
  const [rows, setRows] = useState<OrderRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [view, setView] = useState<View>('order');
  const [status, setStatus] = useState<StatusFilter>('all');
  const [search, setSearch] = useState('');
  const [sort, setSort] = useState<{ key: string; dir: SortDir }>({ key: 'ordered_at', dir: 'desc' });

  useEffect(() => {
    fetchOrders()
      .then(setRows)
      .catch((e) => setError(e instanceof Error ? e.message : 'Gagal memuat order'))
      .finally(() => setLoading(false));
  }, []);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    const list = rows.filter(
      (o) =>
        (status === 'all' || o.status === status) &&
        (!q || `${o.form_no} ${o.buddy_name} ${o.service_name} ${o.subject ?? ''}`.toLowerCase().includes(q))
    );
    return sortItems(list, (o: any) => o[sort.key], sort.dir);
  }, [rows, status, search, sort]);

  const buddies = useMemo(() => sortItems(groupByBuddy(filtered), (b: any) => (sort.key === 'buddy_name' ? b.name : b.total), sort.key === 'buddy_name' ? sort.dir : 'desc'), [filtered, sort]);

  const totals = useMemo(
    () => ({
      count: filtered.length,
      running: filtered.filter((o) => o.status === 'progress').length,
      revenue: filtered.reduce((a, o) => a + o.revenue_total, 0),
      paid: filtered.reduce((a, o) => a + o.paid_total, 0),
    }),
    [filtered]
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-[var(--ink)]">Order</h1>
        <p className="text-sm text-[var(--mute)]">Order resmi (nomor FO) beserta sesi, tutor, dan pembayarannya.</p>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {[
          { label: 'Jumlah order', value: String(totals.count) },
          { label: 'Sedang berjalan', value: String(totals.running) },
          { label: 'Pendapatan', value: formatRupiah(totals.revenue) },
          { label: 'Sudah dibayar', value: formatRupiah(totals.paid) },
        ].map((c) => (
          <div key={c.label} className="card p-4">
            <p className="text-xs text-[var(--mute)]">{c.label}</p>
            <p className="text-lg font-extrabold text-[var(--ink)] mt-0.5">{c.value}</p>
          </div>
        ))}
      </div>

      <div className="card p-4 space-y-3">
        <div className="flex flex-col sm:flex-row gap-3 sm:items-center sm:justify-between">
          <div className="relative w-full sm:max-w-xs">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--mute)] pointer-events-none" size={18} />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Cari nomor FO, nama buddy, layanan..."
              className="inp !pl-10"
            />
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <SortControl
              options={
                view === 'order'
                  ? [{ key: 'ordered_at', label: 'Tanggal order' }, { key: 'form_no', label: 'No. formulir' }, { key: 'buddy_name', label: 'Buddy' }, { key: 'total_price', label: 'Total' }]
                  : [{ key: 'total_price', label: 'Total' }, { key: 'buddy_name', label: 'Nama' }]
              }
              sortKey={view === 'buddy' && !['total_price', 'buddy_name'].includes(sort.key) ? 'total_price' : sort.key}
              dir={sort.dir}
              onChange={(key, dir) => setSort({ key, dir })}
            />
            <div className="flex items-center gap-1 p-1 bg-[var(--soft)] rounded-xl">
              <button type="button" className="seg" aria-pressed={view === 'order'} onClick={() => setView('order')}>Per order</button>
              <button type="button" className="seg" aria-pressed={view === 'buddy'} onClick={() => setView('buddy')}>Per buddy</button>
            </div>
          </div>
        </div>
        <div className="flex flex-wrap gap-2">
          {STATUS_PILLS.map((p) => (
            <button
              key={p.key}
              type="button"
              aria-pressed={status === p.key}
              onClick={() => setStatus(p.key)}
              className={`px-4 py-1.5 rounded-lg border font-semibold text-sm ${status === p.key ? 'bg-[var(--blue)] border-[var(--blue)] text-white' : 'border-[var(--line)] text-[var(--ink)] hover:bg-[var(--hov)]'}`}
            >
              {p.label}
            </button>
          ))}
        </div>
      </div>

      {loading && (
        <div className="flex items-center gap-2 text-[var(--mute)] font-semibold py-10">
          <Loader2 className="animate-spin" size={18} /> Memuat order...
        </div>
      )}
      {error && (
        <div className="bg-[#FEE2E2] border border-[#FCA5A5] text-[#991B1B] text-sm rounded-xl p-4 flex items-start gap-2">
          <AlertCircle size={18} className="shrink-0 mt-0.5" />
          <span>{error}</span>
        </div>
      )}
      {!loading && !error && filtered.length === 0 && (
        <div className="card p-10 text-center text-[var(--mute)]">Tidak ada order yang cocok.</div>
      )}

      {!loading && !error && filtered.length > 0 && view === 'order' && (
        <div key="order" className="page-enter card overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs text-[var(--mute)] border-b border-[var(--line)]">
                <th className="p-3 font-semibold">No. FO</th>
                <th className="p-3 font-semibold">Buddy</th>
                <th className="p-3 font-semibold">Layanan</th>
                <th className="p-3 font-semibold">Tanggal</th>
                <th className="p-3 font-semibold">Sesi</th>
                <th className="p-3 font-semibold text-right">Total</th>
                <th className="p-3 font-semibold">Bayar</th>
                <th className="p-3 font-semibold">Status</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((o) => (
                <tr
                  key={o.id}
                  onClick={() => navigate(`/order/${o.id}`)}
                  className="border-b border-[var(--line)] last:border-0 hover:bg-[var(--soft)] cursor-pointer"
                >
                  <td className="p-3 font-bold text-[var(--blue)]">{o.form_no}</td>
                  <td className="p-3 font-semibold text-[var(--ink)]">{o.buddy_name}</td>
                  <td className="p-3 text-[var(--ink)] max-w-[260px]">
                    <span className="block truncate">{o.service_name}</span>
                    {o.subject && <span className="block truncate text-xs text-[var(--mute)]">{o.subject}</span>}
                  </td>
                  <td className="p-3 whitespace-nowrap text-[var(--mute)]">{dateLabel(o.ordered_at)}</td>
                  <td className="p-3 whitespace-nowrap">{o.sessions_done}/{o.sessions_total}</td>
                  <td className="p-3 text-right font-semibold whitespace-nowrap">{formatRupiah(o.revenue_total)}</td>
                  <td className="p-3">{payBadge(o.payment_status)}</td>
                  <td className="p-3">
                    <span className={`badge ${o.status === 'done' ? 'b-done' : o.status === 'batal' ? 'b-no' : 'b-pending'}`}>
                      <i />{orderStatusLabel(o.status)}
                    </span>
                    {o.is_expired && <span className="badge b-no ml-1"><i />Hangus</span>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {!loading && !error && filtered.length > 0 && view === 'buddy' && (
        <div key="buddy" className="page-enter grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
          {buddies.map((b) => (
            <button
              key={b.key}
              type="button"
              onClick={() => {
                setSearch(b.name);
                setView('order');
              }}
              className="card p-4 text-left hover:border-[var(--blue)] transition-colors"
            >
              <p className="font-bold text-[var(--ink)] truncate">{b.name}</p>
              <p className="text-xs text-[var(--mute)] mt-0.5">
                {b.orders} order{b.running > 0 ? ` · ${b.running} berjalan` : ''}
              </p>
              <p className="text-lg font-extrabold text-[var(--blue)] mt-2">{formatRupiah(b.total)}</p>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

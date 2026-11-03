import { useEffect, useState } from 'react';
import {
  Wallet,
  BarChart3,
  CheckCircle2,
  Clock,
  Search,
  LayoutGrid,
  List,
  Receipt,
} from 'lucide-react';
import { usePayments } from '../hooks/usePayments';
import { PaymentCard } from '../components/payment/PaymentCard';
import { StatCard } from '../components/ui/StatCard';
import { fetchPaymentStats } from '../lib/api/payment';
import type { PaymentStatus, PaymentStats } from '../types/payment';

type FilterStatus = PaymentStatus | 'all';
type ViewMode = 'grid' | 'table';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'all', label: 'Semua' },
  { key: 'pending', label: 'Menunggu' },
  { key: 'success', label: 'Berhasil' },
  { key: 'failed', label: 'Gagal' },
  { key: 'expired', label: 'Kedaluwarsa' },
  { key: 'refunded', label: 'Refund' },
];

const formatRupiah = (n: number) => `Rp${n.toLocaleString('id-ID')}`;

const getInitials = (name?: string) => {
  if (!name) return '?';
  return name
    .split(' ')
    .map((w) => w[0])
    .slice(0, 2)
    .join('')
    .toUpperCase();
};

const getBadge = (status: string) => {
  switch (status) {
    case 'pending':
      return <span className="badge b-pending"><i />Menunggu</span>;
    case 'success':
      return <span className="badge b-done"><i />Berhasil</span>;
    case 'failed':
      return <span className="badge b-no"><i />Gagal</span>;
    case 'expired':
      return <span className="badge b-no"><i />Kedaluwarsa</span>;
    case 'refunded':
      return <span className="badge b-fu"><i />Refund</span>;
    default:
      return <span className="badge b-no">{status}</span>;
  }
};

export function PaymentListPage() {
  const { payments, filter, setFilter, search, setSearch, loading, error } =
    usePayments();

  const [stats, setStats] = useState<PaymentStats>({
    totalTransactions: 0,
    totalRevenue: 0,
    pending: 0,
    success: 0,
    failed: 0,
    expired: 0,
    refunded: 0,
  });
  const [viewMode, setViewMode] = useState<ViewMode>('grid');

  useEffect(() => {
    fetchPaymentStats()
      .then(setStats)
      .catch((e) => console.error('Stats error', e));
  }, [payments.length]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-extrabold text-[var(--ink)]">Transaksi</h1>
        <p className="text-sm text-[var(--mute)] mt-1">
          Pantau semua transaksi pembayaran
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard
          label="Total Pendapatan"
          value={formatRupiah(stats.totalRevenue)}
          icon={<Wallet size={20} />}
          color="green"
        />
        <StatCard
          label="Total Transaksi"
          value={stats.totalTransactions}
          icon={<BarChart3 size={20} />}
          color="blue"
        />
        <StatCard
          label="Berhasil"
          value={stats.success}
          icon={<CheckCircle2 size={20} />}
          color="teal"
        />
        <StatCard
          label="Menunggu"
          value={stats.pending}
          icon={<Clock size={20} />}
          color="yellow"
        />
      </div>

      {/* Filters + View toggle */}
      <div className="card p-4 space-y-3">
        <div className="flex flex-col sm:flex-row gap-3 sm:items-center sm:justify-between">
          <div className="relative w-full sm:max-w-xs">
            <Search
              className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--mute)] pointer-events-none"
              size={18}
            />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Cari mapel atau nama Buddy..."
              className="inp pl-10"
            />
          </div>

          <div className="flex items-center gap-1 p-1 bg-[var(--soft)] rounded-xl self-start sm:self-auto">
            <button
              type="button"
              onClick={() => setViewMode('grid')}
              aria-pressed={viewMode === 'grid'}
              className="seg flex items-center gap-1.5"
            >
              <LayoutGrid size={16} />
              Grid
            </button>
            <button
              type="button"
              onClick={() => setViewMode('table')}
              aria-pressed={viewMode === 'table'}
              className="seg flex items-center gap-1.5"
            >
              <List size={16} />
              Tabel
            </button>
          </div>
        </div>

        <div className="flex flex-wrap gap-2">
          {filters.map((f) => (
            <button
              key={f.key}
              type="button"
              onClick={() => setFilter(f.key)}
              className={`px-4 py-2 rounded-xl text-sm font-bold transition-colors ${
                filter === f.key
                  ? 'bg-[var(--blue)] text-white'
                  : 'bg-[var(--soft)] text-[var(--mute)] hover:bg-[var(--hov)]'
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {/* Loading */}
      {loading && (
        <div className="flex justify-center py-20">
          <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {/* Error */}
      {error && (
        <div className="bg-[#FEE2E2] border border-[#FCA5A5] text-[#991B1B] text-sm rounded-xl p-4">
          {error}
        </div>
      )}

      {/* Empty */}
      {!loading && !error && payments.length === 0 && (
        <div className="card p-12 text-center">
          <Receipt size={48} className="mx-auto text-[var(--mute)] mb-3" />
          <p className="font-bold text-[var(--ink)]">Tidak ada transaksi</p>
          <p className="text-sm text-[var(--mute)] mt-1">
            {search
              ? 'Coba kata kunci lain'
              : 'Belum ada transaksi dengan filter ini'}
          </p>
        </div>
      )}

      {/* Grid view (baru) */}
      {!loading && !error && payments.length > 0 && viewMode === 'grid' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {payments.map((p) => (
            <PaymentCard key={p.id} payment={p} />
          ))}
        </div>
      )}

      {/* Table view (lama, styling baru) */}
      {!loading && !error && payments.length > 0 && viewMode === 'table' && (
        <div className="card overflow-hidden">
          <div className="overflow-x-auto">
            <table>
              <thead>
                <tr>
                  <th>ID Transaksi</th>
                  <th>Buddy</th>
                  <th>Mapel</th>
                  <th>Total Bayar</th>
                  <th>Status</th>
                  <th>Tanggal</th>
                </tr>
              </thead>
              <tbody>
                {payments.map((p: any) => (
                  <tr key={p.id}>
                    <td className="font-mono text-xs text-[var(--mute)]">
                      {String(p.id).slice(0, 8)}...
                    </td>
                    <td>
                      <div className="flex items-center gap-2">
                        <span className="w-6 h-6 rounded-full bg-[var(--blue)] text-white grid place-items-center font-bold text-[10px] shrink-0">
                          {getInitials(p.booking?.customer?.full_name)}
                        </span>
                        {p.booking?.customer?.full_name || '-'}
                      </div>
                    </td>
                    <td className="font-semibold">
                      {p.booking?.subject || '-'}
                    </td>
                    <td className="font-bold text-[var(--ink)]">
                      {formatRupiah(p.amount ?? 0)}
                    </td>
                    <td>{getBadge(p.status)}</td>
                    <td className="text-[var(--mute)] text-sm">
                      {new Date(p.created_at).toLocaleDateString('id-ID', {
                        day: 'numeric',
                        month: 'short',
                        year: 'numeric',
                      })}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
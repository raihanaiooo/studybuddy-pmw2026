import { PageHeader } from '../components/ui/PageHeader';
import { StatCard } from '../components/ui/StatCard';
import { GraduationCap, Users, Wallet, Receipt, ArrowRight } from 'lucide-react';
import { useDashboard } from '../hooks/useDashboard';
import type { RecentPayment } from '../hooks/useDashboard';

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

function RecentTransactionRow({ p }: { p: RecentPayment }) {
  return (
    <tr>
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
      <td className="font-semibold">{p.booking?.subject || '-'}</td>
      <td className="font-bold text-[var(--ink)]">{formatRupiah(p.amount ?? 0)}</td>
      <td>{getBadge(p.status)}</td>
      <td className="text-[var(--mute)] text-sm">
        {new Date(p.created_at).toLocaleDateString('id-ID', {
          day: 'numeric',
          month: 'short',
          year: 'numeric',
        })}
      </td>
    </tr>
  );
}

export function DashboardPage() {
  const { stats, recentPayments, loading, error, reload } = useDashboard();

  return (
    <div className="space-y-6">
      <PageHeader title="Dashboard" subtitle="Ringkasan aktivitas Study Buddy hari ini." />

      {/* Loading */}
      {loading && (
        <div className="flex justify-center py-20">
          <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {/* Error */}
      {!loading && error && (
        <div className="bg-[#FEE2E2] border border-[#FCA5A5] text-[#991B1B] text-sm rounded-xl p-4">
          {error}
          <button type="button" onClick={() => reload()} className="btn ml-3">
            Coba Lagi
          </button>
        </div>
      )}

      {!loading && !error && (
        <>
          {/* 4 Card Statistik dari Supabase */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <StatCard
              label="Total Pendapatan"
              value={formatRupiah(stats.totalRevenue)}
              subtitle="Dari pembayaran berhasil"
              icon={<Wallet size={20} strokeWidth={2.5} />}
              color="green"
            />
            <StatCard
              label="Total Buddy/Siswa"
              value={stats.totalBuddies}
              icon={<Users size={20} strokeWidth={2.5} />}
              color="blue"
            />
            <StatCard
              label="Tutor Terverifikasi"
              value={stats.totalTutors}
              icon={<GraduationCap size={20} strokeWidth={2.5} />}
              color="teal"
            />
            <StatCard
              label="Total Transaksi"
              value={stats.totalTransactions}
              icon={<Receipt size={20} strokeWidth={2.5} />}
              color="yellow"
            />
          </div>

          {/* Transaksi Terbaru */}
          <div className="flex justify-between items-end mb-3">
            <h2 className="text-lg font-bold text-[var(--ink)]">Transaksi Terbaru</h2>
            <a
              href="/payments"
              className="text-sm font-bold text-[var(--blue)] hover:underline inline-flex items-center gap-1"
            >
              Lihat Semua <ArrowRight size={16} />
            </a>
          </div>

          {recentPayments.length === 0 ? (
            <div className="card p-12 text-center">
              <Receipt size={48} className="mx-auto text-[var(--mute)] mb-3" />
              <p className="font-bold text-[var(--ink)]">Belum ada transaksi</p>
              <p className="text-sm text-[var(--mute)] mt-1">
                Transaksi pembayaran akan muncul di sini secara real-time
              </p>
            </div>
          ) : (
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
                    {recentPayments.map((p) => (
                      <RecentTransactionRow key={p.id} p={p} />
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}

import { useEffect, useState } from 'react';
import { usePayments } from '../hooks/usePayments';
import { PaymentCard } from '../components/payment/PaymentCard';
import { StatCard } from '../components/ui/StatCard';
import { fetchPaymentStats } from '../lib/api/payment';
import type { PaymentStatus, PaymentStats } from '../types/payment';

type FilterStatus = PaymentStatus | 'all';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'all', label: 'Semua' },
  { key: 'pending', label: 'Menunggu' },
  { key: 'success', label: 'Berhasil' },
  { key: 'failed', label: 'Gagal' },
  { key: 'expired', label: 'Kedaluwarsa' },
  { key: 'refunded', label: 'Refund' },
];

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

  useEffect(() => {
    fetchPaymentStats()
      .then(setStats)
      .catch((e) => console.error('Stats error', e));
  }, [payments.length]);

  const formatRupiah = (n: number) => `Rp${n.toLocaleString('id-ID')}`;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[#1A1F3C]">Transaksi</h1>
        <p className="text-sm text-[#6B7280] mt-1">
          Pantau semua transaksi pembayaran
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard
          label="Total Pendapatan"
          value={formatRupiah(stats.totalRevenue)}
          icon="💰"
          color="green"
        />
        <StatCard
          label="Total Transaksi"
          value={stats.totalTransactions}
          icon="📊"
          color="blue"
        />
        <StatCard
          label="Berhasil"
          value={stats.success}
          icon="✅"
          color="teal"
        />
        <StatCard
          label="Menunggu"
          value={stats.pending}
          icon="⏳"
          color="yellow"
        />
      </div>

      {/* Filters */}
      <div className="bg-white rounded-2xl p-4 border border-[#E5E7EB] space-y-3">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari ID, ref, atau mapel..."
          className="w-full px-4 py-2.5 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA] focus:ring-2 focus:ring-[#1A5EAA]/20"
        />
        <div className="flex flex-wrap gap-2">
          {filters.map((f) => (
            <button
              key={f.key}
              onClick={() => setFilter(f.key)}
              className={`
                px-4 py-2 rounded-xl text-sm font-semibold transition-colors
                ${
                  filter === f.key
                    ? 'bg-[#1A5EAA] text-white'
                    : 'bg-[#F5F6FA] text-[#6B7280] hover:bg-[#E5E7EB]'
                }
              `}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {/* Content */}
      {loading && (
        <div className="flex justify-center py-20">
          <div className="w-10 h-10 border-4 border-[#1A5EAA] border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {error && (
        <div className="bg-[#E53935]/10 border border-[#E53935]/30 text-[#E53935] text-sm rounded-xl p-4">
          {error}
        </div>
      )}

      {!loading && !error && payments.length === 0 && (
        <div className="bg-white rounded-2xl p-12 text-center border border-[#E5E7EB]">
          <div className="text-5xl mb-3">💰</div>
          <p className="font-semibold text-[#1A1F3C]">Tidak ada transaksi</p>
          <p className="text-sm text-[#6B7280] mt-1">
            {search ? 'Coba kata kunci lain' : 'Belum ada transaksi dengan filter ini'}
          </p>
        </div>
      )}

      {!loading && !error && payments.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {payments.map((p) => (
            <PaymentCard key={p.id} payment={p} />
          ))}
        </div>
      )}
    </div>
  );
}
import { useEffect, useState } from 'react';
import { usePayrolls } from '../hooks/usePayrolls';
import { PayrollCard } from '../components/payroll/PayrollCard';
import { GeneratePayrollModal } from '../components/payroll/GeneratePayrollModal';
import { StatCard } from '../components/ui/StatCard';
import { fetchPayrollStats, exportPayrollsToCSV } from '../lib/api/payroll';
import type { PayrollStatus, PayrollStats } from '../types/payroll';

type FilterStatus = PayrollStatus | 'all';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'all', label: 'Semua' },
  { key: 'pending', label: 'Belum Dibayar' },
  { key: 'paid', label: 'Sudah Dibayar' },
];

export function PayrollListPage() {
  const {
    payrolls,
    filter,
    setFilter,
    search,
    setSearch,
    loading,
    generating,
    error,
    generate,
  } = usePayrolls();

  const [stats, setStats] = useState<PayrollStats>({
    total: 0,
    pending: 0,
    paid: 0,
    pendingAmount: 0,
    paidAmount: 0,
  });
  const [showGenerate, setShowGenerate] = useState(false);

  useEffect(() => {
    fetchPayrollStats()
      .then(setStats)
      .catch((e) => console.error('Stats error', e));
  }, [payrolls.length]);

  const formatRupiah = (n: number) => `Rp${n.toLocaleString('id-ID')}`;

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold text-[#1A1F3C]">Payroll</h1>
          <p className="text-sm text-[#6B7280] mt-1">
            Rekap komisi Tutor & status pembayaran
          </p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => exportPayrollsToCSV(payrolls)}
            disabled={payrolls.length === 0}
            className="px-4 py-2.5 rounded-xl border border-[#E5E7EB] bg-white text-[#1A1F3C] font-semibold hover:bg-[#F5F6FA] transition-colors disabled:opacity-50"
          >
            📥 Export CSV
          </button>
          <button
            onClick={() => setShowGenerate(true)}
            disabled={generating}
            className="px-4 py-2.5 rounded-xl bg-[#1A5EAA] text-white font-semibold hover:bg-[#154A87] transition-colors disabled:opacity-50"
          >
            ⚙️ Generate
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard label="Total Record" value={stats.total} icon="📊" color="blue" />
        <StatCard
          label="Belum Dibayar"
          value={stats.pending}
          icon="⏳"
          color="yellow"
          subtitle={formatRupiah(stats.pendingAmount)}
        />
        <StatCard
          label="Sudah Dibayar"
          value={stats.paid}
          icon="✅"
          color="green"
          subtitle={formatRupiah(stats.paidAmount)}
        />
        <StatCard
          label="Total Komisi"
          value={formatRupiah(stats.pendingAmount + stats.paidAmount)}
          icon="💰"
          color="teal"
        />
      </div>

      {/* Filters */}
      <div className="bg-white rounded-2xl p-4 border border-[#E5E7EB] space-y-3">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari nama Tutor..."
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

      {!loading && !error && payrolls.length === 0 && (
        <div className="bg-white rounded-2xl p-12 text-center border border-[#E5E7EB]">
          <div className="text-5xl mb-3">📄</div>
          <p className="font-semibold text-[#1A1F3C]">Belum ada payroll</p>
          <p className="text-sm text-[#6B7280] mt-1">
            Klik "Generate" untuk membuat rekap payroll bulan ini
          </p>
        </div>
      )}

      {!loading && !error && payrolls.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {payrolls.map((p) => (
            <PayrollCard key={p.id} payroll={p} />
          ))}
        </div>
      )}

      <GeneratePayrollModal
        isOpen={showGenerate}
        onClose={() => setShowGenerate(false)}
        onConfirm={generate}
      />
    </div>
  );
}
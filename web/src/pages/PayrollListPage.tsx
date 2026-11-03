import { useEffect, useState } from 'react';
import {
  BarChart3,
  Clock,
  CheckCircle2,
  Wallet,
  Download,
  Settings,
  FileText,
  Search,
  LayoutGrid,
  List,
} from 'lucide-react';
import { usePayrolls } from '../hooks/usePayrolls';
import { PayrollCard } from '../components/payroll/PayrollCard';
import { PayrollStatusBadge } from '../components/payroll/PayrollStatusBadge';
import { GeneratePayrollModal } from '../components/payroll/GeneratePayrollModal';
import { StatCard } from '../components/ui/StatCard';
import { fetchPayrollStats, exportPayrollsToCSV } from '../lib/api/payroll';
import { formatPeriod } from '../types/payroll';
import type { PayrollStatus, PayrollStats } from '../types/payroll';

type FilterStatus = PayrollStatus | 'all';
type ViewMode = 'grid' | 'table';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'all', label: 'Semua' },
  { key: 'pending', label: 'Belum Dibayar' },
  { key: 'paid', label: 'Sudah Dibayar' },
];

const formatRupiah = (n: number) => `Rp${n.toLocaleString('id-ID')}`;

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
  const [viewMode, setViewMode] = useState<ViewMode>('grid');

  useEffect(() => {
    fetchPayrollStats()
      .then(setStats)
      .catch((e) => console.error('Stats error', e));
  }, [payrolls.length]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        <div>
          <h1 className="text-2xl font-extrabold text-[var(--ink)]">Payroll</h1>
          <p className="text-sm text-[var(--mute)] mt-1">
            Rekap komisi Tutor & status pembayaran
          </p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => exportPayrollsToCSV(payrolls)}
            disabled={payrolls.length === 0}
            className="btn disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Download size={16} />
            Export CSV
          </button>
          <button
            onClick={() => setShowGenerate(true)}
            disabled={generating}
            className="btn btn-p disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Settings size={16} />
            Generate
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard
          label="Total Record"
          value={stats.total}
          icon={<BarChart3 size={20} />}
          color="blue"
        />
        <StatCard
          label="Belum Dibayar"
          value={stats.pending}
          icon={<Clock size={20} />}
          color="yellow"
          subtitle={formatRupiah(stats.pendingAmount)}
        />
        <StatCard
          label="Sudah Dibayar"
          value={stats.paid}
          icon={<CheckCircle2 size={20} />}
          color="green"
          subtitle={formatRupiah(stats.paidAmount)}
        />
        <StatCard
          label="Total Komisi"
          value={formatRupiah(stats.pendingAmount + stats.paidAmount)}
          icon={<Wallet size={20} />}
          color="teal"
        />
      </div>

      {/* Filters + View Toggle */}
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
              placeholder="Cari nama Tutor..."
              className="inp pl-10"
            />
          </div>

          {/* View toggle (pakai .seg) */}
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
      {!loading && !error && payrolls.length === 0 && (
        <div className="card p-12 text-center">
          <FileText size={48} className="mx-auto text-[var(--mute)] mb-3" />
          <p className="font-bold text-[var(--ink)]">Belum ada payroll</p>
          <p className="text-sm text-[var(--mute)] mt-1">
            Klik "Generate" untuk membuat rekap payroll bulan ini
          </p>
        </div>
      )}

      {/* Grid view */}
      {!loading && !error && payrolls.length > 0 && viewMode === 'grid' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {payrolls.map((p) => (
            <PayrollCard key={p.id} payroll={p} />
          ))}
        </div>
      )}

      {/* Table view (dari fitur lama, styling baru) */}
      {!loading && !error && payrolls.length > 0 && viewMode === 'table' && (
        <div className="card overflow-hidden">
          <div className="overflow-x-auto">
            <table>
              <thead>
                <tr>
                  <th>Tutor</th>
                  <th>Periode</th>
                  <th>Total Sesi</th>
                  <th>Komisi</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {payrolls.map((p) => (
                  <tr key={p.id}>
                    <td className="font-bold">{p.tutor?.full_name ?? '-'}</td>
                    <td>{formatPeriod(p.period_month, p.period_year)}</td>
                    <td>{p.total_sessions} Sesi</td>
                    <td className="font-bold text-[var(--blue)]">
                      {formatRupiah(p.total_commission)}
                    </td>
                    <td>
                      <PayrollStatusBadge status={p.status} />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
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
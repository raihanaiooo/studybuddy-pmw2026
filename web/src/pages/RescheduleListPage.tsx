import { useEffect, useState } from 'react';
import { useReschedules } from '../hooks/useReschedules';
import { RescheduleCard } from '../components/reschedule/RescheduleCard';
import { StatCard } from '../components/ui/StatCard';
import { fetchRescheduleStats } from '../lib/api/reschedules';
import type { RescheduleStatus, RescheduleStats } from '../types/reschedule';

type FilterStatus = RescheduleStatus | 'all';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'menunggu_admin', label: 'Menunggu' },
  { key: 'disetujui', label: 'Disetujui' },
  { key: 'ditolak', label: 'Ditolak' },
  { key: 'all', label: 'Semua' },
];

export function RescheduleListPage() {
  const { reschedules, filter, setFilter, search, setSearch, loading, error } =
    useReschedules();

  const [stats, setStats] = useState<RescheduleStats>({
    total: 0,
    pending: 0,
    approved: 0,
    rejected: 0,
  });

  useEffect(() => {
    fetchRescheduleStats()
      .then(setStats)
      .catch((e) => console.error('Stats error', e));
  }, [reschedules.length]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[#1A1F3C]">Reschedule</h1>
        <p className="text-sm text-[#6B7280] mt-1">
          Tinjau pengajuan reschedule dari Buddy & Tutor
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <StatCard label="Total" value={stats.total} icon="📊" color="blue" />
        <StatCard
          label="Menunggu"
          value={stats.pending}
          icon="⏳"
          color="yellow"
        />
        <StatCard
          label="Disetujui"
          value={stats.approved}
          icon="✅"
          color="green"
        />
        <StatCard
          label="Ditolak"
          value={stats.rejected}
          icon="❌"
          color="red"
        />
      </div>

      {/* Filters */}
      <div className="bg-white rounded-2xl p-4 border border-[#E5E7EB] space-y-3">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari alasan, pengaju, atau mapel..."
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

      {!loading && !error && reschedules.length === 0 && (
        <div className="bg-white rounded-2xl p-12 text-center border border-[#E5E7EB]">
          <div className="text-5xl mb-3">🔄</div>
          <p className="font-semibold text-[#1A1F3C]">Tidak ada reschedule</p>
          <p className="text-sm text-[#6B7280] mt-1">
            {search ? 'Coba kata kunci lain' : 'Belum ada reschedule dengan filter ini'}
          </p>
        </div>
      )}

      {!loading && !error && reschedules.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {reschedules.map((r) => (
            <RescheduleCard key={r.id} reschedule={r} />
          ))}
        </div>
      )}
    </div>
  );
}
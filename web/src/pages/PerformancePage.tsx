import { useEffect, useState } from 'react';
import { useTutorPerformance } from '../hooks/useTutorPerformance';
import { PerformanceCard } from '../components/performance/PerformanceCard';
import { StatCard } from '../components/ui/StatCard';
import { fetchPerformanceStats } from '../lib/api/performance';
import type { PerformanceStats } from '../types/performance';

type FilterStatus = 'all' | 'active' | 'inactive' | 'frequent_cancel';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'all', label: 'Semua' },
  { key: 'active', label: 'Aktif' },
  { key: 'inactive', label: 'Tidak Aktif' },
  { key: 'frequent_cancel', label: 'Sering Cancel' },
];

export function PerformancePage() {
  const { data, filter, setFilter, search, setSearch, loading, error } =
    useTutorPerformance();

  const [stats, setStats] = useState<PerformanceStats>({
    totalTutors: 0,
    activeTutors: 0,
    inactiveTutors: 0,
    frequentCancelTutors: 0,
  });

  useEffect(() => {
    fetchPerformanceStats()
      .then(setStats)
      .catch((e) => console.error('Stats error', e));
  }, [data.length]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-text-primary">
          Performa Tutor
        </h1>
        <p className="text-sm text-text-secondary mt-1">
          Pantau KPI & aktivitas Tutor
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <StatCard
          label="Total Tutor"
          value={stats.totalTutors}
          icon="👥"
          color="blue"
        />
        <StatCard
          label="Aktif"
          value={stats.activeTutors}
          icon="✅"
          color="green"
        />
        <StatCard
          label="Tidak Aktif"
          value={stats.inactiveTutors}
          icon="⚠️"
          color="red"
        />
        <StatCard
          label="Sering Cancel"
          value={stats.frequentCancelTutors}
          icon="🚫"
          color="yellow"
        />
      </div>

      {/* Filters */}
      <div className="bg-card rounded-2xl p-4 border border-border space-y-3">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari nama Tutor..."
          className="w-full px-4 py-2.5 rounded-xl border border-border bg-background text-sm focus:outline-none focus:border-primary-blue focus:ring-2 focus:ring-primary-blue/20"
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
                    ? 'bg-primary-blue text-white'
                    : 'bg-background text-text-secondary hover:bg-border'
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
          <div className="w-10 h-10 border-4 border-primary-blue border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {error && (
        <div className="bg-primary-red-subtle border border-primary-red/30 text-primary-red text-sm rounded-xl p-4">
          {error}
        </div>
      )}

      {!loading && !error && data.length === 0 && (
        <div className="bg-card rounded-2xl p-12 text-center border border-border">
          <div className="text-5xl mb-3">📊</div>
          <p className="font-semibold text-text-primary">
            Tidak ada data performa
          </p>
          <p className="text-sm text-text-secondary mt-1">
            {search ? 'Coba kata kunci lain' : 'Belum ada Tutor dengan filter ini'}
          </p>
        </div>
      )}

      {!loading && !error && data.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {data.map((p) => (
            <PerformanceCard key={p.tutor_id} data={p} />
          ))}
        </div>
      )}
    </div>
  );
}
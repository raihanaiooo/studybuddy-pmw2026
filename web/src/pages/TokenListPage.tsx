import { useEffect, useState } from 'react';
import { useTokens } from '../hooks/useTokens';
import { TokenCard } from '../components/package/TokenCard';
import { StatCard } from '../components/ui/StatCard';
import { fetchPackageStats } from '../lib/api/packages';
import type { TokenStatus, PackageStats } from '../types/package';
import { Ticket, CheckCircle, BarChart3, Wallet } from 'lucide-react';

type FilterStatus = TokenStatus | 'all';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'all', label: 'Semua' },
  { key: 'active', label: 'Aktif' },
  { key: 'used', label: 'Terpakai' },
  { key: 'expired', label: 'Kadaluarsa' },
];

export function TokenListPage() {
  const { tokens, filter, setFilter, search, setSearch, loading, error } = useTokens();

  const [stats, setStats] = useState<PackageStats>({
    totalPackages: 0, activePackages: 0, totalTokens: 0, activeTokens: 0, totalRevenue: 0,
  });

  useEffect(() => {
    fetchPackageStats().then(setStats).catch((e) => console.error('Stats error', e));
  }, [tokens.length]);

  const formatRupiah = (n: number) => `Rp${n.toLocaleString('id-ID')}`;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-[var(--ink)]">Token Buddy</h1>
        <p className="text-sm text-[var(--mute)] mt-1">Pantau token hasil pembelian paket.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard label="Total Token" value={stats.totalTokens} icon={<Ticket size={20} strokeWidth={2.5} />} color="blue" />
        <StatCard label="Token Aktif" value={stats.activeTokens} icon={<CheckCircle size={20} strokeWidth={2.5} />} color="green" />
        <StatCard label="Token Terpakai" value={stats.totalTokens - stats.activeTokens} icon={<BarChart3 size={20} strokeWidth={2.5} />} color="teal" />
        <StatCard label="Total Revenue" value={formatRupiah(stats.totalRevenue)} icon={<Wallet size={20} strokeWidth={2.5} />} color="yellow" />
      </div>

      {/* Filters */}
      <div className="card p-4 space-y-3">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari nama Buddy, email, atau paket..."
          className="inp"
        />
        <div className="flex flex-wrap gap-2">
          {filters.map((f) => (
            <button
              key={f.key}
              onClick={() => setFilter(f.key)}
              className={`px-4 py-2 rounded-lg text-sm font-bold transition-colors ${
                filter === f.key ? 'bg-[var(--blue)] text-white' : 'bg-[var(--soft)] text-[var(--mute)] hover:bg-[var(--hov)]'
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {/* Content */}
      {loading && (
        <div className="flex justify-center py-20">
          <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {error && <div className="bg-red-50 border border-red-200 text-red-600 text-sm rounded-xl p-4">{error}</div>}

      {!loading && !error && tokens.length === 0 && (
        <div className="card p-12 text-center">
          <Ticket size={48} className="mx-auto text-[var(--mute)] mb-3" />
          <p className="font-bold text-[var(--ink)]">Tidak ada token</p>
          <p className="text-sm text-[var(--mute)] mt-1">{search ? 'Coba kata kunci lain' : 'Belum ada token dengan filter ini'}</p>
        </div>
      )}

      {!loading && !error && tokens.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {tokens.map((t) => <TokenCard key={t.id} token={t} />)}
        </div>
      )}
    </div>
  );
}
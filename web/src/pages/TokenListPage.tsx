import { useEffect, useState } from 'react';
import { useTokens } from '../hooks/useTokens';
import { TokenCard } from '../components/package/TokenCard';
import { StatCard } from '../components/ui/StatCard';
import { fetchPackageStats } from '../lib/api/packages';
import type { TokenStatus, PackageStats } from '../types/package';

type FilterStatus = TokenStatus | 'all';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'all', label: 'Semua' },
  { key: 'active', label: 'Aktif' },
  { key: 'used', label: 'Terpakai' },
  { key: 'expired', label: 'Kadaluarsa' },
];

export function TokenListPage() {
  const { tokens, filter, setFilter, search, setSearch, loading, error } =
    useTokens();

  const [stats, setStats] = useState<PackageStats>({
    totalPackages: 0,
    activePackages: 0,
    totalTokens: 0,
    activeTokens: 0,
    totalRevenue: 0,
  });

  useEffect(() => {
    fetchPackageStats()
      .then(setStats)
      .catch((e) => console.error('Stats error', e));
  }, [tokens.length]);

  const formatRupiah = (n: number) => `Rp${n.toLocaleString('id-ID')}`;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[#1A1F3C]">Token Buddy</h1>
        <p className="text-sm text-[#6B7280] mt-1">
          Pantau token hasil pembelian paket
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard
          label="Total Token"
          value={stats.totalTokens}
          icon="🎟️"
          color="blue"
        />
        <StatCard
          label="Token Aktif"
          value={stats.activeTokens}
          icon="✅"
          color="green"
        />
        <StatCard
          label="Token Terpakai"
          value={stats.totalTokens - stats.activeTokens}
          icon="📊"
          color="teal"
        />
        <StatCard
          label="Total Revenue"
          value={formatRupiah(stats.totalRevenue)}
          icon="💰"
          color="yellow"
        />
      </div>

      {/* Filters */}
      <div className="bg-white rounded-2xl p-4 border border-[#E5E7EB] space-y-3">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari nama Buddy, email, atau paket..."
          className="w-full px-4 py-2.5 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA]"
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

      {!loading && !error && tokens.length === 0 && (
        <div className="bg-white rounded-2xl p-12 text-center border border-[#E5E7EB]">
          <div className="text-5xl mb-3">🎟️</div>
          <p className="font-semibold text-[#1A1F3C]">Tidak ada token</p>
          <p className="text-sm text-[#6B7280] mt-1">
            {search ? 'Coba kata kunci lain' : 'Belum ada token dengan filter ini'}
          </p>
        </div>
      )}

      {!loading && !error && tokens.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {tokens.map((t) => (
            <TokenCard key={t.id} token={t} />
          ))}
        </div>
      )}
    </div>
  );
}
import { useEffect, useState } from 'react';
import { usePackages } from '../hooks/usePackages';
import { PackageCard } from '../components/package/PackageCard';
import { PackageFormModal } from '../components/package/PackageFormModal';
import { StatCard } from '../components/ui/StatCard';
import { fetchPackageStats } from '../lib/api/packages';
import type { Package, PackageStats } from '../types/package';

export function PackageListPage() {
  const {
    packages,
    includeInactive,
    setIncludeInactive,
    search,
    setSearch,
    loading,
    error,
    create,
    update,
    toggleActive,
  } = usePackages();

  const [stats, setStats] = useState<PackageStats>({
    totalPackages: 0,
    activePackages: 0,
    totalTokens: 0,
    activeTokens: 0,
    totalRevenue: 0,
  });
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<Package | null>(null);

  useEffect(() => {
    fetchPackageStats()
      .then(setStats)
      .catch((e) => console.error('Stats error', e));
  }, [packages.length]);

  function handleOpenCreate() {
    setEditing(null);
    setModalOpen(true);
  }

  function handleOpenEdit(pkg: Package) {
    setEditing(pkg);
    setModalOpen(true);
  }

  async function handleSubmit(data: any) {
    if (editing) {
      await update(editing.id, data);
    } else {
      await create(data);
    }
  }

  async function handleToggleActive(pkg: Package) {
    if (
      !confirm(
        `Yakin ${pkg.is_active ? 'nonaktifkan' : 'aktifkan'} "${pkg.package_name}"?`
      )
    ) {
      return;
    }
    await toggleActive(pkg.id, !pkg.is_active);
  }

  const formatRupiah = (n: number) => `Rp${n.toLocaleString('id-ID')}`;

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold text-[#1A1F3C]">Paket Belajar</h1>
          <p className="text-sm text-[#6B7280] mt-1">
            Kelola katalog paket & bundling
          </p>
        </div>
        <button
          onClick={handleOpenCreate}
          className="px-4 py-2.5 rounded-xl bg-[#1A5EAA] text-white font-semibold hover:bg-[#154A87] transition-colors"
        >
          ➕ Tambah Paket
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard
          label="Total Paket"
          value={stats.totalPackages}
          icon="📦"
          color="blue"
        />
        <StatCard
          label="Paket Aktif"
          value={stats.activePackages}
          icon="✅"
          color="green"
        />
        <StatCard
          label="Token Terjual"
          value={stats.totalTokens}
          icon="🎟️"
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
          placeholder="Cari nama paket..."
          className="w-full px-4 py-2.5 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA]"
        />
        <label className="flex items-center gap-2 cursor-pointer text-sm">
          <input
            type="checkbox"
            checked={includeInactive}
            onChange={(e) => setIncludeInactive(e.target.checked)}
            className="w-4 h-4 rounded"
          />
          <span className="text-[#6B7280]">Tampilkan paket nonaktif</span>
        </label>
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

      {!loading && !error && packages.length === 0 && (
        <div className="bg-white rounded-2xl p-12 text-center border border-[#E5E7EB]">
          <div className="text-5xl mb-3">📦</div>
          <p className="font-semibold text-[#1A1F3C]">Belum ada paket</p>
          <p className="text-sm text-[#6B7280] mt-1">
            Klik "Tambah Paket" untuk mulai
          </p>
        </div>
      )}

      {!loading && !error && packages.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {packages.map((pkg) => (
            <PackageCard
              key={pkg.id}
              package={pkg}
              onEdit={() => handleOpenEdit(pkg)}
              onToggleActive={() => handleToggleActive(pkg)}
            />
          ))}
        </div>
      )}

      <PackageFormModal
        isOpen={modalOpen}
        editing={editing}
        onClose={() => setModalOpen(false)}
        onSubmit={handleSubmit}
      />
    </div>
  );
}
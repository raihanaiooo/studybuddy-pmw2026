import { useEffect, useState } from 'react';
import {
  Package as PackageIcon,
  CheckCircle,
  Ticket,
  Wallet,
  Plus,
  AlertCircle,
  Search,
} from 'lucide-react';
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
    // Perbaikan: Kurung kurawal yang tadinya menutup fungsi terlalu cepat sudah dihapus
    if (!(await (window.confirm as any)(`Yakin ${pkg.is_active ? 'nonaktifkan' : 'aktifkan'} "${pkg.package_name}"?`))) return;

    await toggleActive(pkg.id, !pkg.is_active);
  }

  const formatRupiah = (n: number) => `Rp${n.toLocaleString('id-ID')}`;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        <div>
          <h1 className="text-2xl font-extrabold text-[var(--ink)]">
            Paket Belajar
          </h1>
          <p className="text-sm text-[var(--mute)] mt-1">
            Kelola katalog paket & bundling.
          </p>
        </div>
        <button onClick={handleOpenCreate} className="btn btn-p">
          <Plus size={18} />
          Tambah Paket
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard
          label="Total Paket"
          value={stats.totalPackages}
          icon={<PackageIcon size={20} strokeWidth={2.5} />}
          color="blue"
        />
        <StatCard
          label="Paket Aktif"
          value={stats.activePackages}
          icon={<CheckCircle size={20} strokeWidth={2.5} />}
          color="green"
        />
        <StatCard
          label="Token Terjual"
          value={stats.totalTokens}
          icon={<Ticket size={20} strokeWidth={2.5} />}
          color="teal"
        />
        <StatCard
          label="Total Revenue"
          value={formatRupiah(stats.totalRevenue)}
          icon={<Wallet size={20} strokeWidth={2.5} />}
          color="yellow"
        />
      </div>

      {/* Filters */}
      <div className="card p-4 space-y-3">
        <div className="relative w-full sm:max-w-md">
          <Search
            className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--mute)] pointer-events-none"
            size={18}
          />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Cari nama paket..."
            className="inp pl-10"
          />
        </div>
        <label className="flex items-center gap-2 cursor-pointer text-sm font-semibold text-[var(--mute)] select-none">
          <input
            type="checkbox"
            checked={includeInactive}
            onChange={(e) => setIncludeInactive(e.target.checked)}
            className="w-4 h-4 rounded accent-[var(--blue)]"
          />
          Tampilkan paket nonaktif
        </label>
      </div>

      {/* Loading */}
      {loading && (
        <div className="flex justify-center py-20">
          <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {/* Error */}
      {error && (
        <div className="bg-[#FEE2E2] border border-[#FCA5A5] text-[#991B1B] text-sm rounded-xl p-4 flex items-start gap-2">
          <AlertCircle size={18} className="shrink-0 mt-0.5" />
          <span>{error}</span>
        </div>
      )}

      {/* Empty */}
      {!loading && !error && packages.length === 0 && (
        <div className="card p-12 text-center">
          <PackageIcon size={48} className="mx-auto text-[var(--mute)] mb-3" />
          <p className="font-bold text-[var(--ink)]">Belum ada paket</p>
          <p className="text-sm text-[var(--mute)] mt-1">
            Klik "Tambah Paket" untuk mulai.
          </p>
        </div>
      )}

      {/* Grid */}
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
        onSubmit={handleSubmit}
        onClose={() => setModalOpen(false)}
      />
    </div>
  );
}
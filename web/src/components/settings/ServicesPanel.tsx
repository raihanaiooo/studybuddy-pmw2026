import { useState } from 'react';
import { SortControl } from '../ui/SortControl';
import { sortItems, type SortDir } from '../../lib/sortList';
import {
  Package as PackageIcon,
  CheckCircle,
  Plus,
  AlertCircle,
  Search,
} from 'lucide-react';
import { usePackages } from '../../hooks/usePackages';
import { PackageCard } from '../package/PackageCard';
import { PackageFormModal } from '../package/PackageFormModal';
import { StatCard } from '../ui/StatCard';
import type { Package } from '../../types/package';

/** Katalog layanan dan harga (tabel packages) di halaman Pengaturan. */
export function ServicesPanel() {
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

  const [modalOpen, setModalOpen] = useState(false);
  const [sort, setSort] = useState<{ key: 'package_name' | 'price'; dir: SortDir }>({ key: 'package_name', dir: 'asc' });
  const [editing, setEditing] = useState<Package | null>(null);

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
    try {
      await toggleActive(pkg.id, !pkg.is_active);
    } catch (err: any) {
      await (window.alert as any)('Gagal mengubah status paket: ' + (err?.message ?? err));
    }
  }

  const sortedPackages = sortItems(packages, (p) => p[sort.key], sort.dir);
  const activeCount = packages.filter((p) => p.is_active).length;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        <div>
          <h2 className="text-xl font-extrabold text-[var(--ink)]">
            Layanan & Harga
          </h2>
          <p className="text-sm text-[var(--mute)] mt-1">
            Katalog paket dan bundling: harga, jumlah sesi, dan masa berlaku.
          </p>
        </div>
        <button onClick={handleOpenCreate} className="btn btn-p">
          <Plus size={18} />
          Tambah Layanan
        </button>
      </div>

      {/* Ringkasan */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <StatCard
          label="Layanan Ditampilkan"
          value={packages.length}
          icon={<PackageIcon size={20} strokeWidth={2.5} />}
          color="blue"
        />
        <StatCard
          label="Layanan Aktif"
          value={activeCount}
          icon={<CheckCircle size={20} strokeWidth={2.5} />}
          color="green"
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
            className="inp !pl-10"
          />
        </div>
        <div className="flex flex-wrap items-center justify-between gap-3">
        <SortControl
          options={[{ key: 'package_name', label: 'Nama' }, { key: 'price', label: 'Harga' }]}
          sortKey={sort.key}
          dir={sort.dir}
          onChange={(key, dir) => setSort({ key: key as 'package_name' | 'price', dir })}
        />
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
            Klik "Tambah Layanan" untuk mulai.
          </p>
        </div>
      )}

      {/* Grid */}
      {!loading && !error && packages.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {sortedPackages.map((pkg) => (
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
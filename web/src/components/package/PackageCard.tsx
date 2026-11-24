import { Pencil } from 'lucide-react';
import { VisibilitySwitch } from '../content/ContentItemCards';
import type { Package } from '../../types/package';

interface Props {
  package: Package;
  onEdit: () => void;
  onToggleActive: () => void;
}

function formatRupiah(n: number) {
  return `Rp${n.toLocaleString('id-ID')}`;
}

export function PackageCard({ package: pkg, onEdit, onToggleActive }: Props) {
  return (
    <div className={`card p-5 hover:shadow-md transition-shadow ${pkg.is_active ? '' : 'opacity-60'}`}>
      {/* Header */}
      <div className="flex flex-wrap items-start justify-between gap-3 mb-3">
        <div className="min-w-0 flex-1">
          <h3 className="font-bold text-[var(--ink)] truncate">
            {pkg.package_name}
          </h3>
          <p className="text-xs text-[var(--mute)] mt-0.5 line-clamp-2">
            {pkg.description ?? '-'}
          </p>
        </div>
      </div>

      {/* Info grid */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 mb-3 text-sm">
        <div>
          <p className="text-xs text-[var(--mute)]">Sesi</p>
          <p className="font-semibold text-[var(--ink)]">{pkg.session_count}</p>
        </div>
        <div>
          <p className="text-xs text-[var(--mute)]">Berlaku</p>
          <p className="font-semibold text-[var(--ink)]">
            {pkg.validity_days} hari
          </p>
        </div>
        <div>
          <p className="text-xs text-[var(--mute)]">Reschedule</p>
          <p className="font-semibold text-[var(--ink)]">
            {pkg.reschedule_quota}x
          </p>
        </div>
        <div>
          <p className="text-xs text-[var(--mute)]">Max Tutor</p>
          <p className="font-semibold text-[var(--blue)]">
            {pkg.max_tutors} Tutor
          </p>
        </div>
      </div>

      {/* Price + actions */}
      <div className="pt-3 border-t border-[var(--line)] flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="text-xs text-[var(--mute)]">Harga</p>
          <p className="text-lg font-bold text-[var(--blue)]">
            {formatRupiah(pkg.price)}
          </p>
          {pkg.is_refundable && (
            <p className="text-xs text-[#0F766E] mt-0.5 font-semibold">
              Refundable
            </p>
          )}
        </div>
        <div className="flex gap-2">
          <span className="flex items-center gap-2 mr-1">
            <VisibilitySwitch on={pkg.is_active} label={`Paket ${pkg.package_name} aktif`} onChange={onToggleActive} />
            <span className={`text-xs font-semibold ${pkg.is_active ? 'text-[#166534]' : 'text-[var(--mute)]'}`}>
              {pkg.is_active ? 'Aktif' : 'Nonaktif'}
            </span>
          </span>
          <button
            type="button"
            onClick={onEdit}
            className="btn btn-p text-xs"
          >
            <Pencil size={14} />
            Edit
          </button>
        </div>
      </div>
    </div>
  );
}
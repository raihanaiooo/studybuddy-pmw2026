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
    <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB] hover:shadow-md transition-shadow">
      <div className="flex flex-wrap items-start justify-between gap-3 mb-3">
        <div className="min-w-0 flex-1">
          <h3 className="font-bold text-[#1A1F3C] truncate">
            {pkg.package_name}
          </h3>
          <p className="text-xs text-[#6B7280] mt-0.5 line-clamp-2">
            {pkg.description ?? '-'}
          </p>
        </div>
        <span
          className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold shrink-0 ${
            pkg.is_active
              ? 'bg-[#00C853]/15 text-[#00C853]'
              : 'bg-[#9CA3AF]/15 text-[#9CA3AF]'
          }`}
        >
          {pkg.is_active ? 'Aktif' : 'Nonaktif'}
        </span>
      </div>

      {/* Info grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 gap-2 mb-3 text-sm">
        <div>
          <p className="text-xs text-[#6B7280]">Sesi</p>
          <p className="font-semibold text-[#1A1F3C]">{pkg.session_count}</p>
        </div>
        <div>
          <p className="text-xs text-[#6B7280]">Berlaku</p>
          <p className="font-semibold text-[#1A1F3C]">
            {pkg.validity_days} hari
          </p>
        </div>
        <div>
          <p className="text-xs text-[#6B7280]">Reschedule</p>
          <p className="font-semibold text-[#1A1F3C]">
            {pkg.reschedule_quota}x
          </p>
        </div>
      </div>

      {/* Price + actions */}
      <div className="pt-3 border-t border-[#E5E7EB] flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="text-xs text-[#6B7280]">Harga</p>
          <p className="text-lg font-bold text-[#1A5EAA]">
            {formatRupiah(pkg.price)}
          </p>
          {pkg.is_refundable && (
            <p className="text-xs text-[#00BFA5] mt-0.5">Refundable</p>
          )}
        </div>
        <div className="flex gap-2">
          <button
            onClick={onToggleActive}
            className={`
              px-3 py-2 rounded-xl text-xs font-semibold transition-colors
              ${
                pkg.is_active
                  ? 'border border-[#E53935] text-[#E53935] hover:bg-[#E53935]/10'
                  : 'border border-[#00C853] text-[#00C853] hover:bg-[#00C853]/10'
              }
            `}
          >
            {pkg.is_active ? 'Nonaktifkan' : 'Aktifkan'}
          </button>
          <button
            onClick={onEdit}
            className="px-3 py-2 rounded-xl bg-[#1A5EAA] text-white text-xs font-semibold hover:bg-[#154A87] transition-colors"
          >
            Edit
          </button>
        </div>
      </div>
    </div>
  );
}
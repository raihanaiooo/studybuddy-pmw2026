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
    <div className="bg-card rounded-2xl p-5 border border-border shadow-sm hover:shadow-md transition-shadow">
      <div className="flex flex-wrap items-start justify-between gap-3 mb-3">
        <div className="min-w-0 flex-1">
          <h3 className="font-poppins font-bold text-text-primary truncate">
            {pkg.package_name}
          </h3>
          <p className="text-xs font-nunito text-text-secondary mt-0.5 line-clamp-2">
            {pkg.description ?? '-'}
          </p>
        </div>
        <span
          className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold shrink-0 ${
            pkg.is_active
              ? 'bg-online-green-subtle text-online-green'
              : 'bg-background text-text-light'
          }`}
        >
          {pkg.is_active ? 'Aktif' : 'Nonaktif'}
        </span>
      </div>

      {/* Info grid */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 mb-3 text-sm">
        <div>
          <p className="text-xs font-nunito text-text-light">Sesi</p>
          <p className="font-nunito font-semibold text-text-primary">
            {pkg.session_count}
          </p>
        </div>
        <div>
          <p className="text-xs font-nunito text-text-light">Berlaku</p>
          <p className="font-nunito font-semibold text-text-primary">
            {pkg.validity_days} hari
          </p>
        </div>
        <div>
          <p className="text-xs font-nunito text-text-light">Reschedule</p>
          <p className="font-nunito font-semibold text-text-primary">
            {pkg.reschedule_quota}x
          </p>
        </div>
        <div>
          <p className="text-xs font-nunito text-text-light">Max Tutor</p>
          <p className="font-nunito font-semibold text-primary-blue">
            {pkg.max_tutors} Tutor
          </p>
        </div>
      </div>

      {/* Price + actions */}
      <div className="pt-3 border-t border-border flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="text-xs font-nunito text-text-light">Harga</p>
          <p className="text-lg font-poppins font-bold text-primary-blue">
            {formatRupiah(pkg.price)}
          </p>
          {pkg.is_refundable && (
            <p className="text-xs font-nunito text-accent-teal mt-0.5">
              Refundable
            </p>
          )}
        </div>
        <div className="flex gap-2">
          <button
            onClick={onToggleActive}
            className={`
              px-3 py-2 rounded-xl text-xs font-nunito font-semibold transition-colors
              ${
                pkg.is_active
                  ? 'border border-primary-red text-primary-red hover:bg-primary-red-subtle'
                  : 'border border-online-green text-online-green hover:bg-online-green-subtle'
              }
            `}
          >
            {pkg.is_active ? 'Nonaktifkan' : 'Aktifkan'}
          </button>
          <button
            onClick={onEdit}
            className="px-3 py-2 rounded-xl bg-primary-blue text-white text-xs font-nunito font-semibold hover:bg-primary-blue-dark transition-colors"
          >
            Edit
          </button>
        </div>
      </div>
    </div>
  );
}
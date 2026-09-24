import type { VerificationStatus } from '../../types/tutor';

interface Props {
  status: VerificationStatus;
}

const config: Record<
  VerificationStatus,
  { label: string; className: string }
> = {
  pending: {
    label: 'Menunggu Verifikasi',
    className: 'bg-[#F4A200]/15 text-[#F4A200]',
  },
  verified: {
    label: 'Terverifikasi',
    className: 'bg-[#00C853]/15 text-[#00C853]',
  },
  rejected: {
    label: 'Ditolak',
    className: 'bg-[#E53935]/15 text-[#E53935]',
  },
};

export function VerificationBadge({ status }: Props) {
  const c = config[status];
  return (
    <span
      className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold ${c.className}`}
    >
      {c.label}
    </span>
  );
}
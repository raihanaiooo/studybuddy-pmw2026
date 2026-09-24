import type { ComplaintStatus } from '../../types/complaint';

interface Props {
  status: ComplaintStatus;
}

const config: Record<ComplaintStatus, { label: string; className: string }> = {
  pending: {
    label: 'Menunggu',
    className: 'bg-[#F4A200]/15 text-[#F4A200]',
  },
  in_review: {
    label: 'Ditinjau',
    className: 'bg-[#1A5EAA]/15 text-[#1A5EAA]',
  },
  resolved: {
    label: 'Selesai',
    className: 'bg-[#00C853]/15 text-[#00C853]',
  },
  rejected: {
    label: 'Ditolak',
    className: 'bg-[#E53935]/15 text-[#E53935]',
  },
};

export function ComplaintStatusBadge({ status }: Props) {
  const c = config[status] ?? config.pending;
  return (
    <span
      className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold ${c.className}`}
    >
      {c.label}
    </span>
  );
}
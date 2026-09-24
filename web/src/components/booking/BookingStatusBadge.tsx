import type { BookingStatus } from '../../types/booking';

interface Props {
  status: BookingStatus;
}

const config: Record<BookingStatus, { label: string; className: string }> = {
  pending: {
    label: 'Menunggu',
    className: 'bg-[#F4A200]/15 text-[#F4A200]',
  },
  confirmed: {
    label: 'Dikonfirmasi',
    className: 'bg-[#1A5EAA]/15 text-[#1A5EAA]',
  },
  ongoing: {
    label: 'Berlangsung',
    className: 'bg-[#00C853]/15 text-[#00C853]',
  },
  completed: {
    label: 'Selesai',
    className: 'bg-[#00BFA5]/15 text-[#00BFA5]',
  },
  cancelled: {
    label: 'Dibatalkan',
    className: 'bg-[#E53935]/15 text-[#E53935]',
  },
};

export function BookingStatusBadge({ status }: Props) {
  const c = config[status] ?? config.pending;
  return (
    <span
      className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold ${c.className}`}
    >
      {c.label}
    </span>
  );
}
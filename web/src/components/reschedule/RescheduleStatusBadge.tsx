import type { RescheduleStatus } from '../../types/reschedule';

interface Props {
  status: RescheduleStatus;
}

const config: Record<RescheduleStatus, { label: string; className: string }> = {
  menunggu_admin: {
    label: 'Menunggu',
    className: 'bg-[#F4A200]/15 text-[#F4A200]',
  },
  disetujui: {
    label: 'Disetujui',
    className: 'bg-[#00C853]/15 text-[#00C853]',
  },
  ditolak: {
    label: 'Ditolak',
    className: 'bg-[#E53935]/15 text-[#E53935]',
  },
};

export function RescheduleStatusBadge({ status }: Props) {
  const c = config[status] ?? config.menunggu_admin;
  return (
    <span
      className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold ${c.className}`}
    >
      {c.label}
    </span>
  );
}
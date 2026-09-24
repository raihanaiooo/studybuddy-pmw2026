import type { PayrollStatus } from '../../types/payroll';

interface Props {
  status: PayrollStatus;
}

const config: Record<PayrollStatus, { label: string; className: string }> = {
  pending: {
    label: 'Belum Dibayar',
    className: 'bg-[#F4A200]/15 text-[#F4A200]',
  },
  paid: {
    label: 'Sudah Dibayar',
    className: 'bg-[#00C853]/15 text-[#00C853]',
  },
};

export function PayrollStatusBadge({ status }: Props) {
  const c = config[status] ?? config.pending;
  return (
    <span
      className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold ${c.className}`}
    >
      {c.label}
    </span>
  );
}
import type { PaymentStatus } from '../../types/payment';

interface Props {
  status: PaymentStatus;
}

const config: Record<PaymentStatus, { label: string; className: string }> = {
  pending: {
    label: 'Menunggu',
    className: 'bg-[#F4A200]/15 text-[#F4A200]',
  },
  success: {
    label: 'Berhasil',
    className: 'bg-[#00C853]/15 text-[#00C853]',
  },
  failed: {
    label: 'Gagal',
    className: 'bg-[#E53935]/15 text-[#E53935]',
  },
  expired: {
    label: 'Kedaluwarsa',
    className: 'bg-[#9CA3AF]/15 text-[#9CA3AF]',
  },
  refunded: {
    label: 'Refund',
    className: 'bg-[#00BFA5]/15 text-[#00BFA5]',
  },
};

export function PaymentStatusBadge({ status }: Props) {
  const c = config[status] ?? config.pending;
  return (
    <span
      className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold ${c.className}`}
    >
      {c.label}
    </span>
  );
}
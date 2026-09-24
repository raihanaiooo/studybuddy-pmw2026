import { Link } from 'react-router-dom';
import type { PaymentWithRelations } from '../../types/payment';
import { PaymentStatusBadge } from './PaymentStatusBadge';

interface Props {
  payment: PaymentWithRelations;
}

function formatRupiah(n: number) {
  return `Rp${n.toLocaleString('id-ID')}`;
}

function formatDateTime(iso: string) {
  const d = new Date(iso);
  return d.toLocaleString('id-ID', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

export function PaymentCard({ payment }: Props) {
  return (
    <Link
      to={`/payments/${payment.id}`}
      className="block bg-white rounded-2xl p-5 border border-[#E5E7EB] hover:shadow-md hover:border-[#1A5EAA]/30 transition-all"
    >
      <div className="flex flex-wrap items-start justify-between gap-3 mb-3">
        <div className="min-w-0 flex-1">
          <h3 className="font-bold text-[#1A1F3C] truncate">
            {payment.booking?.subject ?? 'Booking'}
          </h3>
          <p className="text-xs text-[#6B7280] mt-0.5">
            ID: {payment.id.slice(0, 8)}...
          </p>
        </div>
        <PaymentStatusBadge status={payment.status} />
      </div>

      <div className="flex flex-wrap items-center justify-between gap-2">
        <div>
          <p className="text-xs text-[#6B7280]">Jumlah</p>
          <p className="text-lg font-bold text-[#1A5EAA]">
            {formatRupiah(payment.amount)}
          </p>
        </div>
        <div className="text-right">
          <p className="text-xs text-[#6B7280]">Dibuat</p>
          <p className="text-sm text-[#1A1F3C]">
            {formatDateTime(payment.created_at)}
          </p>
        </div>
      </div>
    </Link>
  );
}
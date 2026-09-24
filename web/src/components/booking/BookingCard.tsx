import { Link } from 'react-router-dom';
import type { BookingWithRelations } from '../../types/booking';
import { BookingStatusBadge } from './BookingStatusBadge';

interface Props {
  booking: BookingWithRelations;
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

export function BookingCard({ booking }: Props) {
  return (
    <Link
      to={`/bookings/${booking.id}`}
      className="block bg-white rounded-2xl p-5 border border-[#E5E7EB] hover:shadow-md hover:border-[#1A5EAA]/30 transition-all"
    >
      <div className="flex flex-wrap items-start justify-between gap-3 mb-3">
        <div className="min-w-0 flex-1">
          <h3 className="font-bold text-[#1A1F3C] truncate">
            {booking.subject}
          </h3>
          <p className="text-xs text-[#6B7280] mt-0.5">
            {formatDateTime(booking.session_time)} · {booking.duration_minutes} menit
          </p>
        </div>
        <BookingStatusBadge status={booking.status} />
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm">
        <div className="flex items-center gap-2">
          <span className="text-[#9CA3AF] text-xs">Buddy:</span>
          <span className="text-[#1A1F3C] font-medium truncate">
            {booking.customer?.full_name ?? '-'}
          </span>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-[#9CA3AF] text-xs">Tutor:</span>
          <span className="text-[#1A1F3C] font-medium truncate">
            {booking.tutor?.full_name ?? '-'}
          </span>
        </div>
      </div>
    </Link>
  );
}
import { Link } from 'react-router-dom';
import type { RescheduleWithRelations } from '../../types/reschedule';
import { RescheduleStatusBadge } from './RescheduleStatusBadge';

interface Props {
  reschedule: RescheduleWithRelations;
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

export function RescheduleCard({ reschedule }: Props) {
  return (
    <Link
      to={`/reschedules/${reschedule.id}`}
      className="block bg-white rounded-2xl p-5 border border-[#E5E7EB] hover:shadow-md hover:border-[#1A5EAA]/30 transition-all"
    >
      <div className="flex flex-wrap items-start justify-between gap-3 mb-3">
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2 mb-1">
            <span className="text-xs px-2 py-1 rounded-lg bg-[#1A5EAA]/10 text-[#1A5EAA] font-semibold capitalize">
              dari {reschedule.requested_by_role}
            </span>
          </div>
          <h3 className="font-bold text-[#1A1F3C] truncate">
            {reschedule.booking?.subject ?? 'Booking'}
          </h3>
        </div>
        <RescheduleStatusBadge status={reschedule.status} />
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm mb-3">
        <div>
          <p className="text-xs text-[#6B7280] mb-0.5">Jadwal Lama</p>
          <p className="text-[#1A1F3C] font-medium">
            {formatDateTime(reschedule.original_session_time)}
          </p>
        </div>
        <div>
          <p className="text-xs text-[#6B7280] mb-0.5">Jadwal Baru</p>
          <p className="text-[#1A5EAA] font-medium">
            {formatDateTime(reschedule.new_session_time)}
          </p>
        </div>
      </div>

      <div className="pt-3 border-t border-[#E5E7EB] flex flex-wrap items-center justify-between gap-2 text-xs">
        <div>
          <span className="text-[#6B7280]">Pengaju: </span>
          <span className="text-[#1A1F3C] font-medium">
            {reschedule.requester?.full_name ?? '-'}
          </span>
        </div>
        <span className="text-[#6B7280]">
          {formatDateTime(reschedule.created_at)}
        </span>
      </div>
    </Link>
  );
}
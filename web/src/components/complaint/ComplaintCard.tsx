import { Link } from 'react-router-dom';
import type { ComplaintWithRelations } from '../../types/complaint';
import { CATEGORY_LABELS } from '../../types/complaint';
import { ComplaintStatusBadge } from './ComplaintStatusBadge';

interface Props {
  complaint: ComplaintWithRelations;
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

export function ComplaintCard({ complaint }: Props) {
  return (
    <Link
      to={`/complaints/${complaint.id}`}
      className="block bg-white rounded-2xl p-5 border border-[#E5E7EB] hover:shadow-md hover:border-[#1A5EAA]/30 transition-all"
    >
      <div className="flex flex-wrap items-start justify-between gap-3 mb-3">
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-center gap-2 mb-1">
            <span className="text-xs px-2 py-1 rounded-lg bg-[#1A5EAA]/10 text-[#1A5EAA] font-semibold">
              {CATEGORY_LABELS[complaint.category]}
            </span>
            <span className="text-xs text-[#6B7280] capitalize">
              dari {complaint.reporter_role}
            </span>
          </div>
          <p className="text-sm text-[#1A1F3C] font-medium line-clamp-2">
            {complaint.description}
          </p>
        </div>
        <ComplaintStatusBadge status={complaint.status} />
      </div>

      <div className="flex flex-wrap items-center justify-between gap-2 pt-3 border-t border-[#E5E7EB]">
        <div className="text-xs">
          <span className="text-[#6B7280]">Pelapor: </span>
          <span className="text-[#1A1F3C] font-medium">
            {complaint.reporter?.full_name ?? '-'}
          </span>
        </div>
        <div className="text-xs text-[#6B7280]">
          {formatDateTime(complaint.created_at)}
        </div>
      </div>
    </Link>
  );
}
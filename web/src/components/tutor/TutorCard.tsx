import { Link } from 'react-router-dom';
import { Clock, BookOpen } from 'lucide-react';
import type { Tutor } from '../../types/tutor';
import {
  getPendingDays,
  getSlaLabel,
  getSlaStatus,
} from '../../types/tutor';
import { VerificationBadge } from './VerificationBadge';

interface Props {
  tutor: Tutor;
}

/**
 * Mapping warna SLA → token baru.
 * - overdue → merah (selaras badge .b-no)
 * - warning → kuning (selaras badge .b-pending)
 * - normal  → netral (soft/mute)
 */
const slaConfig = {
  overdue: {
    bg: 'bg-[#FEE2E2]',
    text: 'text-[#991B1B]',
    border: 'border-[#FCA5A5]',
  },
  warning: {
    bg: 'bg-[#FEF3C7]',
    text: 'text-[#92400E]',
    border: 'border-[#FCD34D]',
  },
  normal: {
    bg: 'bg-[var(--soft)]',
    text: 'text-[var(--mute)]',
    border: 'border-[var(--line)]',
  },
} as const;

export function TutorCard({ tutor }: Props) {
  const slaStatus = getSlaStatus(tutor);
  const slaLabel = getSlaLabel(slaStatus);
  const pendingDays = getPendingDays(tutor);
  const isPending = tutor.verification_status === 'pending';
  const sla = slaConfig[slaStatus];

  return (
    <Link
      to={`/tutors/${tutor.id}`}
      className="card block p-5 hover:shadow-md hover:border-[var(--blue)]/30 transition-all"
    >
      <div className="flex items-start gap-4">
        {/* Avatar */}
        <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-[var(--blue)] to-[#6BB5FF] flex items-center justify-center text-white text-xl font-bold shrink-0">
          {tutor.full_name?.[0]?.toUpperCase() ?? '?'}
        </div>

        {/* Info */}
        <div className="flex-1 min-w-0">
          <div className="flex flex-wrap items-center gap-2 mb-1">
            <h3 className="font-bold text-[var(--ink)] truncate">
              {tutor.full_name}
            </h3>
            <VerificationBadge status={tutor.verification_status} />
            {slaLabel && (
              <span
                className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10.5px] font-bold border ${sla.bg} ${sla.text} ${sla.border}`}
              >
                <Clock size={11} />
                {slaLabel}
              </span>
            )}
          </div>

          <p className="text-sm text-[var(--mute)] truncate">
            {tutor.university ?? 'Belum ada institusi'}
          </p>

          {/* Pending days */}
          {isPending && (
            <p
              className={`text-[11.5px] font-semibold mt-1 ${
                slaStatus === 'overdue'
                  ? 'text-[#991B1B]'
                  : slaStatus === 'warning'
                    ? 'text-[#92400E]'
                    : 'text-[var(--mute)]'
              }`}
            >
              {pendingDays === 0
                ? 'Baru hari ini'
                : `${pendingDays} hari menunggu verifikasi`}
            </p>
          )}

          {tutor.subjects?.length > 0 && (
            <div className="flex flex-wrap gap-1.5 mt-2">
              {tutor.subjects.slice(0, 3).map((s) => (
                <span
                  key={s}
                  className="text-xs px-2 py-0.5 rounded-lg bg-[var(--blue)]/10 text-[var(--blue)] font-semibold inline-flex items-center gap-1"
                >
                  <BookOpen size={11} />
                  {s}
                </span>
              ))}
              {tutor.subjects.length > 3 && (
                <span className="text-xs px-2 py-0.5 text-[var(--mute)]">
                  +{tutor.subjects.length - 3}
                </span>
              )}
            </div>
          )}
        </div>
      </div>
    </Link>
  );
}
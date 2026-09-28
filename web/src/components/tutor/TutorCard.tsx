import { Link } from 'react-router-dom';
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

const slaConfig = {
  overdue: {
    bg: 'bg-primary-red-subtle',
    text: 'text-primary-red',
    border: 'border-primary-red/30',
  },
  warning: {
    bg: 'bg-primary-yellow-subtle',
    text: 'text-primary-yellow',
    border: 'border-primary-yellow/30',
  },
  normal: {
    bg: 'bg-background',
    text: 'text-text-secondary',
    border: 'border-border',
  },
};

export function TutorCard({ tutor }: Props) {
  const slaStatus = getSlaStatus(tutor);
  const slaLabel = getSlaLabel(slaStatus);
  const pendingDays = getPendingDays(tutor);
  const isPending = tutor.verification_status === 'pending';
  const sla = slaConfig[slaStatus];

  return (
    <Link
      to={`/tutors/${tutor.id}`}
      className="block bg-card rounded-2xl p-5 border border-border shadow-sm hover:shadow-md hover:border-primary-blue/30 transition-all"
    >
      <div className="flex items-start gap-4">
        {/* Avatar */}
        <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-primary-blue-dark to-primary-blue-light flex items-center justify-center text-white text-xl font-bold shrink-0">
          {tutor.full_name?.[0]?.toUpperCase() ?? '?'}
        </div>

        {/* Info */}
        <div className="flex-1 min-w-0">
          <div className="flex flex-wrap items-center gap-2 mb-1">
            <h3 className="font-bold text-text-primary truncate">
              {tutor.full_name}
            </h3>
            <VerificationBadge status={tutor.verification_status} />
            {slaLabel && (
              <span
                className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-[10.5px] font-bold border ${sla.bg} ${sla.text} ${sla.border}`}
              >
                ⏱ {slaLabel}
              </span>
            )}
          </div>

          <p className="text-sm text-text-secondary truncate">
            {tutor.university ?? 'Belum ada institusi'}
          </p>

          {/* Pending days */}
          {isPending && (
            <p
              className={`text-[11.5px] font-semibold mt-1 ${
                slaStatus === 'overdue'
                  ? 'text-primary-red'
                  : slaStatus === 'warning'
                    ? 'text-primary-yellow'
                    : 'text-text-light'
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
                  className="text-xs px-2 py-0.5 rounded-lg bg-primary-blue-subtle text-primary-blue font-medium"
                >
                  {s}
                </span>
              ))}
              {tutor.subjects.length > 3 && (
                <span className="text-xs px-2 py-0.5 text-text-secondary">
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
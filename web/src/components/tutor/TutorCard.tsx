import { Link } from 'react-router-dom';
import type { Tutor } from '../../types/tutor';
import { VerificationBadge } from './VerificationBadge';

interface Props {
  tutor: Tutor;
}

export function TutorCard({ tutor }: Props) {
  return (
    <Link
      to={`/tutors/${tutor.id}`}
      className="block bg-white rounded-2xl p-5 border border-[#E5E7EB] hover:shadow-md hover:border-[#1A5EAA]/30 transition-all"
    >
      <div className="flex items-start gap-4">
        {/* Avatar */}
        <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-[#1A5EAA] to-[#6BB5FF] flex items-center justify-center text-white text-xl font-bold shrink-0">
          {tutor.full_name?.[0]?.toUpperCase() ?? '?'}
        </div>

        {/* Info */}
        <div className="flex-1 min-w-0">
          <div className="flex flex-wrap items-center gap-2 mb-1">
            <h3 className="font-bold text-[#1A1F3C] truncate">
              {tutor.full_name}
            </h3>
            <VerificationBadge status={tutor.verification_status} />
          </div>

          <p className="text-sm text-[#6B7280] truncate">
            {tutor.university ?? 'Belum ada institusi'}
          </p>

          {tutor.subjects?.length > 0 && (
            <div className="flex flex-wrap gap-1.5 mt-2">
              {tutor.subjects.slice(0, 3).map((s) => (
                <span
                  key={s}
                  className="text-xs px-2 py-0.5 rounded-lg bg-[#1A5EAA]/10 text-[#1A5EAA] font-medium"
                >
                  {s}
                </span>
              ))}
              {tutor.subjects.length > 3 && (
                <span className="text-xs px-2 py-0.5 text-[#6B7280]">
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
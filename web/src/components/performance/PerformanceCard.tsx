import type { TutorPerformance } from '../../types/performance';
import {
  INACTIVE_DAYS_THRESHOLD,
  CANCEL_RATE_THRESHOLD,
} from '../../types/performance';

interface Props {
  data: TutorPerformance;
}

export function PerformanceCard({ data }: Props) {
  const isInactive =
    data.days_since_last_session === null ||
    data.days_since_last_session >= INACTIVE_DAYS_THRESHOLD;
  const isFrequentCancel = data.cancel_rate > CANCEL_RATE_THRESHOLD;

  return (
    <div className="bg-card rounded-2xl p-5 border border-border shadow-sm hover:shadow-md transition-shadow">
      {/* Header */}
      <div className="flex items-start gap-4 mb-4">
        <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-primary-blue-dark to-primary-blue-light flex items-center justify-center text-white text-xl font-bold shrink-0">
          {data.tutor_name?.[0]?.toUpperCase() ?? '?'}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex flex-wrap items-center gap-2 mb-1">
            <h3 className="font-bold text-text-primary truncate">
              {data.tutor_name}
            </h3>
            {isInactive && (
              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10.5px] font-bold bg-primary-red-subtle text-primary-red border border-primary-red/30">
                ⚠️ Tidak Aktif
              </span>
            )}
            {isFrequentCancel && (
              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10.5px] font-bold bg-primary-yellow-subtle text-primary-yellow border border-primary-yellow/30">
                🚫 Sering Cancel
              </span>
            )}
            {!isInactive && !isFrequentCancel && (
              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10.5px] font-bold bg-online-green-subtle text-online-green border border-online-green/30">
                ✅ Aktif
              </span>
            )}
          </div>
          <p className="text-sm text-text-secondary truncate">
            {data.university ?? 'Belum ada institusi'}
          </p>
        </div>
      </div>

      {/* KPI Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-4">
        <div>
          <p className="text-[11px] text-text-light font-semibold uppercase tracking-wide">
            Sesi Selesai
          </p>
          <p className="text-lg font-bold text-text-primary">
            {data.total_sessions}
          </p>
        </div>
        <div>
          <p className="text-[11px] text-text-light font-semibold uppercase tracking-wide">
            Total Jam
          </p>
          <p className="text-lg font-bold text-text-primary">
            {data.total_hours}j
          </p>
        </div>
        <div>
          <p className="text-[11px] text-text-light font-semibold uppercase tracking-wide">
            Rating
          </p>
          <p className="text-lg font-bold text-primary-yellow">
            ★ {data.avg_rating.toFixed(1)}
          </p>
        </div>
        <div>
          <p className="text-[11px] text-text-light font-semibold uppercase tracking-wide">
            Cancel Rate
          </p>
          <p
            className={`text-lg font-bold ${
              isFrequentCancel ? 'text-primary-red' : 'text-text-primary'
            }`}
          >
            {data.cancel_rate}%
          </p>
        </div>
      </div>

      {/* Footer */}
      <div className="pt-3 border-t border-border flex flex-wrap items-center justify-between gap-2 text-xs">
        <div className="text-text-secondary">
          {data.cancelled_sessions} cancel / {data.total_sessions + data.cancelled_sessions} total
        </div>
        <div
          className={`font-semibold ${
            isInactive ? 'text-primary-red' : 'text-text-secondary'
          }`}
        >
          {data.last_session_date
            ? data.days_since_last_session === 0
              ? 'Ngajar hari ini'
              : `Terakhir ngajar: ${data.days_since_last_session} hari lalu`
            : 'Belum pernah ngajar'}
        </div>
      </div>
    </div>
  );
}
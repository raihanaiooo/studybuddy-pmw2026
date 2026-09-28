export interface TutorPerformance {
  tutor_id: string;
  tutor_name: string;
  avatar_url: string | null;
  university: string | null;
  verification_status: string;

  // KPI
  total_sessions: number;       // booking completed
  cancelled_sessions: number;   // booking cancelled
  total_minutes: number;        // total duration completed
  total_hours: number;          // total_minutes / 60
  avg_rating: number;           // dari tutors.rating
  total_reviews: number;        // dari tutors.total_reviews
  cancel_rate: number;          // cancel / total (%)

  // Activity
  last_session_date: string | null;
  days_since_last_session: number | null;
}

export interface PerformanceStats {
  totalTutors: number;
  activeTutors: number;      // ngajar < 30 hari
  inactiveTutors: number;    // ngajar >= 30 hari
  frequentCancelTutors: number; // cancel rate > 20%
}

// ============================================
// KPI Thresholds
// ============================================

/** Batas "tidak aktif" — 30 hari tanpa ngajar */
export const INACTIVE_DAYS_THRESHOLD = 30;

/** Batas "sering cancel" — 20% cancel rate */
export const CANCEL_RATE_THRESHOLD = 20;

export type PerformanceStatus = 'active' | 'inactive' | 'frequent_cancel';

export function getPerformanceStatus(
  p: TutorPerformance
): PerformanceStatus[] {
  const statuses: PerformanceStatus[] = [];

  if (
    p.days_since_last_session === null ||
    p.days_since_last_session >= INACTIVE_DAYS_THRESHOLD
  ) {
    statuses.push('inactive');
  } else {
    statuses.push('active');
  }

  if (p.cancel_rate > CANCEL_RATE_THRESHOLD) {
    statuses.push('frequent_cancel');
  }

  return statuses;
}
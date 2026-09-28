import { supabase } from '../supabase';
import type {
  TutorPerformance,
  PerformanceStats,
} from '../../types/performance';
import { INACTIVE_DAYS_THRESHOLD, CANCEL_RATE_THRESHOLD } from '../../types/performance';

export async function fetchTutorPerformance(): Promise<TutorPerformance[]> {
  // 1. Ambil semua tutor
  const { data: tutors, error: tutorError } = await supabase
    .from('tutors')
    .select('id, full_name, avatar_url, university, verification_status, rating, total_reviews')
    .eq('verification_status', 'verified');

  if (tutorError) throw tutorError;

  // 2. Ambil semua bookings (completed & cancelled) untuk hitung KPI
  const { data: bookings, error: bookingError } = await supabase
    .from('bookings')
    .select('id, tutor_id, status, duration_minutes, session_time')
    .in('status', ['completed', 'cancelled']);

  if (bookingError) throw bookingError;

  // 3. Group bookings per tutor
  const bookingsByTutor: Record<string, typeof bookings> = {};
  for (const b of bookings ?? []) {
    if (!bookingsByTutor[b.tutor_id]) bookingsByTutor[b.tutor_id] = [];
    bookingsByTutor[b.tutor_id].push(b);
  }

  // 4. Hitung KPI per tutor
  const now = Date.now();
  const results: TutorPerformance[] = [];

  for (const tutor of tutors ?? []) {
    const tutorBookings = bookingsByTutor[tutor.id] ?? [];
    const completed = tutorBookings.filter((b) => b.status === 'completed');
    const cancelled = tutorBookings.filter((b) => b.status === 'cancelled');

    const totalMinutes = completed.reduce(
      (sum, b) => sum + (b.duration_minutes ?? 60),
      0
    );
    const totalSessions = completed.length;
    const totalAll = tutorBookings.length;
    const cancelRate =
      totalAll > 0 ? (cancelled.length / totalAll) * 100 : 0;

    // Cari tanggal sesi terakhir
    let lastSessionDate: string | null = null;
    if (completed.length > 0) {
      const sorted = [...completed].sort(
        (a, b) =>
          new Date(b.session_time).getTime() -
          new Date(a.session_time).getTime()
      );
      lastSessionDate = sorted[0].session_time;
    }

    let daysSinceLast: number | null = null;
    if (lastSessionDate) {
      const diffMs = now - new Date(lastSessionDate).getTime();
      daysSinceLast = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    }

    results.push({
      tutor_id: tutor.id,
      tutor_name: tutor.full_name,
      avatar_url: tutor.avatar_url,
      university: tutor.university,
      verification_status: tutor.verification_status,
      total_sessions: totalSessions,
      cancelled_sessions: cancelled.length,
      total_minutes: totalMinutes,
      total_hours: Math.round((totalMinutes / 60) * 10) / 10,
      avg_rating: Number(tutor.rating ?? 0),
      total_reviews: Number(tutor.total_reviews ?? 0),
      cancel_rate: Math.round(cancelRate * 10) / 10,
      last_session_date: lastSessionDate,
      days_since_last_session: daysSinceLast,
    });
  }

  // 5. Sort: yang perlu perhatian di atas
  results.sort((a, b) => {
    const aStatus = getSortPriority(a);
    const bStatus = getSortPriority(b);
    return aStatus - bStatus;
  });

  return results;
}

/** Prioritas sort: semakin kecil, semakin di atas */
function getSortPriority(p: TutorPerformance): number {
  const isInactive =
    p.days_since_last_session === null ||
    p.days_since_last_session >= INACTIVE_DAYS_THRESHOLD;
  const isFrequentCancel = p.cancel_rate > CANCEL_RATE_THRESHOLD;

  if (isInactive && isFrequentCancel) return 0; // Paling parah
  if (isInactive) return 1;
  if (isFrequentCancel) return 2;
  return 3; // Normal
}

export async function fetchPerformanceStats(): Promise<PerformanceStats> {
  const perf = await fetchTutorPerformance();

  let active = 0;
  let inactive = 0;
  let frequentCancel = 0;

  for (const p of perf) {
    const isInactive =
      p.days_since_last_session === null ||
      p.days_since_last_session >= INACTIVE_DAYS_THRESHOLD;
    const isFrequentCancel = p.cancel_rate > CANCEL_RATE_THRESHOLD;

    if (isInactive) inactive += 1;
    else active += 1;

    if (isFrequentCancel) frequentCancel += 1;
  }

  return {
    totalTutors: perf.length,
    activeTutors: active,
    inactiveTutors: inactive,
    frequentCancelTutors: frequentCancel,
  };
}
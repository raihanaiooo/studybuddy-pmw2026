import { supabase } from '../supabase';
import type {
  Booking,
  BookingWithRelations,
  BookingStatus,
  BookingStats,
} from '../../types/booking';

export async function fetchBookings(
  status?: BookingStatus | 'all'
): Promise<BookingWithRelations[]> {
  let query = supabase
    .from('bookings')
    .select(
      `
      *,
      customer:users!bookings_customer_id_fkey(id, full_name, email),
      tutor:tutors!bookings_tutor_id_fkey(id, full_name, user_id)
    `
    )
    .order('session_time', { ascending: false });

  if (status && status !== 'all') {
    query = query.eq('status', status);
  }

  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as BookingWithRelations[];
}

export async function fetchBookingById(
  id: string
): Promise<BookingWithRelations | null> {
  const { data, error } = await supabase
    .from('bookings')
    .select(
      `
      *,
      customer:users!bookings_customer_id_fkey(id, full_name, email),
      tutor:tutors!bookings_tutor_id_fkey(id, full_name, user_id)
    `
    )
    .eq('id', id)
    .single();

  if (error) throw error;
  return data as BookingWithRelations;
}

export async function fetchBookingStats(): Promise<BookingStats> {
  const { data, error } = await supabase.from('bookings').select('status');
  if (error) throw error;

  const stats: BookingStats = {
    total: data?.length ?? 0,
    pending: 0,
    confirmed: 0,
    ongoing: 0,
    completed: 0,
    cancelled: 0,
  };

  for (const row of data ?? []) {
    const s = row.status as BookingStatus;
    if (s in stats) stats[s] += 1;
  }

  return stats;
}
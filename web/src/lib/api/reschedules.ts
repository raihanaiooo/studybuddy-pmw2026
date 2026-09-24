import { supabase } from '../supabase';
import type {
  RescheduleWithRelations,
  RescheduleStatus,
  RescheduleStats,
} from '../../types/reschedule';

export async function fetchReschedules(
  status?: RescheduleStatus | 'all'
): Promise<RescheduleWithRelations[]> {
  let query = supabase
    .from('reschedules')
    .select(
      `
      *,
      requester:users!reschedules_requested_by_fkey(id, full_name, email),
      reviewer:users!reschedules_reviewed_by_fkey(id, full_name),
      booking:bookings!reschedules_booking_id_fkey(
        id, subject, session_time, customer_id, tutor_id
      )
    `
    )
    .order('created_at', { ascending: false });

  if (status && status !== 'all') {
    query = query.eq('status', status);
  }

  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as RescheduleWithRelations[];
}

export async function fetchRescheduleById(
  id: string
): Promise<RescheduleWithRelations | null> {
  const { data, error } = await supabase
    .from('reschedules')
    .select(
      `
      *,
      requester:users!reschedules_requested_by_fkey(id, full_name, email),
      reviewer:users!reschedules_reviewed_by_fkey(id, full_name),
      booking:bookings!reschedules_booking_id_fkey(
        id, subject, session_time, customer_id, tutor_id
      )
    `
    )
    .eq('id', id)
    .single();

  if (error) throw error;
  return data as RescheduleWithRelations;
}

export async function approveReschedule(
  rescheduleId: string,
  adminNote: string,
  adminId: string
): Promise<void> {
  // 1. Ambil reschedule untuk dapat new_session_time & booking_id
  const { data: reschedule, error: fetchError } = await supabase
    .from('reschedules')
    .select('booking_id, new_session_time')
    .eq('id', rescheduleId)
    .single();

  if (fetchError) throw fetchError;

  // 2. Update status reschedule
  const { error: updateError } = await supabase
    .from('reschedules')
    .update({
      status: 'disetujui',
      admin_note: adminNote || null,
      reviewed_by: adminId,
      reviewed_at: new Date().toISOString(),
    })
    .eq('id', rescheduleId);

  if (updateError) throw updateError;

  // 3. Update booking session_time
  const { error: bookingError } = await supabase
    .from('bookings')
    .update({
      session_time: reschedule.new_session_time,
    })
    .eq('id', reschedule.booking_id);

  if (bookingError) throw bookingError;
}

export async function rejectReschedule(
  rescheduleId: string,
  adminNote: string,
  adminId: string
): Promise<void> {
  const { error } = await supabase
    .from('reschedules')
    .update({
      status: 'ditolak',
      admin_note: adminNote,
      reviewed_by: adminId,
      reviewed_at: new Date().toISOString(),
    })
    .eq('id', rescheduleId);

  if (error) throw error;
}

export async function fetchRescheduleStats(): Promise<RescheduleStats> {
  const { data, error } = await supabase.from('reschedules').select('status');
  if (error) throw error;

  const stats: RescheduleStats = {
    total: data?.length ?? 0,
    pending: 0,
    approved: 0,
    rejected: 0,
  };

  for (const row of data ?? []) {
    if (row.status === 'menunggu_admin') stats.pending += 1;
    else if (row.status === 'disetujui') stats.approved += 1;
    else if (row.status === 'ditolak') stats.rejected += 1;
  }

  return stats;
}
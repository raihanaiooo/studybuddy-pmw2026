import { supabase } from '../supabase';
import type {
  Complaint,
  ComplaintWithRelations,
  ComplaintStatus,
  ComplaintStats,
} from '../../types/complaint';

export async function fetchComplaints(
  status?: ComplaintStatus | 'all'
): Promise<ComplaintWithRelations[]> {
  let query = supabase
    .from('complaints')
    .select(
      `
      *,
      reporter:users!complaints_reporter_id_fkey(id, full_name, email),
      booking:bookings!complaints_booking_id_fkey(
        id, subject, session_time, customer_id, tutor_id
      ),
      handler:users!complaints_handled_by_fkey(id, full_name)
    `
    )
    .order('created_at', { ascending: false });

  if (status && status !== 'all') {
    query = query.eq('status', status);
  }

  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as ComplaintWithRelations[];
}

export async function fetchComplaintById(
  id: string
): Promise<ComplaintWithRelations | null> {
  const { data, error } = await supabase
    .from('complaints')
    .select(
      `
      *,
      reporter:users!complaints_reporter_id_fkey(id, full_name, email),
      booking:bookings!complaints_booking_id_fkey(
        id, subject, session_time, customer_id, tutor_id
      ),
      handler:users!complaints_handled_by_fkey(id, full_name)
    `
    )
    .eq('id', id)
    .single();

  if (error) throw error;
  return data as ComplaintWithRelations;
}

export async function updateComplaintStatus(
  complaintId: string,
  status: ComplaintStatus,
  adminNote: string | null,
  adminId: string
): Promise<void> {
  const { error } = await supabase
    .from('complaints')
    .update({
      status,
      admin_note: adminNote,
      handled_by: adminId,
      handled_at: new Date().toISOString(),
    })
    .eq('id', complaintId);

  if (error) throw error;
}

export async function fetchComplaintStats(): Promise<ComplaintStats> {
  const { data, error } = await supabase.from('complaints').select('status');
  if (error) throw error;

  const stats: ComplaintStats = {
    total: data?.length ?? 0,
    pending: 0,
    in_review: 0,
    resolved: 0,
    rejected: 0,
  };

  for (const row of data ?? []) {
    const s = row.status as ComplaintStatus;
    if (s in stats) stats[s] += 1;
  }

  return stats;
}
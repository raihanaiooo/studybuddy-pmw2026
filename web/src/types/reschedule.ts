export type RescheduleStatus = 'menunggu_admin' | 'disetujui' | 'ditolak';

export type RequestedByRole = 'buddy' | 'tutor';

export interface Reschedule {
  id: string;
  booking_id: string;
  requested_by: string;
  requested_by_role: RequestedByRole;
  reason: string;
  original_session_time: string;
  new_session_time: string;
  status: RescheduleStatus;
  admin_note: string | null;
  reviewed_by: string | null;
  reviewed_at: string | null;
  created_at: string;
}

export interface RescheduleWithRelations extends Reschedule {
  requester?: { id: string; full_name: string; email: string } | null;
  reviewer?: { id: string; full_name: string } | null;
  booking?: {
    id: string;
    subject: string;
    session_time: string;
    customer_id: string;
    tutor_id: string;
  } | null;
}

export interface RescheduleStats {
  total: number;
  pending: number;
  approved: number;
  rejected: number;
}
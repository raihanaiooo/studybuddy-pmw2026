export type BookingStatus =
  | 'pending'
  | 'confirmed'
  | 'ongoing'
  | 'completed'
  | 'cancelled';

export interface Booking {
  id: string;
  customer_id: string;
  tutor_id: string;
  session_time: string;
  duration_minutes: number;
  subject: string;
  session_type: string | null;
  status: BookingStatus;
  notes: string | null;
  created_at: string;
  slot_id: string | null;
  cancelled_at: string | null;
  cancel_reason: string | null;
}

export interface BookingWithRelations extends Booking {
  customer?: { id: string; full_name: string; email: string } | null;
  tutor?: {
    id: string;
    full_name: string;
    user_id: string;
  } | null;
}

export interface BookingStats {
  total: number;
  pending: number;
  confirmed: number;
  ongoing: number;
  completed: number;
  cancelled: number;
}
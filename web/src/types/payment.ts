export type PaymentStatus =
  | 'pending'
  | 'success'
  | 'failed'
  | 'expired'
  | 'refunded';

export interface Payment {
  id: string;
  booking_id: string;
  amount: number;
  method: string;
  status: PaymentStatus;
  external_ref: string | null;
  paid_at: string | null;
  expires_at: string | null;
  created_at: string;
}

export interface PaymentWithRelations extends Payment {
  booking?: {
    id: string;
    subject: string;
    session_time: string;
    customer_id: string;
    tutor_id: string;
  } | null;
}

export interface PaymentStats {
  totalTransactions: number;
  totalRevenue: number;
  pending: number;
  success: number;
  failed: number;
  expired: number;
  refunded: number;
}
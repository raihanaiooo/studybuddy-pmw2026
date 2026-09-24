import { supabase } from '../supabase';
import type {
  Payment,
  PaymentWithRelations,
  PaymentStatus,
  PaymentStats,
} from '../../types/payment';

export async function fetchPayments(
  status?: PaymentStatus | 'all'
): Promise<PaymentWithRelations[]> {
  let query = supabase
    .from('payments')
    .select(
      `
      *,
      booking:bookings!payments_booking_id_fkey(
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
  return (data ?? []) as PaymentWithRelations[];
}

export async function fetchPaymentById(
  id: string
): Promise<PaymentWithRelations | null> {
  const { data, error } = await supabase
    .from('payments')
    .select(
      `
      *,
      booking:bookings!payments_booking_id_fkey(
        id, subject, session_time, customer_id, tutor_id
      )
    `
    )
    .eq('id', id)
    .single();

  if (error) throw error;
  return data as PaymentWithRelations;
}

export async function fetchPaymentStats(): Promise<PaymentStats> {
  const { data, error } = await supabase
    .from('payments')
    .select('status, amount');

  if (error) throw error;

  const stats: PaymentStats = {
    totalTransactions: data?.length ?? 0,
    totalRevenue: 0,
    pending: 0,
    success: 0,
    failed: 0,
    expired: 0,
    refunded: 0,
  };

  for (const row of data ?? []) {
    const s = row.status as PaymentStatus;
    if (s in stats) {
      stats[s] += 1;
    }
    if (s === 'success') {
      stats.totalRevenue += Number(row.amount ?? 0);
    }
  }

  return stats;
}
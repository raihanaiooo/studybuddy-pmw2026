import { supabase } from '../supabase';

export interface OrderRow {
  id: string;
  form_no: string;
  buddy_name: string;
  service_category: string | null;
  service_name: string;
  subject: string | null;
  kind: 'paket' | 'lepas';
  status: 'progress' | 'done' | 'batal';
  sessions_total: number;
  total_price: number;
  ordered_at: string;
  // dari order_summary
  sessions_done: number;
  revenue_total: number;
  paid_total: number;
  payment_status: string | null;
  is_expired: boolean;
}

export async function fetchOrders(): Promise<OrderRow[]> {
  const { data, error } = await supabase
    .from('orders')
    .select('id, form_no, buddy_name, service_category, service_name, subject, kind, status, sessions_total, total_price, ordered_at')
    .is('deleted_at', null)
    .order('ordered_at', { ascending: false });
  if (error) throw error;
  const { data: sums, error: sErr } = await supabase
    .from('order_summary')
    .select('order_id, sessions_done, revenue_total, paid_total, payment_status, is_expired');
  if (sErr) throw sErr;
  const byId = new Map((sums ?? []).map((s: any) => [s.order_id, s]));
  return (data ?? []).map((o: any) => {
    const s: any = byId.get(o.id) ?? {};
    return {
      ...o,
      total_price: Number(o.total_price),
      sessions_done: Number(s.sessions_done ?? 0),
      revenue_total: Number(s.revenue_total ?? 0),
      paid_total: Number(s.paid_total ?? 0),
      payment_status: s.payment_status ?? null,
      is_expired: !!s.is_expired,
    } as OrderRow;
  });
}

export interface OrderDetail {
  order: any;
  summary: any;
  sessions: any[];
  adjustments: any[];
  payments: any[];
}

export async function fetchOrderDetail(id: string): Promise<OrderDetail | null> {
  const { data: order, error } = await supabase.from('orders').select('*').eq('id', id).is('deleted_at', null).maybeSingle();
  if (error) throw error;
  if (!order) return null;
  const [sum, ses, adj, pay] = await Promise.all([
    supabase.from('order_summary').select('*').eq('order_id', id).maybeSingle(),
    supabase.from('order_sessions').select('*, tutors(full_name)').eq('order_id', id).is('deleted_at', null).order('created_at', { ascending: true }),
    supabase.from('order_adjustments').select('*, tutors(full_name)').eq('order_id', id).is('deleted_at', null).order('created_at', { ascending: true }),
    supabase.from('order_payments').select('*').eq('order_id', id).is('deleted_at', null).order('paid_at', { ascending: true }),
  ]);
  for (const r of [sum, ses, adj, pay]) if (r.error) throw r.error;
  return { order, summary: sum.data, sessions: ses.data ?? [], adjustments: adj.data ?? [], payments: pay.data ?? [] };
}

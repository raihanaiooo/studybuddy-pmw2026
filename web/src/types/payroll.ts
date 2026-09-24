export type PayrollStatus = 'pending' | 'paid';

export interface PayrollRecord {
  id: string;
  tutor_id: string;
  period_month: number;
  period_year: number;
  total_sessions: number;
  total_gross: number;
  total_commission: number;
  status: PayrollStatus;
  paid_at: string | null;
  paid_by: string | null;
  notes: string | null;
  created_at: string;
}

export interface PayrollWithRelations extends PayrollRecord {
  tutor?: {
    id: string;
    full_name: string;
    user_id: string;
  } | null;
  payer?: { id: string; full_name: string } | null;
}

export interface SessionEarning {
  booking_id: string;
  session_time: string;
  subject: string;
  amount: number;
  commission: number;
  customer_name: string;
}

export interface PayrollDetail extends PayrollWithRelations {
  sessions: SessionEarning[];
}

export interface PayrollStats {
  total: number;
  pending: number;
  paid: number;
  pendingAmount: number;
  paidAmount: number;
}

export const MONTH_NAMES = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

export function formatPeriod(month: number, year: number): string {
  return `${MONTH_NAMES[month - 1]} ${year}`;
}

export const COMMISSION_RATE = 0.7; // 70% untuk Tutor
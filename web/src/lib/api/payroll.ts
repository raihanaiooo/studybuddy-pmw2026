import { supabase } from '../supabase';
import type {
  PayrollWithRelations,
  PayrollDetail,
  PayrollStats,
  PayrollStatus,
  SessionEarning,
} from '../../types/payroll';
import { COMMISSION_RATE } from '../../types/payroll';

export async function fetchPayrolls(
  status?: PayrollStatus | 'all'
): Promise<PayrollWithRelations[]> {
  let query = supabase
    .from('payroll_records')
    .select(
      `
      *,
      tutor:tutors!payroll_records_tutor_id_fkey(id, full_name, user_id),
      payer:users!payroll_records_paid_by_fkey(id, full_name)
    `
    )
    .order('period_year', { ascending: false })
    .order('period_month', { ascending: false })
    .order('created_at', { ascending: false });

  if (status && status !== 'all') {
    query = query.eq('status', status);
  }

  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as PayrollWithRelations[];
}

export async function fetchPayrollById(
  id: string
): Promise<PayrollDetail | null> {
  const { data, error } = await supabase
    .from('payroll_records')
    .select(
      `
      *,
      tutor:tutors!payroll_records_tutor_id_fkey(id, full_name, user_id),
      payer:users!payroll_records_paid_by_fkey(id, full_name)
    `
    )
    .eq('id', id)
    .single();

  if (error) throw error;
  if (!data) return null;

  // Ambil detail sesi untuk periode ini
  const sessions = await fetchPayrollSessions(
    data.tutor_id,
    data.period_month,
    data.period_year
  );

  return { ...data, sessions } as PayrollDetail;
}

/**
 * Ambil detail sesi (completed + paid) dalam periode tertentu untuk Tutor.
 */
export async function fetchPayrollSessions(
  tutorId: string,
  month: number,
  year: number
): Promise<SessionEarning[]> {
  // Range tanggal
  const startDate = new Date(year, month - 1, 1).toISOString();
  const endDate = new Date(year, month, 1).toISOString();

  const { data, error } = await supabase
    .from('bookings')
    .select(
      `
      id,
      session_time,
      subject,
      status,
      customer:users!bookings_customer_id_fkey(full_name),
      payment:payments!payments_booking_id_fkey(amount, status)
    `
    )
    .eq('tutor_id', tutorId)
    .eq('status', 'completed')
    .gte('session_time', startDate)
    .lt('session_time', endDate)
    .order('session_time', { ascending: true });

  if (error) throw error;

  // Filter yang payment success + map ke SessionEarning
  return (data ?? [])
    .filter((row: any) => row.payment?.[0]?.status === 'success')
    .map((row: any) => {
      const amount = Number(row.payment?.[0]?.amount ?? 0);
      return {
        booking_id: row.id,
        session_time: row.session_time,
        subject: row.subject,
        amount,
        commission: amount * COMMISSION_RATE,
        customer_name: row.customer?.full_name ?? '-',
      };
    });
}

/**
 * Generate payroll records untuk semua Tutor untuk periode tertentu.
 * Kalau record sudah ada, skip (unique constraint).
 */
export async function generatePayroll(
  month: number,
  year: number
): Promise<{ created: number; skipped: number }> {
  // Ambil semua tutor terverifikasi
  const { data: tutors, error: tutorError } = await supabase
    .from('tutors')
    .select('id, full_name')
    .eq('verification_status', 'verified');

  if (tutorError) throw tutorError;

  let created = 0;
  let skipped = 0;

  for (const tutor of tutors ?? []) {
    const sessions = await fetchPayrollSessions(tutor.id, month, year);
    if (sessions.length === 0) {
      skipped += 1;
      continue;
    }

    const totalGross = sessions.reduce((sum, s) => sum + s.amount, 0);
    const totalCommission = sessions.reduce((sum, s) => sum + s.commission, 0);

    const { error: insertError } = await supabase
      .from('payroll_records')
      .insert({
        tutor_id: tutor.id,
        period_month: month,
        period_year: year,
        total_sessions: sessions.length,
        total_gross: totalGross,
        total_commission: totalCommission,
        status: 'pending',
      });

    if (insertError) {
      // Skip kalau duplikat (unique constraint)
      if (insertError.code === '23505') {
        skipped += 1;
        continue;
      }
      throw insertError;
    }

    created += 1;
  }

  return { created, skipped };
}

export async function markPayrollPaid(
  payrollId: string,
  adminId: string,
  notes?: string
): Promise<void> {
  const { error } = await supabase
    .from('payroll_records')
    .update({
      status: 'paid',
      paid_at: new Date().toISOString(),
      paid_by: adminId,
      notes: notes ?? null,
    })
    .eq('id', payrollId);

  if (error) throw error;
}

export async function fetchPayrollStats(): Promise<PayrollStats> {
  const { data, error } = await supabase
    .from('payroll_records')
    .select('status, total_commission');

  if (error) throw error;

  const stats: PayrollStats = {
    total: data?.length ?? 0,
    pending: 0,
    paid: 0,
    pendingAmount: 0,
    paidAmount: 0,
  };

  for (const row of data ?? []) {
    const commission = Number(row.total_commission ?? 0);
    if (row.status === 'pending') {
      stats.pending += 1;
      stats.pendingAmount += commission;
    } else if (row.status === 'paid') {
      stats.paid += 1;
      stats.paidAmount += commission;
    }
  }

  return stats;
}

/**
 * Export data payroll ke CSV.
 */
export function exportPayrollsToCSV(payrolls: PayrollWithRelations[]): void {
  const headers = [
    'Tutor',
    'Periode',
    'Total Sesi',
    'Total Bruto',
    'Komisi (70%)',
    'Status',
    'Tanggal Bayar',
  ];

  const rows = payrolls.map((p) => [
    p.tutor?.full_name ?? '-',
    `${p.period_month}/${p.period_year}`,
    p.total_sessions,
    p.total_gross,
    p.total_commission,
    p.status === 'paid' ? 'Sudah Dibayar' : 'Belum Dibayar',
    p.paid_at ? new Date(p.paid_at).toLocaleDateString('id-ID') : '-',
  ]);

  const csvContent = [
    headers.join(','),
    ...rows.map((r) =>
      r.map((c) => `"${String(c).replace(/"/g, '""')}"`).join(',')
    ),
  ].join('\n');

  const blob = new Blob(['\ufeff' + csvContent], {
    type: 'text/csv;charset=utf-8;',
  });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `payroll-${new Date().toISOString().slice(0, 10)}.csv`;
  link.click();
  URL.revokeObjectURL(url);
}
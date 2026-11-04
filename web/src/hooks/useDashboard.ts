import { useCallback, useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import type { PaymentStatus } from '../types/payment';

export interface DashboardStats {
  totalRevenue: number;
  totalBuddies: number;
  totalTutors: number;
  totalTransactions: number;
}

export interface RecentPayment {
  id: string;
  amount: number;
  method: string;
  status: PaymentStatus;
  created_at: string;
  booking?: {
    subject: string | null;
    customer?: { full_name: string } | null;
  } | null;
}

const emptyStats: DashboardStats = {
  totalRevenue: 0,
  totalBuddies: 0,
  totalTutors: 0,
  totalTransactions: 0,
};

export function useDashboard() {
  const [stats, setStats] = useState<DashboardStats>(emptyStats);
  const [recentPayments, setRecentPayments] = useState<RecentPayment[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setError(null);
    try {
      // Semua query jalan paralel: pendapatan, buddy, tutor, transaksi, 5 terakhir
      const [revenueRes, buddyRes, tutorRes, trxRes, recentRes] = await Promise.all([
        // Total pendapatan: sum amount payments yang status-nya success
        supabase.from('payments').select('amount').eq('status', 'success'),
        // Total Buddy/Siswa: count users role 'buddy' atau 'customer'
        supabase
          .from('users')
          .select('id', { count: 'exact', head: true })
          .in('role', ['buddy', 'customer']),
        // Total Tutor terverifikasi
        supabase
          .from('tutors')
          .select('id', { count: 'exact', head: true })
          .eq('verification_status', 'verified'),
        // Total semua transaksi
        supabase.from('payments').select('id', { count: 'exact', head: true }),
        // 5 transaksi terakhir + nama buddy & mapel
        supabase
          .from('payments')
          .select(
            `id, amount, method, status, created_at,
            booking:bookings!payments_booking_id_fkey(
              subject,
              customer:users!bookings_customer_id_fkey(full_name)
            )`
          )
          .order('created_at', { ascending: false })
          .limit(5),
      ]);

      // Propagasi error dari salah satu query
      const firstError =
        revenueRes.error || buddyRes.error || tutorRes.error || trxRes.error || recentRes.error;
      if (firstError) throw firstError;

      const totalRevenue = (revenueRes.data ?? []).reduce(
        (sum, r) => sum + Number(r.amount ?? 0),
        0
      );

      setStats({
        totalRevenue,
        totalBuddies: buddyRes.count ?? 0,
        totalTutors: tutorRes.count ?? 0,
        totalTransactions: trxRes.count ?? 0,
      });
      setRecentPayments((recentRes.data ?? []) as unknown as RecentPayment[]);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();

    // Real-time: refetch otomatis setiap ada perubahan di tabel payments.
    // (Aktifkan table repilcation 'payments' di Dashboard Supabase agar berfungsi.)
    const channel = supabase
      .channel('dashboard-payments')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'payments' },
        () => {
          load();
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [load]);

  return { stats, recentPayments, loading, error, reload: load };
}

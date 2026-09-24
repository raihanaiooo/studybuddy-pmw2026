import { useEffect, useState } from 'react';
import { StatCard } from '../components/ui/StatCard';
import { supabase } from '../lib/supabase';
import type { AdminStats } from '../types';

export function DashboardPage() {
  const [stats, setStats] = useState<AdminStats>({
    totalBookings: 0,
    totalRevenue: 0,
    totalTutors: 0,
    totalBuddies: 0,
    pendingVerifications: 0,
    pendingReschedules: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadStats() {
      try {
        const [bookings, tutors, buddies, pendingTutors, pendingResch, payments] =
          await Promise.all([
            supabase.from('bookings').select('*', { count: 'exact', head: true }),
            supabase
              .from('tutors')
              .select('*', { count: 'exact', head: true })
              .eq('verification_status', 'verified'),
            supabase
              .from('users')
              .select('*', { count: 'exact', head: true })
              .eq('role', 'buddy'),
            supabase
              .from('tutors')
              .select('*', { count: 'exact', head: true })
              .eq('verification_status', 'pending'),
            supabase
              .from('reschedules')
              .select('*', { count: 'exact', head: true })
              .eq('status', 'menunggu_admin'),
            supabase.from('payments').select('amount').eq('status', 'success'),
          ]);

        const revenue =
          payments.data?.reduce((sum, p) => sum + Number(p.amount ?? 0), 0) ?? 0;

        setStats({
          totalBookings: bookings.count ?? 0,
          totalTutors: tutors.count ?? 0,
          totalBuddies: buddies.count ?? 0,
          pendingVerifications: pendingTutors.count ?? 0,
          pendingReschedules: pendingResch.count ?? 0,
          totalRevenue: revenue,
        });
      } catch (e) {
        console.error('Failed to load stats', e);
      } finally {
        setLoading(false);
      }
    }

    loadStats();
  }, []);

  const formatRupiah = (n: number) =>
    `Rp${n.toLocaleString('id-ID')}`;

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="w-10 h-10 border-4 border-[#1A5EAA] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[#1A1F3C]">Dashboard</h1>
        <p className="text-sm text-[#6B7280] mt-1">
          Ringkasan aktivitas Study Buddy
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <StatCard
          label="Total Booking"
          value={stats.totalBookings}
          icon="📅"
          color="blue"
        />
        <StatCard
          label="Total Pendapatan"
          value={formatRupiah(stats.totalRevenue)}
          icon="💰"
          color="green"
        />
        <StatCard
          label="Tutor Terverifikasi"
          value={stats.totalTutors}
          icon="👨‍🏫"
          color="teal"
        />
        <StatCard
          label="Total Buddy"
          value={stats.totalBuddies}
          icon="🎓"
          color="blue"
        />
      </div>

      {/* Action Required */}
      <div>
        <h2 className="text-lg font-bold text-[#1A1F3C] mb-3">
          Perlu Tindakan
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <StatCard
            label="Tutor Menunggu Verifikasi"
            value={stats.pendingVerifications}
            icon="⏳"
            color="yellow"
            subtitle="Perlu ditinjau"
          />
          <StatCard
            label="Reschedule Menunggu Approval"
            value={stats.pendingReschedules}
            icon="🔄"
            color="red"
            subtitle="Perlu disetujui"
          />
        </div>
      </div>
    </div>
  );
}
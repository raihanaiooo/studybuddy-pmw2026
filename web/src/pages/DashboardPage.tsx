import { useEffect, useState } from 'react';
import { PageHeader } from '../components/ui/PageHeader';
import { StatCard } from '../components/ui/StatCard';
import { ShoppingCart, GraduationCap, Users, Wallet } from 'lucide-react';

export function DashboardPage() {
  const [stats, setStats] = useState({ orders: 0, tutors: 0, users: 0, revenue: 0 });

  useEffect(() => {
    // Nanti ganti pakai data asli dari Supabase
    setStats({ orders: 7, tutors: 5, users: 25, revenue: 1500000 });
  }, []);

  return (
    <div>
      <PageHeader title="Dashboard" subtitle="Ringkasan aktivitas Study Buddy hari ini." />

      {/* 4 Card Statistik */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard label="Total Orderan" value={stats.orders} icon={<ShoppingCart size={20} strokeWidth={2.5} />} color="blue" />
        <StatCard label="Tutor Terverifikasi" value={stats.tutors} icon={<GraduationCap size={20} strokeWidth={2.5} />} color="green" />
        <StatCard label="Total Pengguna" value={stats.users} icon={<Users size={20} strokeWidth={2.5} />} color="yellow" />
        <StatCard label="Pendapatan" value={`Rp${stats.revenue.toLocaleString('id-ID')}`} icon={<Wallet size={20} strokeWidth={2.5} />} color="blue" />
      </div>

      {/* Tabel Orderan Terbaru */}
      <div className="flex justify-between items-end mb-3">
        <h2 className="text-lg font-bold text-[var(--ink)]">Orderan Terbaru</h2>
        <a href="/orders" className="text-sm font-bold text-[var(--blue)] hover:underline">Lihat Semua</a>
      </div>

      <div className="card overflow-hidden">
        <div className="overflow-x-auto">
          <table>
            <thead>
              <tr>
                <th>Nama Siswa</th>
                <th>Mapel</th>
                <th>Tanggal</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>
                  <div className="flex items-center gap-3">
                    <span className="w-8 h-8 rounded-full bg-[var(--blue)] text-white grid place-items-center font-bold text-xs">RP</span>
                    <b>Rani Putri</b>
                  </div>
                </td>
                <td>Matematika SMA</td>
                <td className="text-[var(--mute)]">03 Nov 2026</td>
                <td><span className="badge b-pending"><i></i>Pending</span></td>
              </tr>
              <tr>
                <td>
                  <div className="flex items-center gap-3">
                    <span className="w-8 h-8 rounded-full bg-[var(--blue)] text-white grid place-items-center font-bold text-xs">FN</span>
                    <b>Fajar Nugroho</b>
                  </div>
                </td>
                <td>Fisika SMA</td>
                <td className="text-[var(--mute)]">03 Nov 2026</td>
                <td><span className="badge b-fu"><i></i>Follow Up</span></td>
              </tr>
              <tr>
                <td>
                  <div className="flex items-center gap-3">
                    <span className="w-8 h-8 rounded-full bg-[var(--blue)] text-white grid place-items-center font-bold text-xs">SM</span>
                    <b>Salsa Maharani</b>
                  </div>
                </td>
                <td>Kimia SMA</td>
                <td className="text-[var(--mute)]">01 Nov 2026</td>
                <td><span className="badge b-done"><i></i>Done</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
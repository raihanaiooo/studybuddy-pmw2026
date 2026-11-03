import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { PageHeader } from '../components/ui/PageHeader';
import { ArrowLeft, User, GraduationCap, Calendar, Clock, FileText } from 'lucide-react';

export function BookingDetailPage() {
  const { id } = useParams();
  const [booking, setBooking] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchBooking = async () => {
      const { data } = await supabase
        .from('bookings')
        .select(`*, customer:users!bookings_customer_id_fkey(full_name, email), tutor:tutors!bookings_tutor_id_fkey(full_name, university)`)
        .eq('id', id)
        .single();
      if (data) setBooking(data);
      setLoading(false);
    };
    fetchBooking();
  }, [id]);

  if (loading) return <div className="p-10 text-center text-[var(--mute)]">Memuat data...</div>;
  if (!booking) return <div className="p-10 text-center text-red-500">Booking tidak ditemukan.</div>;

  const getBadge = (status: string) => {
    switch (status) {
      case 'pending': return <span className="badge b-pending"><i></i>Menunggu</span>;
      case 'confirmed': return <span className="badge b-fu"><i></i>Dikonfirmasi</span>;
      case 'ongoing': return <span className="badge b-fu"><i></i>Berlangsung</span>;
      case 'completed': return <span className="badge b-done"><i></i>Selesai</span>;
      case 'cancelled': return <span className="badge b-no"><i></i>Dibatalkan</span>;
      default: return <span className="badge b-no">{status}</span>;
    }
  };

  return (
    <div>
      <Link to="/bookings" className="inline-flex items-center gap-2 text-sm font-bold text-[var(--mute)] hover:text-[var(--blue)] mb-4 transition-colors">
        <ArrowLeft size={16} /> Kembali ke Daftar Booking
      </Link>

      <PageHeader
        title="Detail Booking"
        subtitle={`ID: ${booking.id}`}
        action={getBadge(booking.status)}
      />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Kolom Kiri: Info Utama */}
        <div className="lg:col-span-2 space-y-6">
          <div className="card p-6">
            <h2 className="text-lg font-bold mb-4 text-[var(--ink)] border-b border-[var(--line)] pb-3">Informasi Sesi</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-[var(--mute)] mb-1">Mata Pelajaran</p>
                <p className="font-bold text-[var(--ink)] flex items-center gap-2"><FileText size={16} /> {booking.subject}</p>
              </div>
              <div>
                <p className="text-sm text-[var(--mute)] mb-1">Jadwal</p>
                <p className="font-bold text-[var(--ink)] flex items-center gap-2">
                  <Calendar size={16} />
                  {new Date(booking.session_time).toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
                </p>
                <p className="text-sm text-[var(--mute)] mt-1 flex items-center gap-2">
                  <Clock size={16} />
                  {new Date(booking.session_time).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' })} WIB ({booking.duration_minutes} menit)
                </p>
              </div>
            </div>
          </div>

          <div className="card p-6">
            <h2 className="text-lg font-bold mb-4 text-[var(--ink)] border-b border-[var(--line)] pb-3">Catatan Tambahan</h2>
            <p className="text-[var(--ink)] text-sm leading-relaxed">
              {booking.notes || <span className="text-[var(--mute)] italic">Tidak ada catatan.</span>}
            </p>
          </div>
        </div>

        {/* Kolom Kanan: Info Peserta */}
        <div className="space-y-6">
          <div className="card p-6">
            <h2 className="text-lg font-bold mb-4 text-[var(--ink)] border-b border-[var(--line)] pb-3">Buddy</h2>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-[var(--blue)] text-white flex items-center justify-center">
                <User size={20} />
              </div>
              <div>
                <p className="font-bold text-[var(--ink)]">{booking.customer?.full_name}</p>
                <p className="text-sm text-[var(--mute)]">{booking.customer?.email}</p>
              </div>
            </div>
          </div>

          <div className="card p-6">
            <h2 className="text-lg font-bold mb-4 text-[var(--ink)] border-b border-[var(--line)] pb-3">Tutor</h2>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-[var(--ink)] text-white flex items-center justify-center">
                <GraduationCap size={20} />
              </div>
              <div>
                <p className="font-bold text-[var(--ink)]">{booking.tutor?.full_name}</p>
                <p className="text-sm text-[var(--mute)]">{booking.tutor?.university || '-'}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
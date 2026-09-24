import { Link, useParams } from 'react-router-dom';
import { useBookingDetail } from '../hooks/useBookingDetail';
import { BookingStatusBadge } from '../components/booking/BookingStatusBadge';

function formatDateTime(iso: string) {
  const d = new Date(iso);
  return d.toLocaleString('id-ID', {
    weekday: 'long',
    day: '2-digit',
    month: 'long',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

export function BookingDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { booking, loading, error } = useBookingDetail(id);

  if (loading) {
    return (
      <div className="flex justify-center py-20">
        <div className="w-10 h-10 border-4 border-[#1A5EAA] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !booking) {
    return (
      <div className="bg-white rounded-2xl p-8 text-center border border-[#E5E7EB]">
        <p className="text-[#E53935] mb-4">{error ?? 'Booking tidak ditemukan'}</p>
        <Link
          to="/bookings"
          className="inline-block bg-[#1A5EAA] text-white px-5 py-2.5 rounded-xl font-semibold hover:bg-[#154A87]"
        >
          Kembali
        </Link>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <Link
          to="/bookings"
          className="text-sm text-[#1A5EAA] hover:underline font-medium inline-flex items-center gap-1 mb-3"
        >
          ← Kembali ke daftar Booking
        </Link>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h1 className="text-2xl font-bold text-[#1A1F3C]">
              {booking.subject}
            </h1>
            <p className="text-sm text-[#6B7280] mt-1">ID: {booking.id}</p>
          </div>
          <BookingStatusBadge status={booking.status} />
        </div>
      </div>

      {/* Info Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Jadwal */}
        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
          <h2 className="font-bold text-[#1A1F3C] mb-3">Jadwal</h2>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Waktu</span>
              <span className="text-[#1A1F3C] font-medium text-right">
                {formatDateTime(booking.session_time)}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Durasi</span>
              <span className="text-[#1A1F3C] font-medium">
                {booking.duration_minutes} menit
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Tipe</span>
              <span className="text-[#1A1F3C] font-medium capitalize">
                {booking.session_type ?? '-'}
              </span>
            </div>
          </div>
        </div>

        {/* Peserta */}
        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
          <h2 className="font-bold text-[#1A1F3C] mb-3">Peserta</h2>
          <div className="space-y-3 text-sm">
            <div>
              <p className="text-xs text-[#6B7280] mb-1">Buddy</p>
              <p className="text-[#1A1F3C] font-medium">
                {booking.customer?.full_name ?? '-'}
              </p>
              <p className="text-xs text-[#9CA3AF]">
                {booking.customer?.email ?? '-'}
              </p>
            </div>
            <div>
              <p className="text-xs text-[#6B7280] mb-1">Tutor</p>
              <p className="text-[#1A1F3C] font-medium">
                {booking.tutor?.full_name ?? '-'}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Notes */}
      {booking.notes && (
        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
          <h2 className="font-bold text-[#1A1F3C] mb-2">Catatan</h2>
          <p className="text-sm text-[#1A1F3C]">{booking.notes}</p>
        </div>
      )}

      {/* Cancel info */}
      {booking.status === 'cancelled' && (
        <div className="bg-[#E53935]/10 border border-[#E53935]/30 rounded-2xl p-5">
          <h2 className="font-bold text-[#E53935] mb-2">Booking Dibatalkan</h2>
          {booking.cancel_reason && (
            <p className="text-sm text-[#1A1F3C] mb-1">
              <strong>Alasan:</strong> {booking.cancel_reason}
            </p>
          )}
          {booking.cancelled_at && (
            <p className="text-xs text-[#6B7280]">
              Dibatalkan: {formatDateTime(booking.cancelled_at)}
            </p>
          )}
        </div>
      )}
    </div>
  );
}
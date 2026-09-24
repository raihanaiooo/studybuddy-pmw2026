import { Link, useParams } from 'react-router-dom';
import { usePaymentDetail } from '../hooks/usePaymentDetail';
import { PaymentStatusBadge } from '../components/payment/PaymentStatusBadge';

function formatRupiah(n: number) {
  return `Rp${n.toLocaleString('id-ID')}`;
}

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

export function PaymentDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { payment, loading, error } = usePaymentDetail(id);

  if (loading) {
    return (
      <div className="flex justify-center py-20">
        <div className="w-10 h-10 border-4 border-[#1A5EAA] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !payment) {
    return (
      <div className="bg-white rounded-2xl p-8 text-center border border-[#E5E7EB]">
        <p className="text-[#E53935] mb-4">
          {error ?? 'Transaksi tidak ditemukan'}
        </p>
        <Link
          to="/payments"
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
          to="/payments"
          className="text-sm text-[#1A5EAA] hover:underline font-medium inline-flex items-center gap-1 mb-3"
        >
          ← Kembali ke daftar Transaksi
        </Link>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h1 className="text-2xl font-bold text-[#1A1F3C]">
              Detail Transaksi
            </h1>
            <p className="text-sm text-[#6B7280] mt-1">ID: {payment.id}</p>
          </div>
          <PaymentStatusBadge status={payment.status} />
        </div>
      </div>

      {/* Amount Card */}
      <div className="bg-gradient-to-br from-[#1A5EAA] to-[#6BB5FF] rounded-2xl p-6 text-white">
        <p className="text-sm opacity-90 mb-1">Total Pembayaran</p>
        <p className="text-3xl font-bold">{formatRupiah(payment.amount)}</p>
      </div>

      {/* Info Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
          <h2 className="font-bold text-[#1A1F3C] mb-3">Informasi Transaksi</h2>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Metode</span>
              <span className="text-[#1A1F3C] font-medium uppercase">
                {payment.method}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Ref Eksternal</span>
              <span className="text-[#1A1F3C] font-medium text-right">
                {payment.external_ref ?? '-'}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Dibuat</span>
              <span className="text-[#1A1F3C] font-medium text-right">
                {formatDateTime(payment.created_at)}
              </span>
            </div>
            {payment.paid_at && (
              <div className="flex justify-between gap-3">
                <span className="text-[#6B7280]">Dibayar</span>
                <span className="text-[#1A1F3C] font-medium text-right">
                  {formatDateTime(payment.paid_at)}
                </span>
              </div>
            )}
            {payment.expires_at && (
              <div className="flex justify-between gap-3">
                <span className="text-[#6B7280]">Kedaluwarsa</span>
                <span className="text-[#1A1F3C] font-medium text-right">
                  {formatDateTime(payment.expires_at)}
                </span>
              </div>
            )}
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
          <h2 className="font-bold text-[#1A1F3C] mb-3">Booking Terkait</h2>
          {payment.booking ? (
            <div className="space-y-2 text-sm">
              <div className="flex justify-between gap-3">
                <span className="text-[#6B7280]">Mapel</span>
                <span className="text-[#1A1F3C] font-medium text-right">
                  {payment.booking.subject}
                </span>
              </div>
              <div className="flex justify-between gap-3">
                <span className="text-[#6B7280]">Jadwal</span>
                <span className="text-[#1A1F3C] font-medium text-right">
                  {formatDateTime(payment.booking.session_time)}
                </span>
              </div>
              <Link
                to={`/bookings/${payment.booking.id}`}
                className="inline-block mt-3 text-sm text-[#1A5EAA] hover:underline font-medium"
              >
                Lihat Booking →
              </Link>
            </div>
          ) : (
            <p className="text-sm text-[#9CA3AF]">Booking tidak ditemukan</p>
          )}
        </div>
      </div>
    </div>
  );
}
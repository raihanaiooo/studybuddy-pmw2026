import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { supabase } from '../../lib/supabase';
import { ArrowLeft, CreditCard, Calendar, User, Hash } from 'lucide-react';

export function PaymentDetailPage() {
  const { id } = useParams();
  const [payment, setPayment] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchPayment = async () => {
      const { data } = await supabase
        .from('payments')
        .select(`*, booking:bookings!payments_booking_id_fkey(subject, customer:users!bookings_customer_id_fkey(full_name))`)
        .eq('id', id)
        .single();
      if (data) setPayment(data);
      setLoading(false);
    };
    fetchPayment();
  }, [id]);

  if (loading) return <div className="p-10 text-center text-[var(--mute)]">Memuat data...</div>;
  if (!payment) return <div className="p-10 text-center text-red-500">Transaksi tidak ditemukan.</div>;

  const getBadge = (status: string) => {
    switch (status) {
      case 'pending': return <span className="badge b-pending"><i></i>Pending</span>;
      case 'success': return <span className="badge b-done"><i></i>Berhasil</span>;
      case 'failed': return <span className="badge b-no"><i></i>Gagal</span>;
      case 'expired': return <span className="badge b-no"><i></i>Kedaluwarsa</span>;
      case 'refunded': return <span className="badge b-fu"><i></i>Refund</span>;
      default: return <span className="badge b-no">{status}</span>;
    }
  };

  return (
    <div>
      <Link to="/payments" className="inline-flex items-center gap-2 text-sm font-bold text-[var(--mute)] hover:text-[var(--blue)] mb-4 transition-colors">
        <ArrowLeft size={16} /> Kembali ke Daftar Transaksi
      </Link>

      <div className="max-w-3xl mx-auto">
        <div className="card p-8 text-center mb-6 relative overflow-hidden">
          <div className="absolute top-0 left-0 w-full h-1 bg-[var(--blue)]"></div>
          <p className="text-[var(--mute)] font-semibold mb-2">Total Pembayaran</p>
          <h1 className="text-4xl font-extrabold text-[var(--blue)] mb-4">
            Rp{payment.amount?.toLocaleString('id-ID')}
          </h1>
          <div>{getBadge(payment.status)}</div>
        </div>

        <div className="card p-6">
          <h2 className="text-lg font-bold mb-4 text-[var(--ink)] border-b border-[var(--line)] pb-3">Rincian Transaksi</h2>
          <div className="space-y-4">
            <div className="flex justify-between items-center py-2">
              <span className="text-[var(--mute)] flex items-center gap-2"><Hash size={16} /> ID Transaksi</span>
              <span className="font-mono text-sm font-semibold">{payment.id}</span>
            </div>
            <div className="flex justify-between items-center py-2 border-t border-[var(--line)]">
              <span className="text-[var(--mute)] flex items-center gap-2"><User size={16} /> Nama Buddy</span>
              <span className="font-semibold">{payment.booking?.customer?.full_name || '-'}</span>
            </div>
            <div className="flex justify-between items-center py-2 border-t border-[var(--line)]">
              <span className="text-[var(--mute)] flex items-center gap-2"><CreditCard size={16} /> Metode Pembayaran</span>
              <span className="font-semibold uppercase">{payment.method}</span>
            </div>
            <div className="flex justify-between items-center py-2 border-t border-[var(--line)]">
              <span className="text-[var(--mute)] flex items-center gap-2"><Calendar size={16} /> Waktu Transaksi</span>
              <span className="font-semibold">
                {new Date(payment.created_at).toLocaleString('id-ID', { dateStyle: 'medium', timeStyle: 'short' })}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
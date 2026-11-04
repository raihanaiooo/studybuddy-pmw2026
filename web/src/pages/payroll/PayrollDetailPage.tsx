import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import {
  ArrowLeft,
  Printer,
  CheckCircle2,
  BookOpen,
  AlertCircle,
  Loader2,
} from 'lucide-react';
import { usePayrollDetail } from '../../hooks/usePayrollDetail';
import { PayrollStatusBadge } from '../../components/payroll/PayrollStatusBadge';
import { formatPeriod } from '../../types/payroll';

function formatRupiah(n: number) {
  return `Rp${n.toLocaleString('id-ID')}`;
}

function formatDateTime(iso: string) {
  const d = new Date(iso);
  return d.toLocaleString('id-ID', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

function formatDate(iso: string) {
  const d = new Date(iso);
  return d.toLocaleDateString('id-ID', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

export function PayrollDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { payroll, loading, updating, error, markPaid } = usePayrollDetail(id);
  const [showConfirm, setShowConfirm] = useState(false);
  const [notes, setNotes] = useState('');

  async function handleMarkPaid() {
    await markPaid(notes);
    setShowConfirm(false);
    setNotes('');
  }

  function handlePrint() {
    window.print();
  }

  if (loading) {
    return (
      <div className="flex justify-center py-20">
        <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !payroll) {
    return (
      <div className="card p-8 text-center">
        <AlertCircle
          size={40}
          className="mx-auto text-[#991B1B] mb-3"
        />
        <p className="text-[#991B1B] mb-4">
          {error ?? 'Payroll tidak ditemukan'}
        </p>
        <Link to="/payroll" className="btn btn-p inline-flex">
          <ArrowLeft size={16} />
          Kembali
        </Link>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header — hidden saat print */}
      <div className="print:hidden">
        <Link
          to="/payroll"
          className="text-sm text-[var(--blue)] hover:underline font-semibold inline-flex items-center gap-1 mb-3"
        >
          <ArrowLeft size={16} />
          Kembali ke daftar Payroll
        </Link>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h1 className="text-2xl font-extrabold text-[var(--ink)]">
              Slip Gaji Tutor
            </h1>
            <p className="text-sm text-[var(--mute)] mt-1">
              {formatPeriod(payroll.period_month, payroll.period_year)}
            </p>
          </div>
          <div className="flex gap-2">
            <button onClick={handlePrint} className="btn">
              <Printer size={16} />
              Cetak
            </button>
            {payroll.status === 'pending' && (
              <button
                onClick={() => setShowConfirm(true)}
                disabled={updating}
                className="btn btn-p disabled:opacity-50 disabled:cursor-not-allowed"
                style={{ background: '#00C853', borderColor: '#00C853' }}
              >
                <CheckCircle2 size={16} />
                Tandai Sudah Dibayar
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Slip Content */}
      <div className="card p-6 lg:p-8 print:border-0 print:shadow-none">
        {/* Slip Header */}
        <div className="flex flex-wrap items-start justify-between gap-3 pb-4 border-b-2 border-[var(--blue)]">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[var(--blue)] to-[#6BB5FF] flex items-center justify-center text-white">
                <BookOpen size={20} />
              </div>
              <div>
                <h2 className="font-bold text-[var(--ink)] text-lg">Study Buddy</h2>
                <p className="text-xs text-[var(--mute)]">Slip Gaji Tutor</p>
              </div>
            </div>
          </div>
          <div className="text-right">
            <p className="text-xs text-[var(--mute)]">Periode</p>
            <p className="font-bold text-[var(--ink)]">
              {formatPeriod(payroll.period_month, payroll.period_year)}
            </p>
            <div className="mt-2 flex justify-end">
              <PayrollStatusBadge status={payroll.status} />
            </div>
          </div>
        </div>

        {/* Tutor Info */}
        <div className="py-4 border-b border-[var(--line)]">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <p className="text-xs text-[var(--mute)] mb-0.5">Nama Tutor</p>
              <p className="font-bold text-[var(--ink)]">
                {payroll.tutor?.full_name ?? '-'}
              </p>
            </div>
            <div>
              <p className="text-xs text-[var(--mute)] mb-0.5">ID Tutor</p>
              <p className="text-sm text-[var(--ink)] font-mono">
                {payroll.tutor?.id ?? '-'}
              </p>
            </div>
          </div>
        </div>

        {/* Detail Sesi */}
        <div className="py-4">
          <h3 className="font-bold text-[var(--ink)] mb-3">
            Detail Sesi ({payroll.total_sessions})
          </h3>

          {payroll.sessions.length === 0 ? (
            <p className="text-sm text-[var(--mute)] py-4 text-center">
              Tidak ada sesi pada periode ini
            </p>
          ) : (
            <div className="overflow-x-auto -mx-6 lg:-mx-8 px-6 lg:px-8">
              <table className="min-w-[600px]">
                <thead>
                  <tr>
                    <th>Tanggal</th>
                    <th>Mapel</th>
                    <th>Buddy</th>
                    <th className="text-right">Bruto</th>
                    <th className="text-right">Komisi</th>
                  </tr>
                </thead>
                <tbody>
                  {payroll.sessions.map((s) => (
                    <tr key={s.booking_id}>
                      <td className="text-[var(--ink)]">
                        {formatDate(s.session_time)}
                      </td>
                      <td className="text-[var(--ink)]">{s.subject}</td>
                      <td className="text-[var(--mute)]">{s.customer_name}</td>
                      <td className="text-right text-[var(--ink)]">
                        {formatRupiah(s.amount)}
                      </td>
                      <td className="text-right text-[var(--blue)] font-semibold">
                        {formatRupiah(s.commission)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Summary */}
        <div className="pt-4 border-t-2 border-[var(--blue)]">
          <div className="ml-auto max-w-xs space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-[var(--mute)]">Total Bruto</span>
              <span className="text-[var(--ink)]">
                {formatRupiah(payroll.total_gross)}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-[var(--mute)]">Komisi (70%)</span>
              <span className="font-bold text-[var(--blue)]">
                {formatRupiah(payroll.total_commission)}
              </span>
            </div>
            <div className="flex justify-between pt-2 border-t border-[var(--line)]">
              <span className="font-semibold text-[var(--ink)]">
                Total Dibayarkan
              </span>
              <span className="font-bold text-[var(--blue)] text-lg">
                {formatRupiah(payroll.total_commission)}
              </span>
            </div>
          </div>
        </div>

        {/* Payment info */}
        {payroll.status === 'paid' && payroll.paid_at && (
          <div className="mt-6 pt-4 border-t border-[var(--line)] bg-[#DCFCE7] -mx-6 lg:-mx-8 px-6 lg:px-8 py-4">
            <p className="text-sm text-[#166534] font-bold mb-1 flex items-center gap-1.5">
              <CheckCircle2 size={16} />
              Sudah Dibayar
            </p>
            <p className="text-xs text-[var(--mute)]">
              Tanggal transfer: {formatDateTime(payroll.paid_at)}
            </p>
            {payroll.payer && (
              <p className="text-xs text-[var(--mute)]">
                Diproses oleh: {payroll.payer.full_name}
              </p>
            )}
            {payroll.notes && (
              <p className="text-xs text-[var(--mute)] mt-1">
                Catatan: {payroll.notes}
              </p>
            )}
          </div>
        )}
      </div>

      {/* Modal Confirm Paid */}
      {showConfirm && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="card shadow-2xl max-w-md w-full p-6">
            <h3 className="text-lg font-bold text-[var(--ink)] mb-2">
              Tandai Sudah Dibayar?
            </h3>
            <p className="text-sm text-[var(--mute)] mb-4">
              Pastikan kamu sudah transfer{' '}
              <strong className="text-[var(--ink)]">
                {formatRupiah(payroll.total_commission)}
              </strong>{' '}
              ke {payroll.tutor?.full_name}.
            </p>
            <div className="mb-4">
              <label className="block text-sm font-semibold text-[var(--ink)] mb-2">
                Catatan (opsional)
              </label>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Misal: transfer via BCA, ref #12345..."
                rows={2}
                className="inp resize-none"
              />
            </div>
            <div className="flex gap-3">
              <button
                type="button"
                onClick={() => setShowConfirm(false)}
                disabled={updating}
                className="btn flex-1 justify-center"
              >
                Batal
              </button>
              <button
                type="button"
                onClick={handleMarkPaid}
                disabled={updating}
                className="btn flex-1 justify-center text-white disabled:opacity-50"
                style={{ background: '#00C853', borderColor: '#00C853' }}
              >
                {updating ? (
                  <>
                    <Loader2 size={16} className="animate-spin" />
                    Memproses...
                  </>
                ) : (
                  <>
                    <CheckCircle2 size={16} />
                    Ya, Tandai
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
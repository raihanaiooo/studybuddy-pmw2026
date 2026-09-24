import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { usePayrollDetail } from '../hooks/usePayrollDetail';
import { PayrollStatusBadge } from '../components/payroll/PayrollStatusBadge';
import { formatPeriod } from '../types/payroll';

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
        <div className="w-10 h-10 border-4 border-[#1A5EAA] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !payroll) {
    return (
      <div className="bg-white rounded-2xl p-8 text-center border border-[#E5E7EB]">
        <p className="text-[#E53935] mb-4">
          {error ?? 'Payroll tidak ditemukan'}
        </p>
        <Link
          to="/payroll"
          className="inline-block bg-[#1A5EAA] text-white px-5 py-2.5 rounded-xl font-semibold hover:bg-[#154A87]"
        >
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
          className="text-sm text-[#1A5EAA] hover:underline font-medium inline-flex items-center gap-1 mb-3"
        >
          ← Kembali ke daftar Payroll
        </Link>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h1 className="text-2xl font-bold text-[#1A1F3C]">
              Slip Gaji Tutor
            </h1>
            <p className="text-sm text-[#6B7280] mt-1">
              {formatPeriod(payroll.period_month, payroll.period_year)}
            </p>
          </div>
          <div className="flex gap-2">
            <button
              onClick={handlePrint}
              className="px-4 py-2.5 rounded-xl border border-[#E5E7EB] bg-white text-[#1A1F3C] font-semibold hover:bg-[#F5F6FA] transition-colors"
            >
              🖨️ Cetak
            </button>
            {payroll.status === 'pending' && (
              <button
                onClick={() => setShowConfirm(true)}
                disabled={updating}
                className="px-4 py-2.5 rounded-xl bg-[#00C853] text-white font-semibold hover:bg-[#00A84A] transition-colors disabled:opacity-50"
              >
                ✅ Tandai Sudah Dibayar
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Slip Content */}
      <div className="bg-white rounded-2xl border border-[#E5E7EB] p-6 lg:p-8 print:border-0 print:shadow-none">
        {/* Slip Header */}
        <div className="flex flex-wrap items-start justify-between gap-3 pb-4 border-b-2 border-[#1A5EAA]">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#1A5EAA] to-[#6BB5FF] flex items-center justify-center text-white text-xl">
                📚
              </div>
              <div>
                <h2 className="font-bold text-[#1A1F3C] text-lg">Study Buddy</h2>
                <p className="text-xs text-[#6B7280]">Slip Gaji Tutor</p>
              </div>
            </div>
          </div>
          <div className="text-right">
            <p className="text-xs text-[#6B7280]">Periode</p>
            <p className="font-bold text-[#1A1F3C]">
              {formatPeriod(payroll.period_month, payroll.period_year)}
            </p>
            <div className="mt-2">
              <PayrollStatusBadge status={payroll.status} />
            </div>
          </div>
        </div>

        {/* Tutor Info */}
        <div className="py-4 border-b border-[#E5E7EB]">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <p className="text-xs text-[#6B7280] mb-0.5">Nama Tutor</p>
              <p className="font-bold text-[#1A1F3C]">
                {payroll.tutor?.full_name ?? '-'}
              </p>
            </div>
            <div>
              <p className="text-xs text-[#6B7280] mb-0.5">ID Tutor</p>
              <p className="text-sm text-[#1A1F3C] font-mono">
                {payroll.tutor?.id ?? '-'}
              </p>
            </div>
          </div>
        </div>

        {/* Detail Sesi */}
        <div className="py-4">
          <h3 className="font-bold text-[#1A1F3C] mb-3">
            Detail Sesi ({payroll.total_sessions})
          </h3>

          {payroll.sessions.length === 0 ? (
            <p className="text-sm text-[#6B7280] py-4 text-center">
              Tidak ada sesi pada periode ini
            </p>
          ) : (
            <div className="overflow-x-auto -mx-6 lg:-mx-8 px-6 lg:px-8">
              <table className="w-full text-sm min-w-[600px]">
                <thead>
                  <tr className="border-b border-[#E5E7EB]">
                    <th className="text-left py-2 px-2 font-semibold text-[#6B7280] text-xs">
                      Tanggal
                    </th>
                    <th className="text-left py-2 px-2 font-semibold text-[#6B7280] text-xs">
                      Mapel
                    </th>
                    <th className="text-left py-2 px-2 font-semibold text-[#6B7280] text-xs">
                      Buddy
                    </th>
                    <th className="text-right py-2 px-2 font-semibold text-[#6B7280] text-xs">
                      Bruto
                    </th>
                    <th className="text-right py-2 px-2 font-semibold text-[#6B7280] text-xs">
                      Komisi
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {payroll.sessions.map((s) => (
                    <tr
                      key={s.booking_id}
                      className="border-b border-[#F5F6FA]"
                    >
                      <td className="py-2 px-2 text-[#1A1F3C]">
                        {formatDate(s.session_time)}
                      </td>
                      <td className="py-2 px-2 text-[#1A1F3C]">
                        {s.subject}
                      </td>
                      <td className="py-2 px-2 text-[#6B7280]">
                        {s.customer_name}
                      </td>
                      <td className="py-2 px-2 text-right text-[#1A1F3C]">
                        {formatRupiah(s.amount)}
                      </td>
                      <td className="py-2 px-2 text-right text-[#1A5EAA] font-semibold">
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
        <div className="pt-4 border-t-2 border-[#1A5EAA]">
          <div className="ml-auto max-w-xs space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-[#6B7280]">Total Bruto</span>
              <span className="text-[#1A1F3C]">
                {formatRupiah(payroll.total_gross)}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-[#6B7280]">Komisi (70%)</span>
              <span className="font-bold text-[#1A5EAA]">
                {formatRupiah(payroll.total_commission)}
              </span>
            </div>
            <div className="flex justify-between pt-2 border-t border-[#E5E7EB]">
              <span className="font-semibold text-[#1A1F3C]">
                Total Dibayarkan
              </span>
              <span className="font-bold text-[#1A5EAA] text-lg">
                {formatRupiah(payroll.total_commission)}
              </span>
            </div>
          </div>
        </div>

        {/* Payment info */}
        {payroll.status === 'paid' && payroll.paid_at && (
          <div className="mt-6 pt-4 border-t border-[#E5E7EB] bg-[#00C853]/5 -mx-6 lg:-mx-8 px-6 lg:px-8 py-4">
            <p className="text-sm text-[#00C853] font-semibold mb-1">
              ✅ Sudah Dibayar
            </p>
            <p className="text-xs text-[#6B7280]">
              Tanggal transfer: {formatDateTime(payroll.paid_at)}
            </p>
            {payroll.payer && (
              <p className="text-xs text-[#6B7280]">
                Diproses oleh: {payroll.payer.full_name}
              </p>
            )}
            {payroll.notes && (
              <p className="text-xs text-[#6B7280] mt-1">
                Catatan: {payroll.notes}
              </p>
            )}
          </div>
        )}
      </div>

      {/* Modal Confirm Paid */}
      {showConfirm && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6">
            <h3 className="text-lg font-bold text-[#1A1F3C] mb-2">
              Tandai Sudah Dibayar?
            </h3>
            <p className="text-sm text-[#6B7280] mb-4">
              Pastikan kamu sudah transfer{' '}
              <strong>{formatRupiah(payroll.total_commission)}</strong> ke{' '}
              {payroll.tutor?.full_name}.
            </p>
            <div className="mb-4">
              <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
                Catatan (opsional)
              </label>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Misal: transfer via BCA, ref #12345..."
                rows={2}
                className="w-full px-4 py-3 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA] focus:ring-2 focus:ring-[#1A5EAA]/20 resize-none"
              />
            </div>
            <div className="flex gap-3">
              <button
                type="button"
                onClick={() => setShowConfirm(false)}
                disabled={updating}
                className="flex-1 px-4 py-3 rounded-xl border border-[#E5E7EB] text-[#6B7280] font-semibold hover:bg-[#F5F6FA]"
              >
                Batal
              </button>
              <button
                type="button"
                onClick={handleMarkPaid}
                disabled={updating}
                className="flex-1 px-4 py-3 rounded-xl bg-[#00C853] text-white font-semibold hover:bg-[#00A84A] disabled:opacity-50 flex items-center justify-center gap-2"
              >
                {updating ? (
                  <>
                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                    Memproses...
                  </>
                ) : (
                  'Ya, Tandai'
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
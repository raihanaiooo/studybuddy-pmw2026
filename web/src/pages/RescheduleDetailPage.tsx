import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useRescheduleDetail } from '../hooks/useRescheduleDetail';
import { RescheduleStatusBadge } from '../components/reschedule/RescheduleStatusBadge';
import { RescheduleActionModal } from '../components/reschedule/RescheduleActionModal';

type ActionType = 'approve' | 'reject';

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

export function RescheduleDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { reschedule, loading, updating, error, approve, reject } =
    useRescheduleDetail(id);
  const [modal, setModal] = useState<ActionType | null>(null);

  async function handleAction(note: string) {
    if (!modal) return;
    if (modal === 'approve') await approve(note);
    else await reject(note);
  }

  if (loading) {
    return (
      <div className="flex justify-center py-20">
        <div className="w-10 h-10 border-4 border-[#1A5EAA] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !reschedule) {
    return (
      <div className="bg-white rounded-2xl p-8 text-center border border-[#E5E7EB]">
        <p className="text-[#E53935] mb-4">
          {error ?? 'Reschedule tidak ditemukan'}
        </p>
        <Link
          to="/reschedules"
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
          to="/reschedules"
          className="text-sm text-[#1A5EAA] hover:underline font-medium inline-flex items-center gap-1 mb-3"
        >
          ← Kembali ke daftar Reschedule
        </Link>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h1 className="text-2xl font-bold text-[#1A1F3C]">
              Detail Reschedule
            </h1>
            <p className="text-sm text-[#6B7280] mt-1">ID: {reschedule.id}</p>
          </div>
          <RescheduleStatusBadge status={reschedule.status} />
        </div>
      </div>

      {/* Action buttons */}
      {reschedule.status === 'menunggu_admin' && (
        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB] flex flex-wrap gap-3">
          <button
            onClick={() => setModal('approve')}
            disabled={updating}
            className="flex-1 min-w-[140px] bg-[#00C853] hover:bg-[#00A84A] disabled:opacity-50 text-white font-semibold py-3 rounded-xl transition-colors"
          >
            ✅ Setujui
          </button>
          <button
            onClick={() => setModal('reject')}
            disabled={updating}
            className="flex-1 min-w-[140px] bg-[#E53935] hover:bg-[#C62828] disabled:opacity-50 text-white font-semibold py-3 rounded-xl transition-colors"
          >
            ❌ Tolak
          </button>
        </div>
      )}

      {/* Schedule comparison */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
          <h2 className="font-bold text-[#1A1F3C] mb-2">Jadwal Lama</h2>
          <p className="text-sm text-[#1A1F3C]">
            {formatDateTime(reschedule.original_session_time)}
          </p>
        </div>
        <div className="bg-gradient-to-br from-[#1A5EAA] to-[#6BB5FF] rounded-2xl p-5 text-white">
          <h2 className="font-bold mb-2">Jadwal Baru</h2>
          <p className="text-sm">{formatDateTime(reschedule.new_session_time)}</p>
        </div>
      </div>

      {/* Info */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
          <h2 className="font-bold text-[#1A1F3C] mb-3">Informasi Pengajuan</h2>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Pengaju</span>
              <span className="text-[#1A1F3C] font-medium text-right">
                {reschedule.requester?.full_name ?? '-'}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Peran</span>
              <span className="text-[#1A1F3C] font-medium capitalize text-right">
                {reschedule.requested_by_role}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Diajukan</span>
              <span className="text-[#1A1F3C] font-medium text-right">
                {formatDateTime(reschedule.created_at)}
              </span>
            </div>
            {reschedule.reviewed_at && (
              <div className="flex justify-between gap-3">
                <span className="text-[#6B7280]">Ditinjau</span>
                <span className="text-[#1A1F3C] font-medium text-right">
                  {formatDateTime(reschedule.reviewed_at)}
                </span>
              </div>
            )}
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
          <h2 className="font-bold text-[#1A1F3C] mb-3">Booking Terkait</h2>
          {reschedule.booking ? (
            <div className="space-y-2 text-sm">
              <div className="flex justify-between gap-3">
                <span className="text-[#6B7280]">Mapel</span>
                <span className="text-[#1A1F3C] font-medium text-right">
                  {reschedule.booking.subject}
                </span>
              </div>
              <div className="flex justify-between gap-3">
                <span className="text-[#6B7280]">Jadwal</span>
                <span className="text-[#1A1F3C] font-medium text-right">
                  {formatDateTime(reschedule.booking.session_time)}
                </span>
              </div>
              <Link
                to={`/bookings/${reschedule.booking.id}`}
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

      {/* Reason */}
      <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
        <h2 className="font-bold text-[#1A1F3C] mb-2">Alasan Reschedule</h2>
        <p className="text-sm text-[#1A1F3C] whitespace-pre-wrap">
          {reschedule.reason}
        </p>
      </div>

      {/* Admin Note */}
      {reschedule.admin_note && (
        <div className="bg-[#1A5EAA]/10 border border-[#1A5EAA]/30 rounded-2xl p-5">
          <h2 className="font-bold text-[#1A5EAA] mb-2">Catatan Admin</h2>
          <p className="text-sm text-[#1A1F3C] whitespace-pre-wrap">
            {reschedule.admin_note}
          </p>
          {reschedule.reviewer && (
            <p className="text-xs text-[#6B7280] mt-2">
              Oleh: {reschedule.reviewer.full_name}
            </p>
          )}
        </div>
      )}

      {/* Modal */}
      {modal && (
        <RescheduleActionModal
          isOpen={true}
          action={modal}
          onClose={() => setModal(null)}
          onConfirm={handleAction}
        />
      )}
    </div>
  );
}
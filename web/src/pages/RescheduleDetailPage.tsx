import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import {
  ArrowLeft,
  CheckCircle2,
  XCircle,
  AlertCircle,
  CalendarClock,
  CalendarPlus,
  Info,
  CalendarDays,
  MessageSquare,
  StickyNote,
  ExternalLink,
} from 'lucide-react';
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
        <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !reschedule) {
    return (
      <div className="card p-8 text-center">
        <AlertCircle size={40} className="mx-auto text-[#991B1B] mb-3" />
        <p className="text-[#991B1B] mb-4">
          {error ?? 'Reschedule tidak ditemukan'}
        </p>
        <Link to="/reschedules" className="btn btn-p inline-flex">
          <ArrowLeft size={16} />
          Kembali
        </Link>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <Link
          to="/reschedules"
          className="text-sm text-[var(--blue)] hover:underline font-semibold inline-flex items-center gap-1 mb-3"
        >
          <ArrowLeft size={16} />
          Kembali ke daftar Reschedule
        </Link>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h1 className="text-2xl font-extrabold text-[var(--ink)]">
              Detail Reschedule
            </h1>
            <p className="text-sm text-[var(--mute)] mt-1 font-mono">
              ID: {reschedule.id}
            </p>
          </div>
          <RescheduleStatusBadge status={reschedule.status} />
        </div>
      </div>

      {/* Action buttons */}
      {reschedule.status === 'menunggu_admin' && (
        <div className="card p-5 flex flex-wrap gap-3">
          <button
            type="button"
            onClick={() => setModal('approve')}
            disabled={updating}
            className="btn flex-1 min-w-[140px] justify-center text-white disabled:opacity-50"
            style={{ background: '#00C853', borderColor: '#00C853' }}
          >
            <CheckCircle2 size={18} />
            Setujui
          </button>
          <button
            type="button"
            onClick={() => setModal('reject')}
            disabled={updating}
            className="btn flex-1 min-w-[140px] justify-center text-white disabled:opacity-50"
            style={{ background: '#E53935', borderColor: '#E53935' }}
          >
            <XCircle size={18} />
            Tolak
          </button>
        </div>
      )}

      {/* Schedule comparison */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="card p-5">
          <h2 className="font-bold text-[var(--ink)] mb-2 flex items-center gap-2">
            <CalendarClock size={18} className="text-[var(--mute)]" />
            Jadwal Lama
          </h2>
          <p className="text-sm text-[var(--ink)]">
            {formatDateTime(reschedule.original_session_time)}
          </p>
        </div>
        <div className="rounded-xl p-5 text-white bg-gradient-to-br from-[var(--blue)] to-[#6BB5FF]">
          <h2 className="font-bold mb-2 flex items-center gap-2">
            <CalendarPlus size={18} />
            Jadwal Baru
          </h2>
          <p className="text-sm">
            {formatDateTime(reschedule.new_session_time)}
          </p>
        </div>
      </div>

      {/* Info */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="card p-5">
          <h2 className="font-bold text-[var(--ink)] mb-3 flex items-center gap-2">
            <Info size={18} className="text-[var(--blue)]" />
            Informasi Pengajuan
          </h2>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between gap-3">
              <span className="text-[var(--mute)]">Pengaju</span>
              <span className="text-[var(--ink)] font-semibold text-right">
                {reschedule.requester?.full_name ?? '-'}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[var(--mute)]">Peran</span>
              <span className="text-[var(--ink)] font-semibold capitalize text-right">
                {reschedule.requested_by_role}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[var(--mute)]">Diajukan</span>
              <span className="text-[var(--ink)] font-semibold text-right">
                {formatDateTime(reschedule.created_at)}
              </span>
            </div>
            {reschedule.reviewed_at && (
              <div className="flex justify-between gap-3">
                <span className="text-[var(--mute)]">Ditinjau</span>
                <span className="text-[var(--ink)] font-semibold text-right">
                  {formatDateTime(reschedule.reviewed_at)}
                </span>
              </div>
            )}
          </div>
        </div>

        <div className="card p-5">
          <h2 className="font-bold text-[var(--ink)] mb-3 flex items-center gap-2">
            <CalendarDays size={18} className="text-[var(--blue)]" />
            Booking Terkait
          </h2>
          {reschedule.booking ? (
            <div className="space-y-2 text-sm">
              <div className="flex justify-between gap-3">
                <span className="text-[var(--mute)]">Mapel</span>
                <span className="text-[var(--ink)] font-semibold text-right">
                  {reschedule.booking.subject}
                </span>
              </div>
              <div className="flex justify-between gap-3">
                <span className="text-[var(--mute)]">Jadwal</span>
                <span className="text-[var(--ink)] font-semibold text-right">
                  {formatDateTime(reschedule.booking.session_time)}
                </span>
              </div>
              <Link
                to={`/bookings/${reschedule.booking.id}`}
                className="inline-flex items-center gap-1 mt-3 text-sm text-[var(--blue)] hover:underline font-semibold"
              >
                Lihat Booking
                <ExternalLink size={14} />
              </Link>
            </div>
          ) : (
            <p className="text-sm text-[var(--mute)]">
              Booking tidak ditemukan
            </p>
          )}
        </div>
      </div>

      {/* Reason */}
      <div className="card p-5">
        <h2 className="font-bold text-[var(--ink)] mb-2 flex items-center gap-2">
          <MessageSquare size={18} className="text-[var(--blue)]" />
          Alasan Reschedule
        </h2>
        <p className="text-sm text-[var(--ink)] whitespace-pre-wrap">
          {reschedule.reason}
        </p>
      </div>

      {/* Admin Note */}
      {reschedule.admin_note && (
        <div className="bg-[var(--blue)]/10 border border-[var(--blue)]/30 rounded-2xl p-5">
          <h2 className="font-bold text-[var(--blue)] mb-2 flex items-center gap-2">
            <StickyNote size={18} />
            Catatan Admin
          </h2>
          <p className="text-sm text-[var(--ink)] whitespace-pre-wrap">
            {reschedule.admin_note}
          </p>
          {reschedule.reviewer && (
            <p className="text-xs text-[var(--mute)] mt-2">
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
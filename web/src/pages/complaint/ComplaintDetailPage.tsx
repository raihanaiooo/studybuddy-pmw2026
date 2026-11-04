import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import {
  ArrowLeft,
  Search,
  CheckCircle2,
  XCircle,
  AlertCircle,
  MessageSquare,
  CalendarDays,
  ExternalLink,
  Info,
  StickyNote,
} from 'lucide-react';
import { useComplaintDetail } from '../../hooks/useComplaintDetail';
import { ComplaintStatusBadge } from '../../components/complaint/ComplaintStatusBadge';
import { ComplaintHandleModal } from '../../components/complaint/ComplaintHandleModal';
import { CATEGORY_LABELS } from '../../types/complaint';

type ActionType = 'in_review' | 'resolved' | 'rejected';

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

export function ComplaintDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { complaint, loading, updating, error, update } =
    useComplaintDetail(id);
  const [modal, setModal] = useState<ActionType | null>(null);

  async function handleAction(note: string) {
    if (!modal) return;
    await update(modal, note);
  }

  if (loading) {
    return (
      <div className="flex justify-center py-20">
        <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !complaint) {
    return (
      <div className="card p-8 text-center">
        <AlertCircle size={40} className="mx-auto text-[#991B1B] mb-3" />
        <p className="text-[#991B1B] mb-4">
          {error ?? 'Komplain tidak ditemukan'}
        </p>
        <Link to="/complaints" className="btn btn-p inline-flex">
          <ArrowLeft size={16} />
          Kembali
        </Link>
      </div>
    );
  }

  const canAction =
    complaint.status === 'pending' || complaint.status === 'in_review';

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <Link
          to="/complaints"
          className="text-sm text-[var(--blue)] hover:underline font-semibold inline-flex items-center gap-1 mb-3"
        >
          <ArrowLeft size={16} />
          Kembali ke daftar Komplain
        </Link>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h1 className="text-2xl font-extrabold text-[var(--ink)]">
              Detail Komplain
            </h1>
            <p className="text-sm text-[var(--mute)] mt-1 font-mono">
              ID: {complaint.id}
            </p>
          </div>
          <ComplaintStatusBadge status={complaint.status} />
        </div>
      </div>

      {/* Action buttons */}
      {canAction && (
        <div className="card p-5 flex flex-wrap gap-3">
          {complaint.status === 'pending' && (
            <button
              type="button"
              onClick={() => setModal('in_review')}
              disabled={updating}
              className="btn btn-p flex-1 min-w-[140px] justify-center disabled:opacity-50"
            >
              <Search size={18} />
              Tandai Ditinjau
            </button>
          )}
          <button
            type="button"
            onClick={() => setModal('resolved')}
            disabled={updating}
            className="btn flex-1 min-w-[140px] justify-center text-white disabled:opacity-50"
            style={{ background: '#00C853', borderColor: '#00C853' }}
          >
            <CheckCircle2 size={18} />
            Selesaikan
          </button>
          <button
            type="button"
            onClick={() => setModal('rejected')}
            disabled={updating}
            className="btn flex-1 min-w-[140px] justify-center text-white disabled:opacity-50"
            style={{ background: '#E53935', borderColor: '#E53935' }}
          >
            <XCircle size={18} />
            Tolak
          </button>
        </div>
      )}

      {/* Info grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Info Komplain */}
        <div className="card p-5">
          <h2 className="font-bold text-[var(--ink)] mb-3 flex items-center gap-2">
            <Info size={18} className="text-[var(--blue)]" />
            Informasi Komplain
          </h2>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between gap-3">
              <span className="text-[var(--mute)]">Kategori</span>
              <span className="text-[var(--ink)] font-semibold text-right">
                {CATEGORY_LABELS[complaint.category]}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[var(--mute)]">Pelapor</span>
              <span className="text-[var(--ink)] font-semibold text-right">
                {complaint.reporter?.full_name ?? '-'}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[var(--mute)]">Peran</span>
              <span className="text-[var(--ink)] font-semibold capitalize text-right">
                {complaint.reporter_role}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[var(--mute)]">Dilaporkan</span>
              <span className="text-[var(--ink)] font-semibold text-right">
                {formatDateTime(complaint.created_at)}
              </span>
            </div>
            {complaint.handled_at && (
              <div className="flex justify-between gap-3">
                <span className="text-[var(--mute)]">Ditangani</span>
                <span className="text-[var(--ink)] font-semibold text-right">
                  {formatDateTime(complaint.handled_at)}
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Booking Terkait */}
        <div className="card p-5">
          <h2 className="font-bold text-[var(--ink)] mb-3 flex items-center gap-2">
            <CalendarDays size={18} className="text-[var(--blue)]" />
            Booking Terkait
          </h2>
          {complaint.booking ? (
            <div className="space-y-2 text-sm">
              <div className="flex justify-between gap-3">
                <span className="text-[var(--mute)]">Mapel</span>
                <span className="text-[var(--ink)] font-semibold text-right">
                  {complaint.booking.subject}
                </span>
              </div>
              <div className="flex justify-between gap-3">
                <span className="text-[var(--mute)]">Jadwal</span>
                <span className="text-[var(--ink)] font-semibold text-right">
                  {formatDateTime(complaint.booking.session_time)}
                </span>
              </div>
              <Link
                to={`/bookings/${complaint.booking.id}`}
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

      {/* Description */}
      <div className="card p-5">
        <h2 className="font-bold text-[var(--ink)] mb-2 flex items-center gap-2">
          <MessageSquare size={18} className="text-[var(--blue)]" />
          Deskripsi
        </h2>
        <p className="text-sm text-[var(--ink)] whitespace-pre-wrap">
          {complaint.description}
        </p>
      </div>

      {/* Admin Note */}
      {complaint.admin_note && (
        <div className="bg-[var(--blue)]/10 border border-[var(--blue)]/30 rounded-2xl p-5">
          <h2 className="font-bold text-[var(--blue)] mb-2 flex items-center gap-2">
            <StickyNote size={18} />
            Catatan Admin
          </h2>
          <p className="text-sm text-[var(--ink)] whitespace-pre-wrap">
            {complaint.admin_note}
          </p>
          {complaint.handler && (
            <p className="text-xs text-[var(--mute)] mt-2">
              Oleh: {complaint.handler.full_name}
            </p>
          )}
        </div>
      )}

      {/* Modal */}
      {modal && (
        <ComplaintHandleModal
          isOpen={true}
          action={modal}
          onClose={() => setModal(null)}
          onConfirm={handleAction}
        />
      )}
    </div>
  );
}
import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useComplaintDetail } from '../hooks/useComplaintDetail';
import { ComplaintStatusBadge } from '../components/complaint/ComplaintStatusBadge';
import { ComplaintHandleModal } from '../components/complaint/ComplaintHandleModal';
import { CATEGORY_LABELS } from '../types/complaint';

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
  const { complaint, loading, updating, error, update } = useComplaintDetail(id);
  const [modal, setModal] = useState<ActionType | null>(null);

  async function handleAction(note: string) {
    if (!modal) return;
    await update(modal, note);
  }

  if (loading) {
    return (
      <div className="flex justify-center py-20">
        <div className="w-10 h-10 border-4 border-[#1A5EAA] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !complaint) {
    return (
      <div className="bg-white rounded-2xl p-8 text-center border border-[#E5E7EB]">
        <p className="text-[#E53935] mb-4">
          {error ?? 'Komplain tidak ditemukan'}
        </p>
        <Link
          to="/complaints"
          className="inline-block bg-[#1A5EAA] text-white px-5 py-2.5 rounded-xl font-semibold hover:bg-[#154A87]"
        >
          Kembali
        </Link>
      </div>
    );
  }

  const canAction = complaint.status === 'pending' || complaint.status === 'in_review';

  return (
    <div className="space-y-6">
      <div>
        <Link
          to="/complaints"
          className="text-sm text-[#1A5EAA] hover:underline font-medium inline-flex items-center gap-1 mb-3"
        >
          ← Kembali ke daftar Komplain
        </Link>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h1 className="text-2xl font-bold text-[#1A1F3C]">Detail Komplain</h1>
            <p className="text-sm text-[#6B7280] mt-1">ID: {complaint.id}</p>
          </div>
          <ComplaintStatusBadge status={complaint.status} />
        </div>
      </div>

      {/* Action buttons */}
      {canAction && (
        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB] flex flex-wrap gap-3">
          {complaint.status === 'pending' && (
            <button
              onClick={() => setModal('in_review')}
              disabled={updating}
              className="flex-1 min-w-[140px] bg-[#1A5EAA] hover:bg-[#154A87] disabled:opacity-50 text-white font-semibold py-3 rounded-xl transition-colors"
            >
              🔍 Tandai Ditinjau
            </button>
          )}
          <button
            onClick={() => setModal('resolved')}
            disabled={updating}
            className="flex-1 min-w-[140px] bg-[#00C853] hover:bg-[#00A84A] disabled:opacity-50 text-white font-semibold py-3 rounded-xl transition-colors"
          >
            ✅ Selesaikan
          </button>
          <button
            onClick={() => setModal('rejected')}
            disabled={updating}
            className="flex-1 min-w-[140px] bg-[#E53935] hover:bg-[#C62828] disabled:opacity-50 text-white font-semibold py-3 rounded-xl transition-colors"
          >
            ❌ Tolak
          </button>
        </div>
      )}

      {/* Info */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
          <h2 className="font-bold text-[#1A1F3C] mb-3">Informasi Komplain</h2>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Kategori</span>
              <span className="text-[#1A1F3C] font-medium text-right">
                {CATEGORY_LABELS[complaint.category]}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Pelapor</span>
              <span className="text-[#1A1F3C] font-medium text-right">
                {complaint.reporter?.full_name ?? '-'}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Peran</span>
              <span className="text-[#1A1F3C] font-medium capitalize text-right">
                {complaint.reporter_role}
              </span>
            </div>
            <div className="flex justify-between gap-3">
              <span className="text-[#6B7280]">Dilaporkan</span>
              <span className="text-[#1A1F3C] font-medium text-right">
                {formatDateTime(complaint.created_at)}
              </span>
            </div>
            {complaint.handled_at && (
              <div className="flex justify-between gap-3">
                <span className="text-[#6B7280]">Ditangani</span>
                <span className="text-[#1A1F3C] font-medium text-right">
                  {formatDateTime(complaint.handled_at)}
                </span>
              </div>
            )}
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
          <h2 className="font-bold text-[#1A1F3C] mb-3">Booking Terkait</h2>
          {complaint.booking ? (
            <div className="space-y-2 text-sm">
              <div className="flex justify-between gap-3">
                <span className="text-[#6B7280]">Mapel</span>
                <span className="text-[#1A1F3C] font-medium text-right">
                  {complaint.booking.subject}
                </span>
              </div>
              <div className="flex justify-between gap-3">
                <span className="text-[#6B7280]">Jadwal</span>
                <span className="text-[#1A1F3C] font-medium text-right">
                  {formatDateTime(complaint.booking.session_time)}
                </span>
              </div>
              <Link
                to={`/bookings/${complaint.booking.id}`}
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

      {/* Description */}
      <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB]">
        <h2 className="font-bold text-[#1A1F3C] mb-2">Deskripsi</h2>
        <p className="text-sm text-[#1A1F3C] whitespace-pre-wrap">
          {complaint.description}
        </p>
      </div>

      {/* Admin Note */}
      {complaint.admin_note && (
        <div className="bg-[#1A5EAA]/10 border border-[#1A5EAA]/30 rounded-2xl p-5">
          <h2 className="font-bold text-[#1A5EAA] mb-2">Catatan Admin</h2>
          <p className="text-sm text-[#1A1F3C] whitespace-pre-wrap">
            {complaint.admin_note}
          </p>
          {complaint.handler && (
            <p className="text-xs text-[#6B7280] mt-2">
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
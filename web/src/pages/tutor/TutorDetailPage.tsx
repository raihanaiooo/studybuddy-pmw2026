import { useState } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import {
  ArrowLeft,
  CheckCircle2,
  XCircle,
  AlertCircle,
  BookOpen,
  GraduationCap,
  User as UserIcon,
  Pencil,
  Phone,
} from 'lucide-react';
import { useTutorDetail } from '../../hooks/useTutorDetail';
import { VerificationBadge } from '../../components/tutor/VerificationBadge';
import { DocumentPreview } from '../../components/tutor/DocumentPreview';
import { VerificationModal } from '../../components/tutor/VerificationModal';
import { TutorEditModal } from '../../components/tutor/TutorEditModal';
import { backTabFor } from '../../lib/tutorTabs';

export function TutorDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { tutor, documents, priv, loading, error, updating, verify, reload } =
    useTutorDetail(id);
  const [editing, setEditing] = useState(false);
  const [modal, setModal] = useState<'approve' | 'reject' | 'revoke' | null>(null);
  const location = useLocation();
  const backTo = `/tutors?tab=${backTabFor(location.state, tutor?.verification_status)}`;

  async function handleVerify(note: string) {
    if (!modal) return;
    const newStatus = modal === 'approve' ? 'verified' : modal === 'revoke' ? 'pending' : 'rejected';
    await verify(newStatus, note);
  }

  if (loading) {
    return (
      <div className="flex justify-center py-20">
        <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !tutor) {
    return (
      <div className="card p-8 text-center">
        <AlertCircle size={40} className="mx-auto text-[#991B1B] mb-3" />
        <p className="text-[#991B1B] mb-4">
          {error ?? 'Tutor tidak ditemukan'}
        </p>
        <Link to={backTo} className="btn btn-p inline-flex">
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
          to={backTo}
          className="text-sm text-[var(--blue)] hover:underline font-semibold inline-flex items-center gap-1 mb-3"
        >
          <ArrowLeft size={16} />
          Kembali ke daftar Tutor
        </Link>
        <div className="flex items-start gap-4 flex-wrap">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-[var(--blue)] to-[#6BB5FF] flex items-center justify-center text-white text-2xl font-bold shrink-0">
            {tutor.full_name?.[0]?.toUpperCase() ?? '?'}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex flex-wrap items-center gap-2 mb-1">
              <h1 className="text-2xl font-extrabold text-[var(--ink)]">
                {tutor.full_name}
              </h1>
              <VerificationBadge status={tutor.verification_status} />
            </div>
            <p className="text-sm text-[var(--mute)]">
              {tutor.university ?? 'Belum ada institusi'}
              {tutor.gpa ? ` · IPK ${tutor.gpa}` : ''}
              {tutor.is_outsourced ? ' · Outsourcing' : ''}
            </p>
          </div>
          <button type="button" onClick={() => setEditing(true)} className="btn shrink-0">
            <Pencil size={16} />
            Edit
          </button>
        </div>
      </div>

      {/* Action: pending */}
      {tutor.verification_status === 'pending' && (
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

      {/* Action: sudah diputuskan (bisa dibatalkan) */}
      {tutor.verification_status !== 'pending' && (
        <div className="card p-4 flex flex-wrap items-center gap-3">
          <p className="text-sm text-[var(--mute)] flex-1 min-w-[200px]">
            {tutor.verification_status === 'verified'
              ? 'Tutor ini terverifikasi. Keputusan bisa dibatalkan bila ada kesalahan.'
              : 'Tutor ini ditolak. Bisa disetujui ulang bila ternyata dokumennya sudah benar.'}
          </p>
          {tutor.verification_status === 'verified' ? (
            <button type="button" onClick={() => setModal('revoke')} disabled={updating} className="btn text-[#B45309] border-[#FCD34D] hover:bg-[#FEF3C7] disabled:opacity-50">
              Cabut verifikasi
            </button>
          ) : (
            <button type="button" onClick={() => setModal('approve')} disabled={updating} className="btn text-[#166534] border-[#86EFAC] hover:bg-[#DCFCE7] disabled:opacity-50">
              <CheckCircle2 size={16} />
              Setujui
            </button>
          )}
        </div>
      )}

      {/* Note */}
      {tutor.verification_note && (
        <div className="bg-[#FEF3C7] border border-[#FCD34D] rounded-xl p-4 text-sm text-[#92400E]">
          <strong>Catatan:</strong> {tutor.verification_note}
        </div>
      )}

      {/* Informasi Tutor */}
      <div className="card p-5 space-y-4">
        <h2 className="font-bold text-[var(--ink)] flex items-center gap-2">
          <UserIcon size={18} className="text-[var(--blue)]" />
          Informasi Tutor
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <p className="text-xs text-[var(--mute)] mb-1">Bio</p>
            <p className="text-sm text-[var(--ink)]">
              {tutor.bio || 'Belum ada bio'}
            </p>
          </div>
          <div>
            <p className="text-xs text-[var(--mute)] mb-1">Mata Pelajaran</p>
            <div className="flex flex-wrap gap-1.5">
              {tutor.subjects?.length > 0 ? (
                tutor.subjects.map((s) => (
                  <span
                    key={s}
                    className="text-xs px-2 py-1 rounded-lg bg-[var(--blue)]/10 text-[var(--blue)] font-semibold inline-flex items-center gap-1"
                  >
                    <BookOpen size={12} />
                    {s}
                  </span>
                ))
              ) : (
                <span className="text-sm text-[var(--mute)]">-</span>
              )}
            </div>
          </div>
          <div>
            <p className="text-xs text-[var(--mute)] mb-1">Jenjang Diajar</p>
            <div className="flex flex-wrap gap-1.5">
              {tutor.jenjang_diajar?.length > 0 ? (
                tutor.jenjang_diajar.map((j) => (
                  <span
                    key={j}
                    className="text-xs px-2 py-1 rounded-lg bg-[#CCFBF1] text-[#0F766E] font-semibold inline-flex items-center gap-1"
                  >
                    <GraduationCap size={12} />
                    {j}
                  </span>
                ))
              ) : (
                <span className="text-sm text-[var(--mute)]">-</span>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Kontak dan rekening (hanya admin) */}
      <div className="card p-5 space-y-3">
        <h2 className="font-bold text-[var(--ink)] flex items-center gap-2">
          <Phone size={18} className="text-[var(--blue)]" />
          Kontak &amp; Rekening
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm">
          <div><p className="text-xs text-[var(--mute)] mb-1">WhatsApp</p><p className="text-[var(--ink)]">{priv.whatsapp || '-'}</p></div>
          <div><p className="text-xs text-[var(--mute)] mb-1">Email</p><p className="text-[var(--ink)] break-all">{priv.email || '-'}</p></div>
          <div><p className="text-xs text-[var(--mute)] mb-1">Rekening / e-wallet</p><p className="text-[var(--ink)]">{priv.payout_account || '-'}</p></div>
        </div>
      </div>

      {/* Dokumen */}
      <div className="space-y-3">
        <h2 className="font-bold text-[var(--ink)]">Dokumen Verifikasi</h2>
        {documents.length === 0 ? (
          <div className="card p-8 text-center text-sm text-[var(--mute)]">
            Belum ada dokumen diunggah
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            {documents.map((doc) => (
              <DocumentPreview key={doc.id} document={doc} />
            ))}
          </div>
        )}
      </div>

      {editing && <TutorEditModal tutor={tutor} priv={priv} onClose={() => setEditing(false)} onSaved={reload} />}

      {/* Modal */}
      {modal && (
        <VerificationModal
          isOpen={true}
          mode={modal}
          tutorName={tutor.full_name}
          onClose={() => setModal(null)}
          onConfirm={handleVerify}
        />
      )}
    </div>
  );
}
import { useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { useTutorDetail } from '../hooks/useTutorDetail';
import { VerificationBadge } from '../components/tutor/VerificationBadge';
import { DocumentPreview } from '../components/tutor/DocumentPreview';
import { VerificationModal } from '../components/tutor/VerificationModal';

export function TutorDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { tutor, documents, loading, error, updating, verify } = useTutorDetail(id);
  const [modal, setModal] = useState<'approve' | 'reject' | null>(null);

  async function handleVerify(note: string) {
    if (!modal) return;
    const newStatus = modal === 'approve' ? 'verified' : 'rejected';
    await verify(newStatus, note);
  }

  if (loading) {
    return (
      <div className="flex justify-center py-20">
        <div className="w-10 h-10 border-4 border-[#1A5EAA] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !tutor) {
    return (
      <div className="bg-white rounded-2xl p-8 text-center border border-[#E5E7EB]">
        <p className="text-[#E53935] mb-4">{error ?? 'Tutor tidak ditemukan'}</p>
        <Link
          to="/tutors"
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
          to="/tutors"
          className="text-sm text-[#1A5EAA] hover:underline font-medium inline-flex items-center gap-1 mb-3"
        >
          ← Kembali ke daftar Tutor
        </Link>
        <div className="flex items-start gap-4 flex-wrap">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-[#1A5EAA] to-[#6BB5FF] flex items-center justify-center text-white text-2xl font-bold shrink-0">
            {tutor.full_name?.[0]?.toUpperCase() ?? '?'}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex flex-wrap items-center gap-2 mb-1">
              <h1 className="text-2xl font-bold text-[#1A1F3C]">
                {tutor.full_name}
              </h1>
              <VerificationBadge status={tutor.verification_status} />
            </div>
            <p className="text-sm text-[#6B7280]">
              {tutor.university ?? 'Belum ada institusi'}
              {tutor.gpa ? ` · IPK ${tutor.gpa}` : ''}
            </p>
          </div>
        </div>
      </div>

      {tutor.verification_status === 'pending' && (
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

      {tutor.verification_note && (
        <div className="bg-[#F4A200]/10 border border-[#F4A200]/30 rounded-xl p-4 text-sm text-[#1A1F3C]">
          <strong>Catatan:</strong> {tutor.verification_note}
        </div>
      )}

      <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB] space-y-4">
        <h2 className="font-bold text-[#1A1F3C]">Informasi Tutor</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <p className="text-xs text-[#6B7280] mb-1">Bio</p>
            <p className="text-sm text-[#1A1F3C]">
              {tutor.bio || 'Belum ada bio'}
            </p>
          </div>
          <div>
            <p className="text-xs text-[#6B7280] mb-1">Mata Pelajaran</p>
            <div className="flex flex-wrap gap-1.5">
              {tutor.subjects?.length > 0 ? (
                tutor.subjects.map((s) => (
                  <span
                    key={s}
                    className="text-xs px-2 py-1 rounded-lg bg-[#1A5EAA]/10 text-[#1A5EAA] font-medium"
                  >
                    {s}
                  </span>
                ))
              ) : (
                <span className="text-sm text-[#9CA3AF]">-</span>
              )}
            </div>
          </div>
          <div>
            <p className="text-xs text-[#6B7280] mb-1">Jenjang Diajar</p>
            <div className="flex flex-wrap gap-1.5">
              {tutor.jenjang_diajar?.length > 0 ? (
                tutor.jenjang_diajar.map((j) => (
                  <span
                    key={j}
                    className="text-xs px-2 py-1 rounded-lg bg-[#00BFA5]/10 text-[#00BFA5] font-medium"
                  >
                    {j}
                  </span>
                ))
              ) : (
                <span className="text-sm text-[#9CA3AF]">-</span>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="space-y-3">
        <h2 className="font-bold text-[#1A1F3C]">Dokumen Verifikasi</h2>
        {documents.length === 0 ? (
          <div className="bg-white rounded-2xl p-8 text-center border border-[#E5E7EB] text-sm text-[#6B7280]">
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
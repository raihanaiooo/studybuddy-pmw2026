import { useState } from 'react';

interface Props {
  isOpen: boolean;
  mode: 'approve' | 'reject';
  tutorName: string;
  onClose: () => void;
  onConfirm: (note: string) => Promise<void>;
}

export function VerificationModal({
  isOpen,
  mode,
  tutorName,
  onClose,
  onConfirm,
}: Props) {
  const [note, setNote] = useState('');
  const [loading, setLoading] = useState(false);

  if (!isOpen) return null;

  const isApprove = mode === 'approve';
  const title = isApprove ? 'Setujui Tutor' : 'Tolak Verifikasi';
  const buttonText = isApprove ? 'Ya, Setujui' : 'Ya, Tolak';
  const buttonColor = isApprove ? 'bg-[#00C853] hover:bg-[#00A84A]' : 'bg-[#E53935] hover:bg-[#C62828]';

  async function handleConfirm() {
    if (!isApprove && !note.trim()) {
      alert('Catatan alasan wajib diisi saat menolak');
      return;
    }
    setLoading(true);
    try {
      await onConfirm(note.trim());
      setNote('');
      onClose();
    } catch (e) {
      alert(e instanceof Error ? e.message : 'Terjadi kesalahan');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6">
        <h3 className="text-lg font-bold text-[#1A1F3C] mb-2">{title}</h3>
        <p className="text-sm text-[#6B7280] mb-4">
          {isApprove
            ? `Setujui verifikasi ${tutorName}? Tutor akan bisa menerima booking.`
            : `Tolak verifikasi ${tutorName}? Tutor akan diminta upload ulang.`}
        </p>

        <div className="mb-4">
          <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
            Catatan {isApprove ? '(opsional)' : '(wajib)'}
          </label>
          <textarea
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder={
              isApprove
                ? 'Catatan tambahan (opsional)...'
                : 'Jelaskan alasan penolakan...'
            }
            rows={3}
            className="w-full px-4 py-3 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA] focus:ring-2 focus:ring-[#1A5EAA]/20 resize-none"
          />
        </div>

        <div className="flex gap-3">
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            className="flex-1 px-4 py-3 rounded-xl border border-[#E5E7EB] text-[#6B7280] font-semibold hover:bg-[#F5F6FA] transition-colors"
          >
            Batal
          </button>
          <button
            type="button"
            onClick={handleConfirm}
            disabled={loading}
            className={`flex-1 px-4 py-3 rounded-xl text-white font-semibold transition-colors flex items-center justify-center gap-2 ${buttonColor} disabled:opacity-50`}
          >
            {loading ? (
              <>
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Memproses...
              </>
            ) : (
              buttonText
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
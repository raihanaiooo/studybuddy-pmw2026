import { useState } from 'react';

type ActionType = 'in_review' | 'resolved' | 'rejected';

interface Props {
  isOpen: boolean;
  action: ActionType;
  onClose: () => void;
  onConfirm: (note: string) => Promise<void>;
}

const config: Record<ActionType, { title: string; button: string; color: string }> = {
  in_review: {
    title: 'Tandai Sedang Ditinjau',
    button: 'Tandai Ditinjau',
    color: 'bg-[#1A5EAA] hover:bg-[#154A87]',
  },
  resolved: {
    title: 'Selesaikan Komplain',
    button: 'Ya, Selesaikan',
    color: 'bg-[#00C853] hover:bg-[#00A84A]',
  },
  rejected: {
    title: 'Tolak Komplain',
    button: 'Ya, Tolak',
    color: 'bg-[#E53935] hover:bg-[#C62828]',
  },
};

export function ComplaintHandleModal({
  isOpen,
  action,
  onClose,
  onConfirm,
}: Props) {
  const [note, setNote] = useState('');
  const [loading, setLoading] = useState(false);

  if (!isOpen) return null;

  const c = config[action];

  async function handleConfirm() {
    if (action === 'rejected' && !note.trim()) {
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
        <h3 className="text-lg font-bold text-[#1A1F3C] mb-4">{c.title}</h3>

        <div className="mb-4">
          <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
            Catatan {action === 'rejected' ? '(wajib)' : '(opsional)'}
          </label>
          <textarea
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder={
              action === 'resolved'
                ? 'Tindakan yang sudah dilakukan...'
                : action === 'rejected'
                ? 'Jelaskan alasan penolakan...'
                : 'Catatan untuk komplain ini...'
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
            className={`flex-1 px-4 py-3 rounded-xl text-white font-semibold transition-colors flex items-center justify-center gap-2 ${c.color} disabled:opacity-50`}
          >
            {loading ? (
              <>
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Memproses...
              </>
            ) : (
              c.button
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
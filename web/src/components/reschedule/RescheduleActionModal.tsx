import { useState } from 'react';

type ActionType = 'approve' | 'reject';

interface Props {
  isOpen: boolean;
  action: ActionType;
  onClose: () => void;
  onConfirm: (note: string) => Promise<void>;
}

const config: Record<ActionType, { title: string; button: string; color: string }> = {
  approve: {
    title: 'Setujui Reschedule',
    button: 'Ya, Setujui',
    color: 'bg-[#00C853] hover:bg-[#00A84A]',
  },
  reject: {
    title: 'Tolak Reschedule',
    button: 'Ya, Tolak',
    color: 'bg-[#E53935] hover:bg-[#C62828]',
  },
};

export function RescheduleActionModal({
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
    if (action === 'reject' && !note.trim()) {
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
        <h3 className="text-lg font-bold text-[#1A1F3C] mb-2">{c.title}</h3>
        <p className="text-sm text-[#6B7280] mb-4">
          {action === 'approve'
            ? 'Jadwal booking akan diubah ke jadwal baru yang diajukan.'
            : 'Pengajuan reschedule ini akan ditolak.'}
        </p>

        <div className="mb-4">
          <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
            Catatan {action === 'reject' ? '(wajib)' : '(opsional)'}
          </label>
          <textarea
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder={
              action === 'approve'
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
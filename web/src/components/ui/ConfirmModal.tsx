import type { ReactNode } from 'react';
import { AlertCircle, X } from 'lucide-react';

interface ConfirmModalProps {
  isOpen: boolean;
  title: string;
  description: string | ReactNode;
  confirmText?: string;
  cancelText?: string;
  isDestructive?: boolean;
  onConfirm: () => void;
  onClose: () => void;
}

export function ConfirmModal({
  isOpen,
  title,
  description,
  confirmText = 'Ya, Lanjutkan',
  cancelText = 'Batal',
  isDestructive = false,
  onConfirm,
  onClose,
}: ConfirmModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/40 z-[90] flex items-center justify-center p-4">
      <div className="card w-full max-w-md p-6 relative">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-1.5 rounded-lg text-[var(--mute)] hover:bg-[var(--hov)]"
        >
          <X size={18} />
        </button>

        <div className={`w-12 h-12 rounded-full flex items-center justify-center mb-4 ${isDestructive ? 'bg-[#FEE2E2] text-[#991B1B]' : 'bg-[#DBEAFE] text-[var(--blue)]'}`}>
          <AlertCircle size={24} />
        </div>

        <h3 className="text-lg font-bold text-[var(--ink)] mb-2">{title}</h3>
        <div className="text-sm text-[var(--mute)] mb-6">{description}</div>

        <div className="flex gap-3 justify-end">
          <button onClick={onClose} className="btn">
            {cancelText}
          </button>
          <button
            onClick={() => { onConfirm(); onClose(); }}
            className={`btn text-white ${isDestructive ? 'bg-[#E53935] hover:bg-[#C62828] border-none' : 'btn-p'}`}
          >
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  );
}
import { useEffect, useState } from 'react';
import { CheckCircle2, AlertCircle, X } from 'lucide-react';

export type ToastType = 'success' | 'error';

interface ToastProps {
  message: string;
  type: ToastType;
  onClose: () => void;
}

export function Toast({ message, type, onClose }: ToastProps) {
  useEffect(() => {
    const timer = setTimeout(onClose, 3000);
    return () => clearTimeout(timer);
  }, [onClose]);

  return (
    <div className={`fixed top-6 right-6 z-[100] flex items-start gap-3 p-4 rounded-xl border shadow-lg max-w-sm animate-in slide-in-from-top-5 fade-in duration-300 ${
      type === 'success'
        ? 'bg-[#DCFCE7] border-[#86EFAC] text-[#166534]'
        : 'bg-[#FEE2E2] border-[#FCA5A5] text-[#991B1B]'
    }`}>
      {type === 'success' ? <CheckCircle2 size={20} className="shrink-0" /> : <AlertCircle size={20} className="shrink-0" />}
      <p className="text-sm font-semibold flex-1">{message}</p>
      <button onClick={onClose} className="opacity-50 hover:opacity-100 transition-opacity">
        <X size={16} />
      </button>
    </div>
  );
}
import { useEffect, useState } from 'react';
import { CheckCircle2, AlertCircle, Info, X } from 'lucide-react';

type ModalType = 'alert' | 'confirm' | 'prompt';

interface ModalState {
  type: ModalType;
  title: string;
  message: string;
  onResult: (value: any) => void;
}

export function GlobalUIManager() {
  const [modal, setModal] = useState<ModalState | null>(null);
  const [inputValue, setInputValue] = useState('');
  const [toast, setToast] = useState<{ msg: string; type: 'success' | 'error' } | null>(null);

  useEffect(() => {
    // FUNGSI PENAHAN: Ngeblokir kode JS sampai user klik tombol di modal
    const waitForResult = () => {
      return new Promise((resolve) => {
        (window as any).__resolveModal = resolve;
      });
    };

    window.alert = (async (message: string) => {
      setModal({ type: 'alert', title: 'Informasi', message, onResult: () => {} });
      await waitForResult(); // TAHAN DI SINI SAMPAI DIKLIK
    }) as any;

    window.confirm = (async (message: string) => {
      setModal({ type: 'confirm', title: 'Konfirmasi', message, onResult: (val) => {} });
      const result = await waitForResult(); // TAHAN DI SINI
      return result;
    }) as any;

    window.prompt = (async (message: string, defaultValue?: string) => {
      setInputValue(defaultValue || '');
      setModal({ type: 'prompt', title: 'Input Data', message, onResult: (val) => {} });
      const result = await waitForResult(); // TAHAN DI SINI
      return result;
    }) as any;

    (window as any).showToast = (msg: string, type: 'success' | 'error' = 'success') => {
      setToast({ msg, type });
      setTimeout(() => setToast(null), 3000);
    };
  }, []);

  const handleClose = (result: any) => {
    if (modal) {
      // Lanjutkan kode yang tadi ketahan
      if ((window as any).__resolveModal) {
        (window as any).__resolveModal(result);
        (window as any).__resolveModal = null;
      }
      setModal(null);
    }
  };

  return (
    <>
      {/* ... (TOAST & MODAL SAMA PERSIS KAYAK SEBELUMNYA) ... */}
      {toast && (
        <div className={`fixed top-6 right-6 z-[9999] flex items-start gap-3 p-4 rounded-xl border shadow-lg max-w-sm ${
          toast.type === 'success'
            ? 'bg-[#DCFCE7] border-[#86EFAC] text-[#166534]'
            : 'bg-[#FEE2E2] border-[#FCA5A5] text-[#991B1B]'
        }`}>
          {toast.type === 'success' ? <CheckCircle2 size={20} className="shrink-0" /> : <AlertCircle size={20} className="shrink-0" />}
          <p className="text-sm font-semibold flex-1">{toast.msg}</p>
          <button onClick={() => setToast(null)} className="opacity-50 hover:opacity-100 transition-opacity">
            <X size={16} />
          </button>
        </div>
      )}

      {modal && (
        <div className="fixed inset-0 bg-black/40 z-[9998] flex items-center justify-center p-4 backdrop-blur-sm">
          <div className="card w-full max-w-md p-6 relative">
            <div className="flex items-center gap-3 mb-4">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                modal.type === 'confirm' ? 'bg-[#FEF3C7] text-[#92400E]' : 'bg-[#DBEAFE] text-[var(--blue)]'
              }`}>
                {modal.type === 'confirm' ? <AlertCircle size={20} /> : <Info size={20} />}
              </div>
              <h3 className="text-lg font-bold text-[var(--ink)]">{modal.title}</h3>
            </div>

            <p className="text-sm text-[var(--mute)] mb-4 whitespace-pre-wrap">{modal.message}</p>

            {modal.type === 'prompt' && (
              <input
                type="text"
                className="inp w-full mb-4"
                value={inputValue}
                onChange={(e) => setInputValue(e.target.value)}
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === 'Enter') handleClose(inputValue);
                  if (e.key === 'Escape') handleClose(null);
                }}
              />
            )}

            <div className="flex gap-2 justify-end mt-6">
              {modal.type !== 'alert' && (
                <button onClick={() => handleClose(modal.type === 'confirm' ? false : null)} className="btn">
                  Batal
                </button>
              )}
              <button
                onClick={() => handleClose(modal.type === 'confirm' ? true : modal.type === 'prompt' ? inputValue : undefined)}
                className="btn btn-p"
              >
                {modal.type === 'alert' ? 'OK' : 'Lanjutkan'}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
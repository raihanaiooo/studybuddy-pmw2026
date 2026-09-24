import { useState } from 'react';
import { MONTH_NAMES } from '../../types/payroll';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: (month: number, year: number) => Promise<{ created: number; skipped: number }>;
}

export function GeneratePayrollModal({ isOpen, onClose, onConfirm }: Props) {
  const now = new Date();
  const [month, setMonth] = useState(now.getMonth() + 1);
  const [year, setYear] = useState(now.getFullYear());
  const [loading, setLoading] = useState(false);

  if (!isOpen) return null;

  async function handleGenerate() {
    setLoading(true);
    try {
      const result = await onConfirm(month, year);
      alert(
        `Berhasil generate payroll!\n\nDibuat: ${result.created}\nDilewati: ${result.skipped}`
      );
      onClose();
    } catch (e) {
      alert(e instanceof Error ? e.message : 'Terjadi kesalahan');
    } finally {
      setLoading(false);
    }
  }

  const years = Array.from({ length: 5 }, (_, i) => now.getFullYear() - i);

  return (
    <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6">
        <h3 className="text-lg font-bold text-[#1A1F3C] mb-2">
          Generate Payroll
        </h3>
        <p className="text-sm text-[#6B7280] mb-4">
          Sistem akan menghitung komisi 70% untuk semua sesi selesai & dibayar
          pada periode yang dipilih.
        </p>

        <div className="grid grid-cols-2 gap-3 mb-4">
          <div>
            <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
              Bulan
            </label>
            <select
              value={month}
              onChange={(e) => setMonth(Number(e.target.value))}
              className="w-full px-4 py-3 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA] focus:ring-2 focus:ring-[#1A5EAA]/20"
            >
              {MONTH_NAMES.map((name, i) => (
                <option key={i + 1} value={i + 1}>
                  {name}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
              Tahun
            </label>
            <select
              value={year}
              onChange={(e) => setYear(Number(e.target.value))}
              className="w-full px-4 py-3 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA] focus:ring-2 focus:ring-[#1A5EAA]/20"
            >
              {years.map((y) => (
                <option key={y} value={y}>
                  {y}
                </option>
              ))}
            </select>
          </div>
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
            onClick={handleGenerate}
            disabled={loading}
            className="flex-1 px-4 py-3 rounded-xl bg-[#1A5EAA] hover:bg-[#154A87] text-white font-semibold transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {loading ? (
              <>
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Memproses...
              </>
            ) : (
              'Generate'
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
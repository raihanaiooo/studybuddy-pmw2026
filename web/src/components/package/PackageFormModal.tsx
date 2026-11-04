import { useEffect, useState } from 'react';
import { X, Save, Loader2 } from 'lucide-react';
import type { Package, PackageFormData } from '../../types/package';

interface Props {
  isOpen: boolean;
  editing: Package | null;
  onClose: () => void;
  onSubmit: (data: PackageFormData) => Promise<void>;
}

const emptyForm: PackageFormData = {
  package_name: '',
  session_count: 1,
  validity_days: 35,
  reschedule_quota: 0,
  max_tutors: 1,
  is_refundable: false,
  price: 0,
  description: '',
  is_active: true,
};

export function PackageFormModal({ isOpen, editing, onClose, onSubmit }: Props) {
  const [form, setForm] = useState<PackageFormData>(emptyForm);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (editing) {
      setForm({
        package_name: editing.package_name,
        session_count: editing.session_count,
        validity_days: editing.validity_days,
        reschedule_quota: editing.reschedule_quota,
        max_tutors: editing.max_tutors ?? 1,
        is_refundable: editing.is_refundable,
        price: editing.price,
        description: editing.description ?? '',
        is_active: editing.is_active,
      });
    } else {
      setForm(emptyForm);
    }
  }, [editing, isOpen]);

  if (!isOpen) return null;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!form.package_name.trim()) {
      await (window.alert as any)('Nama paket wajib diisi');
      return;
    }
    if (form.price <= 0) {
      await (window.alert as any)('Harga harus lebih dari 0');
      return;
    }
    if (form.max_tutors < 1) {
      await (window.alert as any)('Max Tutor minimal 1');
      return;
    }
    setSaving(true);
    try {
      await onSubmit(form);
      onClose();
    } catch (e) {
      await (window.alert as any)(e instanceof Error ? e.message : 'Terjadi kesalahan');
    } finally {
      setSaving(false);
    }
  }

  function update<K extends keyof PackageFormData>(
    key: K,
    value: PackageFormData[K]
  ) {
    setForm({ ...form, [key]: value });
  }

  return (
    <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4 overflow-y-auto">
      <div className="card shadow-2xl max-w-lg w-full p-6 my-4">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold text-[var(--ink)]">
            {editing ? 'Edit Paket' : 'Tambah Paket Baru'}
          </h3>
          <button
            type="button"
            onClick={onClose}
            disabled={saving}
            className="p-1.5 rounded-lg text-[var(--mute)] hover:bg-[var(--hov)] disabled:opacity-50"
            aria-label="Tutup"
          >
            <X size={18} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-semibold text-[var(--ink)] mb-2">
              Nama Paket *
            </label>
            <input
              type="text"
              value={form.package_name}
              onChange={(e) => update('package_name', e.target.value)}
              placeholder="Misal: Bundling Bulanan (12 Sesi)"
              className="inp"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-semibold text-[var(--ink)] mb-2">
                Jumlah Sesi *
              </label>
              <input
                type="number"
                min={1}
                value={form.session_count}
                onChange={(e) =>
                  update('session_count', Number(e.target.value) || 1)
                }
                className="inp"
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-[var(--ink)] mb-2">
                Berlaku (hari) *
              </label>
              <input
                type="number"
                min={1}
                max={35}
                value={form.validity_days}
                onChange={(e) =>
                  update('validity_days', Number(e.target.value) || 1)
                }
                className="inp"
              />
              <p className="text-xs text-[var(--mute)] mt-1">Maks 35 hari</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-semibold text-[var(--ink)] mb-2">
                Kuota Reschedule
              </label>
              <input
                type="number"
                min={0}
                max={10}
                value={form.reschedule_quota}
                onChange={(e) =>
                  update('reschedule_quota', Number(e.target.value) || 0)
                }
                className="inp"
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-[var(--ink)] mb-2">
                Max Tutor *
              </label>
              <input
                type="number"
                min={1}
                max={10}
                value={form.max_tutors}
                onChange={(e) =>
                  update('max_tutors', Number(e.target.value) || 1)
                }
                className="inp"
              />
              <p className="text-xs text-[var(--mute)] mt-1">
                3-12 sesi: max 2 · Bulanan: max 4
              </p>
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-[var(--ink)] mb-2">
              Harga (Rp) *
            </label>
            <input
              type="number"
              min={0}
              value={form.price}
              onChange={(e) => update('price', Number(e.target.value) || 0)}
              className="inp"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-[var(--ink)] mb-2">
              Deskripsi
            </label>
            <textarea
              value={form.description}
              onChange={(e) => update('description', e.target.value)}
              rows={2}
              className="inp resize-none"
            />
          </div>

          <div className="flex flex-wrap gap-4">
            <label className="flex items-center gap-2 cursor-pointer select-none">
              <input
                type="checkbox"
                checked={form.is_refundable}
                onChange={(e) => update('is_refundable', e.target.checked)}
                className="w-4 h-4 rounded accent-[var(--blue)]"
              />
              <span className="text-sm font-semibold text-[var(--ink)]">
                Bisa refund
              </span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer select-none">
              <input
                type="checkbox"
                checked={form.is_active}
                onChange={(e) => update('is_active', e.target.checked)}
                className="w-4 h-4 rounded accent-[var(--blue)]"
              />
              <span className="text-sm font-semibold text-[var(--ink)]">
                Aktif
              </span>
            </label>
          </div>

          <div className="flex gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              disabled={saving}
              className="btn flex-1 justify-center"
            >
              Batal
            </button>
            <button
              type="submit"
              disabled={saving}
              className="btn btn-p flex-1 justify-center disabled:opacity-50"
            >
              {saving ? (
                <>
                  <Loader2 size={16} className="animate-spin" />
                  Menyimpan...
                </>
              ) : (
                <>
                  <Save size={16} />
                  Simpan
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
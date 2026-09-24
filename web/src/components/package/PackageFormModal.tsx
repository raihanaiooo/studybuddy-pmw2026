import { useEffect, useState } from 'react';
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
      alert('Nama paket wajib diisi');
      return;
    }
    if (form.price <= 0) {
      alert('Harga harus lebih dari 0');
      return;
    }
    setSaving(true);
    try {
      await onSubmit(form);
      onClose();
    } catch (e) {
      alert(e instanceof Error ? e.message : 'Terjadi kesalahan');
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
      <div className="bg-white rounded-2xl shadow-2xl max-w-lg w-full p-6 my-4">
        <h3 className="text-lg font-bold text-[#1A1F3C] mb-4">
          {editing ? 'Edit Paket' : 'Tambah Paket Baru'}
        </h3>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
              Nama Paket *
            </label>
            <input
              type="text"
              value={form.package_name}
              onChange={(e) => update('package_name', e.target.value)}
              placeholder="Misal: Bundling Bulanan (12 Sesi)"
              className="w-full px-4 py-3 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA]"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
                Jumlah Sesi *
              </label>
              <input
                type="number"
                min={1}
                value={form.session_count}
                onChange={(e) =>
                  update('session_count', Number(e.target.value) || 1)
                }
                className="w-full px-4 py-3 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA]"
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
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
                className="w-full px-4 py-3 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA]"
              />
              <p className="text-xs text-[#9CA3AF] mt-1">Maks 35 hari</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
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
                className="w-full px-4 py-3 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA]"
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
                Harga (Rp) *
              </label>
              <input
                type="number"
                min={0}
                value={form.price}
                onChange={(e) => update('price', Number(e.target.value) || 0)}
                className="w-full px-4 py-3 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA]"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-[#1A1F3C] mb-2">
              Deskripsi
            </label>
            <textarea
              value={form.description}
              onChange={(e) => update('description', e.target.value)}
              rows={2}
              className="w-full px-4 py-3 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA] resize-none"
            />
          </div>

          <div className="flex flex-wrap gap-4">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={form.is_refundable}
                onChange={(e) => update('is_refundable', e.target.checked)}
                className="w-4 h-4 rounded"
              />
              <span className="text-sm text-[#1A1F3C]">Bisa refund</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={form.is_active}
                onChange={(e) => update('is_active', e.target.checked)}
                className="w-4 h-4 rounded"
              />
              <span className="text-sm text-[#1A1F3C]">Aktif</span>
            </label>
          </div>

          <div className="flex gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              disabled={saving}
              className="flex-1 px-4 py-3 rounded-xl border border-[#E5E7EB] text-[#6B7280] font-semibold hover:bg-[#F5F6FA]"
            >
              Batal
            </button>
            <button
              type="submit"
              disabled={saving}
              className="flex-1 px-4 py-3 rounded-xl bg-[#1A5EAA] text-white font-semibold hover:bg-[#154A87] disabled:opacity-50 flex items-center justify-center gap-2"
            >
              {saving ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  Menyimpan...
                </>
              ) : (
                'Simpan'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
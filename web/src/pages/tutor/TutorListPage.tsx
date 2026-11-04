import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Search,
  Eye,
  CheckCircle2,
  XCircle,
  LayoutGrid,
  List,
  Users,
  Loader2,
  AlertCircle,
  Star,
  Plus
} from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { useTutors } from '../../hooks/useTutors';
import { TutorCard } from '../../components/tutor/TutorCard';
import type { VerificationStatus } from '../../types/tutor';
import { AddTutorModal } from '../../components/tutor/AddTutorModal';

type FilterStatus = VerificationStatus | 'all';
type ViewMode = 'grid' | 'table';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'pending', label: 'Menunggu' },
  { key: 'verified', label: 'Terverifikasi' },
  { key: 'rejected', label: 'Ditolak' },
  { key: 'all', label: 'Semua' },
];

const getInitials = (name?: string) => {
  if (!name) return '?';
  return name
    .split(' ')
    .map((w) => w[0])
    .slice(0, 2)
    .join('')
    .toUpperCase();
};

const renderBadge = (status: VerificationStatus) => {
  if (status === 'verified')
    return <span className="badge b-done"><i />Terverifikasi</span>;
  if (status === 'rejected')
    return <span className="badge b-no"><i />Ditolak</span>;
  return <span className="badge b-pending"><i />Menunggu</span>;
};

export function TutorListPage() {
  const navigate = useNavigate();
  const {
    tutors,
    filter,
    setFilter,
    search,
    setSearch,
    loading,
    error,
    reload // <--- Ambil reload dari hook
  } = useTutors();

  const [viewMode, setViewMode] = useState<ViewMode>('table');
  const [loadingId, setLoadingId] = useState<string | null>(null);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  async function updateVerification(
    id: string,
    status: 'verified' | 'rejected'
  ) {
    let note: string | null = null;
    if (status === 'rejected') {
      const input = await (window.prompt as any)('Masukkan alasan penolakan (wajib):');
      if (input === null) return;
      if (input.trim() === '') {
        await (window.alert as any)('Alasan penolakan tidak boleh kosong!');
        return;
      }
      note = input.trim();
    }

    setLoadingId(id);
    const { error: updErr } = await supabase
      .from('tutors')
      .update({ verification_status: status, verification_note: note })
      .eq('id', id);

    if (updErr) {
      await (window.alert as any)(updErr.message);
    } else {
      // Panggil reload biar tabel update
      reload();
    }
    setLoadingId(null);
  }

  // Fungsi Toggle Featured untuk Landing Page
  async function toggleFeatured(id: string, currentStatus: boolean) {
    setLoadingId(id);
    const { error } = await supabase
      .from('tutors')
      .update({ is_featured: !currentStatus })
      .eq('id', id);

    if (error) {
      await (window.alert as any)(error.message);
    } else {
      // Panggil reload biar tabel update
      reload();
    }
    setLoadingId(null);
  }

  // Karena hook useTutors udah nge-handle filter status & search,
  // kita nggak perlu filter manual lagi di sini.
  // Langsung pakai `tutors` aja.

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-extrabold text-[var(--ink)]">
            Verifikasi Tutor
          </h1>
          <p className="text-sm text-[var(--mute)] mt-1">
            Tinjau dokumen, verifikasi, & pilih tutor untuk tampil di Landing Page
          </p>
        </div>
        <button
          onClick={() => setIsAddModalOpen(true)}
          className="btn btn-p shrink-0"
        >
          <Plus size={18} /> Tambah Tutor Manual
        </button>
      </div>

      {/* Filters + view toggle */}
      <div className="card p-4 space-y-3">
        <div className="flex flex-col sm:flex-row gap-3 sm:items-center sm:justify-between">
          <div className="relative w-full sm:max-w-xs">
            <Search
              className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--mute)] pointer-events-none"
              size={18}
            />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Cari nama atau kampus..."
              className="inp pl-10"
            />
          </div>

          <div className="flex items-center gap-1 p-1 bg-[var(--soft)] rounded-xl self-start sm:self-auto">
            <button
              type="button"
              onClick={() => setViewMode('table')}
              aria-pressed={viewMode === 'table'}
              className="seg flex items-center gap-1.5"
            >
              <List size={16} />
              Tabel
            </button>
            <button
              type="button"
              onClick={() => setViewMode('grid')}
              aria-pressed={viewMode === 'grid'}
              className="seg flex items-center gap-1.5"
            >
              <LayoutGrid size={16} />
              Grid
            </button>
          </div>
        </div>

        <div className="flex flex-wrap gap-2">
          {filters.map((f) => (
            <button
              key={f.key}
              type="button"
              onClick={() => setFilter(f.key)}
              className={`px-4 py-2 rounded-xl text-sm font-bold transition-colors ${
                filter === f.key
                  ? 'bg-[var(--blue)] text-white'
                  : 'bg-[var(--soft)] text-[var(--mute)] hover:bg-[var(--hov)]'
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {/* Loading */}
      {loading && (
        <div className="flex justify-center py-20">
          <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {/* Error */}
      {error && (
        <div className="bg-[#FEE2E2] border border-[#FCA5A5] text-[#991B1B] text-sm rounded-xl p-4 flex items-start gap-2">
          <AlertCircle size={18} className="shrink-0 mt-0.5" />
          <span>{error}</span>
        </div>
      )}

      {/* Empty */}
      {!loading && !error && tutors.length === 0 && (
        <div className="card p-12 text-center">
          <Users size={48} className="mx-auto text-[var(--mute)] mb-3" />
          <p className="font-bold text-[var(--ink)]">Tidak ada Tutor</p>
          <p className="text-sm text-[var(--mute)] mt-1">
            {search
              ? 'Coba kata kunci lain'
              : 'Belum ada Tutor dengan status ini'}
          </p>
        </div>
      )}

      {/* Grid view */}
      {!loading &&
        !error &&
        tutors.length > 0 &&
        viewMode === 'grid' && (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            {tutors.map((tutor) => (
              <TutorCard key={tutor.id} tutor={tutor} />
            ))}
          </div>
        )}

      {/* Table view */}
      {!loading &&
        !error &&
        tutors.length > 0 &&
        viewMode === 'table' && (
          <div className="card overflow-hidden">
            <div className="overflow-x-auto">
              <table>
                <thead>
                  <tr>
                    <th>Tutor</th>
                    <th>Universitas</th>
                    <th>Status</th>
                    <th className="text-right">Aksi</th>
                  </tr>
                </thead>
                <tbody>
                  {tutors.map((t: any) => (
                    <tr key={t.id}>
                      <td>
                        <div className="flex items-center gap-3">
                          <span className="w-8 h-8 rounded-full bg-[var(--blue)] text-white grid place-items-center font-bold text-xs shrink-0">
                            {getInitials(t.full_name)}
                          </span>
                          <b className="text-[var(--ink)]">
                            {t.full_name ?? '-'}
                          </b>
                        </div>
                      </td>
                      <td className="text-[var(--mute)]">
                        {t.university || '-'}
                      </td>
                      <td>{renderBadge(t.verification_status)}</td>
                      <td className="text-right">
                        <div className="flex justify-end gap-2 items-center">

                          {/* TOMBOL FEATURED (BINTANG) */}
                          <button
                            type="button"
                            onClick={() => toggleFeatured(t.id, t.is_featured)}
                            disabled={loadingId === t.id}
                            className={`btn !py-1.5 !px-2.5 border-transparent disabled:opacity-50 ${
                              t.is_featured
                                ? 'text-[var(--blue)] bg-[var(--hov)]'
                                : 'text-[var(--mute)] hover:bg-[var(--soft)]'
                            }`}
                            title={t.is_featured ? 'Hapus dari Landing Page' : 'Tampilkan di Landing Page'}
                          >
                            {loadingId === t.id ? (
                               <Loader2 size={16} className="animate-spin" />
                            ) : (
                               <Star size={16} className={t.is_featured ? 'fill-[var(--blue)]' : ''} />
                            )}
                          </button>

                          <button
                            type="button"
                            onClick={() => navigate(`/tutors/${t.id}`)}
                            className="btn !py-1.5 !px-2.5 text-[var(--blue)] border-transparent hover:bg-[var(--hov)]"
                            title="Lihat Dokumen"
                          >
                            <Eye size={16} />
                            Detail
                          </button>

                          {t.verification_status === 'pending' && (
                            <>
                              <button
                                type="button"
                                onClick={() =>
                                  updateVerification(t.id, 'verified')
                                }
                                disabled={loadingId === t.id}
                                className="btn !py-1.5 !px-2.5 text-[#166534] border-transparent hover:bg-[#DCFCE7] disabled:opacity-50"
                                title="Setujui"
                              >
                                {loadingId === t.id ? (
                                  <Loader2
                                    size={16}
                                    className="animate-spin"
                                  />
                                ) : (
                                  <CheckCircle2 size={16} />
                                )}
                              </button>
                              <button
                                type="button"
                                onClick={() =>
                                  updateVerification(t.id, 'rejected')
                                }
                                disabled={loadingId === t.id}
                                className="btn !py-1.5 !px-2.5 text-[#991B1B] border-transparent hover:bg-[#FEE2E2] disabled:opacity-50"
                                title="Tolak"
                              >
                                <XCircle size={16} />
                              </button>
                            </>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        <AddTutorModal
          isOpen={isAddModalOpen}
          onClose={() => setIsAddModalOpen(false)}
          onSuccess={() => {
            reload(); // <--- Panggil reload dari hook, bukan window.location.reload()
          }}
        />
    </div>
  );
}
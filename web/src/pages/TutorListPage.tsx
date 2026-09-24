import { Link } from 'react-router-dom';
import { useTutors } from '../hooks/useTutors';
import { TutorCard } from '../components/tutor/TutorCard';
import type { VerificationStatus } from '../types/tutor';

type FilterStatus = VerificationStatus | 'all';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'pending', label: 'Menunggu' },
  { key: 'verified', label: 'Terverifikasi' },
  { key: 'rejected', label: 'Ditolak' },
  { key: 'all', label: 'Semua' },
];

export function TutorListPage() {
  const {
    tutors,
    filter,
    setFilter,
    search,
    setSearch,
    loading,
    error,
  } = useTutors();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[#1A1F3C]">Verifikasi Tutor</h1>
        <p className="text-sm text-[#6B7280] mt-1">
          Tinjau dokumen & verifikasi Tutor baru
        </p>
      </div>

      <div className="bg-white rounded-2xl p-4 border border-[#E5E7EB] space-y-3">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari nama Tutor..."
          className="w-full px-4 py-2.5 rounded-xl border border-[#E5E7EB] bg-[#F5F6FA] text-sm focus:outline-none focus:border-[#1A5EAA] focus:ring-2 focus:ring-[#1A5EAA]/20"
        />
        <div className="flex flex-wrap gap-2">
          {filters.map((f) => (
            <button
              key={f.key}
              onClick={() => setFilter(f.key)}
              className={`
                px-4 py-2 rounded-xl text-sm font-semibold transition-colors
                ${
                  filter === f.key
                    ? 'bg-[#1A5EAA] text-white'
                    : 'bg-[#F5F6FA] text-[#6B7280] hover:bg-[#E5E7EB]'
                }
              `}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {loading && (
        <div className="flex justify-center py-20">
          <div className="w-10 h-10 border-4 border-[#1A5EAA] border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {error && (
        <div className="bg-[#E53935]/10 border border-[#E53935]/30 text-[#E53935] text-sm rounded-xl p-4">
          {error}
        </div>
      )}

      {!loading && !error && tutors.length === 0 && (
        <div className="bg-white rounded-2xl p-12 text-center border border-[#E5E7EB]">
          <div className="text-5xl mb-3">👨‍🏫</div>
          <p className="font-semibold text-[#1A1F3C]">Tidak ada Tutor</p>
          <p className="text-sm text-[#6B7280] mt-1">
            {search
              ? 'Coba kata kunci lain'
              : 'Belum ada Tutor dengan status ini'}
          </p>
        </div>
      )}

      {!loading && !error && tutors.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {tutors.map((tutor) => (
            <TutorCard key={tutor.id} tutor={tutor} />
          ))}
        </div>
      )}
    </div>
  );
}
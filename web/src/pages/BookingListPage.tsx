import { useEffect, useState } from 'react';
import { useBookings } from '../hooks/useBookings';
import { BookingCard } from '../components/booking/BookingCard';
import { StatCard } from '../components/ui/StatCard';
import { fetchBookingStats } from '../lib/api/bookings';
import type { BookingStatus, BookingStats } from '../types/booking';

type FilterStatus = BookingStatus | 'all';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'all', label: 'Semua' },
  { key: 'pending', label: 'Menunggu' },
  { key: 'confirmed', label: 'Dikonfirmasi' },
  { key: 'ongoing', label: 'Berlangsung' },
  { key: 'completed', label: 'Selesai' },
  { key: 'cancelled', label: 'Dibatalkan' },
];

export function BookingListPage() {
  const { bookings, filter, setFilter, search, setSearch, loading, error } =
    useBookings();

  const [stats, setStats] = useState<BookingStats>({
    total: 0,
    pending: 0,
    confirmed: 0,
    ongoing: 0,
    completed: 0,
    cancelled: 0,
  });

  useEffect(() => {
    fetchBookingStats()
      .then(setStats)
      .catch((e) => console.error('Stats error', e));
  }, [bookings.length]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[#1A1F3C]">Booking</h1>
        <p className="text-sm text-[#6B7280] mt-1">
          Pantau semua booking di platform
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
        <StatCard label="Total" value={stats.total} icon="📊" color="blue" />
        <StatCard
          label="Menunggu"
          value={stats.pending}
          icon="⏳"
          color="yellow"
        />
        <StatCard
          label="Berlangsung"
          value={stats.ongoing}
          icon="🔴"
          color="green"
        />
        <StatCard
          label="Selesai"
          value={stats.completed}
          icon="✅"
          color="teal"
        />
        <StatCard
          label="Dibatalkan"
          value={stats.cancelled}
          icon="❌"
          color="red"
        />
      </div>

      {/* Filters */}
      <div className="bg-white rounded-2xl p-4 border border-[#E5E7EB] space-y-3">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari mapel, nama Buddy, atau Tutor..."
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

      {/* Content */}
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

      {!loading && !error && bookings.length === 0 && (
        <div className="bg-white rounded-2xl p-12 text-center border border-[#E5E7EB]">
          <div className="text-5xl mb-3">📅</div>
          <p className="font-semibold text-[#1A1F3C]">Tidak ada booking</p>
          <p className="text-sm text-[#6B7280] mt-1">
            {search ? 'Coba kata kunci lain' : 'Belum ada booking dengan filter ini'}
          </p>
        </div>
      )}

      {!loading && !error && bookings.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {bookings.map((b) => (
            <BookingCard key={b.id} booking={b} />
          ))}
        </div>
      )}
    </div>
  );
}
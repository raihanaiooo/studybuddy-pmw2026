import { useEffect, useState } from 'react';
import { useBookings } from '../../hooks/useBookings';
import { BookingCard } from '../../components/booking/BookingCard';
import { StatCard } from '../../components/ui/StatCard';
import { fetchBookingStats } from '../../lib/api/bookings';
import type { BookingStatus, BookingStats } from '../../types/booking';
import { Calendar, Clock, CheckCircle, XCircle, PlayCircle } from 'lucide-react';

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
  const { bookings, filter, setFilter, search, setSearch, loading, error } = useBookings();

  const [stats, setStats] = useState<BookingStats>({
    total: 0, pending: 0, confirmed: 0, ongoing: 0, completed: 0, cancelled: 0,
  });

  useEffect(() => {
    fetchBookingStats().then(setStats).catch((e) => console.error('Stats error', e));
  }, [bookings.length]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-[var(--ink)]">Booking</h1>
        <p className="text-sm text-[var(--mute)] mt-1">Pantau semua booking di platform.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
        <StatCard label="Total" value={stats.total} icon={<Calendar size={20} strokeWidth={2.5} />} color="blue" />
        <StatCard label="Menunggu" value={stats.pending} icon={<Clock size={20} strokeWidth={2.5} />} color="yellow" />
        <StatCard label="Berlangsung" value={stats.ongoing} icon={<PlayCircle size={20} strokeWidth={2.5} />} color="green" />
        <StatCard label="Selesai" value={stats.completed} icon={<CheckCircle size={20} strokeWidth={2.5} />} color="teal" />
        <StatCard label="Dibatalkan" value={stats.cancelled} icon={<XCircle size={20} strokeWidth={2.5} />} color="red" />
      </div>

      {/* Filters */}
      <div className="card p-4 space-y-3">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari mapel, nama Buddy, atau Tutor..."
          className="inp"
        />
        <div className="flex flex-wrap gap-2">
          {filters.map((f) => (
            <button
              key={f.key}
              onClick={() => setFilter(f.key)}
              className={`px-4 py-2 rounded-lg text-sm font-bold transition-colors ${
                filter === f.key ? 'bg-[var(--blue)] text-white' : 'bg-[var(--soft)] text-[var(--mute)] hover:bg-[var(--hov)]'
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {/* Content */}
      {loading && (
        <div className="flex justify-center py-20">
          <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {error && <div className="bg-red-50 border border-red-200 text-red-600 text-sm rounded-xl p-4">{error}</div>}

      {!loading && !error && bookings.length === 0 && (
        <div className="card p-12 text-center">
          <Calendar size={48} className="mx-auto text-[var(--mute)] mb-3" />
          <p className="font-bold text-[var(--ink)]">Tidak ada booking</p>
          <p className="text-sm text-[var(--mute)] mt-1">{search ? 'Coba kata kunci lain' : 'Belum ada booking dengan filter ini'}</p>
        </div>
      )}

      {!loading && !error && bookings.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {bookings.map((b) => <BookingCard key={b.id} booking={b} />)}
        </div>
      )}
    </div>
  );
}
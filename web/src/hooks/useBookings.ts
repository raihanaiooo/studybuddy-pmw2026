import { useCallback, useEffect, useState } from 'react';
import type { BookingWithRelations, BookingStatus } from '../types/booking';
import { fetchBookings } from '../lib/api/bookings';

type FilterStatus = BookingStatus | 'all';

export function useBookings(initialFilter: FilterStatus = 'all') {
  const [bookings, setBookings] = useState<BookingWithRelations[]>([]);
  const [filter, setFilter] = useState<FilterStatus>(initialFilter);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchBookings(filter);
      setBookings(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    load();
  }, [load]);

  const filtered = search.trim()
    ? bookings.filter((b) => {
        const q = search.toLowerCase();
        return (
          b.subject?.toLowerCase().includes(q) ||
          b.customer?.full_name?.toLowerCase().includes(q) ||
          b.tutor?.full_name?.toLowerCase().includes(q)
        );
      })
    : bookings;

  return {
    bookings: filtered,
    filter,
    setFilter,
    search,
    setSearch,
    loading,
    error,
    reload: load,
  };
}
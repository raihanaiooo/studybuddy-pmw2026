import { useCallback, useEffect, useState } from 'react';
import type { BookingWithRelations } from '../types/booking';
import { fetchBookingById } from '../lib/api/bookings';

export function useBookingDetail(id: string | undefined) {
  const [booking, setBooking] = useState<BookingWithRelations | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    setError(null);
    try {
      const data = await fetchBookingById(id);
      if (!data) {
        setError('Booking tidak ditemukan');
        return;
      }
      setBooking(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  return { booking, loading, error, reload: load };
}
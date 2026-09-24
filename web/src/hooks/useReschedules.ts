import { useCallback, useEffect, useState } from 'react';
import type {
  RescheduleWithRelations,
  RescheduleStatus,
} from '../types/reschedule';
import { fetchReschedules } from '../lib/api/reschedules';

type FilterStatus = RescheduleStatus | 'all';

export function useReschedules(initialFilter: FilterStatus = 'menunggu_admin') {
  const [reschedules, setReschedules] = useState<RescheduleWithRelations[]>([]);
  const [filter, setFilter] = useState<FilterStatus>(initialFilter);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchReschedules(filter);
      setReschedules(data);
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
    ? reschedules.filter((r) => {
        const q = search.toLowerCase();
        return (
          r.reason.toLowerCase().includes(q) ||
          r.requester?.full_name?.toLowerCase().includes(q) ||
          r.booking?.subject?.toLowerCase().includes(q)
        );
      })
    : reschedules;

  return {
    reschedules: filtered,
    filter,
    setFilter,
    search,
    setSearch,
    loading,
    error,
    reload: load,
  };
}
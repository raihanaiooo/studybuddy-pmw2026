import { useCallback, useEffect, useState } from 'react';
import type { TutorPerformance } from '../types/performance';
import { fetchTutorPerformance } from '../lib/api/performance';

type FilterStatus = 'all' | 'active' | 'inactive' | 'frequent_cancel';

export function useTutorPerformance(initialFilter: FilterStatus = 'all') {
  const [data, setData] = useState<TutorPerformance[]>([]);
  const [filter, setFilter] = useState<FilterStatus>(initialFilter);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await fetchTutorPerformance();
      setData(result);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const filtered = data.filter((p) => {
    // Search
    if (search.trim()) {
      const q = search.toLowerCase();
      if (!p.tutor_name?.toLowerCase().includes(q)) return false;
    }

    // Filter status
    if (filter === 'active') {
      return (
        p.days_since_last_session !== null &&
        p.days_since_last_session < 30
      );
    }
    if (filter === 'inactive') {
      return (
        p.days_since_last_session === null ||
        p.days_since_last_session >= 30
      );
    }
    if (filter === 'frequent_cancel') {
      return p.cancel_rate > 20;
    }
    return true;
  });

  return {
    data: filtered,
    filter,
    setFilter,
    search,
    setSearch,
    loading,
    error,
    reload: load,
  };
}
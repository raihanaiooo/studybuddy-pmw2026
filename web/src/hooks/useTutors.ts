import { useCallback, useEffect, useState } from 'react';
import type { Tutor, VerificationStatus } from '../types/tutor';
import { fetchTutors } from '../lib/api/tutor';

type FilterStatus = VerificationStatus | 'all';

export function useTutors(initialFilter: FilterStatus = 'pending') {
  const [tutors, setTutors] = useState<Tutor[]>([]);
  const [filter, setFilter] = useState<FilterStatus>(initialFilter);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadTutors = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchTutors(filter);
      setTutors(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    loadTutors();
  }, [loadTutors]);

  const filteredTutors = search.trim()
    ? tutors.filter((t) =>
        t.full_name?.toLowerCase().includes(search.toLowerCase())
      )
    : tutors;

  return {
    tutors: filteredTutors,
    filter,
    setFilter,
    search,
    setSearch,
    loading,
    error,
    reload: loadTutors,
  };
}
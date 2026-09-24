import { useCallback, useEffect, useState } from 'react';
import type {
  ComplaintWithRelations,
  ComplaintStatus,
} from '../types/complaint';
import { fetchComplaints } from '../lib/api/complaints';

type FilterStatus = ComplaintStatus | 'all';

export function useComplaints(initialFilter: FilterStatus = 'pending') {
  const [complaints, setComplaints] = useState<ComplaintWithRelations[]>([]);
  const [filter, setFilter] = useState<FilterStatus>(initialFilter);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchComplaints(filter);
      setComplaints(data);
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
    ? complaints.filter((c) => {
        const q = search.toLowerCase();
        return (
          c.description.toLowerCase().includes(q) ||
          c.reporter?.full_name?.toLowerCase().includes(q) ||
          c.booking?.subject?.toLowerCase().includes(q)
        );
      })
    : complaints;

  return {
    complaints: filtered,
    filter,
    setFilter,
    search,
    setSearch,
    loading,
    error,
    reload: load,
  };
}
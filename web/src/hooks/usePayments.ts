import { useCallback, useEffect, useState } from 'react';
import type { PaymentWithRelations, PaymentStatus } from '../types/payment';
import { fetchPayments } from '../lib/api/payment';

type FilterStatus = PaymentStatus | 'all';

export function usePayments(initialFilter: FilterStatus = 'all') {
  const [payments, setPayments] = useState<PaymentWithRelations[]>([]);
  const [filter, setFilter] = useState<FilterStatus>(initialFilter);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchPayments(filter);
      setPayments(data);
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
    ? payments.filter((p) => {
        const q = search.toLowerCase();
        return (
          p.id.toLowerCase().includes(q) ||
          p.external_ref?.toLowerCase().includes(q) ||
          p.booking?.subject?.toLowerCase().includes(q)
        );
      })
    : payments;

  return {
    payments: filtered,
    filter,
    setFilter,
    search,
    setSearch,
    loading,
    error,
    reload: load,
  };
}
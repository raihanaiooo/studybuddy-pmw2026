import { useCallback, useEffect, useState } from 'react';
import type { PayrollWithRelations, PayrollStatus } from '../types/payroll';
import { fetchPayrolls, generatePayroll } from '../lib/api/payroll';

type FilterStatus = PayrollStatus | 'all';

export function usePayrolls(initialFilter: FilterStatus = 'all') {
  const [payrolls, setPayrolls] = useState<PayrollWithRelations[]>([]);
  const [filter, setFilter] = useState<FilterStatus>(initialFilter);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchPayrolls(filter);
      setPayrolls(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    load();
  }, [load]);

  const generate = useCallback(
    async (month: number, year: number) => {
      setGenerating(true);
      try {
        const result = await generatePayroll(month, year);
        await load();
        return result;
      } finally {
        setGenerating(false);
      }
    },
    [load]
  );

  const filtered = search.trim()
    ? payrolls.filter((p) =>
        p.tutor?.full_name?.toLowerCase().includes(search.toLowerCase())
      )
    : payrolls;

  return {
    payrolls: filtered,
    filter,
    setFilter,
    search,
    setSearch,
    loading,
    generating,
    error,
    reload: load,
    generate,
  };
}
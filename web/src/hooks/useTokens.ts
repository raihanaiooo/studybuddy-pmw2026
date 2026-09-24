import { useCallback, useEffect, useState } from 'react';
import type { TokenWithRelations, TokenStatus } from '../types/package';
import { fetchTokens } from '../lib/api/packages';

type FilterStatus = TokenStatus | 'all';

export function useTokens(initialFilter: FilterStatus = 'all') {
  const [tokens, setTokens] = useState<TokenWithRelations[]>([]);
  const [filter, setFilter] = useState<FilterStatus>(initialFilter);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchTokens(filter);
      setTokens(data);
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
    ? tokens.filter((t) => {
        const q = search.toLowerCase();
        return (
          t.buddy?.full_name?.toLowerCase().includes(q) ||
          t.buddy?.email?.toLowerCase().includes(q) ||
          t.package?.package_name?.toLowerCase().includes(q)
        );
      })
    : tokens;

  return {
    tokens: filtered,
    filter,
    setFilter,
    search,
    setSearch,
    loading,
    error,
    reload: load,
  };
}
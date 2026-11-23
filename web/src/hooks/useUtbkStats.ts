import { useCallback, useEffect, useState } from 'react';
import { fetchUtbkStats } from '../lib/api/diagnostic';
import type { UtbkStats } from '../types/diagnostic';

export function useUtbkStats() {
  const [stats, setStats] = useState<UtbkStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    let active = true;
    fetchUtbkStats()
      .then((data) => {
        if (active) setStats(data);
      })
      .catch((e: unknown) => {
        if (active) setError(e instanceof Error ? e.message : 'Gagal memuat statistik.');
      })
      .finally(() => {
        if (active) setLoading(false);
      });
    return () => {
      active = false;
    };
  }, [reloadKey]);

  const reload = useCallback(() => {
    setLoading(true);
    setError(null);
    setReloadKey((k) => k + 1);
  }, []);

  return { stats, loading, error, reload };
}

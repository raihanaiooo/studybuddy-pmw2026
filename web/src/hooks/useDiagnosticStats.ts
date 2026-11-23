import { useCallback, useEffect, useState } from 'react';
import { fetchDiagnosticStats } from '../lib/api/diagnostic';
import type { DiagnosticStats } from '../types/diagnostic';

export function useDiagnosticStats() {
  const [stats, setStats] = useState<DiagnosticStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    let active = true;
    fetchDiagnosticStats()
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

import { useCallback, useEffect, useState } from 'react';
import type { RescheduleWithRelations } from '../types/reschedule';
import {
  fetchRescheduleById,
  approveReschedule,
  rejectReschedule,
} from '../lib/api/reschedules';
import { useAuth } from './useAuth';

export function useRescheduleDetail(id: string | undefined) {
  const { user } = useAuth();
  const [reschedule, setReschedule] = useState<RescheduleWithRelations | null>(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    setError(null);
    try {
      const data = await fetchRescheduleById(id);
      if (!data) {
        setError('Reschedule tidak ditemukan');
        return;
      }
      setReschedule(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  const approve = useCallback(
    async (note: string) => {
      if (!reschedule || !user) return;
      setUpdating(true);
      try {
        await approveReschedule(reschedule.id, note, user.id);
        setReschedule({
          ...reschedule,
          status: 'disetujui',
          admin_note: note || null,
          reviewed_by: user.id,
          reviewed_at: new Date().toISOString(),
        });
      } finally {
        setUpdating(false);
      }
    },
    [reschedule, user]
  );

  const reject = useCallback(
    async (note: string) => {
      if (!reschedule || !user) return;
      setUpdating(true);
      try {
        await rejectReschedule(reschedule.id, note, user.id);
        setReschedule({
          ...reschedule,
          status: 'ditolak',
          admin_note: note,
          reviewed_by: user.id,
          reviewed_at: new Date().toISOString(),
        });
      } finally {
        setUpdating(false);
      }
    },
    [reschedule, user]
  );

  return {
    reschedule,
    loading,
    updating,
    error,
    approve,
    reject,
    reload: load,
  };
}
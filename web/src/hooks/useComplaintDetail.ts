import { useCallback, useEffect, useState } from 'react';
import type { ComplaintWithRelations } from '../types/complaint';
import {
  fetchComplaintById,
  updateComplaintStatus,
} from '../lib/api/complaints';
import { useAuth } from './useAuth';

export function useComplaintDetail(id: string | undefined) {
  const { user } = useAuth();
  const [complaint, setComplaint] = useState<ComplaintWithRelations | null>(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    setError(null);
    try {
      const data = await fetchComplaintById(id);
      if (!data) {
        setError('Komplain tidak ditemukan');
        return;
      }
      setComplaint(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  const update = useCallback(
    async (status: 'in_review' | 'resolved' | 'rejected', note: string) => {
      if (!complaint || !user) return;
      setUpdating(true);
      try {
        await updateComplaintStatus(complaint.id, status, note || null, user.id);
        setComplaint({
          ...complaint,
          status,
          admin_note: note || null,
          handled_by: user.id,
          handled_at: new Date().toISOString(),
        });
      } finally {
        setUpdating(false);
      }
    },
    [complaint, user]
  );

  return {
    complaint,
    loading,
    updating,
    error,
    update,
    reload: load,
  };
}
import { useCallback, useEffect, useState } from 'react';
import type { Tutor, TutorDocument, VerificationStatus } from '../types/tutor';
import {
  fetchTutorById,
  fetchTutorDocuments,
  updateVerificationStatus,
} from '../lib/api/tutor';

export function useTutorDetail(tutorId: string | undefined) {
  const [tutor, setTutor] = useState<Tutor | null>(null);
  const [documents, setDocuments] = useState<TutorDocument[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [updating, setUpdating] = useState(false);

  const load = useCallback(async () => {
    if (!tutorId) return;
    setLoading(true);
    setError(null);
    try {
      const [t, docs] = await Promise.all([
        fetchTutorById(tutorId),
        fetchTutorDocuments(tutorId),
      ]);
      if (!t) {
        setError('Tutor tidak ditemukan');
        return;
      }
      setTutor(t);
      setDocuments(docs);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, [tutorId]);

  useEffect(() => {
    load();
  }, [load]);

  const verify = useCallback(
    async (status: VerificationStatus, note: string) => {
      if (!tutor) return;
      setUpdating(true);
      try {
        await updateVerificationStatus(tutor.id, status, note);
        setTutor({
          ...tutor,
          verification_status: status,
          verification_note: note || null,
        });
      } finally {
        setUpdating(false);
      }
    },
    [tutor]
  );

  return {
    tutor,
    documents,
    loading,
    error,
    updating,
    verify,
    reload: load,
  };
}
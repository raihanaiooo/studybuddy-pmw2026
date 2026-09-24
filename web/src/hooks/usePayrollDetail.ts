import { useCallback, useEffect, useState } from 'react';
import type { PayrollDetail } from '../types/payroll';
import { fetchPayrollById, markPayrollPaid } from '../lib/api/payroll';
import { useAuth } from './useAuth';

export function usePayrollDetail(id: string | undefined) {
  const { user } = useAuth();
  const [payroll, setPayroll] = useState<PayrollDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    setError(null);
    try {
      const data = await fetchPayrollById(id);
      if (!data) {
        setError('Payroll tidak ditemukan');
        return;
      }
      setPayroll(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  const markPaid = useCallback(
    async (notes: string) => {
      if (!payroll || !user) return;
      setUpdating(true);
      try {
        await markPayrollPaid(payroll.id, user.id, notes);
        setPayroll({
          ...payroll,
          status: 'paid',
          paid_at: new Date().toISOString(),
          paid_by: user.id,
          notes: notes || null,
        });
      } finally {
        setUpdating(false);
      }
    },
    [payroll, user]
  );

  return {
    payroll,
    loading,
    updating,
    error,
    markPaid,
    reload: load,
  };
}
import { useCallback, useEffect, useState } from 'react';
import type { PaymentWithRelations } from '../types/payment';
import { fetchPaymentById } from '../lib/api/payment';

export function usePaymentDetail(id: string | undefined) {
  const [payment, setPayment] = useState<PaymentWithRelations | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    setError(null);
    try {
      const data = await fetchPaymentById(id);
      if (!data) {
        setError('Transaksi tidak ditemukan');
        return;
      }
      setPayment(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  return { payment, loading, error, reload: load };
}
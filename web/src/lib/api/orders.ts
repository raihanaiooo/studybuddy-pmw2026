import { supabase } from '../supabase';
import { getClientSessionId } from '../diagnostic/session';
import { orderErrorMessage, toOrderPayload, type OrderInput } from '../orderForm';

/** Pengunjung: kirim order lewat RPC (validasi dan batas laju ada di server). */
export async function submitOrder(input: OrderInput): Promise<void> {
  const { error } = await supabase.rpc('submit_order', {
    p_client_session_id: getClientSessionId(),
    p_data: toOrderPayload(input),
  });
  if (error) throw new Error(orderErrorMessage(error.message));
}

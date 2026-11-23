/** Mengambil alasan asli dari galat Edge Function (supabase-js hanya memberi "non-2xx status code"). */
export async function functionErrorMessage(err: { message: string; context?: unknown }): Promise<string> {
  const res = err.context;
  if (res instanceof Response) {
    if (res.status === 404) return 'Fungsi create-tutor belum di-deploy di Supabase.';
    try {
      const body = await res.clone().json();
      if (typeof body?.error === 'string') return body.error;
    } catch {
      /* isi bukan JSON */
    }
  }
  return err.message;
}

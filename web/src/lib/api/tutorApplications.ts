import { supabase } from '../supabase';
import { getClientSessionId } from '../diagnostic/session';
import { applicationErrorMessage, toPayload, type ApplicationForm, type OprecRow } from '../tutorApplication';

export type ApplicationStatus = 'baru' | 'diterima' | 'ditolak';

export interface TutorApplication {
  id: string;
  full_name: string;
  university: string;
  major: string | null;
  semester: number | null;
  whatsapp: string;
  email: string;
  subjects: string[];
  jenjang: string[];
  experience: string | null;
  status: ApplicationStatus;
  admin_note: string | null;
  handled_at: string | null;
  created_at: string;
}

/** Pengunjung: kirim pendaftaran lewat RPC (validasi dan batas laju ada di server). */
export async function submitTutorApplication(form: ApplicationForm): Promise<void> {
  const { error } = await supabase.rpc('submit_tutor_application', {
    p_client_session_id: getClientSessionId(),
    p_data: toPayload(form),
  });
  if (error) throw new Error(applicationErrorMessage(error.message));
}

/** Baris oprec terbaru (null bila belum ada). Gagal membaca dianggap tidak ada data. */
export async function fetchLatestOprec(): Promise<OprecRow | null> {
  const { data, error } = await supabase
    .from('oprec_info')
    .select('is_active, start_date, end_date')
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();
  if (error) return null;
  return (data as OprecRow | null) ?? null;
}

const COLUMNS = 'id, full_name, university, major, semester, whatsapp, email, subjects, jenjang, experience, status, admin_note, handled_at, created_at';

/** Admin: daftar pelamar, yang terbaru di atas. */
export async function fetchApplications(status: ApplicationStatus | 'all'): Promise<TutorApplication[]> {
  let query = supabase.from('tutor_applications').select(COLUMNS).order('created_at', { ascending: false });
  if (status !== 'all') query = query.eq('status', status);
  const { data, error } = await query;
  if (error) throw new Error(error.message);
  return (data ?? []) as TutorApplication[];
}

export async function updateApplication(
  id: string,
  status: ApplicationStatus,
  adminId: string,
  note?: string
): Promise<void> {
  const { error } = await supabase
    .from('tutor_applications')
    .update({ status, admin_note: note ?? null, handled_by: adminId, handled_at: new Date().toISOString() })
    .eq('id', id);
  if (error) throw new Error(error.message);
}

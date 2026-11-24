import { supabase } from '../supabase';
import { getClientSessionId } from '../diagnostic/session';
import { applicationErrorMessage, toPayload, type ApplicationForm, type OprecRow } from '../tutorApplication';
import { DOCUMENTS_BUCKET, documentContentType, documentPath } from '../applicationDocuments';
import type { DocumentType } from '../../types/tutor';

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
  documents: Partial<Record<DocumentType, string>>;
  status: ApplicationStatus;
  admin_note: string | null;
  handled_at: string | null;
  created_at: string;
}

/**
 * Pengunjung: unggah dokumen ke penyimpanan privat (jalur memakai id pelamar yang dibuat di sini),
 * lalu kirim pendaftaran lewat RPC. Validasi dan batas laju ada di server.
 */
export async function submitTutorApplication(
  form: ApplicationForm,
  files: Partial<Record<DocumentType, File>>
): Promise<void> {
  const applicationId = crypto.randomUUID();
  const documents: Record<string, string> = {};
  for (const [type, file] of Object.entries(files) as Array<[DocumentType, File]>) {
    const path = documentPath(applicationId, type, file.name);
    const { error } = await supabase.storage
      .from(DOCUMENTS_BUCKET)
      .upload(path, file, { contentType: documentContentType(file.name), upsert: false });
    if (error) throw new Error('Dokumen belum bisa diunggah. Periksa ukuran dan format berkas, lalu coba lagi.');
    documents[type] = path;
  }
  const { error } = await supabase.rpc('submit_tutor_application', {
    p_client_session_id: getClientSessionId(),
    p_data: { ...toPayload(form), application_id: applicationId, documents },
  });
  if (error) throw new Error(applicationErrorMessage(error.message));
}

/** Admin: tautan sementara untuk membuka dokumen pelamar. */
export async function signedDocumentUrl(path: string, expiresIn = 600): Promise<string> {
  const { data, error } = await supabase.storage.from(DOCUMENTS_BUCKET).createSignedUrl(path, expiresIn);
  if (error) throw new Error(error.message);
  return data.signedUrl;
}

/** Admin: hapus semua berkas pelamar (dipakai saat ditolak) dan kosongkan daftar dokumennya. */
export async function deleteApplicationDocuments(application: Pick<TutorApplication, 'id' | 'documents'>): Promise<void> {
  const paths = Object.values(application.documents ?? {}).filter((p): p is string => !!p);
  if (paths.length > 0) {
    const { error } = await supabase.storage.from(DOCUMENTS_BUCKET).remove(paths);
    if (error) throw new Error(error.message);
  }
  const { error } = await supabase.from('tutor_applications').update({ documents: {} }).eq('id', application.id);
  if (error) throw new Error(error.message);
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

const COLUMNS = 'id, full_name, university, major, semester, whatsapp, email, subjects, jenjang, experience, documents, status, admin_note, handled_at, created_at';

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

/** Jumlah pelamar berstatus baru (untuk angka di tab). Melempar galat bila gagal dimuat. */
export async function countNewApplications(): Promise<number> {
  const { count, error } = await supabase
    .from('tutor_applications')
    .select('id', { count: 'exact', head: true })
    .eq('status', 'baru');
  if (error) throw new Error(error.message);
  return count ?? 0;
}

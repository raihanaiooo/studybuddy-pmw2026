import { supabase } from '../supabase';
import type {
  Tutor,
  TutorDocument,
  VerificationStatus,
} from '../../types/tutor';

export async function fetchTutors(
  status?: VerificationStatus | 'all'
): Promise<Tutor[]> {
  let query = supabase
    .from('tutors')
    .select('*')
    .order('created_at', { ascending: false });

  if (status && status !== 'all') {
    query = query.eq('verification_status', status);
  }

  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as Tutor[];
}

export async function fetchTutorById(id: string): Promise<Tutor | null> {
  const { data, error } = await supabase
    .from('tutors')
    .select('*')
    .eq('id', id)
    .single();

  if (error) throw error;
  return data as Tutor;
}

export async function fetchTutorDocuments(
  tutorId: string
): Promise<TutorDocument[]> {
  const { data, error } = await supabase
    .from('tutor_documents')
    .select('*')
    .eq('tutor_id', tutorId)
    .order('jenis_dokumen', { ascending: true });

  if (error) throw error;
  return (data ?? []) as TutorDocument[];
}

export async function updateVerificationStatus(
  tutorId: string,
  status: VerificationStatus,
  note?: string
): Promise<void> {
  const { error } = await supabase
    .from('tutors')
    .update({
      verification_status: status,
      verification_note: note ?? null,
    })
    .eq('id', tutorId);

  if (error) throw error;
}

export async function updateDocumentStatus(
  documentId: string,
  status: 'terverifikasi' | 'ditolak',
  note?: string
): Promise<void> {
  const { error } = await supabase
    .from('tutor_documents')
    .update({
      status,
      rejection_note: note ?? null,
    })
    .eq('id', documentId);

  if (error) throw error;
}

export async function getSignedUrl(
  filePath: string,
  expiresIn = 3600
): Promise<string> {
  const bucket = 'documents';
  const idx = filePath.indexOf(`/${bucket}/`);
  const path = idx >= 0 ? filePath.substring(idx + bucket.length + 2) : filePath;

  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUrl(path, expiresIn);

  if (error) throw error;
  return data.signedUrl;
}
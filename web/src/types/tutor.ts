export type VerificationStatus = 'pending' | 'verified' | 'rejected';

export interface Tutor {
  id: string;
  user_id: string;
  full_name: string;
  avatar_url: string | null;
  bio: string | null;
  subjects: string[];
  jenjang_diajar: string[];
  university: string | null;
  gpa: number | null;
  verification_status: VerificationStatus;
  verification_note: string | null;
  is_online: boolean;
  created_at: string;
}

export type DocumentType =
  | 'transkrip'
  | 'kartu_identitas_pelajar'
  | 'sertifikat_prestasi'
  | 'sertifikat_bahasa';

export type DocumentStatus =
  | 'belum_upload'
  | 'menunggu_verifikasi'
  | 'terverifikasi'
  | 'ditolak';

export interface TutorDocument {
  id: string;
  tutor_id: string;
  jenis_dokumen: DocumentType;
  label: string | null;
  file_url: string | null;
  status: DocumentStatus;
  rejection_note: string | null;
  uploaded_at: string | null;
}

export const DOCUMENT_LABELS: Record<DocumentType, string> = {
  transkrip: 'Transkrip Nilai',
  kartu_identitas_pelajar: 'KTM / Kartu Tanda Pelajar',
  sertifikat_prestasi: 'Sertifikat Prestasi',
  sertifikat_bahasa: 'Sertifikat Bahasa',
};

export const DOCUMENT_REQUIREMENTS: Record<
  DocumentType,
  'Wajib' | 'Bersyarat'
> = {
  transkrip: 'Wajib',
  kartu_identitas_pelajar: 'Wajib',
  sertifikat_prestasi: 'Wajib',
  sertifikat_bahasa: 'Bersyarat',
};
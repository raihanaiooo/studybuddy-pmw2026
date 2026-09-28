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

// ============================================
// SLA Helper — Verifikasi Tutor
// ============================================

/** SLA dalam hari — sesuai keputusan client (~1 minggu) */
export const SLA_DAYS = 7;

/** Batas "mendekati SLA" — 5 hari */
export const SLA_WARNING_DAYS = 5;

/** Hitung berapa hari Tutor sudah pending (dari register) */
export function getPendingDays(tutor: Tutor): number {
  const created = new Date(tutor.created_at).getTime();
  const now = Date.now();
  const diffMs = now - created;
  return Math.floor(diffMs / (1000 * 60 * 60 * 24));
}

export type SlaStatus = 'normal' | 'warning' | 'overdue';

/** Klasifikasi status SLA */
export function getSlaStatus(tutor: Tutor): SlaStatus {
  if (tutor.verification_status !== 'pending') return 'normal';
  const days = getPendingDays(tutor);
  if (days > SLA_DAYS) return 'overdue';
  if (days >= SLA_WARNING_DAYS) return 'warning';
  return 'normal';
}

/** Label status SLA dalam bahasa Indonesia */
export function getSlaLabel(status: SlaStatus): string {
  switch (status) {
    case 'overdue':
      return 'Lewat SLA';
    case 'warning':
      return 'Mendekati SLA';
    case 'normal':
      return '';
  }
}
/** Fungsi murni untuk create-tutor (tanpa API Deno) agar bisa diuji di Vitest. */

export type VerificationStatus = 'pending' | 'verified';

export interface TutorInput {
  fullName: string;
  university: string | null;
  bio: string | null;
  pricePerHour: number;
  subjects: unknown[];
  jenjangDiajar: unknown[];
}

/** Tanpa nilai = 'verified' (tambah manual oleh admin). Hanya 'pending' atau 'verified' yang sah. */
export function resolveVerificationStatus(raw: unknown): VerificationStatus | null {
  if (raw === undefined) return 'verified';
  return raw === 'pending' || raw === 'verified' ? raw : null;
}

/** Baris untuk tabel tutors. Nomor telepon TIDAK termasuk: tabel tutors tidak punya kolom phone (ada di users.phone). */
export function buildTutorRow(userId: string, input: TutorInput, status: VerificationStatus) {
  return {
    user_id: userId,
    full_name: input.fullName,
    university: input.university,
    bio: input.bio,
    price_per_hour: input.pricePerHour,
    subjects: input.subjects,
    jenjang_diajar: input.jenjangDiajar,
    verification_status: status,
    account_status: 'active',
    is_featured: false,
  };
}

const DOCUMENT_LABELS: Record<string, string> = {
  transkrip: 'Transkrip Nilai',
  kartu_identitas_pelajar: 'KTM / Kartu Tanda Pelajar',
  sertifikat_prestasi: 'Sertifikat Prestasi',
  sertifikat_bahasa: 'Sertifikat Bahasa',
};

const CONTENT_TYPES: Record<string, string> = {
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  png: 'image/png',
  pdf: 'application/pdf',
};

export interface DocumentCopy {
  from: string;
  to: string;
  contentType: string;
  row: {
    tutor_id: string;
    jenis_dokumen: string;
    label: string;
    file_url: string;
    status: 'terverifikasi';
    uploaded_at: string;
  };
}

/** Rencana pemindahan dokumen pelamar ke bucket dokumen tutor. Dokumen yang sudah diperiksa admin langsung terverifikasi. */
export function buildDocumentCopies(tutorId: string, documents: unknown, nowIso: string): DocumentCopy[] {
  if (!documents || typeof documents !== 'object') return [];
  const copies: DocumentCopy[] = [];
  for (const [type, path] of Object.entries(documents as Record<string, unknown>)) {
    if (!(type in DOCUMENT_LABELS) || typeof path !== 'string') continue;
    const ext = path.slice(path.lastIndexOf('.') + 1).toLowerCase();
    const to = `${tutorId}/${type}.${ext}`;
    copies.push({
      from: path,
      to,
      contentType: CONTENT_TYPES[ext] ?? 'application/octet-stream',
      row: { tutor_id: tutorId, jenis_dokumen: type, label: DOCUMENT_LABELS[type], file_url: to, status: 'terverifikasi', uploaded_at: nowIso },
    });
  }
  return copies;
}

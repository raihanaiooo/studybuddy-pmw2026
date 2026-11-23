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

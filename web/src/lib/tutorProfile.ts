import { EMAIL_RE, normalizeWhatsapp } from './tutorApplication';

/** Isian form Edit Tutor (semua teks, seperti yang diketik admin). */
export interface TutorProfileForm {
  name: string;
  university: string;
  gpa: string;
  bio: string;
  whatsapp: string;
  email: string;
  payout: string;
}

export type TutorProfileErrors = Partial<Record<keyof TutorProfileForm, string>>;

export interface TutorProfileResult {
  errors: TutorProfileErrors;
  /** Nilai bersih siap simpan; hanya berarti bila errors kosong. */
  value: {
    name: string;
    university: string | null;
    gpa: number | null;
    bio: string | null;
    whatsapp: string | null;
    email: string | null;
    payout: string | null;
  };
}

export function validateTutorProfile(form: TutorProfileForm): TutorProfileResult {
  const errors: TutorProfileErrors = {};
  const name = form.name.trim();
  const university = form.university.trim();
  const bio = form.bio.trim();
  const email = form.email.trim();
  const payout = form.payout.trim();
  const waRaw = form.whatsapp.trim();
  const gpaRaw = form.gpa.trim().replace(',', '.');

  if (name.length < 2) errors.name = 'Nama wajib diisi, minimal 2 huruf.';
  else if (name.length > 100) errors.name = 'Nama terlalu panjang (maksimal 100 huruf).';

  if (university.length > 150) errors.university = 'Nama kampus terlalu panjang (maksimal 150 huruf).';

  let gpa: number | null = null;
  if (gpaRaw !== '') {
    if (!/^\d(\.\d{1,2})?$/.test(gpaRaw) || Number(gpaRaw) > 4) errors.gpa = 'IPK harus angka 0 sampai 4, contoh 3,75.';
    else gpa = Number(gpaRaw);
  }

  if (bio.length > 1000) errors.bio = 'Bio terlalu panjang (maksimal 1000 huruf).';

  let whatsapp: string | null = null;
  if (waRaw !== '') {
    const wa = normalizeWhatsapp(waRaw);
    if (!/^62[0-9]{8,13}$/.test(wa)) errors.whatsapp = 'Nomor WhatsApp belum benar, contoh 0812 3456 7890.';
    else whatsapp = wa;
  }

  if (email !== '' && (email.length > 150 || !EMAIL_RE.test(email))) errors.email = 'Alamat email belum benar.';
  if (payout.length > 200) errors.payout = 'Terlalu panjang (maksimal 200 huruf).';

  return {
    errors,
    value: {
      name,
      university: university || null,
      gpa,
      bio: bio || null,
      whatsapp,
      email: email ? email.toLowerCase() : null,
      payout: payout || null,
    },
  };
}

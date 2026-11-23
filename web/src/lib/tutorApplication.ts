/** Pendaftaran tutor dari landing: pilihan form, validasi (mirip server), payload, pesan galat, dan status oprec. */

export const SUBJECT_OPTIONS = [
  { value: 'mtk', label: 'Matematika' },
  { value: 'fis', label: 'Fisika' },
  { value: 'kim', label: 'Kimia' },
  { value: 'bio', label: 'Biologi' },
  { value: 'ing', label: 'B. Inggris' },
] as const;

export const JENJANG_OPTIONS = [
  { value: 'sd', label: 'SD' },
  { value: 'smp', label: 'SMP' },
  { value: 'sma', label: 'SMA' },
  { value: 'kuliah', label: 'Kuliah' },
] as const;

export interface ApplicationForm {
  full_name: string;
  university: string;
  major: string;
  semester: string;
  whatsapp: string;
  email: string;
  subjects: string[];
  jenjang: string[];
  experience: string;
}

export type ApplicationErrors = Partial<Record<keyof ApplicationForm, string>>;

export function emptyApplicationForm(): ApplicationForm {
  return { full_name: '', university: '', major: '', semester: '', whatsapp: '', email: '', subjects: [], jenjang: [], experience: '' };
}

/** Sama dengan normalisasi di server: buang spasi/tanda, +62 atau 0 di depan menjadi 62. */
export function normalizeWhatsapp(raw: string): string {
  let wa = raw.replace(/[\s\-.()]/g, '').replace(/^\+/, '');
  if (wa.startsWith('0')) wa = `62${wa.slice(1)}`;
  return wa;
}

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

export function validateApplication(form: ApplicationForm): ApplicationErrors {
  const errors: ApplicationErrors = {};
  const name = form.full_name.trim();
  const univ = form.university.trim();

  if (name.length < 2 || name.length > 100) errors.full_name = 'Isi nama lengkap (2–100 huruf).';
  if (univ.length < 2 || univ.length > 100) errors.university = 'Isi nama kampus (2–100 huruf).';
  if (form.major.trim().length > 100) errors.major = 'Jurusan maksimal 100 huruf.';
  if (form.semester.trim() !== '') {
    const n = Number(form.semester);
    if (!/^[0-9]{1,2}$/.test(form.semester.trim()) || n < 1 || n > 14) errors.semester = 'Semester harus angka 1–14.';
  }
  if (!/^62[0-9]{8,13}$/.test(normalizeWhatsapp(form.whatsapp.trim()))) errors.whatsapp = 'Nomor WhatsApp belum benar, contoh 0812 3456 7890.';
  const email = form.email.trim();
  if (email.length > 150 || !EMAIL_RE.test(email)) errors.email = 'Alamat email belum benar.';
  if (form.subjects.length === 0) errors.subjects = 'Pilih minimal satu mata pelajaran.';
  if (form.jenjang.length === 0) errors.jenjang = 'Pilih minimal satu jenjang.';
  if (form.experience.length > 1000) errors.experience = 'Pengalaman maksimal 1000 huruf.';
  return errors;
}

/** Data yang dikirim ke RPC; kolom opsional yang kosong tidak ikut dikirim. */
export function toPayload(form: ApplicationForm): Record<string, unknown> {
  const payload: Record<string, unknown> = {
    full_name: form.full_name.trim(),
    university: form.university.trim(),
    whatsapp: form.whatsapp.trim(),
    email: form.email.trim().toLowerCase(),
    subjects: form.subjects,
    jenjang: form.jenjang,
  };
  if (form.major.trim()) payload.major = form.major.trim();
  if (form.semester.trim()) payload.semester = Number(form.semester);
  if (form.experience.trim()) payload.experience = form.experience.trim();
  return payload;
}

const ERROR_MESSAGES: Array<[string, string]> = [
  ['rate_limited', 'Kamu sudah terlalu sering mengirim pendaftaran. Coba lagi dalam satu jam.'],
  ['duplicate', 'Nomor WhatsApp ini sudah terdaftar dan sedang kami tinjau. Mohon tunggu kabar dari admin.'],
  ['oprec_closed', 'Pendaftaran tutor sedang ditutup.'],
  ['invalid_input:whatsapp', 'Nomor WhatsApp belum benar.'],
  ['invalid_input:email', 'Alamat email belum benar.'],
  ['invalid_input', 'Ada isian yang belum benar. Periksa lagi formulirnya.'],
  ['invalid_session', 'Sesi tidak valid. Muat ulang halaman lalu coba lagi.'],
];

export function applicationErrorMessage(raw: string): string {
  const hit = ERROR_MESSAGES.find(([code]) => raw.includes(code));
  return hit ? hit[1] : 'Pendaftaran belum bisa dikirim. Coba lagi sebentar lagi.';
}

export interface OprecRow {
  is_active: boolean;
  start_date: string | null;
  end_date: string | null;
}

function localDateString(d: Date): string {
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

/** Tanpa data = terbuka. Aturan sama dengan server (baris terbaru, aktif, dalam rentang tanggal). */
export function oprecState(row: OprecRow | null, today: Date): { open: boolean; message?: string } {
  if (!row) return { open: true };
  const day = localDateString(today);
  if (!row.is_active) return { open: false, message: 'Pendaftaran tutor sedang ditutup.' };
  if (row.start_date && day < row.start_date) return { open: false, message: 'Pendaftaran tutor belum dibuka.' };
  if (row.end_date && day > row.end_date) return { open: false, message: 'Pendaftaran tutor sudah ditutup.' };
  return { open: true };
}

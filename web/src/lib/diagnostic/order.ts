const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** Mapel yang boleh diisi otomatis; harus sama dengan pilihan di OrderForm. */
export const ENGLISH_SUBJECT = 'Bahasa Inggris';
export const UTBK_SUBJECT = 'UTBK / SNBT';

const KNOWN_SUBJECTS = ['Matematika', 'Fisika', 'Kimia', 'Biologi', ENGLISH_SUBJECT, UTBK_SUBJECT, 'Lainnya'];

export interface OrderParams {
  attemptId: string | undefined;
  packageId: string | undefined;
  subject: string | undefined;
}

/** Tautan dari hasil tes ke form order di landing page. */
export function buildOrderPath(attemptId: string, packageId: string | null, subject: string = ENGLISH_SUBJECT): string {
  const query = [`attempt=${attemptId}`];
  if (packageId) query.push(`package=${packageId}`);
  query.push(`subject=${encodeURIComponent(subject)}`);
  return `/?${query.join('&')}#order`;
}

/** Membaca parameter order dari URL; nilai yang tidak valid dibuang. */
export function parseOrderParams(search: string): OrderParams {
  const params = new URLSearchParams(search);
  const attempt = params.get('attempt');
  const pkg = params.get('package');
  const subject = params.get('subject');
  return {
    attemptId: attempt && UUID.test(attempt) ? attempt : undefined,
    packageId: pkg && UUID.test(pkg) ? pkg : undefined,
    subject: subject && KNOWN_SUBJECTS.includes(subject) ? subject : undefined,
  };
}

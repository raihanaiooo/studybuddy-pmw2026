/** Halaman form pendaftaran tutor di web ini. */
export const TUTOR_APPLY_PATH = '/daftar-tutor';

/**
 * Tujuan tombol pendaftaran tutor. Tautan dari Manajemen Konten dipakai bila diisi;
 * bila kosong, "#", atau "#order" (form pemesanan murid), arahkan ke form pendaftaran tutor.
 */
export function resolveOprecLink(raw: string | null | undefined): string {
  const link = raw?.trim();
  if (link && link !== '#' && link !== '#order') return link;
  return TUTOR_APPLY_PATH;
}

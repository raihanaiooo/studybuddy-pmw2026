import { ADMIN_WA_NUMBER } from './whatsapp';

const TUTOR_WA_TEXT =
  'Halo admin Study Buddy, saya mahasiswa dan ingin daftar jadi tutor. Mohon info cara pendaftarannya, ya. Terima kasih!';

/**
 * Tujuan tombol pendaftaran tutor. Tautan dari Manajemen Konten dipakai bila diisi;
 * bila kosong, "#", atau "#order" (form pemesanan murid), arahkan ke WhatsApp admin.
 */
export function resolveOprecLink(raw: string | null | undefined): string {
  const link = raw?.trim();
  if (link && link !== '#' && link !== '#order') return link;
  return `https://wa.me/${ADMIN_WA_NUMBER}?text=${encodeURIComponent(TUTOR_WA_TEXT)}`;
}

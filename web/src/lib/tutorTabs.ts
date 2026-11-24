import type { VerificationStatus } from '../types/tutor';

export type TutorTab = 'pelamar' | 'pending' | 'verified' | 'rejected' | 'all';

export const TUTOR_TABS: Array<{ key: TutorTab; label: string }> = [
  { key: 'verified', label: 'Terverifikasi' },
  { key: 'pelamar', label: 'Pelamar baru' },
  { key: 'pending', label: 'Menunggu' },
  { key: 'rejected', label: 'Ditolak' },
  { key: 'all', label: 'Semua' },
];

/** Nilai ?tab= dari alamat; yang kosong atau tidak dikenal jatuh ke tab Terverifikasi (yang paling sering dibuka). */
export function parseTutorTab(value: string | null): TutorTab {
  return TUTOR_TABS.some((t) => t.key === value) ? (value as TutorTab) : 'verified';
}

/** Tab tujuan tombol "Kembali" di halaman detail: tab asal bila ada, bila tidak ikut status tutor. */
export function backTabFor(state: unknown, status: string | undefined): TutorTab {
  const from = (state as { fromTab?: string } | null | undefined)?.fromTab;
  if (from && TUTOR_TABS.some((t) => t.key === from)) return from as TutorTab;
  return parseTutorTab(status ?? null);
}

/** Filter status tutor untuk sebuah tab; null bila tab itu bukan daftar tutor (pelamar). */
export function tabToVerificationFilter(tab: TutorTab): VerificationStatus | 'all' | null {
  return tab === 'pelamar' ? null : tab;
}

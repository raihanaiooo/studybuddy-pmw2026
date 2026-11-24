import type { VerificationStatus } from '../types/tutor';

export type TutorTab = 'pelamar' | 'pending' | 'verified' | 'rejected' | 'all';

export const TUTOR_TABS: Array<{ key: TutorTab; label: string }> = [
  { key: 'pelamar', label: 'Pelamar baru' },
  { key: 'pending', label: 'Menunggu' },
  { key: 'verified', label: 'Terverifikasi' },
  { key: 'rejected', label: 'Ditolak' },
  { key: 'all', label: 'Semua' },
];

/** Nilai ?tab= dari alamat; yang kosong atau tidak dikenal jatuh ke tab Pelamar baru. */
export function parseTutorTab(value: string | null): TutorTab {
  return TUTOR_TABS.some((t) => t.key === value) ? (value as TutorTab) : 'pelamar';
}

/** Filter status tutor untuk sebuah tab; null bila tab itu bukan daftar tutor (pelamar). */
export function tabToVerificationFilter(tab: TutorTab): VerificationStatus | 'all' | null {
  return tab === 'pelamar' ? null : tab;
}

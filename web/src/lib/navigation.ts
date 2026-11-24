/** Daftar menu sidebar admin dan alamat-alamat yang berhubungan, tanpa React agar bisa diuji. */

export type NavIconKey = 'dashboard' | 'orders' | 'tutors' | 'content' | 'diagnostics' | 'settings';

export interface NavItem {
  path: string;
  label: string;
  icon: NavIconKey;
}

export interface NavSection {
  heading: string | null;
  items: NavItem[];
}

export const NAV_SECTIONS: NavSection[] = [
  { heading: null, items: [{ path: '/dashboard', label: 'Dashboard', icon: 'dashboard' }] },
  { heading: 'Operasional', items: [{ path: '/orders', label: 'Orderan Masuk', icon: 'orders' }] },
  { heading: 'Tutor', items: [{ path: '/tutors', label: 'Tutor', icon: 'tutors' }] },
  {
    heading: 'Landing Page',
    items: [
      { path: '/content', label: 'Manajemen Konten', icon: 'content' },
      { path: '/diagnostics', label: 'Diagnostic', icon: 'diagnostics' },
    ],
  },
  { heading: 'Sistem', items: [{ path: '/pengaturan', label: 'Pengaturan', icon: 'settings' }] },
];

/** Fitur yang datanya dari aplikasi mobile; ditahan (tidak ada di menu maupun rute). */
export const HELD_MOBILE_PREFIXES: readonly string[] = [
  '/bookings',
  '/payments',
  '/reschedules',
  '/complaints',
  '/payroll',
  '/tokens',
  '/performance',
];

/** Alamat lama yang digabung ke halaman baru. */
export const LEGACY_REDIRECTS: Record<string, string> = {
  '/tutor-applications': '/tutors?tab=pelamar',
  '/packages': '/pengaturan',
  '/settings': '/pengaturan',
};

export function isHeldPath(pathname: string): boolean {
  return HELD_MOBILE_PREFIXES.some((p) => pathname === p || pathname.startsWith(`${p}/`));
}

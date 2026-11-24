import { describe, expect, it } from 'vitest';
import { HELD_MOBILE_PREFIXES, LEGACY_REDIRECTS, NAV_SECTIONS, isHeldPath } from './navigation';

describe('navigation', () => {
  it('menu memuat 7 item dengan jalur unik', () => {
    const paths = NAV_SECTIONS.flatMap((s) => s.items.map((i) => i.path));
    expect(paths).toEqual(['/dashboard', '/order', '/orders', '/tutors', '/content', '/diagnostics', '/pengaturan']);
    expect(new Set(paths).size).toBe(paths.length);
  });

  it('tidak ada item menu yang jalurnya ditahan', () => {
    for (const s of NAV_SECTIONS) for (const i of s.items) expect(isHeldPath(i.path)).toBe(false);
    expect(HELD_MOBILE_PREFIXES.length).toBe(7);
  });

  it('isHeldPath mencocokkan awalan utuh saja', () => {
    expect(isHeldPath('/bookings')).toBe(true);
    expect(isHeldPath('/bookings/123')).toBe(true);
    expect(isHeldPath('/bookingsx')).toBe(false);
    expect(isHeldPath('/tutors/1')).toBe(false);
  });

  it('alamat lama dialihkan ke halaman baru yang tidak ditahan', () => {
    expect(LEGACY_REDIRECTS['/tutor-applications']).toBe('/tutors?tab=pelamar');
    expect(LEGACY_REDIRECTS['/packages']).toBe('/pengaturan');
    expect(LEGACY_REDIRECTS['/settings']).toBe('/pengaturan');
    for (const to of Object.values(LEGACY_REDIRECTS)) expect(isHeldPath(to.split('?')[0])).toBe(false);
  });
});

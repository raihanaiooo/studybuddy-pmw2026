import { describe, expect, it } from 'vitest';
import { TUTOR_TABS, backTabFor, parseTutorTab, tabToVerificationFilter } from './tutorTabs';

describe('tutorTabs', () => {
  it('parseTutorTab menerima tab yang sah', () => {
    expect(parseTutorTab('verified')).toBe('verified');
    expect(parseTutorTab('rejected')).toBe('rejected');
  });

  it('parseTutorTab jatuh ke Terverifikasi untuk nilai kosong atau salah', () => {
    expect(parseTutorTab(null)).toBe('verified');
    expect(parseTutorTab('')).toBe('verified');
    expect(parseTutorTab('ngawur')).toBe('verified');
  });

  it('backTabFor: tab asal dari state dipakai; bila tidak ada, ikut status tutor', () => {
    expect(backTabFor({ fromTab: 'all' }, 'verified')).toBe('all');
    expect(backTabFor({ fromTab: 'ngawur' }, 'rejected')).toBe('rejected');
    expect(backTabFor(null, 'pending')).toBe('pending');
    expect(backTabFor(undefined, undefined)).toBe('verified');
  });

  it('tabToVerificationFilter: null untuk pelamar, selain itu status yang sama', () => {
    expect(tabToVerificationFilter('pelamar')).toBeNull();
    expect(tabToVerificationFilter('pending')).toBe('pending');
    expect(tabToVerificationFilter('all')).toBe('all');
  });

  it('TUTOR_TABS memuat lima kunci unik dengan Terverifikasi pertama', () => {
    const keys = TUTOR_TABS.map((t) => t.key);
    expect(keys).toEqual(['verified', 'pelamar', 'pending', 'rejected', 'all']);
    expect(new Set(keys).size).toBe(5);
  });
});

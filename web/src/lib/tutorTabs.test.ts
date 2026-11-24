import { describe, expect, it } from 'vitest';
import { TUTOR_TABS, parseTutorTab, tabToVerificationFilter } from './tutorTabs';

describe('tutorTabs', () => {
  it('parseTutorTab menerima tab yang sah', () => {
    expect(parseTutorTab('verified')).toBe('verified');
    expect(parseTutorTab('rejected')).toBe('rejected');
  });

  it('parseTutorTab jatuh ke pelamar untuk nilai kosong atau salah', () => {
    expect(parseTutorTab(null)).toBe('pelamar');
    expect(parseTutorTab('')).toBe('pelamar');
    expect(parseTutorTab('ngawur')).toBe('pelamar');
  });

  it('tabToVerificationFilter: null untuk pelamar, selain itu status yang sama', () => {
    expect(tabToVerificationFilter('pelamar')).toBeNull();
    expect(tabToVerificationFilter('pending')).toBe('pending');
    expect(tabToVerificationFilter('all')).toBe('all');
  });

  it('TUTOR_TABS memuat lima kunci unik dengan pelamar pertama', () => {
    const keys = TUTOR_TABS.map((t) => t.key);
    expect(keys).toEqual(['pelamar', 'pending', 'verified', 'rejected', 'all']);
    expect(new Set(keys).size).toBe(5);
  });
});

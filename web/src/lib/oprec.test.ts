import { describe, expect, it } from 'vitest';
import { resolveOprecLink } from './oprec';

describe('resolveOprecLink', () => {
  it('memakai tautan yang diisi admin', () => {
    expect(resolveOprecLink('https://forms.gle/abc')).toBe('https://forms.gle/abc');
  });

  it.each([undefined, null, '', '   ', '#', '#order'])('jatuh ke halaman form pendaftaran bila tautan %j belum diisi', (raw) => {
    expect(resolveOprecLink(raw)).toBe('/daftar-tutor');
  });
});

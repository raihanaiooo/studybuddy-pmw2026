import { describe, expect, it } from 'vitest';
import { resolveOprecLink } from './oprec';
import { ADMIN_WA_NUMBER } from './whatsapp';

describe('resolveOprecLink', () => {
  it('memakai tautan yang diisi admin', () => {
    expect(resolveOprecLink('https://forms.gle/abc')).toBe('https://forms.gle/abc');
  });

  it.each([undefined, null, '', '   ', '#', '#order'])('jatuh ke WhatsApp admin bila tautan %j belum diisi', (raw) => {
    const url = resolveOprecLink(raw);
    expect(url.startsWith(`https://wa.me/${ADMIN_WA_NUMBER}?text=`)).toBe(true);
    expect(decodeURIComponent(url)).toContain('daftar jadi tutor');
  });
});

import { describe, expect, it } from 'vitest';
import { ADMIN_WA_NUMBER, buildAdminWaUrl } from './whatsapp';

const order = { nama: 'Rina', mapel: 'Bahasa Inggris', jenjang: 'SMA' };

describe('buildAdminWaUrl', () => {
  it('memakai nomor admin Study Buddy', () => {
    expect(ADMIN_WA_NUMBER).toBe('628999303251');
    expect(buildAdminWaUrl(order, false)).toMatch(/^https:\/\/wa\.me\/628999303251\?text=/);
  });

  it('memuat nama, mapel, dan jenjang di pesan', () => {
    const text = decodeURIComponent(buildAdminWaUrl(order, false).split('?text=')[1]);
    expect(text).toContain('Rina');
    expect(text).toContain('Bahasa Inggris');
    expect(text).toContain('SMA');
  });

  it('menyebut hasil tes hanya bila order berasal dari tes', () => {
    const dariTes = decodeURIComponent(buildAdminWaUrl(order, true).split('?text=')[1]);
    const biasa = decodeURIComponent(buildAdminWaUrl(order, false).split('?text=')[1]);
    expect(dariTes).toContain('tes level English');
    expect(biasa).not.toContain('tes level English');
  });
});

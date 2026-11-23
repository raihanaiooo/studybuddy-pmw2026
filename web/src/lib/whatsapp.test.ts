import { describe, expect, it } from 'vitest';
import { ADMIN_WA_NUMBER, buildAdminWaUrl } from './whatsapp';

const order = { nama: 'Rina', mapel: 'Bahasa Inggris', jenjang: 'SMA' };

function messageFor(tes: 'english' | 'utbk' | null): string {
  return decodeURIComponent(buildAdminWaUrl(order, tes).split('?text=')[1]);
}

describe('buildAdminWaUrl', () => {
  it('memakai nomor admin Study Buddy', () => {
    expect(ADMIN_WA_NUMBER).toBe('628999303251');
    expect(buildAdminWaUrl(order, null)).toMatch(/^https:\/\/wa\.me\/628999303251\?text=/);
  });

  it('memuat nama, mapel, dan jenjang di pesan', () => {
    const text = messageFor(null);
    expect(text).toContain('Rina');
    expect(text).toContain('Bahasa Inggris');
    expect(text).toContain('SMA');
  });

  it('menyebut tes English hanya untuk order dari tes English', () => {
    expect(messageFor('english')).toContain('tes level English');
    expect(messageFor('utbk')).not.toContain('tes level English');
    expect(messageFor(null)).not.toContain('tes level English');
  });

  it('menyebut try out UTBK dan paket SNBT hanya untuk order dari tes UTBK', () => {
    const utbk = messageFor('utbk');
    expect(utbk).toContain('try out UTBK');
    expect(utbk).toContain('paket SNBT');
    expect(messageFor('english')).not.toContain('try out UTBK');
    expect(messageFor(null)).not.toContain('try out UTBK');
  });
});

import { describe, expect, it } from 'vitest';
import { buildTutorRow, resolveVerificationStatus } from './tutorRow';

const input = {
  fullName: 'Alya Rahma',
  university: 'ITB',
  bio: 'Privat 2 tahun',
  pricePerHour: 100000,
  subjects: ['mtk'],
  jenjangDiajar: ['sma'],
};

describe('resolveVerificationStatus', () => {
  it('default verified (tambah manual oleh admin) dan menerima pending', () => {
    expect(resolveVerificationStatus(undefined)).toBe('verified');
    expect(resolveVerificationStatus('pending')).toBe('pending');
    expect(resolveVerificationStatus('verified')).toBe('verified');
  });

  it('menolak nilai lain', () => {
    expect(resolveVerificationStatus('rejected')).toBeNull();
    expect(resolveVerificationStatus(5)).toBeNull();
    expect(resolveVerificationStatus('')).toBeNull();
  });
});

describe('buildTutorRow', () => {
  it('tidak memuat kolom phone (tabel tutors tidak punya kolom itu)', () => {
    const row = buildTutorRow('user-1', input, 'pending');
    expect('phone' in row).toBe(false);
  });

  it('memuat kolom yang benar-benar ada di tabel tutors', () => {
    expect(buildTutorRow('user-1', input, 'pending')).toEqual({
      user_id: 'user-1',
      full_name: 'Alya Rahma',
      university: 'ITB',
      bio: 'Privat 2 tahun',
      price_per_hour: 100000,
      subjects: ['mtk'],
      jenjang_diajar: ['sma'],
      verification_status: 'pending',
      account_status: 'active',
      is_featured: false,
    });
  });
});

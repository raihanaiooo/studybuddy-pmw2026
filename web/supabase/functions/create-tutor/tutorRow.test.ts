import { describe, expect, it } from 'vitest';
import { buildDocumentCopies, buildTutorRow, resolveVerificationStatus } from './tutorRow';

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

describe('buildDocumentCopies', () => {
  const APP = '0a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d';
  const docs = { transkrip: `${APP}/transkrip.pdf`, kartu_identitas_pelajar: `${APP}/kartu_identitas_pelajar.jpg` };

  it('memindahkan tiap dokumen ke jalur tutor dan membuat baris tutor_documents terverifikasi', () => {
    const copies = buildDocumentCopies('tutor-9', docs, '2026-11-23T00:00:00.000Z');
    expect(copies).toEqual([
      {
        from: `${APP}/transkrip.pdf`,
        to: 'tutor-9/transkrip.pdf',
        contentType: 'application/pdf',
        row: { tutor_id: 'tutor-9', jenis_dokumen: 'transkrip', label: 'Transkrip Nilai', file_url: 'tutor-9/transkrip.pdf', status: 'terverifikasi', uploaded_at: '2026-11-23T00:00:00.000Z' },
      },
      {
        from: `${APP}/kartu_identitas_pelajar.jpg`,
        to: 'tutor-9/kartu_identitas_pelajar.jpg',
        contentType: 'image/jpeg',
        row: { tutor_id: 'tutor-9', jenis_dokumen: 'kartu_identitas_pelajar', label: 'KTM / Kartu Tanda Pelajar', file_url: 'tutor-9/kartu_identitas_pelajar.jpg', status: 'terverifikasi', uploaded_at: '2026-11-23T00:00:00.000Z' },
      },
    ]);
  });

  it('mengabaikan jenis dokumen yang tidak dikenal dan nilai bukan teks', () => {
    expect(buildDocumentCopies('t', { ktp: 'x/ktp.pdf', transkrip: 5 }, 'now')).toEqual([]);
    expect(buildDocumentCopies('t', null, 'now')).toEqual([]);
  });
});

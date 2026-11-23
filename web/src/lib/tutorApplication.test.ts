import { describe, expect, it } from 'vitest';
import {
  applicationErrorMessage,
  emptyApplicationForm,
  oprecState,
  toPayload,
  validateApplication,
  type ApplicationForm,
} from './tutorApplication';

const valid = (over: Partial<ApplicationForm> = {}): ApplicationForm => ({
  ...emptyApplicationForm(),
  full_name: 'Alya Rahma',
  university: 'ITB',
  major: 'Teknik Fisika',
  semester: '5',
  whatsapp: '0812-3456-7890',
  email: 'Alya@Example.com',
  subjects: ['mtk'],
  jenjang: ['sma'],
  experience: 'Privat 2 tahun',
  ...over,
});

describe('validateApplication', () => {
  it('lolos untuk isian lengkap', () => {
    expect(validateApplication(valid())).toEqual({});
  });

  it('semester, jurusan, dan pengalaman boleh kosong', () => {
    expect(validateApplication(valid({ semester: '', major: '', experience: '' }))).toEqual({});
  });

  it.each([
    ['full_name', { full_name: ' ' }],
    ['university', { university: '' }],
    ['whatsapp', { whatsapp: '12345' }],
    ['email', { email: 'bukan-email' }],
    ['subjects', { subjects: [] }],
    ['jenjang', { jenjang: [] }],
    ['semester', { semester: '99' }],
    ['semester', { semester: 'abc' }],
    ['experience', { experience: 'x'.repeat(1001) }],
  ] as Array<[string, Partial<ApplicationForm>]>)('menolak %s yang tidak valid', (field, over) => {
    expect(Object.keys(validateApplication(valid(over)))).toContain(field);
  });

  it('menerima nomor dengan +62, spasi, dan strip', () => {
    expect(validateApplication(valid({ whatsapp: '+62 812-3456-7890' }))).toEqual({});
  });
});

describe('toPayload', () => {
  it('merapikan teks dan mengubah semester jadi angka', () => {
    const p = toPayload(valid({ full_name: '  Alya  ', semester: '5' }));
    expect(p.full_name).toBe('Alya');
    expect(p.semester).toBe(5);
    expect(p.email).toBe('alya@example.com');
  });

  it('tidak mengirim semester dan jurusan yang kosong', () => {
    const p = toPayload(valid({ semester: '', major: '' }));
    expect('semester' in p).toBe(false);
    expect('major' in p).toBe(false);
  });
});

describe('applicationErrorMessage', () => {
  it.each([
    ['rate_limited', 'terlalu sering'],
    ['duplicate', 'sudah terdaftar'],
    ['oprec_closed', 'ditutup'],
    ['invalid_input:whatsapp', 'WhatsApp'],
    ['invalid_session', 'Muat ulang'],
  ])('menerjemahkan %s', (raw, kata) => {
    expect(applicationErrorMessage(`error: ${raw}`)).toContain(kata);
  });

  it('memakai pesan umum untuk galat tak dikenal tanpa membocorkan detail', () => {
    expect(applicationErrorMessage('relation "x" does not exist')).toBe('Pendaftaran belum bisa dikirim. Coba lagi sebentar lagi.');
  });
});

describe('oprecState', () => {
  const today = new Date('2026-12-01T10:00:00');

  it('terbuka bila tidak ada data oprec', () => {
    expect(oprecState(null, today).open).toBe(true);
  });

  it('terbuka bila aktif dan tanggal kosong', () => {
    expect(oprecState({ is_active: true, start_date: null, end_date: null }, today).open).toBe(true);
  });

  it('tertutup bila nonaktif', () => {
    expect(oprecState({ is_active: false, start_date: null, end_date: null }, today).open).toBe(false);
  });

  it('tertutup sebelum tanggal mulai dan setelah tanggal selesai, terbuka di hari batas', () => {
    expect(oprecState({ is_active: true, start_date: '2026-12-05', end_date: null }, today).open).toBe(false);
    expect(oprecState({ is_active: true, start_date: null, end_date: '2026-11-30' }, today).open).toBe(false);
    expect(oprecState({ is_active: true, start_date: '2026-12-01', end_date: '2026-12-01' }, today).open).toBe(true);
  });
});

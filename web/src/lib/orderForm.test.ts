import { describe, expect, it } from 'vitest';
import { orderErrorMessage, toOrderPayload, validateOrder, type OrderInput } from './orderForm';

const ATTEMPT = '0a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d';
const PACKAGE = 'f0e1d2c3-b4a5-4968-8776-655443322110';

const base = (over: Partial<OrderInput> = {}): OrderInput => ({
  nama: 'Rani',
  wa: '0812-3456-7890',
  mapel: 'Matematika',
  jenjang: 'SMA',
  ...over,
});

describe('validateOrder', () => {
  it('lolos untuk isian lengkap', () => {
    expect(validateOrder(base())).toEqual({});
  });

  it.each([
    ['nama', { nama: ' ' }],
    ['nama', { nama: 'x'.repeat(101) }],
    ['wa', { wa: '123' }],
    ['wa', { wa: 'abcdefghij' }],
    ['mapel', { mapel: '' }],
    ['jenjang', { jenjang: '' }],
  ] as Array<[string, Partial<OrderInput>]>)('menolak %s yang tidak valid', (field, over) => {
    expect(Object.keys(validateOrder(base(over)))).toContain(field);
  });

  it('menerima nomor dengan +62', () => {
    expect(validateOrder(base({ wa: '+62 812 3456 7890' }))).toEqual({});
  });
});

describe('toOrderPayload', () => {
  it('merapikan teks dan menyertakan tautan tes dan paket bila ada', () => {
    const p = toOrderPayload(base({ nama: '  Rani  ', attemptId: ATTEMPT, packageId: PACKAGE }));
    expect(p).toEqual({ nama: 'Rani', wa: '0812-3456-7890', mapel: 'Matematika', jenjang: 'SMA', diagnostic_attempt_id: ATTEMPT, package_id: PACKAGE });
  });

  it('tanpa tes atau paket, kuncinya tidak dikirim', () => {
    const p = toOrderPayload(base());
    expect('diagnostic_attempt_id' in p).toBe(false);
    expect('package_id' in p).toBe(false);
    expect('notes' in p).toBe(false);
  });

  it('tutor pilihan masuk ke catatan order', () => {
    expect(toOrderPayload(base({ tutor: 'Alya Rahma' })).notes).toBe('Tutor pilihan: Alya Rahma');
  });
});

describe('orderErrorMessage', () => {
  it.each([
    ['rate_limited', 'terlalu sering'],
    ['duplicate', 'sudah masuk'],
    ['invalid_input:wa', 'WhatsApp'],
    ['invalid_session', 'Muat ulang'],
  ])('menerjemahkan %s', (raw, kata) => {
    expect(orderErrorMessage(`x ${raw}`)).toContain(kata);
  });

  it('pesan umum untuk galat tak dikenal, tanpa membocorkan detail', () => {
    expect(orderErrorMessage('permission denied for table manual_orders')).toBe('Orderan belum bisa dikirim. Coba lagi sebentar lagi.');
  });
});

import { describe, expect, it } from 'vitest';
import { buildOrderPath, parseOrderParams } from './order';
import { LEVEL_INFO } from './levels';

const ATTEMPT = '0a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d';
const PACKAGE = 'f0e1d2c3-b4a5-4968-8776-655443322110';

describe('buildOrderPath', () => {
  it('memuat attempt, paket, mapel, dan jangkar #order', () => {
    expect(buildOrderPath(ATTEMPT, PACKAGE)).toBe(
      `/?attempt=${ATTEMPT}&package=${PACKAGE}&subject=Bahasa%20Inggris#order`
    );
  });
  it('tanpa paket: parameter package dihilangkan (Review Focus 3)', () => {
    expect(buildOrderPath(ATTEMPT, null)).toBe(`/?attempt=${ATTEMPT}&subject=Bahasa%20Inggris#order`);
  });
});

describe('parseOrderParams', () => {
  it('membaca parameter yang valid', () => {
    expect(parseOrderParams(`?attempt=${ATTEMPT}&package=${PACKAGE}&subject=Bahasa%20Inggris`)).toEqual({
      attemptId: ATTEMPT,
      packageId: PACKAGE,
      subject: 'Bahasa Inggris',
    });
  });
  it('tanpa parameter: semua undefined sehingga order biasa tidak berubah', () => {
    expect(parseOrderParams('')).toEqual({ attemptId: undefined, packageId: undefined, subject: undefined });
  });
  it('membuang ID yang bukan UUID agar insert ke kolom uuid tidak gagal', () => {
    const parsed = parseOrderParams('?attempt=abc&package=1%20OR%201=1&subject=Bahasa%20Inggris');
    expect(parsed.attemptId).toBeUndefined();
    expect(parsed.packageId).toBeUndefined();
  });
  it('hanya menerima mapel dari daftar yang dikenal', () => {
    expect(parseOrderParams('?subject=Bahasa%20Inggris').subject).toBe('Bahasa Inggris');
    expect(parseOrderParams('?subject=<script>').subject).toBeUndefined();
  });
});

describe('LEVEL_INFO', () => {
  it('punya judul dan kalimat "kamu bisa" untuk semua level', () => {
    for (const level of ['PRE_A1', 'A1', 'A2', 'B1', 'B2'] as const) {
      expect(LEVEL_INFO[level].title.length).toBeGreaterThan(3);
      expect(LEVEL_INFO[level].can.length).toBeGreaterThan(15);
    }
  });
});

import { describe, expect, it } from 'vitest';
import { bandShares, conversionPercent, levelShares } from './stats';
import type { DiagnosticStats, UtbkStats } from '../../types/diagnostic';

function stats(by: Partial<DiagnosticStats['by_level']>): DiagnosticStats {
  const by_level = { PRE_A1: 0, A1: 0, A2: 0, B1: 0, B2: 0, ...by };
  const total = Object.values(by_level).reduce((a, b) => a + b, 0);
  return { total_attempts: total, by_level, orders_from_tests: 0, recent: [] };
}

describe('conversionPercent', () => {
  it('menghitung persen pembulatan', () => {
    expect(conversionPercent(20, 5)).toBe(25);
    expect(conversionPercent(3, 1)).toBe(33);
  });
  it('0 bila belum ada tes (tanpa NaN)', () => {
    expect(conversionPercent(0, 0)).toBe(0);
  });
  it('dibatasi 100 bila order lebih banyak dari tes', () => {
    expect(conversionPercent(2, 5)).toBe(100);
  });
});

describe('levelShares', () => {
  it('mengurutkan level dari PRE_A1 ke B2 dengan persentase terhadap total', () => {
    const shares = levelShares(stats({ A1: 1, B1: 3 }));
    expect(shares.map((s) => s.level)).toEqual(['PRE_A1', 'A1', 'A2', 'B1', 'B2']);
    expect(shares.find((s) => s.level === 'B1')).toMatchObject({ count: 3, percent: 75 });
    expect(shares.find((s) => s.level === 'A2')).toMatchObject({ count: 0, percent: 0 });
  });
  it('semua persen 0 bila belum ada tes', () => {
    expect(levelShares(stats({})).every((s) => s.percent === 0)).toBe(true);
  });
});

function utbk(by: Partial<UtbkStats['by_band']>): UtbkStats {
  const by_band = { UTBK_RENDAH: 0, UTBK_SEDANG: 0, UTBK_TINGGI: 0, ...by };
  const total = Object.values(by_band).reduce((a, b) => a + b, 0);
  return { total_attempts: total, by_band, avg_percent: { pu: null, pk: null, lbi: null }, orders_from_tests: 0, recent: [] };
}

describe('bandShares', () => {
  it('urutan rendah, sedang, tinggi dengan persentase terhadap total', () => {
    const shares = bandShares(utbk({ UTBK_RENDAH: 1, UTBK_TINGGI: 3 }));
    expect(shares.map((s) => s.band)).toEqual(['UTBK_RENDAH', 'UTBK_SEDANG', 'UTBK_TINGGI']);
    expect(shares.find((s) => s.band === 'UTBK_TINGGI')).toMatchObject({ count: 3, percent: 75 });
    expect(shares.find((s) => s.band === 'UTBK_SEDANG')).toMatchObject({ count: 0, percent: 0 });
  });
  it('semua persen 0 bila belum ada tes', () => {
    expect(bandShares(utbk({})).every((s) => s.percent === 0)).toBe(true);
  });
});

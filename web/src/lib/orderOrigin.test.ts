import { describe, expect, it } from 'vitest';
import { describeOrderOrigin } from './orderOrigin';

describe('describeOrderOrigin', () => {
  it('null untuk order biasa tanpa tes maupun paket', () => {
    expect(describeOrderOrigin({ attempt: null, package: null })).toBeNull();
    expect(describeOrderOrigin({})).toBeNull();
  });

  it('menjelaskan order dari tes English: level, skor, dan paket', () => {
    const origin = describeOrderOrigin({
      attempt: { test_code: 'english', level: 'PRE_A1', score: 3, result: null },
      package: { package_name: 'Bundling Bulanan (12 Sesi)' },
    });
    expect(origin).toEqual({ test: 'Tes English · Pre-A1 · skor 3', packageName: 'Bundling Bulanan (12 Sesi)' });
  });

  it('menjelaskan order dari try out UTBK: pita dan skor', () => {
    const origin = describeOrderOrigin({
      attempt: { test_code: 'utbk', level: null, score: 15, result: { band: 'UTBK_SEDANG' } },
      package: { package_name: 'Bundling SNBT — Juara' },
    });
    expect(origin?.test).toBe('Try out UTBK · Sudah cukup, tinggal diperdalam · skor 15');
    expect(origin?.packageName).toBe('Bundling SNBT — Juara');
  });

  it('tetap menampilkan tes bila paket tidak ada (aturan tanpa paket)', () => {
    const origin = describeOrderOrigin({ attempt: { test_code: 'english', level: 'B1', score: 16, result: null }, package: null });
    expect(origin).toEqual({ test: 'Tes English · B1 · skor 16', packageName: null });
  });

  it('hanya paket (tanpa tes) tetap dijelaskan', () => {
    expect(describeOrderOrigin({ attempt: null, package: { package_name: 'Bundling Terset' } })).toEqual({
      test: null,
      packageName: 'Bundling Terset',
    });
  });

  it('tidak gagal untuk kode tes atau pita yang tidak dikenal', () => {
    const origin = describeOrderOrigin({ attempt: { test_code: 'lain', level: null, score: 7, result: { band: 'BARU' } }, package: null });
    expect(origin?.test).toContain('skor 7');
  });
});

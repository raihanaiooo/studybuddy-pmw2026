import { describe, expect, it } from 'vitest';
import { BAND_INFO, SUBTEST_INFO, UTBK_DISCLAIMER, UTBK_TEST_CODE, subtestPercent, weakestText } from './utbk';

describe('konstanta UTBK', () => {
  it('kode tes dan disclaimer persis seperti spec', () => {
    expect(UTBK_TEST_CODE).toBe('utbk');
    expect(UTBK_DISCLAIMER).toBe(
      'Ini try out singkat sebagai gambaran awal, bukan penentu atau prediksi kelulusan. Paket yang paling pas tergantung target dan kebutuhan Buddy; admin akan membantu memastikannya.'
    );
  });

  it('subtes dan pita punya label', () => {
    expect(SUBTEST_INFO.pu.title).toBe('Penalaran Umum');
    expect(SUBTEST_INFO.pk.title).toBe('Pengetahuan Kuantitatif');
    expect(SUBTEST_INFO.lbi.title).toBe('Literasi Bahasa Indonesia');
    for (const band of ['UTBK_RENDAH', 'UTBK_SEDANG', 'UTBK_TINGGI'] as const) {
      expect(BAND_INFO[band].label.length).toBeGreaterThan(3);
    }
  });
});

describe('weakestText', () => {
  it('kosong berarti seimbang', () => {
    expect(weakestText([])).toBe('Kemampuanmu relatif seimbang di ketiga subtes');
  });
  it('satu subtes disebut dengan judulnya', () => {
    expect(weakestText(['pu'])).toBe('Perlu diperkuat: Penalaran Umum');
  });
  it('beberapa subtes disebut semuanya', () => {
    const text = weakestText(['pu', 'pk']);
    expect(text).toContain('Penalaran Umum');
    expect(text).toContain('Pengetahuan Kuantitatif');
  });
});

describe('subtestPercent', () => {
  it('membulatkan persen benar', () => {
    expect(subtestPercent({ correct: 3, total: 8 })).toBe(38);
    expect(subtestPercent({ correct: 8, total: 8 })).toBe(100);
  });
  it('0 bila total 0 (tanpa NaN)', () => {
    expect(subtestPercent({ correct: 0, total: 0 })).toBe(0);
  });
});

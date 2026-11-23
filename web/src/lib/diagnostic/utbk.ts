import type { UtbkBand, UtbkSubtest, UtbkSubtestScore } from '../../types/diagnostic';

export const UTBK_TEST_CODE = 'utbk';

export const UTBK_DISCLAIMER =
  'Ini try out singkat sebagai gambaran awal, bukan penentu atau prediksi kelulusan. Paket yang paling pas tergantung target dan kebutuhan Buddy; admin akan membantu memastikannya.';

export const SUBTEST_INFO: Record<UtbkSubtest, { title: string; hint: string }> = {
  pu: { title: 'Penalaran Umum', hint: 'logika dan penalaran' },
  pk: { title: 'Pengetahuan Kuantitatif', hint: 'hitungan' },
  lbi: { title: 'Literasi Bahasa Indonesia', hint: 'bacaan' },
};

export const BAND_INFO: Record<UtbkBand, { label: string }> = {
  UTBK_RENDAH: { label: 'Perlu membangun dasar' },
  UTBK_SEDANG: { label: 'Sudah cukup, tinggal diperdalam' },
  UTBK_TINGGI: { label: 'Sudah kuat, tinggal dipoles' },
};

/** Persen benar satu subtes, dibulatkan; 0 bila tidak ada soal. */
export function subtestPercent(score: UtbkSubtestScore): number {
  return score.total <= 0 ? 0 : Math.round((score.correct / score.total) * 100);
}

export function weakestText(weakest: UtbkSubtest[]): string {
  if (weakest.length === 0) return 'Kemampuanmu relatif seimbang di ketiga subtes';
  return `Perlu diperkuat: ${weakest.map((s) => SUBTEST_INFO[s].title).join(', ')}`;
}

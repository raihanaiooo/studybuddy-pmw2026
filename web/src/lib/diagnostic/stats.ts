import type { DiagnosticLevel, DiagnosticStats, UtbkBand, UtbkStats } from '../../types/diagnostic';

export const LEVEL_ORDER: DiagnosticLevel[] = ['PRE_A1', 'A1', 'A2', 'B1', 'B2'];

/** Persentase tes yang berlanjut jadi order, 0..100. */
export function conversionPercent(attempts: number, orders: number): number {
  if (attempts <= 0) return 0;
  return Math.min(100, Math.round((orders / attempts) * 100));
}

export interface LevelShare {
  level: DiagnosticLevel;
  count: number;
  percent: number;
}

export function levelShares(stats: DiagnosticStats): LevelShare[] {
  const total = LEVEL_ORDER.reduce((sum, level) => sum + (stats.by_level[level] ?? 0), 0);
  return LEVEL_ORDER.map((level) => {
    const count = stats.by_level[level] ?? 0;
    return { level, count, percent: total === 0 ? 0 : Math.round((count / total) * 100) };
  });
}

export const BAND_ORDER: UtbkBand[] = ['UTBK_RENDAH', 'UTBK_SEDANG', 'UTBK_TINGGI'];

export interface BandShare {
  band: UtbkBand;
  count: number;
  percent: number;
}

export function bandShares(stats: UtbkStats): BandShare[] {
  const total = BAND_ORDER.reduce((sum, band) => sum + (stats.by_band[band] ?? 0), 0);
  return BAND_ORDER.map((band) => {
    const count = stats.by_band[band] ?? 0;
    return { band, count, percent: total === 0 ? 0 : Math.round((count / total) * 100) };
  });
}

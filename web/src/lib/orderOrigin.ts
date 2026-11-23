import { BAND_INFO } from './diagnostic/utbk';
import type { UtbkBand } from '../types/diagnostic';

interface OriginAttempt {
  test_code: string;
  level: string | null;
  score: number;
  result: { band?: string } | null;
}

export interface OrderWithOrigin {
  attempt?: OriginAttempt | null;
  package?: { package_name: string } | null;
}

export interface OrderOrigin {
  test: string | null;
  packageName: string | null;
}

function levelText(level: string): string {
  return level === 'PRE_A1' ? 'Pre-A1' : level;
}

/** Ringkasan asal order (hasil tes dan paket yang disarankan) untuk panel admin; null bila order biasa. */
export function describeOrderOrigin(order: OrderWithOrigin): OrderOrigin | null {
  const attempt = order.attempt ?? null;
  const packageName = order.package?.package_name ?? null;
  if (!attempt && !packageName) return null;

  let test: string | null = null;
  if (attempt) {
    if (attempt.test_code === 'english') {
      test = `Tes English · ${attempt.level ? levelText(attempt.level) : '-'} · skor ${attempt.score}`;
    } else if (attempt.test_code === 'utbk') {
      const band = attempt.result?.band;
      const label = band && band in BAND_INFO ? BAND_INFO[band as UtbkBand].label : '-';
      test = `Try out UTBK · ${label} · skor ${attempt.score}`;
    } else {
      test = `Tes ${attempt.test_code} · skor ${attempt.score}`;
    }
  }
  return { test, packageName };
}

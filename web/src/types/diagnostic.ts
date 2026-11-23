export type DiagnosticSkill = 'grammar' | 'vocabulary' | 'reading' | 'pu' | 'pk' | 'lbi';
export type DiagnosticQuestionLevel = 'A1' | 'A2' | 'B1' | 'B2';
export type DiagnosticLevel = 'PRE_A1' | DiagnosticQuestionLevel;

/** Soal untuk pengunjung: tanpa kunci jawaban dan penjelasan (view diagnostic_questions_public). */
export interface DiagnosticQuestion {
  id: string;
  position: number;
  skill: DiagnosticSkill;
  /** Null untuk soal UTBK (tanpa level CEFR). */
  level: DiagnosticQuestionLevel | null;
  stem: string;
  passage: string | null;
  options: string[];
}

export interface DiagnosticPackage {
  id: string;
  package_name: string;
  price: number;
  reason: string;
}

export interface DiagnosticTutor {
  id: string;
  full_name: string;
  university: string | null;
}

/** Hasil RPC submit_diagnostic_attempt. */
export interface DiagnosticResult {
  attempt_id: string;
  score: number;
  total: number;
  level: DiagnosticLevel;
  package: DiagnosticPackage | null;
  tutors: DiagnosticTutor[];
  per_level: Record<DiagnosticQuestionLevel, number>;
}

export interface DiagnosticRecentAttempt {
  id: string;
  level: DiagnosticLevel;
  score: number;
  created_at: string;
  ordered: boolean;
}

/** Hasil RPC diagnostic_stats (khusus management). */
export interface DiagnosticStats {
  total_attempts: number;
  by_level: Record<DiagnosticLevel, number>;
  orders_from_tests: number;
  recent: DiagnosticRecentAttempt[];
}

export type UtbkSubtest = 'pu' | 'pk' | 'lbi';
export type UtbkBand = 'UTBK_RENDAH' | 'UTBK_SEDANG' | 'UTBK_TINGGI';

export interface UtbkSubtestScore {
  correct: number;
  total: number;
}

/** Hasil RPC submit_utbk_attempt. */
export interface UtbkResult {
  attempt_id: string;
  score: number;
  total: number;
  band: UtbkBand;
  per_subtest: Record<UtbkSubtest, UtbkSubtestScore>;
  /** Subtes dengan benar paling sedikit; kosong bila ketiganya sama. */
  weakest: UtbkSubtest[];
  package: DiagnosticPackage | null;
}

export interface UtbkRecentAttempt {
  id: string;
  band: UtbkBand;
  score: number;
  created_at: string;
  ordered: boolean;
}

/** Hasil RPC diagnostic_stats_utbk (khusus admin). */
export interface UtbkStats {
  total_attempts: number;
  by_band: Record<UtbkBand, number>;
  /** Persen benar rata-rata per subtes; null bila belum ada attempt. */
  avg_percent: Record<UtbkSubtest, number | null>;
  orders_from_tests: number;
  recent: UtbkRecentAttempt[];
}

export type DiagnosticSkill = 'grammar' | 'vocabulary' | 'reading';
export type DiagnosticQuestionLevel = 'A1' | 'A2' | 'B1' | 'B2';
export type DiagnosticLevel = 'PRE_A1' | DiagnosticQuestionLevel;

/** Soal untuk pengunjung: tanpa kunci jawaban dan penjelasan (view diagnostic_questions_public). */
export interface DiagnosticQuestion {
  id: string;
  position: number;
  skill: DiagnosticSkill;
  level: DiagnosticQuestionLevel;
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

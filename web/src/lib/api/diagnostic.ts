import { supabase } from '../supabase';
import { getClientSessionId } from '../diagnostic/session';
import type {
  DiagnosticQuestion,
  DiagnosticResult,
  DiagnosticStats,
  UtbkResult,
  UtbkStats,
} from '../../types/diagnostic';

const ERROR_MESSAGES: Record<string, string> = {
  rate_limited: 'Kamu sudah terlalu sering mengerjakan tes. Coba lagi dalam satu jam.',
  invalid_answers: 'Jawabanmu belum lengkap. Pastikan semua soal sudah dijawab.',
  unknown_test: 'Tes ini belum tersedia.',
  invalid_session: 'Sesi tidak valid. Muat ulang halaman lalu coba lagi.',
};

function friendlyMessage(raw: string): string {
  const code = Object.keys(ERROR_MESSAGES).find((c) => raw.includes(c));
  return code ? ERROR_MESSAGES[code] : raw;
}

export async function fetchQuestions(testCode: string): Promise<DiagnosticQuestion[]> {
  const { data, error } = await supabase
    .from('diagnostic_questions_public')
    .select('id, position, skill, level, stem, passage, options')
    .eq('test_code', testCode)
    .order('position', { ascending: true });

  if (error) throw new Error(error.message);
  return (data ?? []) as DiagnosticQuestion[];
}

/** answers: { [questionId]: indeks opsi }. Mengembalikan hasil dari server. */
export async function submitAttempt(
  testCode: string,
  answers: Record<string, number>
): Promise<DiagnosticResult> {
  const { data, error } = await supabase.rpc('submit_diagnostic_attempt', {
    p_test_code: testCode,
    p_client_session_id: getClientSessionId(),
    p_answers: answers,
  });

  if (error) throw new Error(friendlyMessage(error.message));
  return data as DiagnosticResult;
}

export async function fetchDiagnosticStats(): Promise<DiagnosticStats> {
  const { data, error } = await supabase.rpc('diagnostic_stats');
  if (error) throw new Error(error.message);
  return data as DiagnosticStats;
}

/** Try out UTBK: kode tes tetap 'utbk' di server, jadi hanya jawaban yang dikirim. */
export async function submitUtbkAttempt(answers: Record<string, number>): Promise<UtbkResult> {
  const { data, error } = await supabase.rpc('submit_utbk_attempt', {
    p_client_session_id: getClientSessionId(),
    p_answers: answers,
  });

  if (error) throw new Error(friendlyMessage(error.message));
  return data as UtbkResult;
}

export async function fetchUtbkStats(): Promise<UtbkStats> {
  const { data, error } = await supabase.rpc('diagnostic_stats_utbk');
  if (error) throw new Error(error.message);
  return data as UtbkStats;
}

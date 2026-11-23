import type { DiagnosticQuestion } from '../../types/diagnostic';

export function answeredCount(questions: DiagnosticQuestion[], answers: Record<string, number>): number {
  return questions.filter((q) => answers[q.id] !== undefined).length;
}

export function isComplete(questions: DiagnosticQuestion[], answers: Record<string, number>): boolean {
  return questions.length > 0 && answeredCount(questions, answers) === questions.length;
}

/** Indeks soal pertama yang belum dijawab; bila semua terjawab, indeks soal terakhir. */
export function firstUnansweredIndex(questions: DiagnosticQuestion[], answers: Record<string, number>): number {
  const index = questions.findIndex((q) => answers[q.id] === undefined);
  return index === -1 ? Math.max(questions.length - 1, 0) : index;
}

/** Membuang jawaban draft untuk soal yang sudah tidak ada atau indeks opsi yang tidak valid. */
export function pruneAnswers(
  questions: DiagnosticQuestion[],
  answers: Record<string, number>
): Record<string, number> {
  const pruned: Record<string, number> = {};
  for (const q of questions) {
    const value = answers[q.id];
    if (value !== undefined && value < q.options.length) pruned[q.id] = value;
  }
  return pruned;
}

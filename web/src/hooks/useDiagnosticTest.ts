import { useCallback, useEffect, useRef, useState } from 'react';
import { fetchQuestions, submitAttempt } from '../lib/api/diagnostic';
import { clearDraft, loadDraft, saveDraft } from '../lib/diagnostic/session';
import { firstUnansweredIndex, isComplete, pruneAnswers } from '../lib/diagnostic/progress';
import type { DiagnosticQuestion, DiagnosticResult } from '../types/diagnostic';

export type DiagnosticStatus = 'loading' | 'intro' | 'in_progress' | 'submitting' | 'done' | 'error';

export function useDiagnosticTest(testCode: string) {
  const [status, setStatus] = useState<DiagnosticStatus>('loading');
  const [questions, setQuestions] = useState<DiagnosticQuestion[]>([]);
  const [index, setIndex] = useState(0);
  const [answers, setAnswers] = useState<Record<string, number>>({});
  const [result, setResult] = useState<DiagnosticResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const submittingRef = useRef(false);

  useEffect(() => {
    let active = true;
    fetchQuestions(testCode)
      .then((loaded) => {
        if (!active) return;
        if (loaded.length === 0) {
          setError('Tes ini belum tersedia. Coba lagi nanti.');
          setStatus('error');
          return;
        }
        // Pulihkan draft (mis. setelah refresh di tengah tes).
        const draft = pruneAnswers(loaded, loadDraft());
        const hasDraft = Object.keys(draft).length > 0;
        setQuestions(loaded);
        setAnswers(draft);
        setIndex(hasDraft ? firstUnansweredIndex(loaded, draft) : 0);
        setStatus(hasDraft ? 'in_progress' : 'intro');
      })
      .catch((e: unknown) => {
        if (!active) return;
        setError(e instanceof Error ? e.message : 'Gagal memuat soal.');
        setStatus('error');
      });
    return () => {
      active = false;
    };
  }, [testCode]);

  const start = useCallback(() => setStatus('in_progress'), []);

  const answer = useCallback((questionId: string, optionIndex: number) => {
    setAnswers((prev) => {
      const next = { ...prev, [questionId]: optionIndex };
      saveDraft(next);
      return next;
    });
  }, []);

  const next = useCallback(() => setIndex((i) => Math.min(i + 1, questions.length - 1)), [questions.length]);
  const prev = useCallback(() => setIndex((i) => Math.max(i - 1, 0)), []);

  const submit = useCallback(async () => {
    if (submittingRef.current || !isComplete(questions, answers)) return;
    submittingRef.current = true;
    setError(null);
    setStatus('submitting');
    try {
      const res = await submitAttempt(testCode, answers);
      clearDraft();
      setResult(res);
      setStatus('done');
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal mengirim jawaban.');
      setStatus('in_progress');
    } finally {
      submittingRef.current = false;
    }
  }, [questions, answers, testCode]);

  const restart = useCallback(() => {
    clearDraft();
    setAnswers({});
    setIndex(0);
    setResult(null);
    setError(null);
    setStatus('intro');
  }, []);

  return { status, questions, index, answers, result, error, start, answer, next, prev, submit, restart };
}

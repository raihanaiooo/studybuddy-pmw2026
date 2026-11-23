import { TestRunner } from '../components/diagnostic/TestRunner';
import { UtbkResultCard } from '../components/diagnostic/UtbkResultCard';
import { submitUtbkAttempt } from '../lib/api/diagnostic';
import { SUBTEST_INFO, UTBK_DISCLAIMER, UTBK_TEST_CODE } from '../lib/diagnostic/utbk';
import type { DiagnosticQuestion, UtbkSubtest } from '../types/diagnostic';

function subtestBadge(question: DiagnosticQuestion): string | undefined {
  return question.skill in SUBTEST_INFO ? SUBTEST_INFO[question.skill as UtbkSubtest].title : undefined;
}

export function UtbkTestPage() {
  return (
    <TestRunner
      testCode={UTBK_TEST_CODE}
      submitFn={submitUtbkAttempt}
      questionBadge={subtestBadge}
      intro={{
        title: 'Cek kesiapan UTBK kamu.',
        body: (count) =>
          `${count} soal pilihan ganda dari tiga subtes (penalaran umum, kuantitatif, dan literasi Bahasa Indonesia), sekitar 15 menit. Tanpa daftar dan tanpa data pribadi. Di akhir kamu dapat skor per subtes, bagian yang perlu diperkuat, dan paket SNBT yang disarankan.`,
        extra: (
          <p className="mt-5 rounded-2xl border-2 border-[var(--line)] bg-[var(--bg)] px-4 py-3 text-sm text-[var(--mute)] leading-relaxed">
            {UTBK_DISCLAIMER}
          </p>
        ),
      }}
      renderResult={(result, restart) => <UtbkResultCard result={result} onRestart={restart} />}
    />
  );
}

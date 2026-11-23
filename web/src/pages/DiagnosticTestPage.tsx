import { TestRunner } from '../components/diagnostic/TestRunner';
import { ResultCard } from '../components/diagnostic/ResultCard';
import { submitAttempt } from '../lib/api/diagnostic';

const TEST_CODE = 'english';

const submitEnglish = (answers: Record<string, number>) => submitAttempt(TEST_CODE, answers);

export function DiagnosticTestPage() {
  return (
    <TestRunner
      testCode={TEST_CODE}
      submitFn={submitEnglish}
      intro={{
        title: 'Cek level English kamu.',
        body: (count) =>
          `${count} soal pilihan ganda, sekitar 8 menit. Tanpa daftar dan tanpa data pribadi. Di akhir kamu langsung dapat level, paket yang cocok, dan tutor yang bisa membantu.`,
      }}
      renderResult={(result, restart) => <ResultCard result={result} onRestart={restart} />}
    />
  );
}

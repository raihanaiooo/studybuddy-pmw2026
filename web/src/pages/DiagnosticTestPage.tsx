import { Link } from 'react-router-dom';
import { Loader2 } from 'lucide-react';
import { PublicLayout } from '../components/layout/PublicLayout';
import { ProgressBar } from '../components/diagnostic/ProgressBar';
import { QuestionCard } from '../components/diagnostic/QuestionCard';
import { useDiagnosticTest } from '../hooks/useDiagnosticTest';
import { answeredCount, isComplete } from '../lib/diagnostic/progress';

const TEST_CODE = 'english';

const primaryButton =
  'inline-flex items-center justify-center gap-2 font-extrabold rounded-2xl py-3 px-6 bg-[var(--blue)] text-white shadow-[0_5px_0_var(--bdark)] hover:-translate-y-0.5 hover:shadow-[0_7px_0_var(--bdark)] active:translate-y-1 active:shadow-none transition-all disabled:opacity-50 disabled:pointer-events-none';
const secondaryButton =
  'inline-flex items-center justify-center gap-2 font-extrabold rounded-2xl py-3 px-6 border-2 border-[var(--line)] text-[var(--ink)] hover:border-[var(--blue)] transition-colors disabled:opacity-40 disabled:pointer-events-none';

export function DiagnosticTestPage() {
  const test = useDiagnosticTest(TEST_CODE);
  const { status, questions, index, answers, error } = test;
  const current = questions[index];
  const complete = isComplete(questions, answers);
  const isLast = index === questions.length - 1;

  return (
    <PublicLayout>
      <header className="border-b border-[var(--line)] bg-[var(--bg)]/90">
        <div className="max-w-3xl mx-auto px-5 h-16 flex items-center justify-between">
          <Link to="/" className="text-xl font-extrabold tracking-tight text-[var(--ink)]">
            Study<span className="text-[var(--blue)]">Buddy</span>
          </Link>
          <Link to="/" className="text-sm font-bold text-[var(--mute)] hover:text-[var(--ink)]">
            Kembali ke beranda
          </Link>
        </div>
      </header>

      <main className="flex-1 max-w-3xl w-full mx-auto px-5 py-10 md:py-14">
        {status === 'loading' && (
          <div className="flex items-center justify-center gap-3 py-24 text-[var(--mute)] font-semibold">
            <Loader2 className="animate-spin" size={20} /> Memuat soal...
          </div>
        )}

        {status === 'error' && (
          <div className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-8 text-center">
            <h1 className="text-2xl font-extrabold text-[var(--ink)]">Tes belum bisa dibuka</h1>
            <p className="mt-3 text-[var(--mute)]">{error}</p>
            <Link to="/" className={`${primaryButton} mt-6`}>
              Kembali ke beranda
            </Link>
          </div>
        )}

        {status === 'intro' && (
          <div className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-8 md:p-10">
            <h1 className="text-3xl md:text-5xl font-extrabold leading-[1.05] text-[var(--ink)]">
              Cek level English kamu.
            </h1>
            <p className="mt-5 text-[var(--mute)] leading-relaxed">
              {questions.length} soal pilihan ganda, sekitar 8 menit. Tanpa daftar dan tanpa data pribadi. Di akhir
              kamu langsung dapat level, paket yang cocok, dan tutor yang bisa membantu.
            </p>
            <button type="button" onClick={test.start} className={`${primaryButton} mt-8`}>
              Mulai tes
            </button>
          </div>
        )}

        {(status === 'in_progress' || status === 'submitting') && current && (
          <div className="grid gap-6">
            <ProgressBar current={index + 1} total={questions.length} answered={answeredCount(questions, answers)} />

            <QuestionCard
              key={current.id}
              question={current}
              selected={answers[current.id]}
              onSelect={(option) => test.answer(current.id, option)}
            />

            {error && (
              <p role="alert" className="rounded-2xl border-2 border-red-300 bg-red-50 px-4 py-3 text-sm font-semibold text-red-700">
                {error}
              </p>
            )}

            <div className="flex items-center justify-between gap-3">
              <button type="button" onClick={test.prev} disabled={index === 0 || status === 'submitting'} className={secondaryButton}>
                Kembali
              </button>
              {isLast ? (
                <button
                  type="button"
                  onClick={test.submit}
                  disabled={!complete || status === 'submitting'}
                  className={primaryButton}
                >
                  {status === 'submitting' ? 'Mengirim...' : 'Kirim jawaban'}
                </button>
              ) : (
                <button
                  type="button"
                  onClick={test.next}
                  disabled={answers[current.id] === undefined || status === 'submitting'}
                  className={primaryButton}
                >
                  Lanjut
                </button>
              )}
            </div>
            {isLast && !complete && (
              <p className="text-sm text-[var(--mute)] text-center">Jawab semua soal dulu untuk mengirim.</p>
            )}
          </div>
        )}

        {status === 'done' && test.result && (
          <div className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-8 md:p-10 text-center">
            <p className="text-sm font-bold text-[var(--mute)]">Level kamu</p>
            <h1 className="mt-2 text-5xl font-extrabold text-[var(--blue)]">{test.result.level.replace('_', '-')}</h1>
            <p className="mt-3 text-[var(--mute)]">
              Skor {test.result.score} dari {test.result.total}
            </p>
          </div>
        )}
      </main>
    </PublicLayout>
  );
}

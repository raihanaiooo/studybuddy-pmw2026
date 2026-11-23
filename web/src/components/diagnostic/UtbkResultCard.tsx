import { buildOrderPath, UTBK_SUBJECT } from '../../lib/diagnostic/order';
import { BAND_INFO, SUBTEST_INFO, UTBK_DISCLAIMER, subtestPercent, weakestText } from '../../lib/diagnostic/utbk';
import type { UtbkResult, UtbkSubtest } from '../../types/diagnostic';

interface UtbkResultCardProps {
  result: UtbkResult;
  onRestart: () => void;
}

const SUBTEST_ORDER: UtbkSubtest[] = ['pu', 'pk', 'lbi'];

function rupiah(value: number): string {
  return `Rp${Number(value).toLocaleString('id-ID')}`;
}

export function UtbkResultCard({ result, onRestart }: UtbkResultCardProps) {
  const pkg = result.package;

  return (
    <div className="grid gap-6">
      <section className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-8 md:p-10">
        <p className="text-sm font-bold text-[var(--mute)] text-center">Skor try out kamu</p>
        <h1 className="mt-2 text-6xl font-extrabold text-[var(--blue)] text-center">
          {result.score}
          <span className="text-2xl text-[var(--mute)]"> / {result.total}</span>
        </h1>
        <p className="mt-1 text-center text-lg font-extrabold text-[var(--ink)]">{BAND_INFO[result.band].label}</p>

        <ul className="mt-8 grid gap-4">
          {SUBTEST_ORDER.map((key) => {
            const score = result.per_subtest[key];
            const percent = subtestPercent(score);
            return (
              <li key={key} className="grid gap-1.5">
                <div className="flex items-baseline justify-between gap-3 text-sm">
                  <span className="font-extrabold text-[var(--ink)]">
                    {SUBTEST_INFO[key].title} <span className="font-medium text-[var(--mute)]">({SUBTEST_INFO[key].hint})</span>
                  </span>
                  <span className="font-bold text-[var(--mute)]">
                    {score.correct}/{score.total}
                  </span>
                </div>
                <div
                  role="progressbar"
                  aria-label={SUBTEST_INFO[key].title}
                  aria-valuemin={0}
                  aria-valuemax={100}
                  aria-valuenow={percent}
                  className="h-3 rounded-full bg-[var(--line)] overflow-hidden"
                >
                  <div className="h-full bg-[var(--blue)]" style={{ width: `${percent}%` }} />
                </div>
              </li>
            );
          })}
        </ul>

        <p className="mt-6 text-center font-bold text-[var(--ink)]">{weakestText(result.weakest)}</p>
      </section>

      <section className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-6 md:p-8">
        <h2 className="text-xl font-extrabold text-[var(--ink)]">Paket yang disarankan</h2>
        {pkg ? (
          <div className="mt-3">
            <p className="text-lg font-extrabold text-[var(--blue)]">{pkg.package_name}</p>
            <p className="text-sm font-bold text-[var(--mute)]">{rupiah(pkg.price)}</p>
            <p className="mt-2 text-[var(--mute)] leading-relaxed">{pkg.reason}</p>
          </div>
        ) : (
          <p className="mt-3 text-[var(--mute)] leading-relaxed">
            Admin kami akan membantu memilihkan paket SNBT yang paling pas untukmu.
          </p>
        )}
        <a
          href={buildOrderPath(result.attempt_id, pkg?.id ?? null, UTBK_SUBJECT)}
          className="mt-6 inline-flex items-center justify-center font-extrabold rounded-2xl py-3 px-6 bg-[var(--yel)] text-[var(--ink)] shadow-[0_5px_0_#B87A00] hover:-translate-y-0.5 hover:shadow-[0_7px_0_#B87A00] active:translate-y-1 active:shadow-none transition-all"
        >
          {pkg ? 'Pesan paket ini' : 'Hubungi admin untuk pesan'}
        </a>
      </section>

      <p className="rounded-2xl border-2 border-[var(--line)] bg-[var(--bg)] px-4 py-3 text-sm text-[var(--mute)] leading-relaxed">
        {UTBK_DISCLAIMER}
      </p>

      <button
        type="button"
        onClick={onRestart}
        className="justify-self-center text-sm font-bold text-[var(--mute)] underline hover:text-[var(--ink)]"
      >
        Ulangi tes
      </button>
    </div>
  );
}

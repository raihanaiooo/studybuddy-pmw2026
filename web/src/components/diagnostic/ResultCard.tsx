import { LEVEL_INFO } from '../../lib/diagnostic/levels';
import { buildOrderPath } from '../../lib/diagnostic/order';
import type { DiagnosticResult } from '../../types/diagnostic';

interface ResultCardProps {
  result: DiagnosticResult;
  onRestart: () => void;
}

function rupiah(value: number): string {
  return `Rp${Number(value).toLocaleString('id-ID')}`;
}

export function ResultCard({ result, onRestart }: ResultCardProps) {
  const info = LEVEL_INFO[result.level];
  const pkg = result.package;

  return (
    <div className="grid gap-6">
      <section className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-8 md:p-10 text-center">
        <p className="text-sm font-bold text-[var(--mute)]">Level kamu</p>
        <h1 className="mt-2 text-6xl font-extrabold text-[var(--blue)]">{result.level.replace('_', '-')}</h1>
        <p className="mt-1 text-lg font-extrabold text-[var(--ink)]">{info.title}</p>
        <p className="mt-4 text-[var(--mute)] leading-relaxed max-w-md mx-auto">{info.can}</p>
        <p className="mt-4 text-sm font-bold text-[var(--mute)]">
          Skor {result.score} dari {result.total}
        </p>
      </section>

      <section className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-6 md:p-8">
        <h2 className="text-xl font-extrabold text-[var(--ink)]">Paket yang cocok</h2>
        {pkg ? (
          <div className="mt-3">
            <p className="text-lg font-extrabold text-[var(--blue)]">{pkg.package_name}</p>
            <p className="text-sm font-bold text-[var(--mute)]">{rupiah(pkg.price)}</p>
            <p className="mt-2 text-[var(--mute)] leading-relaxed">{pkg.reason}</p>
          </div>
        ) : (
          <p className="mt-3 text-[var(--mute)] leading-relaxed">
            Admin kami akan membantu memilihkan paket yang paling pas untuk levelmu.
          </p>
        )}
        <a
          href={buildOrderPath(result.attempt_id, pkg?.id ?? null)}
          className="mt-6 inline-flex items-center justify-center font-extrabold rounded-2xl py-3 px-6 bg-[var(--yel)] text-[var(--ink)] shadow-[0_5px_0_#B87A00] hover:-translate-y-0.5 hover:shadow-[0_7px_0_#B87A00] active:translate-y-1 active:shadow-none transition-all"
        >
          {pkg ? 'Pesan paket ini' : 'Hubungi admin untuk pesan'}
        </a>
      </section>

      {result.tutors.length > 0 && (
        <section className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-6 md:p-8">
          <h2 className="text-xl font-extrabold text-[var(--ink)]">Tutor yang bisa membantu</h2>
          <ul className="mt-4 grid gap-3">
            {result.tutors.map((tutor) => (
              <li key={tutor.id} className="flex items-center gap-3 rounded-2xl border-2 border-[var(--line)] bg-[var(--bg)] p-3">
                <span className="grid place-items-center w-11 h-11 rounded-full bg-[var(--blue)] text-white font-extrabold">
                  {tutor.full_name.substring(0, 2).toUpperCase()}
                </span>
                <div className="leading-tight">
                  <p className="font-extrabold text-[var(--ink)]">{tutor.full_name}</p>
                  {tutor.university && <p className="text-sm text-[var(--mute)]">{tutor.university}</p>}
                </div>
              </li>
            ))}
          </ul>
        </section>
      )}

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

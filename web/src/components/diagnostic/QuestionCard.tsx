import type { DiagnosticQuestion } from '../../types/diagnostic';

interface QuestionCardProps {
  question: DiagnosticQuestion;
  selected: number | undefined;
  /** Label kecil di atas soal (mis. nama subtes). */
  badge?: string;
  onSelect: (optionIndex: number) => void;
}

const LETTERS = ['A', 'B', 'C', 'D', 'E', 'F'];

export function QuestionCard({ question, selected, badge, onSelect }: QuestionCardProps) {
  return (
    <div className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-6 md:p-9">
      {badge && (
        <p className="mb-4 inline-block rounded-full bg-[var(--hov)] px-3 py-1 text-xs font-extrabold text-[var(--blue)]">{badge}</p>
      )}
      {question.passage && (
        <blockquote className="mb-6 whitespace-pre-line rounded-2xl border-2 border-[var(--line)] bg-[var(--bg)] p-4 md:p-5 text-[var(--ink)] leading-relaxed">
          {question.passage}
        </blockquote>
      )}

      <h2 className="text-xl md:text-2xl font-extrabold leading-snug text-[var(--ink)]">{question.stem}</h2>

      <div role="radiogroup" aria-label="Pilihan jawaban" className="mt-6 grid gap-3">
        {question.options.map((option, i) => {
          const isSelected = selected === i;
          return (
            <button
              key={i}
              type="button"
              role="radio"
              aria-checked={isSelected}
              onClick={() => onSelect(i)}
              className={`flex items-start gap-3 text-left rounded-2xl border-2 px-4 py-3 font-semibold transition-colors ${
                isSelected
                  ? 'border-[var(--blue)] bg-[var(--hov)] text-[var(--ink)]'
                  : 'border-[var(--line)] bg-[var(--bg)] text-[var(--ink)] hover:border-[var(--blue)]'
              }`}
            >
              <span
                className={`shrink-0 grid place-items-center w-7 h-7 rounded-full text-sm font-extrabold ${
                  isSelected ? 'bg-[var(--blue)] text-white' : 'bg-[var(--line)] text-[var(--mute)]'
                }`}
              >
                {LETTERS[i] ?? i + 1}
              </span>
              <span className="pt-0.5">{option}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

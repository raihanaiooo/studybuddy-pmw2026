interface ProgressBarProps {
  current: number; // 1-based
  total: number;
  answered: number;
}

export function ProgressBar({ current, total, answered }: ProgressBarProps) {
  const percent = total === 0 ? 0 : Math.round((answered / total) * 100);
  return (
    <div>
      <div className="flex items-center justify-between text-sm font-bold text-[var(--mute)] mb-2">
        <span>
          Soal {current} dari {total}
        </span>
        <span>{answered} terjawab</span>
      </div>
      <div
        className="h-3 rounded-full bg-[var(--line)] overflow-hidden"
        role="progressbar"
        aria-valuemin={0}
        aria-valuemax={total}
        aria-valuenow={answered}
        aria-label="Progres tes"
      >
        <div className="h-full bg-[var(--blue)] transition-all duration-300" style={{ width: `${percent}%` }} />
      </div>
    </div>
  );
}

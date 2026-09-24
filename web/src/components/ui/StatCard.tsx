interface StatCardProps {
  label: string;
  value: string | number;
  icon: string;
  color?: 'blue' | 'green' | 'yellow' | 'red' | 'teal';
  subtitle?: string;
  onClick?: () => void;
}

const colorMap = {
  blue: {
    bg: 'bg-primary-blue-subtle',
    text: 'text-primary-blue',
    icon: 'text-primary-blue',
  },
  green: {
    bg: 'bg-online-green-subtle',
    text: 'text-online-green',
    icon: 'text-online-green',
  },
  yellow: {
    bg: 'bg-primary-yellow-subtle',
    text: 'text-primary-yellow',
    icon: 'text-primary-yellow',
  },
  red: {
    bg: 'bg-primary-red-subtle',
    text: 'text-primary-red',
    icon: 'text-primary-red',
  },
  teal: {
    bg: 'bg-accent-teal-subtle',
    text: 'text-accent-teal',
    icon: 'text-accent-teal',
  },
};

export function StatCard({
  label,
  value,
  icon,
  color = 'blue',
  subtitle,
  onClick,
}: StatCardProps) {
  const c = colorMap[color];

  return (
    <div
      onClick={onClick}
      className={`
        bg-card rounded-2xl p-5 border border-border
        shadow-[var(--shadow-sm)]
        hover:shadow-[var(--shadow-md)]
        transition-all duration-200
        ${onClick ? 'cursor-pointer hover:-translate-y-0.5' : ''}
      `}
    >
      <div className="flex items-start justify-between gap-3 mb-3">
        <p className="text-[12.5px] font-nunito font-semibold text-text-secondary uppercase tracking-wide">
          {label}
        </p>
        <div
          className={`w-9 h-9 rounded-xl ${c.bg} flex items-center justify-center text-[16px] shrink-0`}
        >
          {icon}
        </div>
      </div>

      <p className="text-[26px] font-poppins font-bold text-text-primary leading-none mb-1.5">
        {value}
      </p>

      {subtitle && (
        <p className={`text-[12px] font-nunito font-medium ${c.text}`}>
          {subtitle}
        </p>
      )}
    </div>
  );
}
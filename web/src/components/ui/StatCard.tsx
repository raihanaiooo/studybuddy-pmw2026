import type { ReactNode } from 'react';

interface StatCardProps {
  label: string;
  value: string | number;
  icon: ReactNode;
  color?: 'blue' | 'green' | 'yellow' | 'red' | 'teal';
  subtitle?: string;
}

export function StatCard({ label, value, icon, color = 'blue', subtitle }: StatCardProps) {
  // Warna background icon (soft color)
  const iconBg = {
    blue: 'bg-[#DBEAFE] text-[#1E40AF]',
    green: 'bg-[#DCFCE7] text-[#166534]',
    yellow: 'bg-[#FEF3C7] text-[#92400E]',
    red: 'bg-[#FEE2E2] text-[#991B1B]',
    teal: 'bg-[#CCFBF1] text-[#0F766E]',
  }[color];

  return (
    <div className="card p-5">
      <p className="text-[var(--mute)] font-semibold text-sm">{label}</p>
      <div className="flex justify-between items-end mt-2">
        <div>
          <p className="text-3xl font-extrabold text-[var(--ink)]">{value}</p>
          {subtitle && <p className="text-xs text-[var(--mute)] mt-1">{subtitle}</p>}
        </div>
        <span className={`w-10 h-10 rounded-xl flex items-center justify-center ${iconBg}`}>
          {icon}
        </span>
      </div>
    </div>
  );
}
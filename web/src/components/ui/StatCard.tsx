interface StatCardProps {
  label: string;
  value: string | number;
  icon: string;
  color?: 'blue' | 'green' | 'yellow' | 'red' | 'teal';
  subtitle?: string;
}

const colorMap = {
  blue: 'bg-[#1A5EAA]/10 text-[#1A5EAA]',
  green: 'bg-[#00C853]/10 text-[#00C853]',
  yellow: 'bg-[#F4A200]/10 text-[#F4A200]',
  red: 'bg-[#E53935]/10 text-[#E53935]',
  teal: 'bg-[#00BFA5]/10 text-[#00BFA5]',
};

export function StatCard({
  label,
  value,
  icon,
  color = 'blue',
  subtitle,
}: StatCardProps) {
  return (
    <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB] hover:shadow-md transition-shadow">
      <div className="flex items-start justify-between gap-3">
        <div className="flex-1 min-w-0">
          <p className="text-xs text-[#6B7280] font-medium mb-1">{label}</p>
          <p className="text-2xl font-bold text-[#1A1F3C] truncate">{value}</p>
          {subtitle && (
            <p className="text-xs text-[#9CA3AF] mt-1">{subtitle}</p>
          )}
        </div>
        <div
          className={`w-12 h-12 rounded-xl flex items-center justify-center text-2xl shrink-0 ${colorMap[color]}`}
        >
          {icon}
        </div>
      </div>
    </div>
  );
}
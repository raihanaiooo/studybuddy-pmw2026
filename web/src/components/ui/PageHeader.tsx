export function PageHeader({ title, subtitle, action }: { title: string, subtitle?: string, action?: React.ReactNode }) {
  return (
    <div className="flex justify-between items-end mb-6">
      <div>
        <h1 className="text-2xl font-extrabold text-[var(--ink)]">{title}</h1>
        {subtitle && <p className="text-[var(--mute)] mt-1">{subtitle}</p>}
      </div>
      {action && <div>{action}</div>}
    </div>
  );
}
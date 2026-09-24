import type { TokenStatus } from '../../types/package';

interface Props {
  status: TokenStatus;
}

const config: Record<TokenStatus, { label: string; className: string }> = {
  active: {
    label: 'Aktif',
    className: 'bg-[#00C853]/15 text-[#00C853]',
  },
  used: {
    label: 'Terpakai',
    className: 'bg-[#00BFA5]/15 text-[#00BFA5]',
  },
  expired: {
    label: 'Kadaluarsa',
    className: 'bg-[#9CA3AF]/15 text-[#9CA3AF]',
  },
};

export function TokenStatusBadge({ status }: Props) {
  const c = config[status] ?? config.expired;
  return (
    <span
      className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold ${c.className}`}
    >
      {c.label}
    </span>
  );
}
import type { TokenWithRelations } from '../../types/package';
import { TokenStatusBadge } from './TokenStatusBadge';

interface Props {
  token: TokenWithRelations;
}

function formatDate(iso: string) {
  const d = new Date(iso);
  return d.toLocaleDateString('id-ID', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

function daysLeft(expiry: string): number {
  const diff = new Date(expiry).getTime() - Date.now();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}

export function TokenCard({ token }: Props) {
  const remaining = daysLeft(token.expiry_date);
  const isExpiringSoon = token.status === 'active' && remaining <= 7;

  return (
    <div className="bg-white rounded-2xl p-5 border border-[#E5E7EB] hover:shadow-md transition-shadow">
      <div className="flex flex-wrap items-start justify-between gap-3 mb-3">
        <div className="min-w-0 flex-1">
          <h3 className="font-bold text-[#1A1F3C] truncate">
            {token.package?.package_name ?? 'Paket'}
          </h3>
          <p className="text-xs text-[#6B7280] mt-0.5 truncate">
            {token.buddy?.full_name ?? '-'} · {token.buddy?.email ?? '-'}
          </p>
        </div>
        <TokenStatusBadge status={token.status} />
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 text-sm mb-3">
        <div>
          <p className="text-xs text-[#6B7280]">Sisa Sesi</p>
          <p className="font-bold text-[#1A5EAA]">
            {token.sessions_remaining}
          </p>
        </div>
        <div>
          <p className="text-xs text-[#6B7280]">Aktif</p>
          <p className="font-medium text-[#1A1F3C]">
            {formatDate(token.active_date)}
          </p>
        </div>
        <div>
          <p className="text-xs text-[#6B7280]">Kadaluarsa</p>
          <p
            className={`font-medium ${
              isExpiringSoon ? 'text-[#E53935]' : 'text-[#1A1F3C]'
            }`}
          >
            {formatDate(token.expiry_date)}
          </p>
        </div>
      </div>

      {token.status === 'active' && (
        <div className="pt-3 border-t border-[#E5E7EB]">
          <p
            className={`text-xs font-semibold ${
              isExpiringSoon ? 'text-[#E53935]' : 'text-[#6B7280]'
            }`}
          >
            {remaining > 0
              ? `${remaining} hari tersisa`
              : 'Kadaluarsa hari ini'}
          </p>
        </div>
      )}
    </div>
  );
}
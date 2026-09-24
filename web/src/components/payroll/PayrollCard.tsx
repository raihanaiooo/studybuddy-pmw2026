import { Link } from 'react-router-dom';
import type { PayrollWithRelations } from '../../types/payroll';
import { formatPeriod } from '../../types/payroll';
import { PayrollStatusBadge } from './PayrollStatusBadge';

interface Props {
  payroll: PayrollWithRelations;
}

function formatRupiah(n: number) {
  return `Rp${n.toLocaleString('id-ID')}`;
}

export function PayrollCard({ payroll }: Props) {
  return (
    <Link
      to={`/payroll/${payroll.id}`}
      className="block bg-white rounded-2xl p-5 border border-[#E5E7EB] hover:shadow-md hover:border-[#1A5EAA]/30 transition-all"
    >
      <div className="flex flex-wrap items-start justify-between gap-3 mb-3">
        <div className="min-w-0 flex-1">
          <h3 className="font-bold text-[#1A1F3C] truncate">
            {payroll.tutor?.full_name ?? 'Tutor'}
          </h3>
          <p className="text-xs text-[#6B7280] mt-0.5">
            Periode: {formatPeriod(payroll.period_month, payroll.period_year)}
          </p>
        </div>
        <PayrollStatusBadge status={payroll.status} />
      </div>

      <div className="grid grid-cols-2 gap-3 mb-3">
        <div>
          <p className="text-xs text-[#6B7280] mb-0.5">Sesi</p>
          <p className="text-sm font-semibold text-[#1A1F3C]">
            {payroll.total_sessions}
          </p>
        </div>
        <div>
          <p className="text-xs text-[#6B7280] mb-0.5">Bruto</p>
          <p className="text-sm font-medium text-[#1A1F3C]">
            {formatRupiah(payroll.total_gross)}
          </p>
        </div>
      </div>

      <div className="pt-3 border-t border-[#E5E7EB]">
        <div className="flex items-baseline justify-between">
          <span className="text-xs text-[#6B7280]">Komisi (70%)</span>
          <span className="text-lg font-bold text-[#1A5EAA]">
            {formatRupiah(payroll.total_commission)}
          </span>
        </div>
      </div>
    </Link>
  );
}
import { ClipboardCheck, Loader2, ShoppingCart, TrendingUp } from 'lucide-react';
import { StatCard } from '../ui/StatCard';
import { useUtbkStats } from '../../hooks/useUtbkStats';
import { BAND_INFO, SUBTEST_INFO } from '../../lib/diagnostic/utbk';
import { bandShares, conversionPercent } from '../../lib/diagnostic/stats';
import type { UtbkSubtest } from '../../types/diagnostic';

const SUBTEST_ORDER: UtbkSubtest[] = ['pu', 'pk', 'lbi'];

function formatDate(iso: string): string {
  return new Date(iso).toLocaleString('id-ID', { dateStyle: 'medium', timeStyle: 'short' });
}

/** Statistik try out UTBK untuk halaman admin /diagnostics. */
export function UtbkStatsSection() {
  const { stats, loading, error, reload } = useUtbkStats();

  return (
    <section aria-labelledby="stats-utbk" className="grid gap-6">
      <div className="flex items-center justify-between">
        <h2 id="stats-utbk" className="text-xl font-extrabold text-[var(--ink)]">UTBK</h2>
        <button type="button" onClick={reload} className="px-4 py-2 rounded-lg border border-[var(--line)] font-semibold text-sm text-[var(--ink)] hover:bg-[var(--hov)]">
          Muat ulang
        </button>
      </div>

      {loading && (
        <div className="flex items-center gap-2 text-[var(--mute)] font-semibold py-10">
          <Loader2 className="animate-spin" size={18} /> Memuat statistik...
        </div>
      )}

      {!loading && error && (
        <div role="alert" className="card p-5 text-red-700 font-semibold">
          Statistik UTBK tidak bisa dimuat: {error}
        </div>
      )}

      {!loading && !error && stats && (
        <div className="grid gap-6">
          <div className="grid gap-4 sm:grid-cols-3">
            <StatCard label="Total try out" value={stats.total_attempts} icon={<ClipboardCheck size={18} />} color="blue" />
            <StatCard label="Order dari try out" value={stats.orders_from_tests} icon={<ShoppingCart size={18} />} color="green" />
            <StatCard
              label="Konversi try out ke order"
              value={`${conversionPercent(stats.total_attempts, stats.orders_from_tests)}%`}
              icon={<TrendingUp size={18} />}
              color="yellow"
            />
          </div>

          <div className="card p-5">
            <h3 className="font-extrabold text-[var(--ink)] mb-4">Sebaran pita skor</h3>
            <ul className="grid gap-3">
              {bandShares(stats).map((share) => (
                <li key={share.band} className="grid grid-cols-[12rem_1fr_5rem] items-center gap-3 text-sm">
                  <span className="font-bold text-[var(--ink)]">{BAND_INFO[share.band].label}</span>
                  <span className="h-3 rounded-full bg-[var(--line)] overflow-hidden">
                    <span className="block h-full bg-[var(--blue)]" style={{ width: `${share.percent}%` }} />
                  </span>
                  <span className="text-right font-semibold text-[var(--mute)]">
                    {share.count} ({share.percent}%)
                  </span>
                </li>
              ))}
            </ul>
          </div>

          <div className="card p-5">
            <h3 className="font-extrabold text-[var(--ink)] mb-4">Rata-rata benar per subtes</h3>
            <ul className="grid gap-3">
              {SUBTEST_ORDER.map((key) => {
                const value = stats.avg_percent[key];
                return (
                  <li key={key} className="grid grid-cols-[12rem_1fr_4rem] items-center gap-3 text-sm">
                    <span className="font-bold text-[var(--ink)]">{SUBTEST_INFO[key].title}</span>
                    <span className="h-3 rounded-full bg-[var(--line)] overflow-hidden">
                      <span className="block h-full bg-[var(--blue)]" style={{ width: `${value ?? 0}%` }} />
                    </span>
                    <span className="text-right font-semibold text-[var(--mute)]">{value === null ? '-' : `${value}%`}</span>
                  </li>
                );
              })}
            </ul>
          </div>

          <div className="card p-5">
            <h3 className="font-extrabold text-[var(--ink)] mb-4">20 try out terbaru</h3>
            {stats.recent.length === 0 ? (
              <p className="text-[var(--mute)]">Belum ada yang mengerjakan try out.</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-left text-[var(--mute)]">
                      <th className="py-2 pr-4 font-semibold">Waktu</th>
                      <th className="py-2 pr-4 font-semibold">Pita</th>
                      <th className="py-2 pr-4 font-semibold">Skor</th>
                      <th className="py-2 font-semibold">Order</th>
                    </tr>
                  </thead>
                  <tbody>
                    {stats.recent.map((attempt) => (
                      <tr key={attempt.id} className="border-t border-[var(--line)]">
                        <td className="py-2 pr-4 text-[var(--ink)]">{formatDate(attempt.created_at)}</td>
                        <td className="py-2 pr-4 font-bold text-[var(--ink)]">{BAND_INFO[attempt.band]?.label ?? attempt.band}</td>
                        <td className="py-2 pr-4 text-[var(--ink)]">{attempt.score}</td>
                        <td className="py-2">
                          <span className={`px-2 py-0.5 rounded-full text-xs font-bold ${attempt.ordered ? 'bg-[#DCFCE7] text-[#166534]' : 'bg-[var(--line)] text-[var(--mute)]'}`}>
                            {attempt.ordered ? 'Sudah order' : 'Belum'}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      )}
    </section>
  );
}

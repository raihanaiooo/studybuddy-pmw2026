import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { AlertCircle, ArrowLeft, Loader2 } from 'lucide-react';
import { fetchOrderDetail, type OrderDetail } from '../../lib/api/orderAdmin';
import { formatRupiah, orderStatusLabel, paymentLabel, sessionStatusLabel } from '../../lib/orderView';

const KIND_LABEL: Record<string, string> = { extend: 'Extend', bonus_tutor: 'Bonus tutor', potongan: 'Potongan', refund: 'Refund' };

function dateLabel(d: string | null) {
  if (!d) return '-';
  return new Date(d.length === 10 ? d + 'T00:00:00' : d).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
}

function Info({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <p className="text-xs text-[var(--mute)] mb-0.5">{label}</p>
      <p className="text-sm font-semibold text-[var(--ink)]">{children}</p>
    </div>
  );
}

export function OrderDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [data, setData] = useState<OrderDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!id) return;
    fetchOrderDetail(id)
      .then((d) => (d ? setData(d) : setError('Order tidak ditemukan')))
      .catch((e) => setError(e instanceof Error ? e.message : 'Gagal memuat order'))
      .finally(() => setLoading(false));
  }, [id]);

  if (loading) {
    return (
      <div className="flex items-center gap-2 text-[var(--mute)] font-semibold py-10">
        <Loader2 className="animate-spin" size={18} /> Memuat order...
      </div>
    );
  }
  if (error || !data) {
    return (
      <div className="card p-8 text-center">
        <AlertCircle size={40} className="mx-auto text-[#991B1B] mb-3" />
        <p className="text-[#991B1B] mb-4">{error ?? 'Order tidak ditemukan'}</p>
        <Link to="/order" className="btn btn-p inline-flex"><ArrowLeft size={16} /> Kembali</Link>
      </div>
    );
  }

  const { order: o, summary: s, sessions, adjustments, payments } = data;
  const statusCls = o.status === 'done' ? 'b-done' : o.status === 'batal' ? 'b-no' : 'b-pending';

  return (
    <div className="space-y-6">
      <div>
        <Link to="/order" className="text-sm text-[var(--blue)] hover:underline font-semibold inline-flex items-center gap-1 mb-3">
          <ArrowLeft size={16} /> Kembali ke daftar Order
        </Link>
        <div className="flex flex-wrap items-center gap-2">
          <h1 className="text-2xl font-extrabold text-[var(--ink)]">{o.form_no}</h1>
          <span className={`badge ${statusCls}`}><i />{orderStatusLabel(o.status)}</span>
          {s?.is_expired && <span className="badge b-no"><i />Hangus</span>}
        </div>
        <p className="text-[var(--mute)]">{o.buddy_name}</p>
      </div>

      <div className="card p-5 grid grid-cols-2 lg:grid-cols-4 gap-4">
        <Info label="Layanan">{o.service_name}</Info>
        <Info label="Kategori">{o.service_category ?? '-'}</Info>
        <Info label="Mapel">{o.subject ?? '-'}</Info>
        <Info label="Jenis">{o.kind === 'paket' ? 'Paket' : 'Lepas'}</Info>
        <Info label="Tanggal order">{dateLabel(o.ordered_at)}</Info>
        <Info label="Sesi selesai">{s?.sessions_done ?? 0} dari {o.sessions_total}</Info>
        <Info label="Berlaku sampai">{dateLabel(o.valid_until)}</Info>
        <Info label="Reschedule">{s?.reschedule_used ?? 0} dari {o.reschedule_quota}x</Info>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {[
          { label: 'Pendapatan', value: formatRupiah(s?.revenue_total) },
          { label: 'Bagian tutor', value: formatRupiah(s?.recipient_share_total) },
          { label: Number(s?.other_income_total) > 0 ? `Bagian perusahaan (termasuk lain-lain ${formatRupiah(s?.other_income_total)})` : 'Bagian perusahaan', value: formatRupiah(s?.company_share_total) },
          { label: `Dibayar (${paymentLabel(s?.payment_status)})`, value: formatRupiah(s?.paid_total) },
        ].map((c) => (
          <div key={c.label} className="card p-4">
            <p className="text-xs text-[var(--mute)]">{c.label}</p>
            <p className="text-lg font-extrabold text-[var(--ink)] mt-0.5">{c.value}</p>
          </div>
        ))}
      </div>

      <section className="space-y-2">
        <h2 className="font-bold text-[var(--ink)]">Sesi per tutor</h2>
        <div className="card overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs text-[var(--mute)] border-b border-[var(--line)]">
                <th className="p-3 font-semibold">Penerima</th>
                <th className="p-3 font-semibold">Sesi</th>
                <th className="p-3 font-semibold">Tanggal</th>
                <th className="p-3 font-semibold text-right">Tarif</th>
                <th className="p-3 font-semibold text-right">Jumlah</th>
                <th className="p-3 font-semibold text-right">Bagian tutor ({sessions.find((x) => x.recipient !== 'kas')?.tutor_pct ?? 70}%)</th>
                <th className="p-3 font-semibold">Status</th>
              </tr>
            </thead>
            <tbody>
              {sessions.length === 0 && (
                <tr><td colSpan={7} className="p-6 text-center text-[var(--mute)]">Belum ada sesi.</td></tr>
              )}
              {sessions.map((x) => (
                <tr key={x.id} className="border-b border-[var(--line)] last:border-0">
                  <td className="p-3 font-semibold">
                    {x.recipient === 'kas' ? (
                      <span title="Sesi hangus: tidak dibayar ke tutor, masuk pendapatan lain-lain">Sesi hangus (kas)</span>
                    ) : (
                      <Link to={`/tutors/${x.tutor_id}`} className="text-[var(--blue)] hover:underline">{x.tutors?.full_name ?? 'Tutor'}</Link>
                    )}
                  </td>
                  <td className="p-3">{x.sessions_count}{x.duration_minutes ? ` × ${x.duration_minutes} mnt` : ''}</td>
                  <td className="p-3 text-[var(--mute)]">{x.session_date ? dateLabel(x.session_date) : x.date_note ?? '-'}</td>
                  <td className="p-3 text-right whitespace-nowrap">{formatRupiah(x.rate)}</td>
                  <td className="p-3 text-right font-semibold whitespace-nowrap">{formatRupiah(x.amount)}</td>
                  <td className="p-3 text-right whitespace-nowrap">{formatRupiah((Number(x.amount) * Number(x.tutor_pct)) / 100)}</td>
                  <td className="p-3"><span className={`badge ${x.status === 'selesai' ? 'b-done' : x.status === 'batal' ? 'b-no' : 'b-pending'}`}><i />{sessionStatusLabel(x.status)}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <div className="grid lg:grid-cols-2 gap-6">
        <section className="space-y-2">
          <h2 className="font-bold text-[var(--ink)]">Penyesuaian</h2>
          <div className="card divide-y divide-[var(--line)]">
            {adjustments.length === 0 && <p className="p-5 text-sm text-[var(--mute)]">Tidak ada extend, bonus, potongan, atau refund.</p>}
            {adjustments.map((a) => (
              <div key={a.id} className="p-4 flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <p className="font-semibold text-[var(--ink)]">{KIND_LABEL[a.kind] ?? a.kind}{a.tutors?.full_name ? ` · ${a.tutors.full_name}` : ''}</p>
                  {a.note && <p className="text-xs text-[var(--mute)] mt-0.5">{a.note}</p>}
                </div>
                <p className="font-bold whitespace-nowrap">{formatRupiah(a.amount)}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="space-y-2">
          <h2 className="font-bold text-[var(--ink)]">Pembayaran pelanggan</h2>
          <div className="card divide-y divide-[var(--line)]">
            {payments.length === 0 && <p className="p-5 text-sm text-[var(--mute)]">Belum ada pembayaran tercatat.</p>}
            {payments.map((p) => (
              <div key={p.id} className="p-4 flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <p className="font-semibold text-[var(--ink)]">{dateLabel(p.paid_at)} · {p.method}</p>
                  {p.note && <p className="text-xs text-[var(--mute)] mt-0.5">{p.note}</p>}
                </div>
                <p className="font-bold whitespace-nowrap">{formatRupiah(p.amount)}</p>
              </div>
            ))}
          </div>
        </section>
      </div>

      {o.notes && (
        <div className="bg-[#FEF3C7] border border-[#FCD34D] rounded-xl p-4 text-sm text-[#92400E]"><strong>Catatan:</strong> {o.notes}</div>
      )}
    </div>
  );
}

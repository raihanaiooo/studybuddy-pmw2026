-- Migration 012: sesi "KAS INTERNAL" = sesi hangus. Tutor tidak menerima bagian apa pun;
-- seluruh nilainya menjadi pendapatan lain-lain (milik tim inti). Dijalankan setelah 009. Aman dijalankan ulang.
--
-- 1. Baris sesi dengan penerima 'kas' selalu bernilai tutor_pct = 0 (diisi otomatis, tidak bisa diubah).
-- 2. Baris kas yang sudah ada (mis. FO033 dari impor, tadinya 70) dikoreksi ke 0.
-- 3. order_summary mendapat kolom other_income_total (jumlah sesi kas); recipient_share_total tidak lagi memuat kas.

create or replace function public.order_sessions_before_write() returns trigger
language plpgsql set search_path = public as $$
begin
  if new.rate is null then
    select price_per_session into new.rate from public.orders where id = new.order_id;
  end if;
  if new.recipient = 'kas' then
    new.tutor_pct := 0;
  elsif new.tutor_pct is null then
    new.tutor_pct := public.setting_num('tutor_pct', 70);
  end if;
  new.amount := round(new.rate * new.sessions_count, 2);
  return new;
end $$;

-- koreksi baris kas yang sudah ada (memicu trigger di atas yang memaksa 0)
update public.order_sessions set tutor_pct = 0 where recipient = 'kas' and tutor_pct <> 0;

-- kolom baru ditaruh paling akhir supaya "create or replace view" boleh
create or replace view public.order_summary with (security_invoker = true) as
select
  o.id as order_id,
  o.form_no,
  o.sessions_total,
  coalesce(s.done, 0)::int as sessions_done,
  greatest(o.sessions_total - coalesce(s.done, 0), 0)::int as sessions_left,
  (coalesce(s.revenue, 0) + coalesce(a.extend_total, 0))::numeric(14,2) as revenue_total,
  (coalesce(s.recipient_share, 0) + coalesce(a.extend_tutor_share, 0))::numeric(14,2) as recipient_share_total,
  (coalesce(s.revenue, 0) + coalesce(a.extend_total, 0) - coalesce(s.recipient_share, 0) - coalesce(a.extend_tutor_share, 0))::numeric(14,2) as company_share_total,
  coalesce(p.paid, 0)::numeric(14,2) as paid_total,
  coalesce(a.refund_total, 0)::numeric(14,2) as refund_total,
  case
    when coalesce(p.paid, 0) = 0 then 'belum'
    when coalesce(p.paid, 0) >= o.total_price + coalesce(a.extend_total, 0) then 'lunas'
    else 'sebagian'
  end as payment_status,
  (o.status = 'progress' and o.valid_until is not null and o.valid_until < (now() at time zone 'Asia/Jakarta')::date
     and o.sessions_total - coalesce(s.done, 0) > 0) as is_expired,
  coalesce(s.resched, 0)::int as reschedule_used,
  (coalesce(s.resched, 0) > o.reschedule_quota) as reschedule_over,
  coalesce(s.other_income, 0)::numeric(14,2) as other_income_total
from public.orders o
left join lateral (
  select sum(amount) as revenue,
         sum(round(amount * tutor_pct / 100, 2)) as recipient_share,
         sum(amount) filter (where recipient = 'kas') as other_income,
         sum(sessions_count) filter (where status = 'selesai') as done,
         sum(reschedule_count) as resched
    from public.order_sessions where order_id = o.id and deleted_at is null and status <> 'batal'
) s on true
left join lateral (
  select sum(amount) filter (where kind = 'extend') as extend_total,
         sum(round(amount * coalesce(tutor_pct, 70) / 100, 2)) filter (where kind = 'extend' and tutor_id is not null) as extend_tutor_share,
         sum(amount) filter (where kind = 'refund') as refund_total
    from public.order_adjustments where order_id = o.id and deleted_at is null
) a on true
left join lateral (
  select sum(amount) as paid from public.order_payments where order_id = o.id and deleted_at is null
) p on true
where o.deleted_at is null;
revoke all on public.order_summary from anon, authenticated;
grant select on public.order_summary to authenticated;

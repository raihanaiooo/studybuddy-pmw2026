-- Study Buddy — Migration 009: order resmi, sesi per tutor, penyesuaian, pembayaran, komplain, pengaturan, audit
-- Rancangan: docs/superpowers/specs/2026-11-24-order-sesi-gaji-design.md (bagian 5 dan 6).
-- Semua tabel baru hanya bisa diakses admin (is_admin()). Penghapusan lewat kolom deleted_at.
-- Aman dijalankan berulang. Berlaku setelah migration 008.

-- ============================================================
-- 1. Katalog layanan: kolom tambahan pada tabel packages yang sudah ada
-- ============================================================
alter table public.packages add column if not exists category text;
alter table public.packages add column if not exists kind text not null default 'paket';
alter table public.packages add column if not exists default_duration_minutes int;
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'packages_kind_check') then
    alter table public.packages add constraint packages_kind_check check (kind in ('paket', 'lepas'));
  end if;
end $$;

-- ============================================================
-- 2. Tabel
-- ============================================================

-- Order resmi = satu Formulir Pesanan (nomor FO).
create table if not exists public.orders (
  id                uuid primary key default gen_random_uuid(),
  form_no           text not null unique,
  lead_id           uuid references public.manual_orders(id) on delete set null,
  buddy_name        text not null,
  age               int,
  grade             text,
  school            text,
  whatsapp          text,
  service_category  text,
  service_name      text not null,
  subject           text,
  kind              text not null default 'paket' check (kind in ('paket', 'lepas')),
  package_id        uuid references public.packages(id) on delete set null,
  sessions_total    int not null check (sessions_total >= 1),
  price_per_session numeric(14,2) not null default 0 check (price_per_session >= 0),
  total_price       numeric(14,2) not null check (total_price >= 0),
  reschedule_quota  int not null check (reschedule_quota >= 0),
  valid_until       date,
  status            text not null default 'progress' check (status in ('progress', 'done', 'batal')),
  ordered_at        date not null default ((now() at time zone 'Asia/Jakarta')::date),
  completed_at      timestamptz,
  notes             text,
  created_by        uuid default auth.uid(),
  created_at        timestamptz not null default now(),
  deleted_at        timestamptz
);
create index if not exists orders_status_idx on public.orders (status) where deleted_at is null;
create index if not exists orders_ordered_at_idx on public.orders (ordered_at);

-- Satu baris = satu kelompok sesi oleh satu penerima (sesuai baris spreadsheet).
create table if not exists public.order_sessions (
  id               uuid primary key default gen_random_uuid(),
  order_id         uuid not null references public.orders(id),
  recipient        text not null default 'tutor' check (recipient in ('tutor', 'kas')),
  tutor_id         uuid references public.tutors(id),
  sessions_count   int not null default 1 check (sessions_count >= 1),
  session_date     date,
  start_time       time,
  tz               text check (tz in ('WIB', 'WITA', 'WIT')),
  date_note        text,
  duration_minutes int check (duration_minutes > 0),
  rate             numeric(14,2) not null check (rate >= 0),
  amount           numeric(14,2) not null,
  tutor_pct        numeric(5,2) not null check (tutor_pct between 0 and 100),
  status           text not null default 'terjadwal' check (status in ('terjadwal', 'selesai', 'batal')),
  reschedule_count int not null default 0 check (reschedule_count >= 0),
  reschedule_note  text,
  payroll_id       uuid,
  created_at       timestamptz not null default now(),
  deleted_at       timestamptz,
  constraint order_sessions_tutor_wajib check (recipient = 'kas' or tutor_id is not null)
);
create index if not exists order_sessions_order_idx on public.order_sessions (order_id);
create index if not exists order_sessions_tutor_idx on public.order_sessions (tutor_id);
create index if not exists order_sessions_payroll_idx on public.order_sessions (payroll_id);

-- extend (tambah pendapatan, dibagi 70/30), bonus_tutor (100% tutor), potongan (kurangi hak tutor), refund (informasi).
create table if not exists public.order_adjustments (
  id         uuid primary key default gen_random_uuid(),
  order_id   uuid not null references public.orders(id),
  session_id uuid references public.order_sessions(id),
  tutor_id   uuid references public.tutors(id),
  kind       text not null check (kind in ('extend', 'bonus_tutor', 'potongan', 'refund')),
  amount     numeric(14,2) not null check (amount >= 0),
  tutor_pct  numeric(5,2) check (tutor_pct between 0 and 100),
  note       text,
  payroll_id uuid,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index if not exists order_adjustments_order_idx on public.order_adjustments (order_id);
create index if not exists order_adjustments_payroll_idx on public.order_adjustments (payroll_id);

-- Pembayaran dari pelanggan (boleh dicicil).
create table if not exists public.order_payments (
  id         uuid primary key default gen_random_uuid(),
  order_id   uuid not null references public.orders(id),
  amount     numeric(14,2) not null check (amount > 0),
  paid_at    date not null default ((now() at time zone 'Asia/Jakarta')::date),
  method     text not null default 'transfer' check (method in ('transfer', 'qris', 'tunai', 'lainnya')),
  note       text,
  created_by uuid default auth.uid(),
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index if not exists order_payments_order_idx on public.order_payments (order_id);

create table if not exists public.order_complaints (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid not null references public.orders(id),
  tutor_id      uuid references public.tutors(id),
  category      text not null,
  description   text not null,
  status        text not null default 'baru' check (status in ('baru', 'diproses', 'selesai', 'ditolak')),
  handling_note text,
  handled_by    uuid,
  handled_at    timestamptz,
  created_at    timestamptz not null default now(),
  deleted_at    timestamptz
);
create index if not exists order_complaints_order_idx on public.order_complaints (order_id);

-- Pengaturan yang bisa diubah admin tanpa developer.
create table if not exists public.app_settings (
  key        text primary key,
  value      jsonb not null,
  updated_by uuid,
  updated_at timestamptz not null default now()
);
insert into public.app_settings (key, value) values
  ('tutor_pct', '70'),
  ('reschedule_hours', '6'),
  ('late_tolerance_minutes', '15'),
  ('payout_day', 'null'),
  ('wa_templates', '{}'),
  ('business', '{}')
on conflict (key) do nothing;

-- Membaca pengaturan angka; nilai bawaan bila kunci tidak ada atau bukan angka.
-- Bukan security definer: pengguna non-admin tidak membaca tabel, jadi memperoleh nilai bawaan.
create or replace function public.setting_num(p_key text, p_default numeric) returns numeric
language sql stable
set search_path = public
as $$
  select coalesce((select case when jsonb_typeof(value) = 'number' then (value #>> '{}')::numeric end
                     from public.app_settings where key = p_key), p_default)
$$;

-- ============================================================
-- 3. Hak akses: hanya admin (RLS), tanpa DELETE, tanpa anon
-- ============================================================
do $$
declare t text;
begin
  foreach t in array array['orders', 'order_sessions', 'order_adjustments', 'order_payments', 'order_complaints', 'app_settings'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant select, insert, update on public.%I to authenticated', t);
    execute format('drop policy if exists %I on public.%I', t || '_admin', t);
    execute format('create policy %I on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())', t || '_admin', t);
  end loop;
end $$;
revoke execute on function public.setting_num(text, numeric) from public, anon;

-- ============================================================
-- 4. Aturan order
-- ============================================================

-- Nomor Formulir berikutnya: FO + angka terbesar + 1 (minimal 3 digit). Baris terhapus tetap dihitung.
create or replace function public.next_form_no() returns text
language sql stable
set search_path = public
as $$
  select 'FO' || lpad((coalesce(max(substring(form_no from '^FO([0-9]+)$')::int), 0) + 1)::text, 3, '0')
    from public.orders
$$;
revoke execute on function public.next_form_no() from public, anon;

-- Order: isi otomatis nomor FO, jatuh tempo, kuota reschedule, dan total harga bila kosong.
create or replace function public.orders_before_insert() returns trigger
language plpgsql set search_path = public as $$
declare v_pkg record;
begin
  if new.form_no is null or btrim(new.form_no) = '' then
    perform pg_advisory_xact_lock(hashtext('orders_form_no'));
    new.form_no := public.next_form_no();
  end if;
  if new.package_id is not null then
    select validity_days, reschedule_quota into v_pkg from public.packages where id = new.package_id;
    if found then
      if new.valid_until is null then new.valid_until := new.ordered_at + v_pkg.validity_days; end if;
      if new.reschedule_quota is null then new.reschedule_quota := v_pkg.reschedule_quota; end if;
    end if;
  end if;
  if new.reschedule_quota is null then new.reschedule_quota := 0; end if;
  if new.total_price is null then new.total_price := round(new.price_per_session * new.sessions_total, 2); end if;
  return new;
end $$;
drop trigger if exists trg_orders_before_insert on public.orders;
create trigger trg_orders_before_insert before insert on public.orders
  for each row execute function public.orders_before_insert();

-- Sesi: tarif dan persen tutor disalin saat dibuat; pendapatan = tarif x jumlah sesi, 2 desimal.
create or replace function public.order_sessions_before_write() returns trigger
language plpgsql set search_path = public as $$
begin
  if new.rate is null then
    select price_per_session into new.rate from public.orders where id = new.order_id;
  end if;
  if new.tutor_pct is null then new.tutor_pct := public.setting_num('tutor_pct', 70); end if;
  new.amount := round(new.rate * new.sessions_count, 2);
  return new;
end $$;
drop trigger if exists trg_order_sessions_before_write on public.order_sessions;
create trigger trg_order_sessions_before_write before insert or update on public.order_sessions
  for each row execute function public.order_sessions_before_write();

-- Penyesuaian: persen tutor disalin dari pengaturan saat dibuat, agar angka lama tidak berubah bila pengaturan diubah.
create or replace function public.order_adjustments_before_insert() returns trigger
language plpgsql set search_path = public as $$
begin
  if new.tutor_pct is null then new.tutor_pct := public.setting_num('tutor_pct', 70); end if;
  return new;
end $$;
drop trigger if exists trg_order_adjustments_before_insert on public.order_adjustments;
create trigger trg_order_adjustments_before_insert before insert on public.order_adjustments
  for each row execute function public.order_adjustments_before_insert();

-- Order selesai otomatis bila jumlah sesi selesai (tak terhapus) mencapai target; kembali berjalan bila turun.
create or replace function public.refresh_order_status(p_order uuid) returns void
language plpgsql set search_path = public as $$
declare v_done int;
begin
  select coalesce(sum(sessions_count), 0) into v_done
    from public.order_sessions where order_id = p_order and status = 'selesai' and deleted_at is null;
  update public.orders set status = 'done', completed_at = now()
   where id = p_order and status = 'progress' and v_done >= sessions_total;
  update public.orders set status = 'progress', completed_at = null
   where id = p_order and status = 'done' and v_done < sessions_total;
end $$;
revoke execute on function public.refresh_order_status(uuid) from public, anon;

create or replace function public.order_sessions_after_write() returns trigger
language plpgsql set search_path = public as $$
begin
  if tg_op in ('UPDATE', 'DELETE') then perform public.refresh_order_status(old.order_id); end if;
  if tg_op in ('INSERT', 'UPDATE') and (tg_op = 'INSERT' or new.order_id is distinct from old.order_id) then
    perform public.refresh_order_status(new.order_id);
  end if;
  return null;
end $$;
drop trigger if exists trg_order_sessions_after_write on public.order_sessions;
create trigger trg_order_sessions_after_write after insert or update or delete on public.order_sessions
  for each row execute function public.order_sessions_after_write();

create or replace function public.orders_after_total_change() returns trigger
language plpgsql set search_path = public as $$
begin perform public.refresh_order_status(new.id); return null; end $$;
drop trigger if exists trg_orders_after_total_change on public.orders;
create trigger trg_orders_after_total_change after update of sessions_total on public.orders
  for each row execute function public.orders_after_total_change();

-- Ringkasan per order. Bagi hasil per baris sesi: penerima (tutor atau kas) 70%, tim inti 30% (persen disalin per baris).
-- Penyesuaian extend menambah pendapatan; bagiannya mengikuti persen tutor saat ini bila ada tutornya, selain itu seluruhnya tim inti.
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
  (coalesce(s.resched, 0) > o.reschedule_quota) as reschedule_over
from public.orders o
left join lateral (
  select sum(amount) as revenue,
         sum(round(amount * tutor_pct / 100, 2)) as recipient_share,
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

-- ============================================================
-- 5. Log aktivitas (audit). Ditulis hanya oleh trigger; admin hanya membaca.
-- ============================================================
create table if not exists public.audit_log (
  id         bigint generated always as identity primary key,
  table_name text not null,
  row_id     text,
  action     text not null check (action in ('insert', 'update', 'delete')),
  old_row    jsonb,
  new_row    jsonb,
  actor      uuid,
  at         timestamptz not null default now()
);
create index if not exists audit_log_table_idx on public.audit_log (table_name, at desc);
create index if not exists audit_log_row_idx on public.audit_log (row_id);
alter table public.audit_log enable row level security;
revoke all on public.audit_log from anon, authenticated;
grant select on public.audit_log to authenticated;
drop policy if exists audit_log_admin_read on public.audit_log;
create policy audit_log_admin_read on public.audit_log for select to authenticated using (public.is_admin());

-- Menulis satu baris per perubahan. Pembaruan yang hanya mengisi deleted_at dicatat sebagai 'delete'; pembaruan tanpa perubahan diabaikan.
create or replace function public.audit_row() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_old jsonb; v_new jsonb; v_id text; v_action text;
begin
  v_old := case when tg_op in ('UPDATE', 'DELETE') then to_jsonb(old) end;
  v_new := case when tg_op in ('INSERT', 'UPDATE') then to_jsonb(new) end;
  if tg_op = 'UPDATE' and v_old = v_new then return null; end if;
  -- status online dan terakhir dilihat berubah sangat sering (aplikasi mobile); tidak dicatat.
  if tg_op = 'UPDATE' and tg_table_name = 'tutors'
     and (v_old - array['is_online', 'last_seen']) = (v_new - array['is_online', 'last_seen']) then return null; end if;
  v_id := coalesce(v_new ->> 'id', v_old ->> 'id', v_new ->> 'key', v_old ->> 'key');
  v_action := lower(tg_op);
  if tg_op = 'UPDATE' and v_old ->> 'deleted_at' is null and v_new ->> 'deleted_at' is not null then v_action := 'delete'; end if;
  insert into public.audit_log (table_name, row_id, action, old_row, new_row, actor)
  values (tg_table_name, v_id, v_action, v_old, v_new, auth.uid());
  return null;
end $$;
revoke execute on function public.audit_row() from public, anon, authenticated;

-- Memasang audit pada tabel yang ada (payroll_transfers dipasang oleh migration 011).
do $$
declare t text;
begin
  foreach t in array array['orders', 'order_sessions', 'order_adjustments', 'order_payments', 'order_complaints',
                           'app_settings', 'payroll_records', 'tutors', 'tutor_applications'] loop
    if to_regclass('public.' || t) is not null then
      execute format('drop trigger if exists trg_audit on public.%I', t);
      execute format('create trigger trg_audit after insert or update or delete on public.%I for each row execute function public.audit_row()', t);
    end if;
  end loop;
end $$;

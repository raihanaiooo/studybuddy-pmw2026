-- Study Buddy — Migration 011: payroll bulanan dari sesi order, transfer, dan penguncian
-- Sumber hitung berpindah dari bookings (mobile) ke order_sessions. Berlaku setelah migration 009.
-- generate_payroll(bulan, tahun): satu transaksi, hanya admin, aman dipanggil berulang.
-- Arti kolom (sama dengan yang dipakai halaman payroll lama): total_gross = pendapatan sesi (100%),
-- total_commission = bagian tutor (70%), total_due = total_commission + bonus - potongan.
-- Aman dijalankan berulang.

-- ============================================================
-- 1. payroll_records: kolom tambahan
-- ============================================================
alter table public.payroll_records add column if not exists total_bonus       numeric(14,2) not null default 0;
alter table public.payroll_records add column if not exists total_deductions  numeric(14,2) not null default 0;
alter table public.payroll_records add column if not exists total_due         numeric(14,2) not null default 0;
alter table public.payroll_records add column if not exists total_transferred numeric(14,2) not null default 0;
-- Asal baris: baris yang sudah ada sebelum migration ini (alur bookings mobile) bernilai 'legacy' dan tidak pernah
-- disentuh generate_payroll. Baris dari generate_payroll bernilai 'order'.
alter table public.payroll_records add column if not exists source text not null default 'legacy';
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'payroll_records_source_check') then
    alter table public.payroll_records add constraint payroll_records_source_check check (source in ('legacy', 'order'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'order_sessions_payroll_fk') then
    alter table public.order_sessions add constraint order_sessions_payroll_fk
      foreign key (payroll_id) references public.payroll_records(id) on delete set null;
  end if;
  if not exists (select 1 from pg_constraint where conname = 'order_adjustments_payroll_fk') then
    alter table public.order_adjustments add constraint order_adjustments_payroll_fk
      foreign key (payroll_id) references public.payroll_records(id) on delete set null;
  end if;
end $$;

-- ============================================================
-- 2. payroll_transfers
-- ============================================================
create table if not exists public.payroll_transfers (
  id             uuid primary key default gen_random_uuid(),
  payroll_id     uuid not null references public.payroll_records(id),
  amount         numeric(14,2) not null check (amount > 0),
  transferred_at date not null default ((now() at time zone 'Asia/Jakarta')::date),
  note           text,
  created_by     uuid default auth.uid(),
  created_at     timestamptz not null default now(),
  deleted_at     timestamptz
);
create index if not exists payroll_transfers_payroll_idx on public.payroll_transfers (payroll_id);

alter table public.payroll_transfers enable row level security;
revoke all on public.payroll_transfers from anon, authenticated;
grant select, insert, update on public.payroll_transfers to authenticated;
drop policy if exists payroll_transfers_admin on public.payroll_transfers;
create policy payroll_transfers_admin on public.payroll_transfers for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop trigger if exists trg_audit on public.payroll_transfers;
create trigger trg_audit after insert or update or delete on public.payroll_transfers
  for each row execute function public.audit_row();

-- Payroll terkunci bila: sudah ada transfer yang berlaku, sudah berstatus paid, atau berasal dari alur lama (legacy).
create or replace function public.payroll_is_locked(p_payroll uuid) returns boolean
language sql stable
set search_path = public
as $$
  select exists (select 1 from public.payroll_transfers where payroll_id = p_payroll and deleted_at is null)
      or coalesce((select status = 'paid' or source <> 'order' from public.payroll_records where id = p_payroll), false)
$$;
revoke execute on function public.payroll_is_locked(uuid) from public, anon;

-- Transfer tidak boleh melebihi hak tutor.
create or replace function public.payroll_transfers_check() returns trigger
language plpgsql set search_path = public as $$
declare v_due numeric; v_other numeric;
begin
  if new.deleted_at is not null then return new; end if;
  select total_due into v_due from public.payroll_records where id = new.payroll_id for update;
  select coalesce(sum(amount), 0) into v_other from public.payroll_transfers
   where payroll_id = new.payroll_id and deleted_at is null and id <> new.id;
  if v_other + new.amount > v_due then raise exception 'transfer_melebihi_hak'; end if;
  return new;
end $$;
drop trigger if exists trg_payroll_transfers_check on public.payroll_transfers;
create trigger trg_payroll_transfers_check before insert or update on public.payroll_transfers
  for each row execute function public.payroll_transfers_check();

-- Jumlah transfer dan status payroll mengikuti transfer yang berlaku.
create or replace function public.payroll_transfers_sync() returns trigger
language plpgsql set search_path = public as $$
declare v_id uuid;
begin
  foreach v_id in array array(select distinct x from unnest(array[case when tg_op <> 'INSERT' then old.payroll_id end,
                                                                   case when tg_op <> 'DELETE' then new.payroll_id end]) x where x is not null) loop
    update public.payroll_records p
       set total_transferred = t.s,
           status  = case when p.total_due > 0 and t.s >= p.total_due then 'paid' else 'pending' end,
           paid_at = case when p.total_due > 0 and t.s >= p.total_due then coalesce(p.paid_at, now()) end,
           paid_by = case when p.total_due > 0 and t.s >= p.total_due then coalesce(p.paid_by, auth.uid()) end
      from (select coalesce(sum(amount), 0) as s from public.payroll_transfers where payroll_id = v_id and deleted_at is null) t
     where p.id = v_id;
  end loop;
  return null;
end $$;
drop trigger if exists trg_payroll_transfers_sync on public.payroll_transfers;
create trigger trg_payroll_transfers_sync after insert or update or delete on public.payroll_transfers
  for each row execute function public.payroll_transfers_sync();

-- ============================================================
-- 3. Penjaga: yang sudah terkunci tidak boleh diubah angkanya
-- ============================================================
create or replace function public.order_sessions_lock_guard() returns trigger
language plpgsql set search_path = public as $$
begin
  if old.payroll_id is not null and public.payroll_is_locked(old.payroll_id)
     and (to_jsonb(new) - array['session_date', 'start_time', 'tz', 'date_note', 'duration_minutes', 'reschedule_count', 'reschedule_note'])
         is distinct from
         (to_jsonb(old) - array['session_date', 'start_time', 'tz', 'date_note', 'duration_minutes', 'reschedule_count', 'reschedule_note']) then
    raise exception 'payroll_terkunci';
  end if;
  return new;
end $$;
drop trigger if exists trg_order_sessions_lock on public.order_sessions;
create trigger trg_order_sessions_lock before update on public.order_sessions
  for each row execute function public.order_sessions_lock_guard();

create or replace function public.order_adjustments_lock_guard() returns trigger
language plpgsql set search_path = public as $$
begin
  if old.payroll_id is not null and public.payroll_is_locked(old.payroll_id)
     and (to_jsonb(new) - 'note') is distinct from (to_jsonb(old) - 'note') then
    raise exception 'payroll_terkunci';
  end if;
  return new;
end $$;
drop trigger if exists trg_order_adjustments_lock on public.order_adjustments;
create trigger trg_order_adjustments_lock before update on public.order_adjustments
  for each row execute function public.order_adjustments_lock_guard();

-- Payroll hasil generate yang sudah terkunci tidak boleh diubah langsung (angka dan status berubah hanya lewat
-- transfer; pembaruan oleh trigger sinkron datang dari kedalaman trigger > 1 dan lolos). Catatan boleh diubah.
create or replace function public.payroll_records_lock_guard() returns trigger
language plpgsql set search_path = public as $$
begin
  if old.source = 'order' and pg_trigger_depth() = 1 and public.payroll_is_locked(old.id)
     and (to_jsonb(new) - array['notes']) is distinct from (to_jsonb(old) - array['notes']) then
    raise exception 'payroll_terkunci';
  end if;
  return new;
end $$;
drop trigger if exists trg_payroll_records_lock on public.payroll_records;
create trigger trg_payroll_records_lock before update on public.payroll_records
  for each row execute function public.payroll_records_lock_guard();

-- ============================================================
-- 4. generate_payroll
-- ============================================================
-- Sesi yang berhak dibayar: penerima tutor, selesai, tak terhapus, ordernya tak terhapus dan siap dibayar
-- (layanan lepas begitu sesinya selesai; paket setelah ordernya done), dengan tanggal jatuh tempo
-- coalesce(session_date, tanggal order) sampai akhir bulan itu. Sesi yang tertinggal terbawa ke bulan berikutnya.
-- Penyesuaian tutor (extend, bonus_tutor, potongan): dibuat sampai akhir bulan itu dan ordernya tak terhapus; refund diabaikan.
-- Payroll yang terkunci (ada transfer, sudah paid, atau legacy) tidak diubah. Payroll yang belum terkunci pada bulan itu
-- dihitung ulang penuh: sesi atau penyesuaian yang tidak lagi berhak (dihapus, dibatalkan, ganti tutor, order dihapus)
-- dilepas dulu, lalu yang berhak ditambahkan.
create or replace function public.generate_payroll(p_month int, p_year int) returns setof public.payroll_records
language plpgsql security definer
set search_path = public
as $$
declare
  v_end    date;
  v_tutor  uuid;
  v_pr     public.payroll_records%rowtype;
  v_count  int; v_sess numeric; v_share numeric; v_ext numeric; v_extshare numeric; v_bonus numeric; v_ded numeric;
begin
  if not public.is_admin() then raise exception 'bukan_admin'; end if;
  if p_month is null or p_month not between 1 and 12 or p_year is null or p_year not between 2000 and 2100 then
    raise exception 'bulan_tidak_valid';
  end if;
  v_end := (make_date(p_year, p_month, 1) + interval '1 month - 1 day')::date;

  -- 1) lepaskan yang tidak lagi berhak dari payroll bulan ini yang belum terkunci
  update public.order_sessions s set payroll_id = null
    from public.payroll_records p
   where s.payroll_id = p.id and p.period_month = p_month and p.period_year = p_year
     and not public.payroll_is_locked(p.id)
     and not exists (
       select 1 from public.orders o
        where o.id = s.order_id and o.deleted_at is null and (o.kind = 'lepas' or o.status = 'done')
          and s.deleted_at is null and s.recipient = 'tutor' and s.status = 'selesai' and s.tutor_id = p.tutor_id
          and coalesce(s.session_date, o.ordered_at) <= v_end);
  update public.order_adjustments a set payroll_id = null
    from public.payroll_records p
   where a.payroll_id = p.id and p.period_month = p_month and p.period_year = p_year
     and not public.payroll_is_locked(p.id)
     and not exists (
       select 1 from public.orders o
        where o.id = a.order_id and o.deleted_at is null and a.deleted_at is null and a.tutor_id = p.tutor_id
          and a.kind in ('extend', 'bonus_tutor', 'potongan'));

  -- 2) tutor yang dihitung: punya item baru yang berhak, atau sudah punya payroll bulan ini yang belum terkunci
  for v_tutor in
    select s.tutor_id
      from public.order_sessions s join public.orders o on o.id = s.order_id
     where s.deleted_at is null and o.deleted_at is null and s.recipient = 'tutor' and s.payroll_id is null
       and s.status = 'selesai' and (o.kind = 'lepas' or o.status = 'done')
       and coalesce(s.session_date, o.ordered_at) <= v_end
    union
    select a.tutor_id
      from public.order_adjustments a join public.orders o on o.id = a.order_id
     where a.deleted_at is null and o.deleted_at is null and a.payroll_id is null and a.tutor_id is not null
       and a.kind in ('extend', 'bonus_tutor', 'potongan')
       and (a.created_at at time zone 'Asia/Jakarta')::date <= v_end
    union
    select p.tutor_id from public.payroll_records p
     where p.period_month = p_month and p.period_year = p_year and not public.payroll_is_locked(p.id)
    order by 1
  loop
    select * into v_pr from public.payroll_records
     where tutor_id = v_tutor and period_month = p_month and period_year = p_year for update;
    if found and public.payroll_is_locked(v_pr.id) then continue; end if;
    if not found then
      insert into public.payroll_records (tutor_id, period_month, period_year, status, source)
      values (v_tutor, p_month, p_year, 'pending', 'order') returning * into v_pr;
    end if;

    update public.order_sessions s set payroll_id = v_pr.id
      from public.orders o
     where o.id = s.order_id and s.tutor_id = v_tutor and s.deleted_at is null and o.deleted_at is null
       and s.recipient = 'tutor' and s.payroll_id is null and s.status = 'selesai'
       and (o.kind = 'lepas' or o.status = 'done') and coalesce(s.session_date, o.ordered_at) <= v_end;
    update public.order_adjustments a set payroll_id = v_pr.id
      from public.orders o
     where o.id = a.order_id and a.tutor_id = v_tutor and a.deleted_at is null and o.deleted_at is null and a.payroll_id is null
       and a.kind in ('extend', 'bonus_tutor', 'potongan')
       and (a.created_at at time zone 'Asia/Jakarta')::date <= v_end;

    select coalesce(sum(sessions_count), 0), coalesce(sum(amount), 0), coalesce(sum(round(amount * tutor_pct / 100, 2)), 0)
      into v_count, v_sess, v_share
      from public.order_sessions where payroll_id = v_pr.id and deleted_at is null;
    select coalesce(sum(amount) filter (where kind = 'extend'), 0),
           coalesce(sum(round(amount * tutor_pct / 100, 2)) filter (where kind = 'extend'), 0),
           coalesce(sum(amount) filter (where kind = 'bonus_tutor'), 0),
           coalesce(sum(amount) filter (where kind = 'potongan'), 0)
      into v_ext, v_extshare, v_bonus, v_ded
      from public.order_adjustments where payroll_id = v_pr.id and deleted_at is null;

    update public.payroll_records
       set total_sessions   = v_count,
           total_gross      = v_sess + v_ext,
           total_commission = v_share + v_extshare,
           total_bonus      = v_bonus,
           total_deductions = v_ded,
           total_due        = v_share + v_extshare + v_bonus - v_ded
     where id = v_pr.id
     returning * into v_pr;
    return next v_pr;
  end loop;
  return;
end $$;
revoke execute on function public.generate_payroll(int, int) from public, anon;
grant execute on function public.generate_payroll(int, int) to authenticated;

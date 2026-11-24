-- Uji migration 009 (bagian tabel inti): RLS admin-saja, batasan data, pengaturan awal, idempotent.
\i order_stubs.sql
\i ../migration/009_order_inti.sql
\i ../migration/009_order_inti.sql

do $$
declare
  admin_id uuid := '00000000-0000-0000-0000-00000000ad01';
  user_id  uuid := '00000000-0000-0000-0000-0000000000b1';
  tutor_id uuid := '00000000-0000-0000-0000-0000000000d1';
  ord uuid := '00000000-0000-0000-0000-0000000000a1';
  m text; n bigint; t text;
  tabel text[] := array['orders','order_sessions','order_adjustments','order_payments','order_complaints','app_settings'];
begin
  insert into public.users (id, role, full_name) values (admin_id, 'admin', 'Admin'), (user_id, 'buddy', 'Buddy');
  insert into public.tutors (id, user_id, full_name) values (tutor_id, user_id, 'Tutor A');

  foreach t in array tabel loop
    if not (select relrowsecurity from pg_class where oid = ('public.' || t)::regclass) then raise exception 'GAGAL [rls aktif]: %', t; end if;
    m := th.as_user('anon', null, format('select count(*) from public.%I', t));
    if m not like 'permission denied%' then raise exception 'GAGAL [anon tertutup]: % -> %', t, m; end if;
  end loop;

  -- admin boleh menulis semua tabel
  m := th.as_user('authenticated', admin_id, format($q$insert into public.orders (id, form_no, buddy_name, service_name, sessions_total, total_price, reschedule_quota) values (%L, 'FO001', 'Budi', 'Kelas Tutor', 3, 150000, 1)$q$, ord));
  if m <> 'ok' then raise exception 'GAGAL [admin order]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format($q$insert into public.order_sessions (order_id, tutor_id, sessions_count, rate, amount, tutor_pct) values (%L, %L, 1, 50000, 0, 70)$q$, ord, tutor_id));
  if m <> 'ok' then raise exception 'GAGAL [admin sesi]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format($q$insert into public.order_adjustments (order_id, kind, amount) values (%L, 'extend', 10000)$q$, ord));
  if m <> 'ok' then raise exception 'GAGAL [admin penyesuaian]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format($q$insert into public.order_payments (order_id, amount, method) values (%L, 100000, 'transfer')$q$, ord));
  if m <> 'ok' then raise exception 'GAGAL [admin pembayaran]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format($q$insert into public.order_complaints (order_id, category, description) values (%L, 'jadwal', 'telat')$q$, ord));
  if m <> 'ok' then raise exception 'GAGAL [admin komplain]: %', m; end if;
  m := th.as_user('authenticated', admin_id, $q$update public.app_settings set value = '65' where key = 'tutor_pct'$q$);
  if m <> 'ok' then raise exception 'GAGAL [admin pengaturan]: %', m; end if;
  m := th.as_user('authenticated', admin_id, $q$update public.app_settings set value = '70' where key = 'tutor_pct'$q$);
  if m <> 'ok' then raise exception 'GAGAL [admin pengaturan balik]: %', m; end if;

  -- pengguna biasa tidak melihat dan tidak menulis
  foreach t in array tabel loop
    n := th.count_as('authenticated', user_id, format('select count(*) from public.%I', t));
    if n <> 0 then raise exception 'GAGAL [bukan admin tertutup]: % melihat % baris', t, n; end if;
  end loop;
  m := th.as_user('authenticated', user_id, $q$insert into public.orders (form_no, buddy_name, service_name, sessions_total, total_price, reschedule_quota) values ('FO099', 'X', 'Y', 1, 0, 0)$q$);
  if m not like 'new row violates row-level security%' then raise exception 'GAGAL [bukan admin tulis]: %', m; end if;

  -- tanpa delete
  foreach t in array tabel loop
    m := th.as_user('authenticated', admin_id, format('delete from public.%I', t));
    if m not like 'permission denied%' then raise exception 'GAGAL [tanpa delete]: % -> %', t, m; end if;
  end loop;

  -- batasan
  m := th.as_user('authenticated', admin_id, format($q$insert into public.order_sessions (order_id, recipient, sessions_count, rate, amount, tutor_pct) values (%L, 'kas', 2, 24000, 0, 70)$q$, ord));
  if m <> 'ok' then raise exception 'GAGAL [kas tanpa tutor]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format($q$insert into public.order_sessions (order_id, recipient, sessions_count, rate, amount, tutor_pct) values (%L, 'tutor', 1, 24000, 0, 70)$q$, ord));
  if m not like '%violates check constraint%' then raise exception 'GAGAL [tutor wajib tutor_id]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format($q$insert into public.order_sessions (order_id, tutor_id, sessions_count, rate, amount, tutor_pct) values (%L, %L, 0, 24000, 0, 70)$q$, ord, tutor_id));
  if m not like '%violates check constraint%' then raise exception 'GAGAL [sesi minimal 1]: %', m; end if;
  m := th.as_user('authenticated', admin_id, $q$insert into public.orders (form_no, buddy_name, service_name, sessions_total, total_price, reschedule_quota, status) values ('FO002', 'X', 'Y', 1, 0, 0, 'aneh')$q$);
  if m not like '%violates check constraint%' then raise exception 'GAGAL [status order]: %', m; end if;
  m := th.as_user('authenticated', admin_id, $q$insert into public.orders (form_no, buddy_name, service_name, sessions_total, total_price, reschedule_quota) values ('FO001', 'X', 'Y', 1, 0, 0)$q$);
  if m not like '%duplicate key%' then raise exception 'GAGAL [form_no unik]: %', m; end if;

  -- pengaturan awal
  if public.setting_num('tutor_pct', 0) <> 70 then raise exception 'GAGAL [setting awal tutor_pct]'; end if;
  if public.setting_num('reschedule_hours', 0) <> 6 then raise exception 'GAGAL [setting awal reschedule_hours]'; end if;
  if public.setting_num('tidak_ada', 5) <> 5 then raise exception 'GAGAL [setting bawaan]'; end if;
  select count(*) into n from public.app_settings;
  if n <> 6 then raise exception 'GAGAL [enam kunci pengaturan]: %', n; end if;

  -- kolom baru paket
  perform category, kind, default_duration_minutes from public.packages limit 1;

  raise notice ' OK: order_inti.test.sql (migration 009 bagian inti)';
end $$;

-- Uji migration 009 (bagian aturan): nomor FO, jatuh tempo, pendapatan sesi, selesai otomatis, ringkasan order.
-- Angka diambil dari spreadsheet Jul-Okt 2026 (mis. FO033: 16 sesi x Rp24.000 dibagi ke 4 penerima).
\i order_stubs.sql
\i ../migration/009_order_inti.sql
\i ../migration/012_kas_pendapatan_lain.sql
\i ../migration/012_kas_pendapatan_lain.sql

do $$
declare
  t1 uuid := '00000000-0000-0000-0000-0000000000d1';
  t2 uuid := '00000000-0000-0000-0000-0000000000d2';
  t3 uuid := '00000000-0000-0000-0000-0000000000d3';
  pkg uuid := '00000000-0000-0000-0000-0000000000e1';
  o uuid; o2 uuid; s1 uuid; s2 uuid; s3 uuid;
  r record; v text; n int; v2 numeric;
begin
  insert into public.users (id, role, full_name) values ('00000000-0000-0000-0000-0000000000c1', 'tutor', 'T');
  insert into public.tutors (id, user_id, full_name) values
    (t1, '00000000-0000-0000-0000-0000000000c1', 'Tutor 1'), (t2, '00000000-0000-0000-0000-0000000000c1', 'Tutor 2'), (t3, '00000000-0000-0000-0000-0000000000c1', 'Tutor 3');
  insert into public.packages (id, package_name, price, session_count, validity_days, reschedule_quota)
    values (pkg, 'Bulanan 12', 300000, 12, 35, 3);

  -- [form_no otomatis]
  insert into public.orders (buddy_name, service_name, sessions_total, price_per_session) values ('A', 'X', 1, 1000) returning form_no into v;
  if v <> 'FO001' then raise exception 'GAGAL [form_no otomatis pertama]: %', v; end if;
  insert into public.orders (form_no, buddy_name, service_name, sessions_total) values ('FO062', 'B', 'X', 1);
  insert into public.orders (buddy_name, service_name, sessions_total) values ('C', 'X', 1) returning form_no into v;
  if v <> 'FO063' then raise exception 'GAGAL [form_no otomatis lanjutan]: %', v; end if;

  -- [fo033] 16 sesi x 24.000: 3 tutor @4 sesi + kas 4 sesi
  insert into public.orders (id, form_no, buddy_name, service_name, sessions_total, price_per_session)
    values ('00000000-0000-0000-0000-000000000033', 'FO033', 'Anak', 'Bulanan', 16, 24000) returning id into o;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, status) values (o, t1, 4, 'selesai'), (o, t2, 4, 'selesai'), (o, t3, 4, 'selesai');
  insert into public.order_sessions (order_id, recipient, sessions_count, status) values (o, 'kas', 4, 'selesai');
  select count(*) into n from public.order_sessions where order_id = o and amount = 96000 and rate = 24000 and tutor_pct = case recipient when 'kas' then 0 else 70 end;
  if n <> 4 then raise exception 'GAGAL [fo033 amount per baris]: %', n; end if;
  select * into r from public.order_summary where order_id = o;
  -- sesi hangus (kas) tidak dibayar ke tutor: seluruhnya pendapatan lain-lain (tim inti)
  if r.revenue_total <> 384000 or r.recipient_share_total <> 201600 or r.company_share_total <> 182400 or r.other_income_total <> 96000 then
    raise exception 'GAGAL [fo033 ringkasan]: % % % %', r.revenue_total, r.recipient_share_total, r.company_share_total, r.other_income_total;
  end if;
  -- [kas selalu 0%] walau diisi 70 oleh pemanggil, dan diperbaiki bila diubah
  insert into public.order_sessions (order_id, recipient, sessions_count, tutor_pct, status) values (o, 'kas', 1, 70, 'terjadwal') returning tutor_pct into v2;
  if v2 <> 0 then raise exception 'GAGAL [kas tutor_pct dipaksa 0]: %', v2; end if;
  update public.order_sessions set tutor_pct = 50 where order_id = o and recipient = 'kas';
  if exists (select 1 from public.order_sessions where order_id = o and recipient = 'kas' and tutor_pct <> 0) then raise exception 'GAGAL [kas tutor_pct diubah]'; end if;
  delete from public.order_sessions where order_id = o and status = 'terjadwal';
  if r.sessions_done <> 16 or r.sessions_left <> 0 then raise exception 'GAGAL [fo033 sisa sesi]: % %', r.sessions_done, r.sessions_left; end if;

  -- [pembulatan]
  insert into public.orders (buddy_name, service_name, sessions_total, price_per_session) values ('P', 'X', 1, 95333.33) returning id into o2;
  insert into public.order_sessions (order_id, tutor_id, sessions_count) values (o2, t1, 1);
  select amount into r from public.order_sessions where order_id = o2;
  if r.amount <> 95333.33 then raise exception 'GAGAL [pembulatan]: %', r.amount; end if;
  select recipient_share_total, company_share_total into r from public.order_summary where order_id = o2;
  if r.recipient_share_total <> 66733.33 or r.company_share_total <> 28600.00 then raise exception 'GAGAL [pembulatan bagi hasil]: % %', r.recipient_share_total, r.company_share_total; end if;

  -- [jatuh tempo dan isian dari paket]
  insert into public.orders (buddy_name, service_name, sessions_total, price_per_session, package_id, ordered_at)
    values ('Q', 'Bulanan', 12, 25000, pkg, date '2026-08-01') returning id into o;
  select valid_until, reschedule_quota, total_price into r from public.orders where id = o;
  if r.valid_until <> date '2026-09-05' or r.reschedule_quota <> 3 or r.total_price <> 300000 then
    raise exception 'GAGAL [jatuh tempo]: % % %', r.valid_until, r.reschedule_quota, r.total_price;
  end if;

  -- [selesai otomatis]
  insert into public.orders (buddy_name, service_name, sessions_total, price_per_session) values ('S', 'X', 3, 50000) returning id into o;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, status) values (o, t1, 1, 'selesai') returning id into s1;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, status) values (o, t1, 1, 'selesai') returning id into s2;
  select status into v from public.orders where id = o;
  if v <> 'progress' then raise exception 'GAGAL [selesai terlalu cepat]: %', v; end if;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, status) values (o, t1, 1, 'terjadwal') returning id into s3;
  update public.order_sessions set status = 'selesai' where id = s3;
  select status into v from public.orders where id = o;
  if v <> 'done' then raise exception 'GAGAL [selesai otomatis]: %', v; end if;
  if (select completed_at from public.orders where id = o) is null then raise exception 'GAGAL [completed_at]'; end if;
  update public.order_sessions set status = 'batal' where id = s3;
  select status into v from public.orders where id = o;
  if v <> 'progress' or (select completed_at from public.orders where id = o) is not null then raise exception 'GAGAL [kembali progress]: %', v; end if;

  -- [sesi terhapus]
  update public.order_sessions set status = 'selesai' where id = s3;
  update public.order_sessions set deleted_at = now() where id = s3;
  select sessions_done into n from public.order_summary where order_id = o;
  if n <> 2 then raise exception 'GAGAL [sesi terhapus tidak dihitung]: %', n; end if;
  select status into v from public.orders where id = o;
  if v <> 'progress' then raise exception 'GAGAL [sesi terhapus status order]: %', v; end if;

  -- [status bayar] total 150.000
  select payment_status into v from public.order_summary where order_id = o;
  if v <> 'belum' then raise exception 'GAGAL [belum bayar]: %', v; end if;
  insert into public.order_payments (order_id, amount) values (o, 50000);
  select payment_status into v from public.order_summary where order_id = o;
  if v <> 'sebagian' then raise exception 'GAGAL [sebagian]: %', v; end if;
  insert into public.order_payments (order_id, amount) values (o, 100000);
  select payment_status into v from public.order_summary where order_id = o;
  if v <> 'lunas' then raise exception 'GAGAL [lunas]: %', v; end if;
  insert into public.order_adjustments (order_id, kind, amount) values (o, 'extend', 25000);
  select payment_status into v from public.order_summary where order_id = o;
  if v <> 'sebagian' then raise exception 'GAGAL [extend menaikkan target]: %', v; end if;
  select revenue_total into r from public.order_summary where order_id = o;
  if r.revenue_total <> 125000 then raise exception 'GAGAL [revenue dengan extend]: %', r.revenue_total; end if;
  insert into public.order_adjustments (order_id, kind, amount) values (o, 'refund', 10000);
  select refund_total into r from public.order_summary where order_id = o;
  if r.refund_total <> 10000 then raise exception 'GAGAL [refund total]: %', r.refund_total; end if;

  -- [hangus]
  insert into public.orders (buddy_name, service_name, sessions_total, price_per_session, valid_until) values ('H', 'X', 2, 1000, current_date - 1) returning id into o;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, status) values (o, t1, 1, 'selesai');
  select is_expired into v from public.order_summary where order_id = o;
  if v::boolean is not true then raise exception 'GAGAL [hangus]'; end if;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, status) values (o, t1, 1, 'selesai');
  select is_expired into v from public.order_summary where order_id = o;
  if v::boolean is not false then raise exception 'GAGAL [tidak hangus bila done]'; end if;

  -- [reschedule]
  insert into public.orders (buddy_name, service_name, sessions_total, price_per_session, reschedule_quota) values ('R', 'X', 3, 1000, 1) returning id into o;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, reschedule_count) values (o, t1, 1, 1);
  select reschedule_over into v from public.order_summary where order_id = o;
  if v::boolean is not false then raise exception 'GAGAL [reschedule sesuai kuota]'; end if;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, reschedule_count) values (o, t1, 1, 1);
  select reschedule_over, reschedule_used into r from public.order_summary where order_id = o;
  if r.reschedule_over is not true or r.reschedule_used <> 2 then raise exception 'GAGAL [reschedule melebihi kuota]: % %', r.reschedule_over, r.reschedule_used; end if;

  -- [batal tetap]
  insert into public.orders (buddy_name, service_name, sessions_total, price_per_session, status) values ('B', 'X', 1, 1000, 'batal') returning id into o;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, status) values (o, t1, 1, 'selesai');
  select status into v from public.orders where id = o;
  if v <> 'batal' then raise exception 'GAGAL [batal tetap]: %', v; end if;


  -- [sesi batal tidak dihitung pendapatan]
  insert into public.orders (buddy_name, service_name, sessions_total, price_per_session) values ('Z', 'X', 3, 10000) returning id into o;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, status) values (o, t1, 1, 'selesai'), (o, t1, 1, 'terjadwal'), (o, t1, 1, 'batal');
  select revenue_total, recipient_share_total into r from public.order_summary where order_id = o;
  if r.revenue_total <> 20000 or r.recipient_share_total <> 14000 then raise exception 'GAGAL [sesi batal dihitung]: % %', r.revenue_total, r.recipient_share_total; end if;

  -- [persen extend disalin saat dibuat] mengubah pengaturan tidak mengubah angka lama
  insert into public.order_adjustments (order_id, tutor_id, kind, amount) values (o, t1, 'extend', 10000);
  update public.app_settings set value = '60' where key = 'tutor_pct';
  select recipient_share_total into r from public.order_summary where order_id = o;
  if r.recipient_share_total <> 21000 then raise exception 'GAGAL [persen extend historis]: %', r.recipient_share_total; end if;
  update public.app_settings set value = '70' where key = 'tutor_pct';

  raise notice ' OK: order_aturan.test.sql (migration 009 bagian aturan)';
end $$;

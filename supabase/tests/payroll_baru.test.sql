-- Uji migration 011: generate_payroll (payroll bulanan dari sesi), transfer, dan penguncian.
\i order_stubs.sql
\i ../migration/009_order_inti.sql
\i ../migration/011_payroll_baru.sql
\i ../migration/011_payroll_baru.sql

do $$
declare
  admin_id uuid := '00000000-0000-0000-0000-00000000ad01';
  user_id  uuid := '00000000-0000-0000-0000-0000000000b1';
  t1 uuid := '00000000-0000-0000-0000-0000000000d1';
  t2 uuid := '00000000-0000-0000-0000-0000000000d2';
  t3 uuid := '00000000-0000-0000-0000-0000000000d3';
  t4 uuid := '00000000-0000-0000-0000-0000000000d4';
  t5 uuid := '00000000-0000-0000-0000-0000000000d5';
  t6 uuid := '00000000-0000-0000-0000-0000000000d6';
  oNov uuid; oX uuid; sN1 uuid; sN2 uuid; sN3 uuid;
  oL uuid; oP uuid; oT uuid; oT2 uuid; oK uuid; oD uuid; o4 uuid; o5 uuid;
  sP2 uuid; sDel uuid; sLate uuid; pay1 uuid;
  m text; n int; r record; c1 numeric;
begin
  insert into public.users (id, role, full_name) values (admin_id, 'admin', 'Admin'), (user_id, 'buddy', 'Buddy');
  insert into public.tutors (id, user_id, full_name) values (t1, user_id, 'T1'), (t2, user_id, 'T2'), (t3, user_id, 'T3'), (t4, user_id, 'T4'), (t5, user_id, 'T5'), (t6, user_id, 'T6');

  -- ===== data September 2026 =====
  -- t1: dua sesi lepas selesai + penyesuaian
  insert into public.orders (buddy_name, service_name, kind, sessions_total, price_per_session, ordered_at) values ('L', 'Lepas', 'lepas', 5, 100000, date '2026-09-10') returning id into oL;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, rate, session_date, status) values
    (oL, t1, 1, 100000, date '2026-09-12', 'selesai'), (oL, t1, 1, 95333.33, date '2026-09-20', 'selesai');
  insert into public.order_adjustments (order_id, tutor_id, kind, amount, created_at) values
    (oL, t1, 'bonus_tutor', 30000, timestamptz '2026-09-15 10:00+07'), (oL, t1, 'potongan', 5000, timestamptz '2026-09-15 10:00+07'),
    (oL, t1, 'refund', 10000, timestamptz '2026-09-15 10:00+07');
  -- t2: paket belum selesai (2 sesi), baru satu selesai
  insert into public.orders (buddy_name, service_name, kind, sessions_total, price_per_session, ordered_at) values ('P', 'Paket', 'paket', 2, 20000, date '2026-09-01') returning id into oP;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, session_date, status) values (oP, t2, 1, date '2026-09-05', 'selesai');
  insert into public.order_sessions (order_id, tutor_id, sessions_count, session_date, status) values (oP, t2, 1, date '2026-09-26', 'terjadwal') returning id into sP2;
  -- t3: tanggal pelaksanaan teks bebas (session_date kosong), lepas, order September; dan order Oktober
  insert into public.orders (buddy_name, service_name, kind, sessions_total, price_per_session, ordered_at) values ('T', 'Lepas', 'lepas', 1, 50000, date '2026-09-03') returning id into oT;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, date_note, status) values (oT, t3, 1, 'Senin minggu pertama', 'selesai');
  insert into public.orders (buddy_name, service_name, kind, sessions_total, price_per_session, ordered_at) values ('T2', 'Lepas', 'lepas', 1, 50000, date '2026-10-03') returning id into oT2;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, date_note, status) values (oT2, t3, 1, 'Selasa', 'selesai');
  -- kas
  insert into public.orders (buddy_name, service_name, kind, sessions_total, price_per_session, ordered_at) values ('K', 'Lepas', 'lepas', 1, 24000, date '2026-09-02') returning id into oK;
  insert into public.order_sessions (order_id, recipient, sessions_count, session_date, status) values (oK, 'kas', 2, date '2026-09-02', 'selesai');
  -- sesi terhapus (t2, order lepas)
  insert into public.orders (buddy_name, service_name, kind, sessions_total, price_per_session, ordered_at) values ('D', 'Lepas', 'lepas', 1, 70000, date '2026-09-04') returning id into oD;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, session_date, status, deleted_at) values (oD, t2, 1, date '2026-09-04', 'selesai', now()) returning id into sDel;

  -- [bukan admin] dan [anon]
  m := th.as_user('authenticated', user_id, 'select * from public.generate_payroll(9, 2026)');
  if m <> 'bukan_admin' then raise exception 'GAGAL [bukan admin]: %', m; end if;
  if has_function_privilege('anon', 'public.generate_payroll(int, int)', 'execute') then raise exception 'GAGAL [anon execute]'; end if;
  m := th.as_user('authenticated', admin_id, 'select * from public.generate_payroll(13, 2026)');
  if m <> 'bulan_tidak_valid' then raise exception 'GAGAL [bulan tidak valid]: %', m; end if;

  -- [bulan kosong]
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  select count(*) into n from public.generate_payroll(1, 2020);
  if n <> 0 then raise exception 'GAGAL [bulan kosong]: %', n; end if;

  -- ===== generate September =====
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  select count(*) into n from public.generate_payroll(9, 2026);
  -- baris: t1 dan t3 (t2 paket belum selesai dan sesi terhapus; kas tidak)
  if n <> 2 then raise exception 'GAGAL [jumlah payroll September]: %', n; end if;
  if exists (select 1 from public.payroll_records where tutor_id = t2) then raise exception 'GAGAL [paket belum selesai / terhapus masuk]'; end if;

  -- [bagi 70/30] + [bonus dan potongan]
  select * into r from public.payroll_records where tutor_id = t1 and period_month = 9 and period_year = 2026;
  if r.total_sessions <> 2 or r.total_gross <> 195333.33 or r.total_commission <> 136733.33
     or r.total_bonus <> 30000 or r.total_deductions <> 5000 or r.total_due <> 161733.33 or r.status <> 'pending' then
    raise exception 'GAGAL [hitungan t1]: % % % % % %', r.total_sessions, r.total_gross, r.total_commission, r.total_bonus, r.total_deductions, r.total_due;
  end if;
  pay1 := r.id;
  if exists (select 1 from public.order_sessions where order_id = oL and payroll_id is distinct from pay1) then raise exception 'GAGAL [sesi t1 ditandai]'; end if;

  -- [tanggal teks] t3 masuk dari order September, order Oktober tidak
  select * into r from public.payroll_records where tutor_id = t3 and period_month = 9;
  if r.total_sessions <> 1 or r.total_due <> 35000 then raise exception 'GAGAL [tanggal teks]: % %', r.total_sessions, r.total_due; end if;
  if (select payroll_id from public.order_sessions where order_id = oT2) is not null then raise exception 'GAGAL [order Oktober ikut September]'; end if;

  -- [kas] tidak ada baris kas, sesi kas tidak ditandai
  if (select payroll_id from public.order_sessions where order_id = oK) is not null then raise exception 'GAGAL [kas ditandai]'; end if;

  -- [dua kali]
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  select count(*) into n from public.generate_payroll(9, 2026);
  select count(*) into c1 from public.payroll_records;
  if c1 <> 2 then raise exception 'GAGAL [dua kali menambah baris]: %', c1; end if;
  select total_due into c1 from public.payroll_records where tutor_id = t1;
  if c1 <> 161733.33 then raise exception 'GAGAL [dua kali mengubah total]: %', c1; end if;

  -- [paket selesai] order paket menjadi done lalu masuk
  update public.order_sessions set status = 'selesai' where id = sP2;
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(9, 2026);
  select * into r from public.payroll_records where tutor_id = t2 and period_month = 9;
  if not found or r.total_sessions <> 2 or r.total_due <> 28000 then raise exception 'GAGAL [paket selesai]: % %', r.total_sessions, r.total_due; end if;

  -- [extend] menambah pendapatan dan dibagi 70/30 untuk tutornya
  insert into public.order_adjustments (order_id, tutor_id, kind, amount, created_at) values (oL, t5, 'extend', 20000, timestamptz '2026-09-28 10:00+07');
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(9, 2026);
  select * into r from public.payroll_records where tutor_id = t5 and period_month = 9;
  if not found or r.total_sessions <> 0 or r.total_gross <> 20000 or r.total_commission <> 14000 or r.total_due <> 14000 then
    raise exception 'GAGAL [extend]: % % %', r.total_gross, r.total_commission, r.total_due;
  end if;

  -- ===== transfer =====
  m := th.as_user('authenticated', admin_id, format($q$insert into public.payroll_transfers (payroll_id, amount) values (%L, 100000)$q$, pay1));
  if m <> 'ok' then raise exception 'GAGAL [transfer sebagian]: %', m; end if;
  select * into r from public.payroll_records where id = pay1;
  if r.status <> 'pending' or r.total_transferred <> 100000 then raise exception 'GAGAL [status setelah sebagian]: % %', r.status, r.total_transferred; end if;

  -- [penjaga payroll_records] payroll yang sudah ada transfernya tidak bisa diubah langsung
  m := th.as_user('authenticated', admin_id, format($q$update public.payroll_records set total_due = 1 where id = %L$q$, pay1));
  if m <> 'payroll_terkunci' then raise exception 'GAGAL [penjaga total payroll]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format($q$update public.payroll_records set status = 'paid', paid_at = now() where id = %L$q$, pay1));
  if m <> 'payroll_terkunci' then raise exception 'GAGAL [penjaga status payroll]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format($q$update public.payroll_records set notes = 'catatan' where id = %L$q$, pay1));
  if m <> 'ok' then raise exception 'GAGAL [catatan payroll boleh]: %', m; end if;

  -- [kunci] sesi baru selesai setelah transfer tidak mengubah payroll terkunci
  insert into public.order_sessions (order_id, tutor_id, sessions_count, rate, session_date, status) values (oL, t1, 1, 100000, date '2026-09-25', 'selesai') returning id into sLate;
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(9, 2026);
  select * into r from public.payroll_records where id = pay1;
  if r.total_sessions <> 2 or r.total_due <> 161733.33 then raise exception 'GAGAL [kunci mengubah payroll]: % %', r.total_sessions, r.total_due; end if;
  if (select payroll_id from public.order_sessions where id = sLate) is not null then raise exception 'GAGAL [sesi telat ditandai]'; end if;
  -- ...dan terbawa ke bulan berikutnya
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(10, 2026);
  select * into r from public.payroll_records where tutor_id = t1 and period_month = 10;
  if not found or r.total_sessions <> 1 or r.total_due <> 70000 then raise exception 'GAGAL [terbawa ke Oktober]: % %', r.total_sessions, r.total_due; end if;
  -- Oktober juga mengambil sesi t3 dari order Oktober
  if (select total_sessions from public.payroll_records where tutor_id = t3 and period_month = 10) is distinct from 1 then raise exception 'GAGAL [t3 Oktober]'; end if;

  -- [penjaga] sesi di payroll terkunci tidak bisa diubah
  m := th.as_user('authenticated', admin_id, format($q$update public.order_sessions set rate = 1 where order_id = %L and payroll_id = %L$q$, oL, pay1));
  if m <> 'payroll_terkunci' then raise exception 'GAGAL [penjaga sesi terkunci]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format($q$update public.order_sessions set reschedule_note = 'catatan' where order_id = %L and payroll_id = %L$q$, oL, pay1));
  if m <> 'ok' then raise exception 'GAGAL [catatan boleh diubah]: %', m; end if;

  -- [transfer lunas dan berlebih]
  m := th.as_user('authenticated', admin_id, format($q$insert into public.payroll_transfers (payroll_id, amount) values (%L, 61733.33)$q$, pay1));
  if m <> 'ok' then raise exception 'GAGAL [transfer pelunasan]: %', m; end if;
  select * into r from public.payroll_records where id = pay1;
  if r.status <> 'paid' or r.paid_at is null or r.total_transferred <> 161733.33 then raise exception 'GAGAL [status paid]: % %', r.status, r.total_transferred; end if;
  m := th.as_user('authenticated', admin_id, format($q$insert into public.payroll_transfers (payroll_id, amount) values (%L, 1)$q$, pay1));
  if m <> 'transfer_melebihi_hak' then raise exception 'GAGAL [transfer berlebih]: %', m; end if;
  -- transfer dibatalkan (hapus lunak) membuka kunci dan status kembali pending
  m := th.as_user('authenticated', admin_id, format($q$update public.payroll_transfers set deleted_at = now() where payroll_id = %L and amount = 61733.33$q$, pay1));
  select status into m from public.payroll_records where id = pay1;
  if m <> 'pending' then raise exception 'GAGAL [batal transfer]: %', m; end if;

  -- ===== payroll yang belum terkunci mengikuti perubahan data (November) =====
  insert into public.orders (buddy_name, service_name, kind, sessions_total, price_per_session, ordered_at) values ('N', 'Lepas', 'lepas', 3, 50000, date '2026-11-01') returning id into oNov;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, session_date, status) values (oNov, t6, 1, date '2026-11-05', 'selesai') returning id into sN1;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, session_date, status) values (oNov, t6, 1, date '2026-11-06', 'selesai') returning id into sN2;
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(11, 2026);
  if (select total_due from public.payroll_records where tutor_id = t6 and period_month = 11) <> 70000 then raise exception 'GAGAL [November awal]'; end if;
  -- [sesi dihapus lunak dan dibatalkan] total turun
  update public.order_sessions set deleted_at = now() where id = sN1;
  update public.order_sessions set status = 'batal' where id = sN2;
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(11, 2026);
  select * into r from public.payroll_records where tutor_id = t6 and period_month = 11;
  if r.total_sessions <> 0 or r.total_due <> 0 or r.total_gross <> 0 then raise exception 'GAGAL [total tidak turun]: % % %', r.total_sessions, r.total_gross, r.total_due; end if;
  if exists (select 1 from public.order_sessions where id in (sN1, sN2) and payroll_id is not null) then raise exception 'GAGAL [sesi batal masih ditandai]'; end if;
  -- [ganti tutor] hak pindah ke tutor baru
  insert into public.order_sessions (order_id, tutor_id, sessions_count, session_date, status, rate) values (oNov, t6, 1, date '2026-11-07', 'selesai', 40000) returning id into sN3;
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(11, 2026);
  if (select total_due from public.payroll_records where tutor_id = t6 and period_month = 11) <> 28000 then raise exception 'GAGAL [sesi t6]'; end if;
  update public.order_sessions set tutor_id = t4 where id = sN3;
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(11, 2026);
  if (select total_due from public.payroll_records where tutor_id = t6 and period_month = 11) <> 0 then raise exception 'GAGAL [ganti tutor: t6 masih dibayar]'; end if;
  if (select total_due from public.payroll_records where tutor_id = t4 and period_month = 11) is distinct from 28000 then raise exception 'GAGAL [ganti tutor: t4 tidak menerima]'; end if;
  -- [order terhapus] penyesuaiannya tidak dibayar
  insert into public.orders (buddy_name, service_name, kind, sessions_total, price_per_session, ordered_at, deleted_at) values ('X', 'Lepas', 'lepas', 1, 1000, date '2026-11-02', now()) returning id into oX;
  insert into public.order_adjustments (order_id, tutor_id, kind, amount, created_at) values (oX, t6, 'bonus_tutor', 7777, timestamptz '2026-11-10 10:00+07');
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(11, 2026);
  if (select total_bonus from public.payroll_records where tutor_id = t6 and period_month = 11) <> 0 then raise exception 'GAGAL [bonus order terhapus dibayar]'; end if;
  -- [payroll lama dari alur bookings] yang sudah paid tidak ditimpa
  insert into public.payroll_records (tutor_id, period_month, period_year, total_sessions, total_gross, total_commission, status, paid_at)
    values (t5, 11, 2026, 4, 500000, 350000, 'paid', now());
  insert into public.orders (buddy_name, service_name, kind, sessions_total, price_per_session, ordered_at) values ('Y', 'Lepas', 'lepas', 1, 50000, date '2026-11-03') returning id into oNov;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, session_date, status) values (oNov, t5, 1, date '2026-11-08', 'selesai') returning id into sN3;
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(11, 2026);
  select * into r from public.payroll_records where tutor_id = t5 and period_month = 11;
  if r.total_gross <> 500000 or r.status <> 'paid' or r.total_sessions <> 4 then raise exception 'GAGAL [payroll lama ditimpa]: % % %', r.total_gross, r.status, r.total_sessions; end if;
  if (select payroll_id from public.order_sessions where id = sN3) is not null then raise exception 'GAGAL [sesi masuk payroll lama]'; end if;

  -- ===== lintas tahun =====
  insert into public.orders (buddy_name, service_name, kind, sessions_total, price_per_session, ordered_at) values ('J', 'Lepas', 'lepas', 1, 40000, date '2026-12-01') returning id into o4;
  insert into public.order_sessions (order_id, tutor_id, sessions_count, session_date, status) values (o4, t4, 1, date '2027-01-05', 'selesai');
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(12, 2026);
  if exists (select 1 from public.payroll_records where tutor_id = t4 and period_month = 12) then raise exception 'GAGAL [sesi Januari masuk Desember]'; end if;
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  perform * from public.generate_payroll(1, 2027);
  select * into r from public.payroll_records where tutor_id = t4 and period_month = 1 and period_year = 2027;
  if not found or r.total_due <> 28000 then raise exception 'GAGAL [Januari]: %', r.total_due; end if;

  raise notice ' OK: payroll_baru.test.sql (migration 011)';
end $$;

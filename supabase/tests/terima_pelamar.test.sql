-- Uji migration 010: tutor tanpa akun dan accept_application (terima pelamar dalam satu transaksi).
\i order_stubs.sql
\i ../migration/009_order_inti.sql
\i ../migration/010_tutor_tanpa_akun.sql
\i ../migration/010_tutor_tanpa_akun.sql

do $$
declare
  admin_id uuid := '00000000-0000-0000-0000-00000000ad01';
  user_id  uuid := '00000000-0000-0000-0000-0000000000b1';
  app1 uuid := '00000000-0000-0000-0000-0000000000a1';
  app2 uuid := '00000000-0000-0000-0000-0000000000a2';
  app3 uuid := '00000000-0000-0000-0000-0000000000a3';
  app4 uuid := '00000000-0000-0000-0000-0000000000a4';
  m text; n bigint; r record; tid uuid;
begin
  insert into public.users (id, role, full_name) values (admin_id, 'admin', 'Admin'), (user_id, 'buddy', 'Buddy');
  insert into public.tutor_applications (id, full_name, whatsapp, email, subjects, jenjang, documents) values
    (app1, 'Siti Calon', '62811111', 's@x.id', '{mtk,fis}', '{sma,smp}',
     '{"transkrip": "11111111-1111-1111-1111-111111111111/transkrip.pdf", "kartu_identitas_pelajar": "11111111-1111-1111-1111-111111111111/kartu_identitas_pelajar.jpg", "lain": "x/y.pdf"}'),
    (app2, 'Sudah Diterima', '62822222', 'a@x.id', '{mtk}', '{sma}', '{}'),
    (app3, 'Dokumen Rusak', '62833333', 'b@x.id', '{mtk}', '{sma}', '[1]'),
    (app4, 'Tanpa Dokumen', '62844444', 'c@x.id', '{ing}', '{sd}', '{}');
  update public.tutor_applications set status = 'diterima' where id = app2;

  -- [bukan admin]
  m := th.as_user('authenticated', user_id, format('select public.accept_application(%L, 50000)', app1));
  if m <> 'bukan_admin' then raise exception 'GAGAL [bukan admin]: %', m; end if;
  if (select status from public.tutor_applications where id = app1) <> 'baru' or exists (select 1 from public.tutors) then
    raise exception 'GAGAL [bukan admin mengubah data]';
  end if;

  -- [anon tanpa hak execute]
  if has_function_privilege('anon', 'public.accept_application(uuid, numeric)', 'execute') then raise exception 'GAGAL [anon execute]'; end if;

  -- [harga]
  m := th.as_user('authenticated', admin_id, format('select public.accept_application(%L, 0)', app1));
  if m <> 'harga_tidak_valid' then raise exception 'GAGAL [harga nol]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format('select public.accept_application(%L, null)', app1));
  if m <> 'harga_tidak_valid' then raise exception 'GAGAL [harga null]: %', m; end if;

  -- [sudah diproses] dan [tidak ada]
  m := th.as_user('authenticated', admin_id, format('select public.accept_application(%L, 50000)', app2));
  if m <> 'pelamar_tidak_valid' then raise exception 'GAGAL [sudah diterima]: %', m; end if;
  m := th.as_user('authenticated', admin_id, $q$select public.accept_application('00000000-0000-0000-0000-0000000000ff', 50000)$q$);
  if m <> 'pelamar_tidak_valid' then raise exception 'GAGAL [tidak ada]: %', m; end if;

  -- [atomik] dokumen rusak menggagalkan seluruh penerimaan
  m := th.as_user('authenticated', admin_id, format('select public.accept_application(%L, 50000)', app3));
  if m = 'ok' then raise exception 'GAGAL [atomik: seharusnya galat]'; end if;
  if (select status from public.tutor_applications where id = app3) <> 'baru' or exists (select 1 from public.tutors where application_id = app3) then
    raise exception 'GAGAL [atomik: data tertinggal]';
  end if;

  -- [terima normal]
  m := th.as_user('authenticated', admin_id, format('select public.accept_application(%L, 75000)', app1));
  if m <> 'ok' then raise exception 'GAGAL [terima normal]: %', m; end if;
  select * into r from public.tutors where application_id = app1;
  if not found or r.user_id is not null or r.verification_status <> 'verified' or r.price_per_hour <> 75000
     or r.full_name <> 'Siti Calon'
     or r.subjects <> '{mtk,fis}' or r.jenjang_diajar <> '{sma,smp}' or r.is_outsourced then
    raise exception 'GAGAL [terima normal: isi tutor]';
  end if;
  tid := r.id;
  select * into r from public.tutor_private where tutor_id = tid;
  if not found or r.whatsapp <> '62811111' or r.email <> 's@x.id' then raise exception 'GAGAL [data pribadi tutor]'; end if;
  -- [data pribadi tertutup] pengguna login biasa dan anon tidak membaca
  if th.count_as('authenticated', user_id, 'select count(*) from public.tutor_private') <> 0 then raise exception 'GAGAL [tutor_private terbaca]'; end if;
  m := th.as_user('anon', null, 'select count(*) from public.tutor_private');
  if m not like 'permission denied%' then raise exception 'GAGAL [anon baca tutor_private]: %', m; end if;
  m := th.as_user('authenticated', user_id, format($q$update public.tutor_private set payout_account = 'x' where tutor_id = %L$q$, tid));
  if th.count_as('authenticated', admin_id, format('select count(*) from public.tutor_private where payout_account = ''x'' and tutor_id = %L', tid)) <> 0 then raise exception 'GAGAL [bukan admin ubah tutor_private]'; end if;
  select * into r from public.tutor_applications where id = app1;
  if r.status <> 'diterima' or r.handled_by is distinct from admin_id or r.handled_at is null then raise exception 'GAGAL [terima normal: pelamar]'; end if;

  -- [tanpa dokumen ganda]
  select count(*) into n from (select jenis_dokumen from public.tutor_documents where tutor_id = tid group by 1 having count(*) > 1) d;
  if n <> 0 then raise exception 'GAGAL [dokumen ganda]'; end if;
  select * into r from public.tutor_documents where tutor_id = tid and jenis_dokumen = 'transkrip';
  if r.status <> 'terverifikasi' or r.storage_bucket <> 'tutor-applications' or r.file_url <> '11111111-1111-1111-1111-111111111111/transkrip.pdf' or r.label <> 'Transkrip Nilai' then
    raise exception 'GAGAL [dokumen transkrip]: % % %', r.status, r.storage_bucket, r.file_url;
  end if;
  select * into r from public.tutor_documents where tutor_id = tid and jenis_dokumen = 'sertifikat_prestasi';
  if r.status <> 'belum_upload' or r.file_url is not null then raise exception 'GAGAL [dokumen tanpa berkas dibiarkan]'; end if;
  if exists (select 1 from public.tutor_documents where tutor_id = tid and jenis_dokumen = 'lain') then raise exception 'GAGAL [jenis tak dikenal]'; end if;

  -- [dua kali]
  m := th.as_user('authenticated', admin_id, format('select public.accept_application(%L, 75000)', app1));
  if m <> 'pelamar_tidak_valid' then raise exception 'GAGAL [dua kali]: %', m; end if;
  if (select count(*) from public.tutors where application_id = app1) <> 1 then raise exception 'GAGAL [tutor kedua]'; end if;

  -- [tanpa dokumen] tetap bisa diterima
  m := th.as_user('authenticated', admin_id, format('select public.accept_application(%L, 60000)', app4));
  if m <> 'ok' then raise exception 'GAGAL [tanpa dokumen]: %', m; end if;

  -- [tutor tanpa akun] admin menambah langsung, dengan atribut baru
  m := th.as_user('authenticated', admin_id, $q$insert into public.tutors (full_name, is_outsourced) values ('Tutor Outsource', true)$q$);
  if m <> 'ok' then raise exception 'GAGAL [tutor tanpa akun]: %', m; end if;
  m := th.as_user('authenticated', admin_id, $q$insert into public.tutor_private (tutor_id, whatsapp, payout_account) select id, '6285', 'BCA 123 a.n. X' from public.tutors where full_name = 'Tutor Outsource'$q$);
  if m <> 'ok' then raise exception 'GAGAL [data pribadi oleh admin]: %', m; end if;

  raise notice ' OK: terima_pelamar.test.sql (migration 010)';
end $$;

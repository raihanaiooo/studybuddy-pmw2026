-- Uji migration 005: pendaftaran tutor dari landing (tabel tertutup, RPC bervalidasi, admin membaca dan memproses).
create schema th;
grant usage on schema th to anon, authenticated;
create or replace function th.ok(p_session text, p_override jsonb default '{}'::jsonb) returns jsonb
language sql as $f$
  select public.submit_tutor_application(p_session,
    jsonb_build_object('full_name','Alya Rahma','university','ITB','major','Teknik Fisika','semester',5,
      'whatsapp','081234567890','email','alya@example.com','subjects',jsonb_build_array('mtk','fis'),
      'jenjang',jsonb_build_array('sma'),'experience','Mengajar privat 2 tahun') || p_override)
$f$;

create or replace function th.msg(p_session text, p_override jsonb) returns text
language plpgsql as $f$
begin
  perform th.ok(p_session, p_override); return 'tidak ada error';
exception when others then return sqlerrm;
end $f$;

do $$
declare r jsonb; n int; m text; ditolak boolean;
  admin_id uuid := '00000000-0000-0000-0000-00000000ad01';
  buddy_id uuid := '00000000-0000-0000-0000-00000000b001';
begin
  insert into public.users (id, role) values (admin_id, 'admin'), (buddy_id, 'customer');
  grant execute on function th.ok(text, jsonb), th.msg(text, jsonb) to anon, authenticated;

  -- sukses: nomor dinormalkan ke 62..., status awal 'baru'
  set local role anon;
  r := th.ok('s-ok');
  reset role;
  if r->>'application_id' is null then raise exception 'GAGAL [sukses]: tanpa application_id: %', r; end if;
  select count(*) into n from public.tutor_applications
   where id = (r->>'application_id')::uuid and status = 'baru' and whatsapp = '6281234567890';
  if n <> 1 then raise exception 'GAGAL [simpan]: baris tidak sesuai (status baru, whatsapp 6281234567890)'; end if;

  -- validasi
  set local role anon;
  m := th.msg('s-v1', '{"full_name":" "}');
  if m <> 'invalid_input:full_name' then reset role; raise exception 'GAGAL [nama]: %', m; end if;
  m := th.msg('s-v2', '{"whatsapp":"12345"}');
  if m <> 'invalid_input:whatsapp' then reset role; raise exception 'GAGAL [wa]: %', m; end if;
  m := th.msg('s-v3', '{"email":"bukan-email"}');
  if m <> 'invalid_input:email' then reset role; raise exception 'GAGAL [email]: %', m; end if;
  m := th.msg('s-v4', '{"subjects":[]}');
  if m <> 'invalid_input:subjects' then reset role; raise exception 'GAGAL [mapel kosong]: %', m; end if;
  m := th.msg('s-v5', '{"subjects":["astrologi"]}');
  if m <> 'invalid_input:subjects' then reset role; raise exception 'GAGAL [mapel asing]: %', m; end if;
  m := th.msg('s-v6', '{"jenjang":["s3"]}');
  if m <> 'invalid_input:jenjang' then reset role; raise exception 'GAGAL [jenjang]: %', m; end if;
  m := th.msg('s-v7', '{"semester":99}');
  if m <> 'invalid_input:semester' then reset role; raise exception 'GAGAL [semester]: %', m; end if;
  m := th.msg('s-v8', jsonb_build_object('experience', repeat('x', 1001)));
  if m <> 'invalid_input:experience' then reset role; raise exception 'GAGAL [pengalaman panjang]: %', m; end if;
  m := th.msg('', '{}');
  if m <> 'invalid_session' then reset role; raise exception 'GAGAL [sesi kosong]: %', m; end if;
  reset role;

  -- ganda: WhatsApp yang sama masih berstatus baru dalam 7 hari
  set local role anon;
  m := th.msg('s-dup', '{}');
  reset role;
  if m <> 'duplicate' then raise exception 'GAGAL [duplikat]: %', m; end if;

  -- batas laju: 3 pendaftaran per jam per sesi (nomor berbeda agar bukan duplikat)
  set local role anon;
  perform th.ok('s-rate', '{"whatsapp":"081111111111"}');
  perform th.ok('s-rate', '{"whatsapp":"081111111112"}');
  perform th.ok('s-rate', '{"whatsapp":"081111111113"}');
  m := th.msg('s-rate', '{"whatsapp":"081111111114"}');
  reset role;
  if m <> 'rate_limited' then raise exception 'GAGAL [laju]: %', m; end if;

  -- oprec: tanpa baris = terbuka; ditutup bila baris terbaru nonaktif atau di luar tanggal
  insert into public.oprec_info (is_active, created_at) values (false, now());
  set local role anon;
  m := th.msg('s-c1', '{"whatsapp":"082222222221"}');
  reset role;
  if m <> 'oprec_closed' then raise exception 'GAGAL [oprec nonaktif]: %', m; end if;

  insert into public.oprec_info (is_active, start_date, end_date, created_at)
  values (true, current_date + 5, current_date + 9, now() + interval '1 second');
  set local role anon;
  m := th.msg('s-c2', '{"whatsapp":"082222222222"}');
  reset role;
  if m <> 'oprec_closed' then raise exception 'GAGAL [belum mulai]: %', m; end if;

  insert into public.oprec_info (is_active, start_date, end_date, created_at)
  values (true, current_date - 1, current_date + 1, now() + interval '2 second');
  set local role anon;
  m := th.msg('s-c3', '{"whatsapp":"082222222223"}');
  reset role;
  if m <> 'tidak ada error' then raise exception 'GAGAL [oprec terbuka]: %', m; end if;

  -- tabel tertutup untuk anon
  set local role anon;
  ditolak := false;
  begin perform 1 from public.tutor_applications limit 1; exception when insufficient_privilege then ditolak := true; end;
  reset role;
  if not ditolak then raise exception 'GAGAL [tabel]: anon bisa membaca tutor_applications'; end if;

  -- non-admin tidak melihat dan tidak mengubah apa pun
  perform set_config('request.jwt.claim.sub', buddy_id::text, true);
  set local role authenticated;
  select count(*) into n from public.tutor_applications;
  update public.tutor_applications set status = 'diterima';
  reset role;
  if n <> 0 then raise exception 'GAGAL [non-admin baca]: melihat % baris', n; end if;
  select count(*) into n from public.tutor_applications where status = 'diterima';
  if n <> 0 then raise exception 'GAGAL [non-admin ubah]: % baris berubah', n; end if;

  -- admin membaca dan memproses
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  set local role authenticated;
  select count(*) into n from public.tutor_applications;
  if n < 5 then reset role; raise exception 'GAGAL [admin baca]: hanya % baris', n; end if;
  update public.tutor_applications
     set status = 'ditolak', admin_note = 'belum memenuhi syarat', handled_by = admin_id, handled_at = now()
   where id = (r->>'application_id')::uuid;
  reset role;
  select count(*) into n from public.tutor_applications where status = 'ditolak' and admin_note is not null;
  if n <> 1 then raise exception 'GAGAL [admin ubah]: % baris', n; end if;

  raise notice ' OK: tutor_applications.test.sql (migration 005)';
end $$;

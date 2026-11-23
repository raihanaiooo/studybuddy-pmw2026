-- Uji migration 004: pengunjung (anon) hanya lewat view tutors_public; tabel tutors dan reviews tertutup untuk anon.
do $$
declare n int; ditolak boolean; kolom text;
begin
  insert into public.tutors (id, full_name, university, verification_status, is_featured, gmeet_link, verification_note, user_id)
  values ('00000000-0000-0000-0000-0000000000a1', 'Tutor Unggulan', 'ITB', 'verified', true, 'https://meet.example/rahasia', 'catatan internal', gen_random_uuid()),
         ('00000000-0000-0000-0000-0000000000a2', 'Tutor Biasa',    'UI',  'verified', false, null, null, gen_random_uuid()),
         ('00000000-0000-0000-0000-0000000000a3', 'Tutor Pending',  'UGM', 'pending',  true,  null, null, gen_random_uuid());
  insert into public.reviews (customer_id, tutor_id, rating, comment)
  values (gen_random_uuid(), '00000000-0000-0000-0000-0000000000a1', 5, 'bagus');

  set local role anon;

  -- view hanya memuat tutor verified DAN featured
  select count(*) into n from public.tutors_public;
  if n <> 1 then reset role; raise exception 'GAGAL [view]: % baris, seharusnya 1 (verified dan featured saja)', n; end if;

  -- view tidak membocorkan kolom internal
  reset role;
  select string_agg(column_name, ',') into kolom from information_schema.columns
   where table_schema = 'public' and table_name = 'tutors_public'
     and column_name in ('gmeet_link', 'verification_note', 'user_id', 'gpa', 'verification_status', 'account_status');
  if kolom is not null then raise exception 'GAGAL [kolom]: view membocorkan %', kolom; end if;

  -- anon tidak boleh membaca tabel tutors maupun reviews langsung
  set local role anon;
  ditolak := false;
  begin perform 1 from public.tutors limit 1; exception when insufficient_privilege then ditolak := true; end;
  if not ditolak then reset role; raise exception 'GAGAL [tutors]: anon masih bisa membaca tabel tutors'; end if;
  ditolak := false;
  begin perform 1 from public.reviews limit 1; exception when insufficient_privilege then ditolak := true; end;
  if not ditolak then reset role; raise exception 'GAGAL [reviews]: anon masih bisa membaca tabel reviews'; end if;
  reset role;

  -- pengguna login (authenticated) tetap bisa membaca tabelnya seperti sebelumnya
  set local role authenticated;
  select count(*) into n from public.tutors;
  if n <> 3 then reset role; raise exception 'GAGAL [authenticated]: tutors terbaca % baris, seharusnya 3', n; end if;
  perform 1 from public.reviews limit 1;
  reset role;

  raise notice ' OK: tutors_public.test.sql (migration 004)';
end $$;

-- Uji migration 007: pelamar mengunggah dokumen ke penyimpanan privat; pendaftaran wajib melampirkannya; hanya admin yang membaca.
create schema th;
grant usage on schema th to anon, authenticated;

create or replace function th.msg(p_session text, p_data jsonb) returns text
language plpgsql as $f$
begin
  perform public.submit_tutor_application(p_session, p_data); return 'tidak ada error';
exception when others then return sqlerrm;
end $f$;

create or replace function th.base(p_app uuid, p_docs jsonb) returns jsonb
language sql as $f$
  select jsonb_build_object('application_id', p_app, 'documents', p_docs,
    'full_name','Alya Rahma','university','ITB','whatsapp','081234567890','email','alya@example.com',
    'subjects',jsonb_build_array('mtk'),'jenjang',jsonb_build_array('sma'))
$f$;

do $$
declare
  a1 uuid := '00000000-0000-0000-0000-0000000000a1';
  a2 uuid := '00000000-0000-0000-0000-0000000000a2';
  a3 uuid := '00000000-0000-0000-0000-0000000000a3';
  admin_id uuid := '00000000-0000-0000-0000-00000000ad01';
  m text; n int; ditolak boolean; docs jsonb; r jsonb;
begin
  grant execute on function th.msg(text, jsonb), th.base(uuid, jsonb) to anon, authenticated;
  insert into public.users (id, role) values (admin_id, 'admin');

  -- bucket privat dengan batas ukuran dan jenis berkas
  select count(*) into n from storage.buckets
   where id = 'tutor-applications' and public = false and file_size_limit = 3145728
     and allowed_mime_types @> array['image/jpeg','image/png','application/pdf'];
  if n <> 1 then raise exception 'GAGAL [bucket]: tutor-applications harus privat, 3 MB, jpeg/png/pdf'; end if;

  -- anon boleh mengunggah ke jalur yang benar, tetapi tidak membaca, mengubah, atau menghapus
  set local role anon;
  insert into storage.objects (bucket_id, name) values
    ('tutor-applications', a1 || '/transkrip.pdf'),
    ('tutor-applications', a1 || '/kartu_identitas_pelajar.jpg');
  ditolak := false;
  begin insert into storage.objects (bucket_id, name) values ('tutor-applications', 'sembarang.pdf');
  exception when others then ditolak := true; end;
  if not ditolak then reset role; raise exception 'GAGAL [jalur]: anon bisa unggah ke jalur sembarang'; end if;
  ditolak := false;
  begin insert into storage.objects (bucket_id, name) values ('tutor-applications', a1 || '/virus.exe');
  exception when others then ditolak := true; end;
  if not ditolak then reset role; raise exception 'GAGAL [ekstensi]: anon bisa unggah .exe'; end if;
  ditolak := false;
  begin insert into storage.objects (bucket_id, name) values ('documents', a1 || '/transkrip.pdf');
  exception when others then ditolak := true; end;
  if not ditolak then reset role; raise exception 'GAGAL [bucket lain]: anon bisa menulis ke bucket documents'; end if;
  select count(*) into n from storage.objects;
  if n <> 0 then reset role; raise exception 'GAGAL [baca]: anon melihat % objek', n; end if;
  delete from storage.objects;
  reset role;
  select count(*) into n from storage.objects;
  if n <> 2 then raise exception 'GAGAL [hapus]: anon menghapus objek (tersisa %)', n; end if;

  -- pendaftaran dengan dokumen lengkap
  docs := jsonb_build_object('transkrip', a1 || '/transkrip.pdf', 'kartu_identitas_pelajar', a1 || '/kartu_identitas_pelajar.jpg');
  set local role anon;
  r := public.submit_tutor_application('d-ok', th.base(a1, docs));
  reset role;
  select count(*) into n from public.tutor_applications where id = a1 and documents = docs;
  if n <> 1 then raise exception 'GAGAL [simpan]: id pelamar atau dokumen tidak tersimpan'; end if;

  -- validasi dokumen
  set local role anon;
  m := th.msg('d-1', th.base(a2, '{}'::jsonb));
  if m <> 'invalid_input:documents' then reset role; raise exception 'GAGAL [tanpa dokumen]: %', m; end if;
  m := th.msg('d-2', th.base(a2, jsonb_build_object('transkrip', a2 || '/transkrip.pdf')));
  if m <> 'invalid_input:documents' then reset role; raise exception 'GAGAL [kartu kurang]: %', m; end if;
  m := th.msg('d-3', th.base(a2, jsonb_build_object('transkrip', a2 || '/transkrip.pdf', 'kartu_identitas_pelajar', a2 || '/kartu_identitas_pelajar.jpg')));
  if m <> 'invalid_input:documents' then reset role; raise exception 'GAGAL [berkas belum diunggah]: %', m; end if;
  m := th.msg('d-4', th.base(a3, jsonb_build_object('transkrip', a1 || '/transkrip.pdf', 'kartu_identitas_pelajar', a1 || '/kartu_identitas_pelajar.jpg')));
  if m <> 'invalid_input:documents' then reset role; raise exception 'GAGAL [jalur milik pelamar lain]: %', m; end if;
  m := th.msg('d-5', th.base(a2, jsonb_build_object('transkrip', a2 || '/transkrip.pdf', 'kartu_identitas_pelajar', a2 || '/kartu_identitas_pelajar.jpg', 'ktp', a2 || '/ktp.pdf')));
  if m <> 'invalid_input:documents' then reset role; raise exception 'GAGAL [jenis dokumen asing]: %', m; end if;
  m := th.msg('d-6', (th.base(a2, docs)) - 'application_id');
  if m <> 'invalid_input:application_id' then reset role; raise exception 'GAGAL [tanpa id]: %', m; end if;
  m := th.msg('d-7', th.base(a1, docs) || '{"whatsapp":"081999999999"}');
  if m <> 'invalid_input:application_id' then reset role; raise exception 'GAGAL [id sudah dipakai]: %', m; end if;
  reset role;

  -- admin membaca, mengubah dokumen, dan menghapus berkasnya
  perform set_config('request.jwt.claim.sub', admin_id::text, true);
  set local role authenticated;
  select count(*) into n from storage.objects where bucket_id = 'tutor-applications';
  if n <> 2 then reset role; raise exception 'GAGAL [admin baca]: melihat % objek', n; end if;
  delete from storage.objects where bucket_id = 'tutor-applications' and name like a1 || '/%';
  update public.tutor_applications set documents = '{}'::jsonb where id = a1;
  reset role;
  select count(*) into n from storage.objects;
  if n <> 0 then raise exception 'GAGAL [admin hapus]: % objek tersisa', n; end if;
  select count(*) into n from public.tutor_applications where id = a1 and documents = '{}'::jsonb;
  if n <> 1 then raise exception 'GAGAL [admin ubah dokumen]'; end if;

  raise notice ' OK: application_documents.test.sql (migration 007)';
end $$;

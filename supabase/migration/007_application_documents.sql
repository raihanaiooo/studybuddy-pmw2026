-- ============================================================
-- Study Buddy — Migration 007: dokumen pelamar tutor
-- Pelamar mengunggah dokumen di formulir. Berkas masuk bucket privat; pengunjung hanya bisa mengunggah ke
-- jalur miliknya (tidak bisa melihat, mengganti, atau menghapus). Pendaftaran wajib melampirkan Transkrip dan
-- KTM/Kartu pelajar. Hanya admin yang membaca dan menghapus berkas, lalu akun tutor dibuat setelah lolos periksa.
-- Berlaku setelah migration 005.
-- ============================================================

alter table public.tutor_applications add column if not exists documents jsonb not null default '{}'::jsonb;
grant update (documents) on public.tutor_applications to authenticated;

-- ---------- Penyimpanan ----------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('tutor-applications', 'tutor-applications', false, 3145728, array['image/jpeg', 'image/png', 'application/pdf'])
on conflict (id) do update
  set public = false, file_size_limit = 3145728, allowed_mime_types = array['image/jpeg', 'image/png', 'application/pdf'];

drop policy if exists tutor_applications_upload on storage.objects;
create policy tutor_applications_upload on storage.objects
  for insert to anon, authenticated
  with check (
    bucket_id = 'tutor-applications'
    and name ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/(transkrip|kartu_identitas_pelajar|sertifikat_prestasi|sertifikat_bahasa)\.(jpg|jpeg|png|pdf)$'
  );

drop policy if exists tutor_applications_admin_read on storage.objects;
create policy tutor_applications_admin_read on storage.objects
  for select to authenticated
  using (bucket_id = 'tutor-applications'
         and exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin'));

drop policy if exists tutor_applications_admin_delete on storage.objects;
create policy tutor_applications_admin_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'tutor-applications'
         and exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin'));

-- ---------- RPC: submit_tutor_application (versi dengan dokumen) ----------
-- Tambahan kode kesalahan: invalid_input:application_id, invalid_input:documents.
create or replace function public.submit_tutor_application(p_client_session_id text, p_data jsonb)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  c_max_per_hour constant int := 3;
  c_subjects constant text[] := array['mtk', 'fis', 'kim', 'bio', 'ing'];
  c_jenjang  constant text[] := array['sd', 'smp', 'sma', 'kuliah'];
  c_doc_types constant text[] := array['transkrip', 'kartu_identitas_pelajar', 'sertifikat_prestasi', 'sertifikat_bahasa'];
  c_uuid_re  constant text := '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
  v_open     record;
  v_name     text;
  v_univ     text;
  v_major    text;
  v_exp      text;
  v_wa       text;
  v_email    text;
  v_semester int;
  v_subjects text[];
  v_jenjang  text[];
  v_id       uuid;
  v_docs     jsonb;
  v_key      text;
  v_path     text;
begin
  if p_client_session_id is null or btrim(p_client_session_id) = '' or length(p_client_session_id) > 100 then
    raise exception 'invalid_session';
  end if;
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'invalid_data';
  end if;

  select is_active, start_date, end_date into v_open from oprec_info order by created_at desc nulls last limit 1;
  if found and (not v_open.is_active
                or (v_open.start_date is not null and current_date < v_open.start_date)
                or (v_open.end_date   is not null and current_date > v_open.end_date)) then
    raise exception 'oprec_closed';
  end if;

  if (select count(*) from tutor_applications
       where client_session_id = p_client_session_id and created_at > now() - interval '1 hour') >= c_max_per_hour then
    raise exception 'rate_limited';
  end if;

  if jsonb_typeof(p_data -> 'full_name') is distinct from 'string' then raise exception 'invalid_input:full_name'; end if;
  v_name := btrim(p_data ->> 'full_name');
  if length(v_name) < 2 or length(v_name) > 100 then raise exception 'invalid_input:full_name'; end if;

  if jsonb_typeof(p_data -> 'university') is distinct from 'string' then raise exception 'invalid_input:university'; end if;
  v_univ := btrim(p_data ->> 'university');
  if length(v_univ) < 2 or length(v_univ) > 100 then raise exception 'invalid_input:university'; end if;

  if p_data ? 'major' and jsonb_typeof(p_data -> 'major') <> 'null' then
    if jsonb_typeof(p_data -> 'major') <> 'string' or length(btrim(p_data ->> 'major')) > 100 then raise exception 'invalid_input:major'; end if;
    v_major := nullif(btrim(p_data ->> 'major'), '');
  end if;

  if p_data ? 'semester' and jsonb_typeof(p_data -> 'semester') <> 'null' then
    if jsonb_typeof(p_data -> 'semester') <> 'number' or (p_data ->> 'semester') !~ '^[0-9]{1,2}$'
       or (p_data ->> 'semester')::int not between 1 and 14 then raise exception 'invalid_input:semester'; end if;
    v_semester := (p_data ->> 'semester')::int;
  end if;

  if jsonb_typeof(p_data -> 'whatsapp') is distinct from 'string' then raise exception 'invalid_input:whatsapp'; end if;
  v_wa := regexp_replace(p_data ->> 'whatsapp', '[\s\-\.\(\)]', '', 'g');
  v_wa := regexp_replace(v_wa, '^\+', '');
  if v_wa ~ '^0' then v_wa := '62' || substr(v_wa, 2); end if;
  if v_wa !~ '^62[0-9]{8,13}$' then raise exception 'invalid_input:whatsapp'; end if;

  if jsonb_typeof(p_data -> 'email') is distinct from 'string' then raise exception 'invalid_input:email'; end if;
  v_email := lower(btrim(p_data ->> 'email'));
  if length(v_email) > 150 or v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then raise exception 'invalid_input:email'; end if;

  if jsonb_typeof(p_data -> 'subjects') is distinct from 'array' then raise exception 'invalid_input:subjects'; end if;
  select coalesce(array_agg(distinct v order by v), '{}') into v_subjects from jsonb_array_elements_text(p_data -> 'subjects') v;
  if cardinality(v_subjects) = 0 or not (v_subjects <@ c_subjects) then raise exception 'invalid_input:subjects'; end if;

  if jsonb_typeof(p_data -> 'jenjang') is distinct from 'array' then raise exception 'invalid_input:jenjang'; end if;
  select coalesce(array_agg(distinct v order by v), '{}') into v_jenjang from jsonb_array_elements_text(p_data -> 'jenjang') v;
  if cardinality(v_jenjang) = 0 or not (v_jenjang <@ c_jenjang) then raise exception 'invalid_input:jenjang'; end if;

  if p_data ? 'experience' and jsonb_typeof(p_data -> 'experience') <> 'null' then
    if jsonb_typeof(p_data -> 'experience') <> 'string' or length(p_data ->> 'experience') > 1000 then raise exception 'invalid_input:experience'; end if;
    v_exp := nullif(btrim(p_data ->> 'experience'), '');
  end if;

  -- id pelamar dibuat di browser (sebelum unggah) dan tidak boleh sudah dipakai
  if jsonb_typeof(p_data -> 'application_id') is distinct from 'string'
     or (p_data ->> 'application_id') !~* c_uuid_re then
    raise exception 'invalid_input:application_id';
  end if;
  v_id := (p_data ->> 'application_id')::uuid;
  if exists (select 1 from tutor_applications where id = v_id) then raise exception 'invalid_input:application_id'; end if;

  -- dokumen: hanya jenis yang dikenal, Transkrip dan KTM wajib, tiap berkas ada di jalur milik pelamar ini
  if jsonb_typeof(p_data -> 'documents') is distinct from 'object' then raise exception 'invalid_input:documents'; end if;
  v_docs := p_data -> 'documents';
  if not (v_docs ? 'transkrip' and v_docs ? 'kartu_identitas_pelajar') then raise exception 'invalid_input:documents'; end if;
  for v_key in select jsonb_object_keys(v_docs) loop
    if not (v_key = any (c_doc_types)) or jsonb_typeof(v_docs -> v_key) <> 'string' then raise exception 'invalid_input:documents'; end if;
    v_path := v_docs ->> v_key;
    if v_path !~ ('^' || v_id::text || '/' || v_key || '\.(jpg|jpeg|png|pdf)$')
       or not exists (select 1 from storage.objects where bucket_id = 'tutor-applications' and name = v_path) then
      raise exception 'invalid_input:documents';
    end if;
  end loop;

  if exists (select 1 from tutor_applications where whatsapp = v_wa and status = 'baru' and created_at > now() - interval '7 days') then
    raise exception 'duplicate';
  end if;

  insert into tutor_applications (id, client_session_id, full_name, university, major, semester, whatsapp, email, subjects, jenjang, experience, documents)
  values (v_id, p_client_session_id, v_name, v_univ, v_major, v_semester, v_wa, v_email, v_subjects, v_jenjang, v_exp, v_docs);

  return jsonb_build_object('application_id', v_id);
end $$;

revoke all on function public.submit_tutor_application(text, jsonb) from public;
grant execute on function public.submit_tutor_application(text, jsonb) to anon, authenticated;

-- ============================================================
-- Study Buddy — Migration 005: pendaftaran tutor dari landing page
-- Pelamar mengisi form di web; data masuk tabel tertutup lewat RPC bervalidasi.
-- Admin membaca dan memproses di panel (tab Pelamar). Tidak ada upload dokumen di tahap ini.
-- ============================================================

create table public.tutor_applications (
  id                uuid primary key default gen_random_uuid(),
  client_session_id text not null,
  full_name         text not null,
  university        text not null,
  major             text,
  semester          int check (semester between 1 and 14),
  whatsapp          text not null,
  email             text not null,
  subjects          text[] not null,
  jenjang           text[] not null,
  experience        text,
  status            text not null default 'baru' check (status in ('baru', 'diterima', 'ditolak')),
  admin_note        text,
  handled_by        uuid,
  handled_at        timestamptz,
  created_at        timestamptz not null default now()
);

create index tutor_applications_session_idx on public.tutor_applications (client_session_id, created_at desc);
create index tutor_applications_wa_idx      on public.tutor_applications (whatsapp, created_at desc);

-- Tertutup untuk pengunjung. Admin (users.role = 'admin') membaca dan mengubah status.
alter table public.tutor_applications enable row level security;
revoke all on public.tutor_applications from anon, authenticated;
grant select on public.tutor_applications to authenticated;
grant update (status, admin_note, handled_by, handled_at) on public.tutor_applications to authenticated;

create policy tutor_applications_admin_read on public.tutor_applications
  for select to authenticated
  using (exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin'));

create policy tutor_applications_admin_update on public.tutor_applications
  for update to authenticated
  using (exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin'))
  with check (exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin'));

-- ---------- RPC: submit_tutor_application ----------
-- Kode kesalahan: invalid_session, invalid_data, oprec_closed, rate_limited, invalid_input:<kolom>, duplicate.
create or replace function public.submit_tutor_application(p_client_session_id text, p_data jsonb)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  c_max_per_hour constant int := 3;
  c_subjects constant text[] := array['mtk', 'fis', 'kim', 'bio', 'ing'];
  c_jenjang  constant text[] := array['sd', 'smp', 'sma', 'kuliah'];
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
begin
  if p_client_session_id is null or btrim(p_client_session_id) = '' or length(p_client_session_id) > 100 then
    raise exception 'invalid_session';
  end if;
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'invalid_data';
  end if;

  -- Oprec: tanpa baris = terbuka; baris terbaru menentukan (aktif dan dalam rentang tanggal).
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

  -- Validasi
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

  if exists (select 1 from tutor_applications where whatsapp = v_wa and status = 'baru' and created_at > now() - interval '7 days') then
    raise exception 'duplicate';
  end if;

  insert into tutor_applications (client_session_id, full_name, university, major, semester, whatsapp, email, subjects, jenjang, experience)
  values (p_client_session_id, v_name, v_univ, v_major, v_semester, v_wa, v_email, v_subjects, v_jenjang, v_exp)
  returning id into v_id;

  return jsonb_build_object('application_id', v_id);
end $$;

revoke all on function public.submit_tutor_application(text, jsonb) from public;
grant execute on function public.submit_tutor_application(text, jsonb) to anon, authenticated;

-- Stub tambahan untuk menguji migration 009-011 (order, sesi, gaji). BUKAN migration.
-- Dimuat setelah 00_stubs.sql. Meniru bentuk tabel di database Supabase nyata (hasil inspect-schema.sql).

alter table public.users drop constraint if exists users_role_check;
alter table public.users add constraint users_role_check check (role in ('buddy', 'tutor', 'admin'));
alter table public.users add column if not exists full_name text;
alter table public.users add column if not exists phone text;

alter table public.packages add column if not exists session_count int not null default 4;
alter table public.packages add column if not exists validity_days int not null default 30;
alter table public.packages add column if not exists reschedule_quota int not null default 0;
alter table public.packages add column if not exists is_refundable boolean not null default true;
alter table public.packages add column if not exists description text;
alter table public.packages add column if not exists max_tutors int not null default 1;

alter table public.tutors add column if not exists created_at timestamptz default now();
alter table public.tutors add column if not exists is_online boolean default false;
alter table public.tutors add column if not exists last_seen timestamptz;
alter table public.tutors alter column user_id set not null;   -- seperti database nyata (migration 010 melonggarkannya)

create or replace function public.is_admin() returns boolean language plpgsql security definer as $$
begin return exists (select 1 from public.users where id = auth.uid() and role = 'admin'); end $$;

create table public.tutor_applications (
  id uuid primary key default gen_random_uuid(),
  client_session_id text not null default 'x',
  full_name text not null,
  university text not null default 'UI',
  major text, semester int,
  whatsapp text not null default '62811',
  email text not null default 'a@x.id',
  subjects text[] not null default '{mtk}',
  jenjang text[] not null default '{sma}',
  experience text,
  status text not null default 'baru' check (status in ('baru','diterima','ditolak')),
  admin_note text, handled_by uuid, handled_at timestamptz,
  created_at timestamptz not null default now(),
  documents jsonb not null default '{}'::jsonb
);

create table public.tutor_documents (
  id uuid primary key default gen_random_uuid(),
  tutor_id uuid not null references public.tutors(id) on delete cascade,
  jenis_dokumen text not null,
  label text, file_url text,
  status text not null default 'belum_upload',
  rejection_note text, uploaded_at timestamptz, created_at timestamptz default now()
);

-- Meniru fn_seed_tutor_documents: tutor baru langsung punya baris dokumen kosong.
create or replace function public.fn_seed_tutor_documents() returns trigger language plpgsql as $$
begin
  insert into public.tutor_documents (tutor_id, jenis_dokumen, label)
  select new.id, j, j from unnest(array['transkrip','kartu_identitas_pelajar','sertifikat_prestasi','sertifikat_bahasa']) j;
  return new;
end $$;
create trigger trg_seed_tutor_documents after insert on public.tutors for each row execute function public.fn_seed_tutor_documents();

create table public.payroll_records (
  id uuid primary key default gen_random_uuid(),
  tutor_id uuid not null references public.tutors(id) on delete cascade,
  period_month int not null, period_year int not null,
  total_sessions int not null default 0,
  total_gross numeric not null default 0,
  total_commission numeric not null default 0,
  status text not null default 'pending' check (status in ('pending','paid')),
  paid_at timestamptz, paid_by uuid, notes text,
  created_at timestamptz default now(),
  unique (tutor_id, period_month, period_year)
);
alter table public.payroll_records enable row level security;
create policy "Admin full access payroll" on public.payroll_records for all to public using (public.is_admin());

-- ---------- pembantu uji ----------
create schema if not exists th;
grant usage on schema th to anon, authenticated;
-- Menjalankan satu pernyataan sebagai pengguna tertentu; mengembalikan 'ok' atau pesan galat.
create or replace function th.as_user(p_role text, p_uid uuid, p_sql text) returns text
language plpgsql as $f$
begin
  perform set_config('request.jwt.claim.sub', coalesce(p_uid::text, ''), true);
  execute format('set local role %I', p_role);
  begin execute p_sql; exception when others then reset role; return sqlerrm; end;
  reset role; return 'ok';
end $f$;
-- Hasil `select count(*)` (p_sql) sebagai pengguna tertentu; -1 bila galat.
create or replace function th.count_as(p_role text, p_uid uuid, p_sql text) returns bigint
language plpgsql as $f$
declare n bigint;
begin
  perform set_config('request.jwt.claim.sub', coalesce(p_uid::text, ''), true);
  execute format('set local role %I', p_role);
  begin execute p_sql into n; exception when others then reset role; return -1; end;
  reset role; return n;
end $f$;
grant execute on function th.as_user(text, uuid, text), th.count_as(text, uuid, text) to anon, authenticated;

-- Stub minimal untuk menguji migration 002 di PostgreSQL biasa (tanpa Supabase).
-- BUKAN migration: jangan dijalankan di database nyata.
-- Meniru hal-hal Supabase yang dipakai fitur diagnostic: role anon/authenticated,
-- auth.uid(), hak default ke role itu di schema public, dan tabel yang dibaca fitur ini.

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
end $$;

create schema if not exists auth;
create or replace function auth.uid() returns uuid
  language sql stable
  as $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;

grant usage on schema public, auth to anon, authenticated;
-- Supabase memberi hak penuh ke anon/authenticated pada tabel baru; RLS yang membatasi.
alter default privileges in schema public grant all on tables to anon, authenticated;
alter default privileges in schema public grant execute on functions to anon, authenticated;

create table public.users (
  id   uuid primary key,
  role text not null check (role in ('customer', 'tutor', 'management', 'admin'))
);

create table public.tutors (
  id                  uuid primary key default gen_random_uuid(),
  full_name           text not null,
  subjects            text[] default '{}',
  verification_status text not null default 'pending',
  is_featured         boolean default false,
  rating              numeric(3,1) default 0,
  university          text
);  -- sengaja tanpa avatar_url: tabel tutors di Supabase nyata tidak punya kolom itu

create table public.packages (
  id           uuid primary key default gen_random_uuid(),
  package_name text not null,
  price        numeric not null default 0,
  is_active    boolean not null default true
);

create table public.manual_orders (
  id       uuid primary key default gen_random_uuid(),
  name     text,
  whatsapp text,
  subject  text,
  jenjang  text,
  status   text default 'pending'
);

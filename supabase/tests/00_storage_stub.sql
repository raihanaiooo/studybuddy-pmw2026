-- Tiruan penyimpanan Supabase untuk uji (BUKAN migration). Dimuat setelah 00_stubs.sql.
create schema if not exists storage;
create table storage.buckets (
  id                 text primary key,
  name               text not null,
  public             boolean default false,
  file_size_limit    bigint,
  allowed_mime_types text[]
);
create table storage.objects (
  id         uuid primary key default gen_random_uuid(),
  bucket_id  text references storage.buckets (id),
  name       text,
  created_at timestamptz default now()
);
alter table storage.objects enable row level security;
grant usage on schema storage to anon, authenticated;
grant all on storage.objects, storage.buckets to anon, authenticated;
-- Bucket yang sudah ada di Supabase nyata (dokumen tutor aktif)
insert into storage.buckets (id, name, public) values ('documents', 'documents', false);

-- Uji migration 008: perapat hak akses. Meniru policy nyata (dari audit) lalu memastikan celahnya tertutup
-- dan alur sah (mobile, admin web, edge function) tetap jalan.
-- Jalankan: run-each.sh hak_akses.test.sql (tanpa migrasi lain; berkas ini memuat 008 sendiri).

-- ---------- tabel yang tidak ada di stub ----------
alter table public.users drop constraint if exists users_role_check;
alter table public.users add constraint users_role_check check (role in ('buddy', 'tutor', 'admin'));
alter table public.users add column full_name text, add column phone text, add column email text,
  add column fcm_token text, add column created_at timestamptz default now();
alter table public.tutors add column total_sessions int default 0, add column total_reviews int default 0,
  add column is_online boolean default false, add column last_seen timestamptz;
alter table public.tutors alter column rating type numeric;
alter table public.packages add column session_count int not null default 4, add column validity_days int not null default 30;

create table public.tokens (
  id uuid primary key default gen_random_uuid(), buddy_id uuid not null, package_id uuid not null references public.packages(id),
  status text not null check (status in ('active','used','expired')), active_date timestamptz not null default now(),
  expiry_date timestamptz not null, sessions_remaining int not null check (sessions_remaining >= 0));
create table public.bookings (
  id uuid primary key default gen_random_uuid(), customer_id uuid not null, tutor_id uuid not null,
  session_time timestamptz not null, duration_minutes int not null default 60, status text not null default 'pending', notes text);
create table public.sessions (id uuid primary key default gen_random_uuid(), booking_id uuid not null references public.bookings(id));
create table public.tutor_documents (
  id uuid primary key default gen_random_uuid(), tutor_id uuid not null, jenis_dokumen text not null,
  file_url text, status text not null default 'belum_upload', rejection_note text);
create table public.reschedules (id uuid primary key default gen_random_uuid(), booking_id uuid, status text not null default 'menunggu');
create table public.complaints (id uuid primary key default gen_random_uuid(), booking_id uuid, status text not null default 'pending');
create table public.payments (id uuid primary key default gen_random_uuid(), booking_id uuid not null);
create table public.refunds (
  id uuid primary key default gen_random_uuid(), payment_id uuid not null, booking_id uuid not null,
  requested_by uuid not null, status text not null default 'pending');
alter table public.reviews add column session_id uuid;

create or replace function public.is_admin() returns boolean language plpgsql security definer as $$
begin return exists (select 1 from public.users where id = auth.uid() and role = 'admin'); end $$;

create view public.tutors_public as
  select id, full_name, university, bio, subjects, jenjang_diajar, price_per_hour, rating, featured_match_percent, featured_reason
  from public.tutors where verification_status = 'verified' and is_featured;
grant select on public.tutors_public to anon, authenticated;

-- ---------- policy seperti di database nyata (sebelum perbaikan) ----------
alter table public.users enable row level security;
create policy "Admin full access users" on public.users for all to public using (public.is_admin());
create policy "Allow insert users from frontend" on public.users for insert to public with check (true);
create policy users_insert_self on public.users for insert to public with check (id = auth.uid());
create policy users_select_self_or_admin on public.users for select to public using (id = auth.uid() or public.is_admin());
create policy users_update_self on public.users for update to public using (id = auth.uid()) with check (id = auth.uid());

alter table public.tutors enable row level security;
create policy "Admin full access tutors" on public.tutors for all to public using (public.is_admin());
create policy "Allow insert tutors from frontend" on public.tutors for insert to public with check (true);
create policy tutors_insert_self on public.tutors for insert to public with check (user_id = auth.uid());
create policy tutors_select_all on public.tutors for select to public using (true);
create policy tutors_update_self on public.tutors for update to public using (user_id = auth.uid()) with check (user_id = auth.uid());

alter table public.tokens enable row level security;
create policy tokens_insert_owner on public.tokens for insert to public with check (buddy_id = auth.uid() or public.is_admin());
create policy tokens_select_owner on public.tokens for select to public using (buddy_id = auth.uid() or public.is_admin());
create policy tokens_update_owner on public.tokens for update to public using (buddy_id = auth.uid() or public.is_admin()) with check (buddy_id = auth.uid() or public.is_admin());

alter table public.bookings enable row level security;
create policy bookings_all_involved on public.bookings for all to public
  using (customer_id = auth.uid() or tutor_id in (select id from public.tutors where user_id = auth.uid()) or public.is_admin())
  with check (customer_id = auth.uid() or tutor_id in (select id from public.tutors where user_id = auth.uid()) or public.is_admin());

alter table public.tutor_documents enable row level security;
create policy docs_all_owner on public.tutor_documents for all to public
  using (tutor_id in (select id from public.tutors where user_id = auth.uid()) or public.is_admin())
  with check (tutor_id in (select id from public.tutors where user_id = auth.uid()) or public.is_admin());

alter table public.reschedules enable row level security;
create policy reschedules_all on public.reschedules for all to public using (true) with check (true);
alter table public.complaints enable row level security;
create policy complaints_all on public.complaints for all to public using (true) with check (true);

alter table public.manual_orders enable row level security;
create policy "Public insert manual_orders" on public.manual_orders for insert to public with check (true);
create policy public_insert_manual_orders on public.manual_orders for insert to public with check (true);

alter table public.sessions enable row level security;
create policy sessions_all on public.sessions for all to public using (true) with check (true);
alter table public.payments enable row level security;
create policy payments_all on public.payments for all to public using (true) with check (true);
alter table public.refunds enable row level security;
create policy refunds_insert_self on public.refunds for insert to public with check (requested_by = auth.uid());
alter table public.reviews enable row level security;
create policy reviews_insert_buddy on public.reviews for insert to public with check (customer_id = auth.uid());

create table auth.users (id uuid primary key default gen_random_uuid(), email text, raw_user_meta_data jsonb);
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path to 'public' as $$
begin
  insert into public.users (id, email, full_name, role)
  values (new.id, new.email, new.raw_user_meta_data ->> 'full_name', coalesce(new.raw_user_meta_data ->> 'role', 'tutor'));
  return new;
end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

-- ---------- terapkan perbaikan ----------
\i ../migration/008_hak_akses.sql

-- ---------- uji ----------
create schema th;
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

do $$
declare
  admin_id uuid := '00000000-0000-0000-0000-00000000ad01';
  buddy_id uuid := '00000000-0000-0000-0000-0000000000b1';
  buddy2_id uuid := '00000000-0000-0000-0000-0000000000b2';
  tutor_user uuid := '00000000-0000-0000-0000-0000000000c1';
  tutor_id uuid := '00000000-0000-0000-0000-0000000000d1';
  pkg uuid := '00000000-0000-0000-0000-0000000000e1';
  bk uuid := '00000000-0000-0000-0000-0000000000f1';
  tok uuid := '00000000-0000-0000-0000-0000000000a1';
  doc uuid := '00000000-0000-0000-0000-0000000000a2';
  m text; n int; v text;
begin
  grant execute on function th.as_user(text, uuid, text) to anon, authenticated;
  insert into public.users (id, role, full_name) values (admin_id, 'admin', 'Admin'), (buddy_id, 'buddy', 'Buddy'), (buddy2_id, 'buddy', 'Buddy2'), (tutor_user, 'tutor', 'Tutor');
  insert into public.tutors (id, user_id, full_name, verification_status, is_featured, price_per_hour, rating) values (tutor_id, tutor_user, 'Tutor', 'pending', false, 50000, 0);
  insert into public.packages (id, package_name, price, is_active, session_count, validity_days) values (pkg, 'Paket 4', 100000, true, 4, 30);
  insert into public.bookings (id, customer_id, tutor_id, session_time) values (bk, buddy_id, tutor_id, now() + interval '1 day');
  insert into public.tutor_documents (id, tutor_id, jenis_dokumen) values (doc, tutor_id, 'ktp');

  -- 0. pendaftaran Auth: peran dari data pendaftaran disaring
  insert into auth.users (id, email, raw_user_meta_data) values
    ('00000000-0000-0000-0000-0000000000b9', 'a@x.id', '{"role":"admin","full_name":"Curang"}'),
    ('00000000-0000-0000-0000-0000000000ba', 'b@x.id', '{"full_name":"Tanpa Peran"}'),
    ('00000000-0000-0000-0000-0000000000bb', 'c@x.id', '{"role":"tutor","full_name":"Tutor Sah"}'),
    ('00000000-0000-0000-0000-0000000000bc', 'd@x.id', '{"role":"buddy"}');
  select string_agg(role, ',' order by email) into v from public.users where email in ('a@x.id','b@x.id','c@x.id','d@x.id');
  if v <> 'buddy,buddy,tutor,buddy' then raise exception 'GAGAL [signUp role]: %', v; end if;

  -- 1. pengguna tidak bisa menjadikan dirinya admin; profil biasa tetap bisa diubah
  m := th.as_user('authenticated', buddy_id, format('update public.users set role = ''admin'' where id = %L', buddy_id));
  if m <> 'kolom_dilindungi:users' then raise exception 'GAGAL [role]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('update public.users set full_name = ''Nama Baru'', phone = ''0812'', fcm_token = ''x'' where id = %L', buddy_id));
  if m <> 'ok' then raise exception 'GAGAL [profil sah]: %', m; end if;
  if not exists (select 1 from public.users where id = buddy_id and role = 'buddy' and full_name = 'Nama Baru') then raise exception 'GAGAL [profil tersimpan]'; end if;

  -- 2. pendaftaran baru: peran admin dipaksa jadi buddy; tutor tetap boleh
  m := th.as_user('authenticated', gen_random_uuid(), format('insert into public.users (id, role, full_name) values (%L, ''admin'', ''Curang'')', '00000000-0000-0000-0000-0000000000aa'));
  if m <> 'ok' and m not like '%row-level security%' then raise exception 'GAGAL [daftar admin] pesan tak terduga: %', m; end if;
  m := th.as_user('authenticated', '00000000-0000-0000-0000-0000000000aa', format('insert into public.users (id, role, full_name) values (%L, ''admin'', ''Curang'')', '00000000-0000-0000-0000-0000000000aa'));
  if m <> 'ok' then raise exception 'GAGAL [daftar admin ditolak keras]: %', m; end if;
  select role into v from public.users where id = '00000000-0000-0000-0000-0000000000aa';
  if v is distinct from 'buddy' then raise exception 'GAGAL [role dipaksa]: role tersimpan %', v; end if;
  m := th.as_user('authenticated', '00000000-0000-0000-0000-0000000000ab', format('insert into public.users (id, role, full_name) values (%L, ''tutor'', ''Calon Tutor'')', '00000000-0000-0000-0000-0000000000ab'));
  if m <> 'ok' then raise exception 'GAGAL [daftar tutor]: %', m; end if;
  -- anon (konfirmasi email aktif): boleh sebagai buddy, tidak lewat kolom lain
  m := th.as_user('anon', null, format('insert into public.users (id, role, full_name) values (%L, ''buddy'', ''Anon'')', '00000000-0000-0000-0000-0000000000ac'));
  if m <> 'ok' then raise exception 'GAGAL [anon daftar buddy]: %', m; end if;
  m := th.as_user('anon', null, format('update public.users set full_name = ''x'' where id = %L', buddy_id));
  if m not like 'permission denied%' then raise exception 'GAGAL [anon update users]: %', m; end if;

  -- 3. tutor tidak bisa memverifikasi dirinya; kolom sah (profil, status online) tetap bisa
  m := th.as_user('authenticated', tutor_user, format('update public.tutors set verification_status = ''verified'' where id = %L', tutor_id));
  if m <> 'kolom_dilindungi:tutors' then raise exception 'GAGAL [self-verify]: %', m; end if;
  m := th.as_user('authenticated', tutor_user, format('update public.tutors set is_featured = true where id = %L', tutor_id));
  if m <> 'kolom_dilindungi:tutors' then raise exception 'GAGAL [self-feature]: %', m; end if;
  m := th.as_user('authenticated', tutor_user, format('update public.tutors set price_per_hour = 1 where id = %L', tutor_id));
  if m <> 'kolom_dilindungi:tutors' then raise exception 'GAGAL [harga]: %', m; end if;
  m := th.as_user('authenticated', tutor_user, format('update public.tutors set bio = ''Halo'', is_online = true, last_seen = now() where id = %L', tutor_id));
  if m <> 'ok' then raise exception 'GAGAL [profil tutor sah]: %', m; end if;
  -- tutor baru yang mendaftar sendiri selalu pending dan bukan unggulan
  m := th.as_user('authenticated', buddy2_id, format('insert into public.tutors (user_id, full_name, verification_status, is_featured, price_per_hour, rating) values (%L, ''Palsu'', ''verified'', true, 1, 5)', buddy2_id));
  if m <> 'ok' then raise exception 'GAGAL [daftar tutor sendiri]: %', m; end if;
  select verification_status || is_featured::text || rating::text into v from public.tutors where user_id = buddy2_id;
  if v <> 'pendingfalse0' then raise exception 'GAGAL [tutor baru dipaksa pending]: %', v; end if;
  -- admin web dan edge function tetap boleh
  m := th.as_user('authenticated', admin_id, format('update public.tutors set verification_status = ''verified'', is_featured = true where id = %L', tutor_id));
  if m <> 'ok' then raise exception 'GAGAL [admin verifikasi]: %', m; end if;
  m := th.as_user('postgres', null, format('update public.tutors set price_per_hour = 60000 where id = %L', tutor_id));
  if m <> 'ok' then raise exception 'GAGAL [postgres/service]: %', m; end if;

  -- 4. dokumen: tutor hanya bisa mengirim untuk diperiksa
  m := th.as_user('authenticated', tutor_user, format('update public.tutor_documents set status = ''terverifikasi'' where id = %L', doc));
  if m <> 'kolom_dilindungi:tutor_documents' then raise exception 'GAGAL [self-verify dokumen]: %', m; end if;
  m := th.as_user('authenticated', tutor_user, format('update public.tutor_documents set file_url = ''u/1.pdf'', status = ''menunggu_verifikasi'' where id = %L', doc));
  if m <> 'ok' then raise exception 'GAGAL [unggah dokumen sah]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format('update public.tutor_documents set status = ''terverifikasi'' where id = %L', doc));
  if m <> 'ok' then raise exception 'GAGAL [admin nilai dokumen]: %', m; end if;

  -- 5. booking: customer dan tutor tidak bisa menukar pihak atau jadwal, tapi bisa mengubah status
  m := th.as_user('authenticated', buddy_id, format('update public.bookings set session_time = now() where id = %L', bk));
  if m <> 'kolom_dilindungi:bookings' then raise exception 'GAGAL [jadwal booking]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('update public.bookings set tutor_id = gen_random_uuid() where id = %L', bk));
  if m <> 'kolom_dilindungi:bookings' then raise exception 'GAGAL [tukar tutor]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('update public.bookings set status = ''cancelled'' where id = %L', bk));
  if m <> 'ok' then raise exception 'GAGAL [ubah status sah]: %', m; end if;
  m := th.as_user('authenticated', admin_id, format('update public.bookings set session_time = now() + interval ''2 days'' where id = %L', bk));
  if m <> 'ok' then raise exception 'GAGAL [admin reschedule]: %', m; end if;

  -- 6. token: sesuai paket, sisa hanya turun, tidak hidup lagi
  m := th.as_user('authenticated', buddy_id, format('insert into public.tokens (id, buddy_id, package_id, status, expiry_date, sessions_remaining) values (%L, %L, %L, ''active'', now() + interval ''30 days'', 999)', tok, buddy_id, pkg));
  if m <> 'token_tidak_valid' then raise exception 'GAGAL [token 999 sesi]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('insert into public.tokens (id, buddy_id, package_id, status, expiry_date, sessions_remaining) values (%L, %L, %L, ''active'', now() + interval ''400 days'', 4)', tok, buddy_id, pkg));
  if m <> 'token_tidak_valid' then raise exception 'GAGAL [token kedaluwarsa panjang]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('insert into public.tokens (id, buddy_id, package_id, status, expiry_date, sessions_remaining) values (%L, %L, %L, ''active'', now() + interval ''30 days'', 4)', tok, buddy_id, pkg));
  if m <> 'ok' then raise exception 'GAGAL [beli token sah]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('update public.tokens set sessions_remaining = 3 where id = %L', tok));
  if m <> 'ok' then raise exception 'GAGAL [pakai token sah]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('update public.tokens set sessions_remaining = 10 where id = %L', tok));
  if m <> 'kolom_dilindungi:tokens' then raise exception 'GAGAL [tambah sisa sesi]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('update public.tokens set expiry_date = now() + interval ''900 days'' where id = %L', tok));
  if m <> 'kolom_dilindungi:tokens' then raise exception 'GAGAL [perpanjang token]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('update public.tokens set status = ''used'', sessions_remaining = 0 where id = %L', tok));
  if m <> 'ok' then raise exception 'GAGAL [token habis sah]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('update public.tokens set status = ''active'' where id = %L', tok));
  if m <> 'kolom_dilindungi:tokens' then raise exception 'GAGAL [hidupkan token habis]: %', m; end if;

  -- 7. keputusan reschedule dan keluhan tidak boleh diisi pengaju
  m := th.as_user('authenticated', buddy_id, format('insert into public.reschedules (booking_id, status) values (%L, ''disetujui'')', bk));
  if m <> 'status_tidak_valid' then raise exception 'GAGAL [reschedule langsung disetujui]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('insert into public.reschedules (booking_id, status) values (%L, ''menunggu'')', bk));
  if m <> 'ok' then raise exception 'GAGAL [ajukan reschedule sah]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('insert into public.complaints (booking_id, status) values (%L, ''resolved'')', bk));
  if m <> 'status_tidak_valid' then raise exception 'GAGAL [keluhan langsung selesai]: %', m; end if;

  -- 8. refund hanya untuk pembayaran sendiri
  insert into public.payments (id, booking_id) values ('00000000-0000-0000-0000-0000000000a3', bk);
  m := th.as_user('authenticated', buddy2_id, format('insert into public.refunds (payment_id, booking_id, requested_by) values (%L, %L, %L)', '00000000-0000-0000-0000-0000000000a3', bk, buddy2_id));
  if m not like '%row-level security%' then raise exception 'GAGAL [refund milik orang lain]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, format('insert into public.refunds (payment_id, booking_id, requested_by) values (%L, %L, %L)', '00000000-0000-0000-0000-0000000000a3', bk, buddy_id));
  if m <> 'ok' then raise exception 'GAGAL [refund sendiri]: %', m; end if;

  -- 9. view tutors_public hanya bisa dibaca; pengunjung tidak bisa mengubah atau menghapus
  m := th.as_user('anon', null, 'update public.tutors_public set price_per_hour = 1');
  if m not like 'permission denied%' then raise exception 'GAGAL [anon update view]: %', m; end if;
  m := th.as_user('anon', null, 'delete from public.tutors_public');
  if m not like 'permission denied%' then raise exception 'GAGAL [anon hapus lewat view]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, 'delete from public.tutors_public');
  if m not like 'permission denied%' then raise exception 'GAGAL [authenticated hapus lewat view]: %', m; end if;
  m := th.as_user('anon', null, 'select count(*) from public.tutors_public');
  if m <> 'ok' then raise exception 'GAGAL [anon baca view]: %', m; end if;
  select count(*) into n from public.tutors where id = tutor_id;
  if n <> 1 then raise exception 'GAGAL [tutor masih ada]'; end if;

  -- 10. tulis langsung oleh pengunjung tertutup
  m := th.as_user('anon', null, 'insert into public.manual_orders (name, whatsapp, subject, jenjang) values (''x'', ''62800000000'', ''y'', ''z'')');
  if m not like 'permission denied%' then raise exception 'GAGAL [anon order langsung]: %', m; end if;
  m := th.as_user('anon', null, 'truncate public.tokens');
  if m not like 'permission denied%' then raise exception 'GAGAL [anon truncate]: %', m; end if;
  m := th.as_user('authenticated', buddy_id, 'truncate public.tokens');
  if m not like 'permission denied%' then raise exception 'GAGAL [authenticated truncate]: %', m; end if;

  raise notice ' OK: hak_akses.test.sql (migration 008)';
end $$;

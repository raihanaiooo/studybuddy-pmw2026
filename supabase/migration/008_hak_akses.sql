-- Study Buddy — Migration 008: perapat hak akses (hasil audit 2026-11-24)
-- Menutup: (1) pengguna menjadikan dirinya admin, (2) tutor memverifikasi dirinya sendiri,
-- (3) view tutors_public bisa diubah/dihapus pengunjung, (4) token dan booking diubah bebas,
-- (5) policy insert "true" yang tersisa. Aplikasi mobile yang sekarang tetap berjalan.
-- Catatan: token masih bisa dibuat pengguna sendiri sampai gateway pembayaran sungguhan ada,
-- tetapi sekarang dibatasi sesuai paket (lihat guard_tokens).

begin;

-- ============================================================
-- Pembantu
-- ============================================================

-- Dipakai policy lama; tanpa search_path tetap bisa dibelokkan.
alter function public.is_admin() set search_path = public;

-- Hak penuh: admin web, service role (edge function), atau SQL editor Supabase. Pengguna biasa (anon/authenticated) tidak.
create or replace function public.is_privileged_db() returns boolean
language sql stable
set search_path = public
as $$ select current_user in ('postgres', 'service_role', 'supabase_admin') or public.is_admin() $$;

-- ============================================================
-- A. Pencabutan hak
-- ============================================================

-- A1. View tutors_public hanya boleh dibaca.
revoke all on public.tutors_public from anon, authenticated;
grant select on public.tutors_public to anon, authenticated;

-- A2. Hak yang tidak pernah dipakai klien. TRUNCATE/REFERENCES/TRIGGER tidak diperlukan siapa pun lewat API.
-- anon hanya membaca; semua tulisan pengunjung lewat fungsi RPC (security definer) yang tidak terpengaruh.
-- Pengecualian users: pendaftaran mobile menulis profil sebelum sesi login terbentuk (dibatasi policy di bawah).
do $$
declare r record;
begin
  for r in select tablename from pg_tables where schemaname = 'public' loop
    execute format('revoke truncate, references, trigger on public.%I from anon, authenticated', r.tablename);
    if r.tablename <> 'users' then
      execute format('revoke insert, update, delete on public.%I from anon', r.tablename);
    else
      execute format('revoke update, delete on public.%I from anon', r.tablename);
    end if;
  end loop;
end $$;

-- A3. Policy yang terlalu longgar.
drop policy if exists "Public insert manual_orders"        on public.manual_orders;
drop policy if exists public_insert_manual_orders          on public.manual_orders;
drop policy if exists "Allow insert users from frontend"   on public.users;
drop policy if exists users_insert_self                    on public.users;
drop policy if exists "Allow insert tutors from frontend"  on public.tutors;

-- Pendaftaran: hanya peran buddy atau tutor (trigger guard_users juga memaksa ini).
drop policy if exists users_insert_signup on public.users;
create policy users_insert_signup on public.users
  for insert to anon, authenticated
  with check (role in ('buddy', 'tutor') and (auth.uid() is null or id = auth.uid()));

-- Ulasan: tutor yang dinilai harus tutor dari sesi tersebut.
drop policy if exists reviews_insert_buddy on public.reviews;
create policy reviews_insert_buddy on public.reviews
  for insert to public
  with check (
    customer_id = auth.uid()
    and session_id in (
      select s.id from public.sessions s join public.bookings b on b.id = s.booking_id
       where b.customer_id = auth.uid() and b.tutor_id = reviews.tutor_id)
  );

-- Refund: hanya untuk pembayaran milik pemohon.
drop policy if exists refunds_insert_self on public.refunds;
create policy refunds_insert_self on public.refunds
  for insert to public
  with check (
    requested_by = auth.uid()
    and booking_id in (select id from public.bookings where customer_id = auth.uid())
    and payment_id in (select id from public.payments p where p.booking_id = refunds.booking_id)
  );

-- A4. Trigger pendaftaran Auth menyalin peran dari data pendaftaran (yang diisi klien) tanpa saringan,
-- sehingga signUp dengan role "admin" langsung menjadi admin. Hanya buddy atau tutor yang diterima; selain itu buddy.
-- (Default lama 'tutor' diganti 'buddy'. Akun tutor dari admin tetap membawa role 'tutor' di datanya.)
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path to 'public' as $$
begin
  insert into public.users (id, email, full_name, role)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'full_name',
    case when new.raw_user_meta_data ->> 'role' in ('buddy', 'tutor') then new.raw_user_meta_data ->> 'role' else 'buddy' end
  );
  return new;
end;
$$;

-- ============================================================
-- B. Penjaga kolom (trigger). Lewat bila: pelaku berhak penuh, atau dipanggil dari trigger lain
-- (mis. penghitung rating dan total sesi) yaitu pg_trigger_depth() > 1.
-- ============================================================

-- B1. users: role dan kolom sistem tidak boleh diubah pengguna.
create or replace function public.guard_users() returns trigger
language plpgsql set search_path = public as $$
begin
  if pg_trigger_depth() > 1 or public.is_privileged_db() then return new; end if;
  if tg_op = 'INSERT' then
    if new.role is distinct from 'buddy' and new.role is distinct from 'tutor' then new.role := 'buddy'; end if;
    return new;
  end if;
  if (to_jsonb(new) - array['full_name','avatar_url','fcm_token','phone','jenjang','interested_subjects','parent_name','parent_phone','parent_consent_at'])
     is distinct from
     (to_jsonb(old) - array['full_name','avatar_url','fcm_token','phone','jenjang','interested_subjects','parent_name','parent_phone','parent_consent_at']) then
    raise exception 'kolom_dilindungi:users' using errcode = '42501';
  end if;
  return new;
end $$;
drop trigger if exists trg_guard_users on public.users;
create trigger trg_guard_users before insert or update on public.users
  for each row execute function public.guard_users();

-- B2. tutors: status verifikasi, unggulan, rating, harga, dan sejenisnya hanya admin.
create or replace function public.guard_tutors() returns trigger
language plpgsql set search_path = public as $$
begin
  if pg_trigger_depth() > 1 or public.is_privileged_db() then return new; end if;
  if tg_op = 'INSERT' then
    new.verification_status := 'pending';
    new.verification_note := null;
    new.is_featured := false;
    new.featured_match_percent := null;
    new.featured_reason := null;
    new.rating := 0;
    new.total_sessions := 0;
    new.total_reviews := 0;
    new.account_status := 'active';
    return new;
  end if;
  if (to_jsonb(new) - array['full_name','university','bio','subjects','jenjang_diajar','gmeet_link','is_online','last_seen'])
     is distinct from
     (to_jsonb(old) - array['full_name','university','bio','subjects','jenjang_diajar','gmeet_link','is_online','last_seen']) then
    raise exception 'kolom_dilindungi:tutors' using errcode = '42501';
  end if;
  return new;
end $$;
drop trigger if exists trg_guard_tutors on public.tutors;
create trigger trg_guard_tutors before insert or update on public.tutors
  for each row execute function public.guard_tutors();

-- B3. tutor_documents: tutor hanya mengirim dokumen untuk diperiksa; penilaian milik admin.
create or replace function public.guard_tutor_documents() returns trigger
language plpgsql set search_path = public as $$
begin
  if pg_trigger_depth() > 1 or public.is_privileged_db() then return new; end if;
  if tg_op = 'INSERT' then
    if new.status in ('terverifikasi', 'ditolak') then new.status := 'menunggu_verifikasi'; end if;
    new.rejection_note := null;
    return new;
  end if;
  if new.tutor_id is distinct from old.tutor_id
     or new.jenis_dokumen is distinct from old.jenis_dokumen
     or new.rejection_note is distinct from old.rejection_note
     or (new.status is distinct from old.status and new.status is distinct from 'menunggu_verifikasi') then
    raise exception 'kolom_dilindungi:tutor_documents' using errcode = '42501';
  end if;
  return new;
end $$;
drop trigger if exists trg_guard_tutor_documents on public.tutor_documents;
create trigger trg_guard_tutor_documents before insert or update on public.tutor_documents
  for each row execute function public.guard_tutor_documents();

-- B4. bookings: pihak yang terlibat tidak boleh menukar customer, tutor, jadwal, atau durasi.
-- Jadwal berubah hanya lewat persetujuan reschedule oleh admin.
create or replace function public.guard_bookings() returns trigger
language plpgsql set search_path = public as $$
begin
  if pg_trigger_depth() > 1 or public.is_privileged_db() then return new; end if;
  if new.customer_id is distinct from old.customer_id
     or new.tutor_id is distinct from old.tutor_id
     or new.session_time is distinct from old.session_time
     or new.duration_minutes is distinct from old.duration_minutes then
    raise exception 'kolom_dilindungi:bookings' using errcode = '42501';
  end if;
  return new;
end $$;
drop trigger if exists trg_guard_bookings on public.bookings;
create trigger trg_guard_bookings before update on public.bookings
  for each row execute function public.guard_bookings();

-- B5. tokens: token baru harus sesuai paket aktif; sisa sesi hanya boleh turun; status tidak boleh dihidupkan lagi.
create or replace function public.guard_tokens() returns trigger
language plpgsql set search_path = public as $$
declare v_pkg record;
begin
  if pg_trigger_depth() > 1 or public.is_privileged_db() then return new; end if;
  if tg_op = 'INSERT' then
    select session_count, validity_days into v_pkg from public.packages where id = new.package_id and is_active;
    if not found
       or new.status <> 'active'
       or new.sessions_remaining > v_pkg.session_count
       or new.expiry_date > now() + make_interval(days => v_pkg.validity_days + 1) then
      raise exception 'token_tidak_valid' using errcode = '42501';
    end if;
    return new;
  end if;
  if new.buddy_id is distinct from old.buddy_id
     or new.package_id is distinct from old.package_id
     or new.active_date is distinct from old.active_date
     or new.expiry_date is distinct from old.expiry_date
     or new.sessions_remaining > old.sessions_remaining
     or (old.status in ('used', 'expired') and new.status = 'active') then
    raise exception 'kolom_dilindungi:tokens' using errcode = '42501';
  end if;
  return new;
end $$;
drop trigger if exists trg_guard_tokens on public.tokens;
create trigger trg_guard_tokens before insert or update on public.tokens
  for each row execute function public.guard_tokens();

-- B6. reschedules dan complaints: pengaju tidak boleh langsung mengisi keputusan.
create or replace function public.guard_decision_insert() returns trigger
language plpgsql set search_path = public as $$
begin
  if pg_trigger_depth() > 1 or public.is_privileged_db() then return new; end if;
  if tg_table_name = 'reschedules' and new.status in ('disetujui', 'ditolak') then
    raise exception 'status_tidak_valid' using errcode = '42501';
  end if;
  if tg_table_name = 'complaints' and new.status in ('resolved', 'rejected', 'in_review') then
    raise exception 'status_tidak_valid' using errcode = '42501';
  end if;
  return new;
end $$;
drop trigger if exists trg_guard_reschedules on public.reschedules;
create trigger trg_guard_reschedules before insert on public.reschedules
  for each row execute function public.guard_decision_insert();
drop trigger if exists trg_guard_complaints on public.complaints;
create trigger trg_guard_complaints before insert on public.complaints
  for each row execute function public.guard_decision_insert();

commit;

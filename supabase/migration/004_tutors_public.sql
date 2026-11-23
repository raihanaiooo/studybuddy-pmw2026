-- ============================================================
-- Study Buddy — Migration 004: tutor publik lewat view terbatas
-- Masalah: kunci publik (anon) bisa membaca seluruh tabel tutors (termasuk gmeet_link,
-- user_id, verification_note, gpa) dan tabel reviews (termasuk customer_id).
-- Perbaikan: landing page membaca view tutors_public (hanya kolom yang ditampilkan,
-- hanya tutor verified dan featured); anon tidak lagi boleh membaca tabel aslinya.
-- Pengguna login (authenticated) tidak terpengaruh.
-- ============================================================

create or replace view public.tutors_public as
select id, full_name, university, bio, subjects, jenjang_diajar,
       price_per_hour, rating, featured_match_percent, featured_reason
from public.tutors
where verification_status = 'verified' and is_featured;

revoke all on public.tutors_public from public;
grant select on public.tutors_public to anon, authenticated;

revoke select on public.tutors  from anon;
revoke select on public.reviews from anon;

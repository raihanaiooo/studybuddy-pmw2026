-- Uji SQL fitur diagnostic. Jalankan terhadap database kosong:
--   psql -v ON_ERROR_STOP=1 -f 00_stubs.sql -f ../migration/002_diagnostic.sql -f diagnostic.test.sql
-- Setiap pemeriksaan melempar exception bila gagal.

create or replace function pg_temp.assert_eq(label text, got text, want text) returns void
language plpgsql as $$
begin
  if got is distinct from want then
    raise exception 'GAGAL [%]: dapat %, seharusnya %', label, coalesce(got, 'NULL'), want;
  end if;
end $$;

-- ===== Task 1: fungsi level =====
select pg_temp.assert_eq('semua nol',                 diagnostic_level(0,0,0,0), 'PRE_A1');
select pg_temp.assert_eq('A1 di bawah ambang',        diagnostic_level(3,6,6,6), 'PRE_A1');
select pg_temp.assert_eq('A1 saja',                   diagnostic_level(4,0,0,0), 'A1');
select pg_temp.assert_eq('A2 gagal, atas diabaikan',  diagnostic_level(6,3,6,6), 'A1');
select pg_temp.assert_eq('B1',                        diagnostic_level(6,4,4,3), 'B1');
select pg_temp.assert_eq('B2 penuh',                  diagnostic_level(6,6,6,6), 'B2');
select pg_temp.assert_eq('batas B2 tepat 4',          diagnostic_level(4,4,4,4), 'B2');
select pg_temp.assert_eq('batas B1, B2 kurang satu',  diagnostic_level(4,4,4,3), 'B1');
select pg_temp.assert_eq('ambang kustom 5',           diagnostic_level(5,5,4,6, 5), 'A2');

-- ===== Task 1: RLS dan view publik =====
insert into diagnostic_questions (id, test_code, position, skill, level, stem, options, correct_index, explanation, is_active)
values
  ('00000000-0000-0000-0000-0000000000a1', 'english', 1, 'grammar', 'A1', 'She ___ a student.', '["is","are","am","be"]', 0, 'Subjek tunggal memakai is.', true),
  ('00000000-0000-0000-0000-0000000000a2', 'english', 2, 'grammar', 'A1', 'Soal nonaktif', '["a","b","c","d"]', 1, 'x', false);

insert into diagnostic_attempts (id, test_code, client_session_id, answers, score, level)
values ('00000000-0000-0000-0000-0000000000b1', 'english', 'sess-fixture', '{}', 0, 'PRE_A1');

-- anon tidak boleh membaca tabel soal dan attempts (0 baris atau ditolak)
do $$
declare n int;
begin
  set local role anon;
  begin
    select count(*) into n from diagnostic_questions;
  exception when insufficient_privilege then n := 0;
  end;
  if n <> 0 then raise exception 'GAGAL [anon baca diagnostic_questions]: % baris terlihat', n; end if;

  begin
    select count(*) into n from diagnostic_attempts;
  exception when insufficient_privilege then n := 0;
  end;
  if n <> 0 then raise exception 'GAGAL [anon baca diagnostic_attempts]: % baris terlihat', n; end if;
  reset role;
end $$;

-- anon tidak boleh menulis ke diagnostic_attempts
do $$
declare ditolak boolean := false;
begin
  set local role anon;
  begin
    insert into diagnostic_attempts (test_code, client_session_id, answers, score, level)
    values ('english', 'sess-anon', '{}', 0, 'PRE_A1');
  exception when others then ditolak := true;
  end;
  reset role;
  if not ditolak then raise exception 'GAGAL [anon insert diagnostic_attempts]: insert berhasil'; end if;
end $$;

-- view publik: hanya soal aktif, tanpa kunci jawaban dan penjelasan
do $$
declare n int; bocor int;
begin
  select count(*) into bocor from information_schema.columns
   where table_name = 'diagnostic_questions_public' and column_name in ('correct_index', 'explanation');
  if bocor <> 0 then raise exception 'GAGAL [view publik]: kolom kunci/penjelasan ada di view'; end if;

  set local role anon;
  select count(*) into n from diagnostic_questions_public;
  reset role;
  if n <> 1 then raise exception 'GAGAL [view publik]: anon melihat % soal, seharusnya 1 (hanya aktif)', n; end if;
end $$;

-- kolom baru manual_orders ada dan nullable
do $$
declare n int;
begin
  select count(*) into n from information_schema.columns
   where table_name = 'manual_orders' and column_name in ('diagnostic_attempt_id', 'package_id') and is_nullable = 'YES';
  if n <> 2 then raise exception 'GAGAL [manual_orders]: kolom baru tidak lengkap atau tidak nullable'; end if;
end $$;

select 'OK: diagnostic.test.sql (Task 1)' as hasil;

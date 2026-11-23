-- Validasi isi seed soal English. Jalankan setelah seed dimuat:
--   supabase/tests/run.sh ../seed/diagnostic_english.sql diagnostic_seed.test.sql

create or replace function pg_temp.assert_eq(label text, got text, want text) returns void
language plpgsql as $$
begin
  if got is distinct from want then
    raise exception 'GAGAL [%]: dapat %, seharusnya %', label, coalesce(got, 'NULL'), want;
  end if;
end $$;

select pg_temp.assert_eq('jumlah soal', (select count(*)::text from diagnostic_questions where test_code = 'english'), '24');

select pg_temp.assert_eq('6 soal per level',
  (select string_agg(level || '=' || n, ',' order by level) from
    (select level, count(*) n from diagnostic_questions where test_code = 'english' group by level) t),
  'A1=6,A2=6,B1=6,B2=6');

select pg_temp.assert_eq('posisi 1..24 berurutan dan level naik',
  (select (min(position) = 1 and max(position) = 24 and count(distinct position) = 24
           and bool_and(rank_ok))::text from (
     select position, level,
            level >= coalesce(lag(level) over (order by position), 'A1') as rank_ok
     from diagnostic_questions where test_code = 'english') t),
  'true');

-- tiap level punya grammar, vocabulary, dan reading
select pg_temp.assert_eq('tiap level punya 3 keahlian',
  (select count(*)::text from (
     select level from diagnostic_questions where test_code = 'english'
     group by level having count(distinct skill) = 3) t),
  '4');

-- B1 dan B2 masing-masing minimal 3 soal reading
select pg_temp.assert_eq('reading B1 dan B2 >= 3',
  (select bool_and(n >= 3)::text from (
     select count(*) n from diagnostic_questions
     where test_code = 'english' and skill = 'reading' and level in ('B1', 'B2')
     group by level) t),
  'true');

-- soal reading wajib punya teks; selain reading tidak boleh
select pg_temp.assert_eq('passage hanya untuk reading',
  (select bool_and((skill = 'reading') = (passage_id is not null))::text
     from diagnostic_questions where test_code = 'english'), 'true');

-- struktur tiap soal
select pg_temp.assert_eq('4 opsi per soal',
  (select bool_and(jsonb_typeof(options) = 'array' and jsonb_array_length(options) = 4)::text
     from diagnostic_questions where test_code = 'english'), 'true');
select pg_temp.assert_eq('correct_index dalam rentang 0..3',
  (select bool_and(correct_index between 0 and 3)::text from diagnostic_questions where test_code = 'english'), 'true');
select pg_temp.assert_eq('opsi unik dalam satu soal',
  (select bool_and((select count(distinct o) from jsonb_array_elements_text(options) o) = 4)::text
     from diagnostic_questions where test_code = 'english'), 'true');
select pg_temp.assert_eq('stem dan penjelasan terisi',
  (select bool_and(length(btrim(stem)) > 5 and length(btrim(explanation)) > 15)::text
     from diagnostic_questions where test_code = 'english'), 'true');
select pg_temp.assert_eq('stem unik',
  (select (count(distinct stem) = count(*))::text from diagnostic_questions where test_code = 'english'), 'true');

-- kunci jawaban tersebar: tiap indeks 0..3 dipakai minimal 4 kali
select pg_temp.assert_eq('sebaran kunci jawaban',
  (select (count(*) = 4 and bool_and(n >= 4))::text from (
     select correct_index, count(*) n from diagnostic_questions where test_code = 'english' group by correct_index) t),
  'true');

-- soal masuk nonaktif sampai ditinjau tutor
select pg_temp.assert_eq('semua soal nonaktif',
  (select bool_and(not is_active)::text from diagnostic_questions where test_code = 'english'), 'true');

-- aturan: 5 level, alasan terisi, paket belum dipetakan
select pg_temp.assert_eq('aturan 5 level',
  (select string_agg(level, ',' order by level) from diagnostic_rules where test_code = 'english'),
  'A1,A2,B1,B2,PRE_A1');
select pg_temp.assert_eq('alasan aturan terisi',
  (select bool_and(length(btrim(reason)) > 10)::text from diagnostic_rules where test_code = 'english'), 'true');
select pg_temp.assert_eq('paket belum dipetakan',
  (select bool_and(package_id is null)::text from diagnostic_rules where test_code = 'english'), 'true');

select 'OK: diagnostic_seed.test.sql (Task 3)' as hasil;

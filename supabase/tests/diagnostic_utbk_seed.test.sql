-- Uji seed UTBK (Task 4).
--   supabase/tests/run.sh ../seed/diagnostic_utbk.sql diagnostic_utbk_seed.test.sql

create or replace function pg_temp.assert_eq(label text, got text, want text) returns void
language plpgsql as $$
begin
  if got is distinct from want then
    raise exception 'GAGAL [%]: dapat %, seharusnya %', label, coalesce(got, 'NULL'), want;
  end if;
end $$;

select pg_temp.assert_eq('24 soal',  (select count(*)::text from diagnostic_questions where test_code = 'utbk'), '24');
select pg_temp.assert_eq('pu 8',     (select count(*)::text from diagnostic_questions where test_code = 'utbk' and skill = 'pu'), '8');
select pg_temp.assert_eq('pk 8',     (select count(*)::text from diagnostic_questions where test_code = 'utbk' and skill = 'pk'), '8');
select pg_temp.assert_eq('lbi 8',    (select count(*)::text from diagnostic_questions where test_code = 'utbk' and skill = 'lbi'), '8');
select pg_temp.assert_eq('semua nonaktif', (select count(*)::text from diagnostic_questions where test_code = 'utbk' and is_active), '0');
select pg_temp.assert_eq('level null',     (select count(*)::text from diagnostic_questions where test_code = 'utbk' and level is not null), '0');
select pg_temp.assert_eq('5 opsi semua',   (select count(*)::text from diagnostic_questions where test_code = 'utbk' and jsonb_array_length(options) <> 5), '0');
select pg_temp.assert_eq('kunci dalam rentang', (select count(*)::text from diagnostic_questions where test_code = 'utbk' and (correct_index < 0 or correct_index >= 5)), '0');
select pg_temp.assert_eq('lbi punya teks', (select count(*)::text from diagnostic_questions q
   left join diagnostic_passages p on p.id = q.passage_id where q.test_code = 'utbk' and q.skill = 'lbi' and p.id is null), '0');
select pg_temp.assert_eq('3 aturan', (select count(*)::text from diagnostic_rules where test_code = 'utbk'), '3');
select pg_temp.assert_eq('aturan beralasan', (select count(*)::text from diagnostic_rules where test_code = 'utbk' and length(reason) > 10), '3');
select pg_temp.assert_eq('belum aktif -> view kosong', (select count(*)::text from diagnostic_questions_public where test_code = 'utbk'), '0');

-- Pemetaan paket lewat nama: tanpa katalog paket tetap null, dengan katalog terisi (seed dijalankan ulang).
select pg_temp.assert_eq('tanpa katalog null', (select count(*)::text from diagnostic_rules where test_code = 'utbk' and package_id is not null), '0');
insert into packages (package_name, price) values
  ('Bundling SNBT — Satset', 200000), ('Bundling SNBT — Juara', 420000), ('Bundling SNBT — SKS', 1100000),
  ('Bundling Bulanan (12 Sesi)', 550000);
\ir ../seed/diagnostic_utbk.sql
select pg_temp.assert_eq('idempoten soal',   (select count(*)::text from diagnostic_questions where test_code = 'utbk'), '24');
select pg_temp.assert_eq('idempoten aturan', (select count(*)::text from diagnostic_rules where test_code = 'utbk'), '3');
select pg_temp.assert_eq('rendah -> SKS',   (select p.package_name from diagnostic_rules r join packages p on p.id = r.package_id where r.test_code = 'utbk' and r.level = 'UTBK_RENDAH'), 'Bundling SNBT — SKS');
select pg_temp.assert_eq('sedang -> Juara', (select p.package_name from diagnostic_rules r join packages p on p.id = r.package_id where r.test_code = 'utbk' and r.level = 'UTBK_SEDANG'), 'Bundling SNBT — Juara');
select pg_temp.assert_eq('tinggi -> Satset',(select p.package_name from diagnostic_rules r join packages p on p.id = r.package_id where r.test_code = 'utbk' and r.level = 'UTBK_TINGGI'), 'Bundling SNBT — Satset');

do $$ begin raise notice ' OK: diagnostic_utbk_seed.test.sql (Task 4)'; end $$;

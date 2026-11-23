-- Uji skema UTBK (Task 1): fungsi pita, constraint yang dilonggarkan, dan English yang tetap ketat.
-- Jalankan lewat run.sh (menerapkan 002 dan 003 lebih dulu).

create or replace function pg_temp.assert_eq(label text, got text, want text) returns void
language plpgsql as $$
begin
  if got is distinct from want then
    raise exception 'GAGAL [%]: dapat %, seharusnya %', label, coalesce(got, 'NULL'), want;
  end if;
end $$;

-- ===== pita =====
select pg_temp.assert_eq('pita 0 dari 24',  diagnostic_utbk_band(0, 24),  'UTBK_RENDAH');
select pg_temp.assert_eq('pita 9 dari 24',  diagnostic_utbk_band(9, 24),  'UTBK_RENDAH');
select pg_temp.assert_eq('pita 10 dari 24', diagnostic_utbk_band(10, 24), 'UTBK_SEDANG');
select pg_temp.assert_eq('pita 16 dari 24', diagnostic_utbk_band(16, 24), 'UTBK_SEDANG');
select pg_temp.assert_eq('pita 17 dari 24', diagnostic_utbk_band(17, 24), 'UTBK_TINGGI');
select pg_temp.assert_eq('pita 24 dari 24', diagnostic_utbk_band(24, 24), 'UTBK_TINGGI');

do $$
declare ditolak boolean := false;
begin
  begin perform diagnostic_utbk_band(0, 0);
  exception when others then ditolak := sqlerrm like '%invalid_total%'; end;
  if not ditolak then raise exception 'GAGAL [total 0]: seharusnya melempar invalid_total'; end if;
end $$;

-- ===== soal: skill dan level =====
insert into diagnostic_questions (test_code, position, skill, level, stem, options, correct_index, explanation, is_active)
values ('utbk_schema', 1, 'pu', null, 'Soal UTBK tanpa level', '["a","b","c","d","e"]', 0, 'x', false);

insert into diagnostic_questions (test_code, position, skill, level, stem, options, correct_index, explanation, is_active)
values ('english_schema', 1, 'grammar', 'A1', 'Soal English tetap valid', '["a","b","c","d"]', 0, 'x', false);

do $$
declare ditolak boolean;
begin
  ditolak := false;
  begin
    insert into diagnostic_questions (test_code, position, skill, level, stem, options, correct_index, explanation, is_active)
    values ('utbk_schema', 2, 'xyz', null, 's', '["a","b"]', 0, 'x', false);
  exception when check_violation then ditolak := true; end;
  if not ditolak then raise exception 'GAGAL [skill ngawur]: skill xyz diterima'; end if;

  ditolak := false;
  begin
    insert into diagnostic_questions (test_code, position, skill, level, stem, options, correct_index, explanation, is_active)
    values ('utbk_schema', 3, 'pu', 'C1', 's', '["a","b"]', 0, 'x', false);
  exception when check_violation then ditolak := true; end;
  if not ditolak then raise exception 'GAGAL [level ngawur]: level C1 diterima'; end if;
end $$;

-- ===== aturan paket =====
insert into diagnostic_rules (test_code, level, package_id, reason)
values ('utbk_schema', 'UTBK_SEDANG', null, 'alasan');

do $$
declare ditolak boolean := false;
begin
  begin
    insert into diagnostic_rules (test_code, level, package_id, reason) values ('utbk_schema', 'Z9', null, 'x');
  exception when check_violation then ditolak := true; end;
  if not ditolak then raise exception 'GAGAL [rules level ngawur]: level Z9 diterima'; end if;
end $$;

-- ===== attempt tanpa level, dengan result =====
insert into diagnostic_attempts (test_code, client_session_id, answers, score, level, result)
values ('utbk_schema', 'sess-schema', '{}', 0, null, '{}'::jsonb);

select pg_temp.assert_eq('attempt english lama tanpa result',
  (select count(*)::text from information_schema.columns
    where table_name = 'diagnostic_attempts' and column_name = 'result'), '1');

-- ===== view publik tetap tanpa kunci =====
select pg_temp.assert_eq('view tanpa kunci',
  (select count(*)::text from information_schema.columns
    where table_name = 'diagnostic_questions_public' and column_name in ('correct_index', 'explanation')), '0');

do $$ begin raise notice ' OK: utbk.test.sql (Task 1)'; end $$;

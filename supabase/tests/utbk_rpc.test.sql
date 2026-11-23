-- Uji RPC submit_utbk_attempt (Task 2).
--   supabase/tests/run.sh utbk_rpc.test.sql
-- Fixture: tes 'utbk' berisi 24 soal aktif: pu 1-8, pk 9-16, lbi 17-24; 5 opsi; kunci = position % 5.

create or replace function pg_temp.assert_eq(label text, got text, want text) returns void
language plpgsql as $$
begin
  if got is distinct from want then
    raise exception 'GAGAL [%]: dapat %, seharusnya %', label, coalesce(got, 'NULL'), want;
  end if;
end $$;

-- Susun jawaban: pada tiap subtes, n soal pertama dijawab benar, sisanya salah.
create or replace function pg_temp.uans(n_pu int, n_pk int, n_lbi int) returns jsonb
language sql as $$
  select jsonb_object_agg(id::text,
           case when rn <= (case skill when 'pu' then n_pu when 'pk' then n_pk else n_lbi end)
                then correct_index else (correct_index + 1) % 5 end)
  from (
    select id, skill, correct_index,
           row_number() over (partition by skill order by position) as rn
    from diagnostic_questions where test_code = 'utbk' and is_active
  ) t
$$;

create or replace function pg_temp.attempts() returns int language sql as
  $$ select count(*)::int from diagnostic_attempts $$;

-- ===== Fixture =====
insert into diagnostic_questions (test_code, position, skill, level, stem, options, correct_index, explanation)
select 'utbk', g, (array['pu','pk','lbi'])[((g - 1) / 8) + 1], null,
       'Soal ' || g, '["a","b","c","d","e"]', g % 5, 'Penjelasan rahasia ' || g
from generate_series(1, 24) g;

insert into packages (id, package_name, price) values
  ('00000000-0000-0000-0000-00000000f101', 'Bundling SNBT — SKS',    1100000),
  ('00000000-0000-0000-0000-00000000f102', 'Bundling SNBT — Juara',   420000),
  ('00000000-0000-0000-0000-00000000f103', 'Bundling SNBT — Satset',  200000);
insert into diagnostic_rules (test_code, level, package_id, reason) values
  ('utbk', 'UTBK_RENDAH', '00000000-0000-0000-0000-00000000f101', 'Butuh dasar lebih kuat'),
  ('utbk', 'UTBK_SEDANG', '00000000-0000-0000-0000-00000000f102', 'Tinggal diperdalam'),
  ('utbk', 'UTBK_TINGGI', '00000000-0000-0000-0000-00000000f103', 'Tinggal dipoles');

-- ===== Penilaian semua benar, kebocoran, hak anon =====
do $$
declare jwb jsonb; n0 int := pg_temp.attempts(); ans jsonb := pg_temp.uans(8, 8, 8);
begin
  set local role anon;                                  -- pengunjung anonim boleh memanggil
  jwb := submit_utbk_attempt('sess-penuh', ans);
  reset role;

  perform pg_temp.assert_eq('skor semua benar', jwb->>'score', '24');
  perform pg_temp.assert_eq('total soal',       jwb->>'total', '24');
  perform pg_temp.assert_eq('pita tinggi',      jwb->>'band', 'UTBK_TINGGI');
  perform pg_temp.assert_eq('pu benar',         jwb->'per_subtest'->'pu'->>'correct', '8');
  perform pg_temp.assert_eq('lbi total',        jwb->'per_subtest'->'lbi'->>'total', '8');
  perform pg_temp.assert_eq('seimbang -> kosong', (jwb->'weakest')::text, '[]');
  perform pg_temp.assert_eq('paket tinggi',     jwb->'package'->>'package_name', 'Bundling SNBT — Satset');
  perform pg_temp.assert_eq('attempt tersimpan', (pg_temp.attempts() - n0)::text, '1');
  perform pg_temp.assert_eq('attempt tanpa level',
    (select (level is null)::text from diagnostic_attempts where client_session_id = 'sess-penuh'), 'true');
  perform pg_temp.assert_eq('result band',
    (select result->>'band' from diagnostic_attempts where client_session_id = 'sess-penuh'), 'UTBK_TINGGI');
  perform pg_temp.assert_eq('paket tersimpan',
    (select recommended_package_id::text from diagnostic_attempts where client_session_id = 'sess-penuh'),
    '00000000-0000-0000-0000-00000000f103');
  if jwb::text like '%correct_index%' or jwb::text like '%explanation%' or jwb::text like '%Penjelasan rahasia%' then
    raise exception 'GAGAL [kebocoran]: respons memuat kunci atau penjelasan';
  end if;
end $$;

-- ===== Pita dan subtes terlemah =====
do $$
declare jwb jsonb;
begin
  jwb := submit_utbk_attempt('s-0', pg_temp.uans(0, 0, 0));
  perform pg_temp.assert_eq('semua salah: pita', jwb->>'band', 'UTBK_RENDAH');
  perform pg_temp.assert_eq('semua salah: seimbang', (jwb->'weakest')::text, '[]');
  perform pg_temp.assert_eq('semua salah: paket', jwb->'package'->>'package_name', 'Bundling SNBT — SKS');

  jwb := submit_utbk_attempt('s-9', pg_temp.uans(3, 3, 3));
  perform pg_temp.assert_eq('9 benar', jwb->>'band', 'UTBK_RENDAH');
  jwb := submit_utbk_attempt('s-10', pg_temp.uans(4, 3, 3));
  perform pg_temp.assert_eq('10 benar', jwb->>'band', 'UTBK_SEDANG');
  perform pg_temp.assert_eq('10 benar: paket', jwb->'package'->>'package_name', 'Bundling SNBT — Juara');
  jwb := submit_utbk_attempt('s-16', pg_temp.uans(6, 5, 5));
  perform pg_temp.assert_eq('16 benar', jwb->>'band', 'UTBK_SEDANG');
  jwb := submit_utbk_attempt('s-17', pg_temp.uans(6, 6, 5));
  perform pg_temp.assert_eq('17 benar', jwb->>'band', 'UTBK_TINGGI');
  perform pg_temp.assert_eq('17 benar: terlemah lbi', (jwb->'weakest')::text, '["lbi"]');

  jwb := submit_utbk_attempt('s-weak', pg_temp.uans(2, 5, 5));
  perform pg_temp.assert_eq('terlemah pu', (jwb->'weakest')::text, '["pu"]');
  jwb := submit_utbk_attempt('s-tie', pg_temp.uans(3, 3, 6));
  perform pg_temp.assert_eq('seri pu dan pk', (jwb->'weakest')::text, '["pu", "pk"]');
end $$;

-- ===== Paket belum dipetakan =====
do $$
declare jwb jsonb;
begin
  update diagnostic_rules set package_id = null where test_code = 'utbk' and level = 'UTBK_TINGGI';
  jwb := submit_utbk_attempt('s-nopkg', pg_temp.uans(8, 8, 8));
  perform pg_temp.assert_eq('paket null', jsonb_typeof(jwb->'package'), 'null');
  perform pg_temp.assert_eq('hasil tetap ada', jwb->>'band', 'UTBK_TINGGI');
  perform pg_temp.assert_eq('paket tersimpan null',
    (select (recommended_package_id is null)::text from diagnostic_attempts where client_session_id = 's-nopkg'), 'true');
  update diagnostic_rules set package_id = '00000000-0000-0000-0000-00000000f103'
   where test_code = 'utbk' and level = 'UTBK_TINGGI';
end $$;

-- ===== Validasi dan batas laju =====
do $$
declare ans jsonb := pg_temp.uans(8, 8, 8); bad jsonb; msg text;
begin
  begin perform submit_utbk_attempt('', ans); exception when others then msg := sqlerrm; end;
  perform pg_temp.assert_eq('sesi kosong', msg, 'invalid_session');

  msg := null;
  begin perform submit_utbk_attempt('s-kurang', ans - (select id::text from diagnostic_questions where test_code = 'utbk' and position = 1));
  exception when others then msg := sqlerrm; end;
  perform pg_temp.assert_eq('jawaban kurang satu', msg, 'invalid_answers');

  msg := null;
  bad := jsonb_set(ans, array[(select id::text from diagnostic_questions where test_code = 'utbk' and position = 1)], '5');
  begin perform submit_utbk_attempt('s-range', bad); exception when others then msg := sqlerrm; end;
  perform pg_temp.assert_eq('indeks opsi 5', msg, 'invalid_answers');

  -- batas laju gabungan: 5 attempt English dari sesi yang sama menutup UTBK
  insert into diagnostic_attempts (test_code, client_session_id, answers, score, level)
  select 'english', 's-rl', '{}', 0, 'PRE_A1' from generate_series(1, 5);
  msg := null;
  begin perform submit_utbk_attempt('s-rl', ans); exception when others then msg := sqlerrm; end;
  perform pg_temp.assert_eq('rate limit gabungan', msg, 'rate_limited');
end $$;

-- ===== Tanpa soal aktif =====
do $$
declare msg text;
begin
  update diagnostic_questions set is_active = false where test_code = 'utbk';
  begin perform submit_utbk_attempt('s-none', '{}'::jsonb); exception when others then msg := sqlerrm; end;
  perform pg_temp.assert_eq('tanpa soal aktif', msg, 'unknown_test');
  update diagnostic_questions set is_active = true where test_code = 'utbk';
end $$;

do $$ begin raise notice ' OK: utbk_rpc.test.sql (Task 2)'; end $$;

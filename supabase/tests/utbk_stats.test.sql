-- Uji statistik admin (Task 3): diagnostic_stats hanya English, diagnostic_stats_utbk baru.
--   supabase/tests/run.sh utbk_stats.test.sql

create or replace function pg_temp.assert_eq(label text, got text, want text) returns void
language plpgsql as $$
begin
  if got is distinct from want then
    raise exception 'GAGAL [%]: dapat %, seharusnya %', label, coalesce(got, 'NULL'), want;
  end if;
end $$;

-- Mulai bersih: berkas uji lain dalam satu run menyisakan attempt dan order.
delete from manual_orders where diagnostic_attempt_id is not null;
delete from diagnostic_attempts;

insert into users (id, role) values
  ('00000000-0000-0000-0000-00000000d001', 'management'),
  ('00000000-0000-0000-0000-00000000d002', 'customer'),
  ('00000000-0000-0000-0000-00000000d003', 'admin');

-- English: dua attempt (B1, A2); satu punya order.
insert into diagnostic_attempts (id, test_code, client_session_id, answers, score, level) values
  ('00000000-0000-0000-0000-0000000000e1', 'english', 'en-1', '{}', 16, 'B1'),
  ('00000000-0000-0000-0000-0000000000e2', 'english', 'en-2', '{}', 11, 'A2');

-- UTBK: satu tinggi (pu 8/8, pk 4/8, lbi 6/8) dan satu rendah (pu 3/8, pk 1/8, lbi 1/8).
insert into diagnostic_attempts (id, test_code, client_session_id, answers, score, level, result) values
  ('00000000-0000-0000-0000-0000000000f1', 'utbk', 'ut-1', '{}', 18, null,
   '{"band":"UTBK_TINGGI","per_subtest":{"pu":{"correct":8,"total":8},"pk":{"correct":4,"total":8},"lbi":{"correct":6,"total":8}},"weakest":["pk"]}'),
  ('00000000-0000-0000-0000-0000000000f2', 'utbk', 'ut-2', '{}', 5, null,
   '{"band":"UTBK_RENDAH","per_subtest":{"pu":{"correct":3,"total":8},"pk":{"correct":1,"total":8},"lbi":{"correct":1,"total":8}},"weakest":["pk","lbi"]}');

insert into manual_orders (name, whatsapp, subject, jenjang, diagnostic_attempt_id) values
  ('Murid English', '0800', 'Bahasa Inggris', 'SMA', '00000000-0000-0000-0000-0000000000e1'),
  ('Murid UTBK',    '0801', 'UTBK / SNBT',    'SMA', '00000000-0000-0000-0000-0000000000f1');

-- ===== diagnostic_stats hanya menghitung English =====
do $$
declare s jsonb;
begin
  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000d003', true);
  set local role authenticated;
  s := diagnostic_stats();
  reset role;
  perform pg_temp.assert_eq('english total',   s->>'total_attempts', '2');
  perform pg_temp.assert_eq('english B1',      s->'by_level'->>'B1', '1');
  perform pg_temp.assert_eq('english order',   s->>'orders_from_tests', '1');
  perform pg_temp.assert_eq('english recent',  jsonb_array_length(s->'recent')::text, '2');
  if s::text like '%UTBK%' then raise exception 'GAGAL [english]: statistik English memuat data UTBK'; end if;
end $$;

-- ===== diagnostic_stats_utbk =====
do $$
declare s jsonb;
begin
  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000d003', true);
  set local role authenticated;
  s := diagnostic_stats_utbk();
  reset role;
  perform pg_temp.assert_eq('utbk total',        s->>'total_attempts', '2');
  perform pg_temp.assert_eq('utbk band tinggi',  s->'by_band'->>'UTBK_TINGGI', '1');
  perform pg_temp.assert_eq('utbk band sedang',  s->'by_band'->>'UTBK_SEDANG', '0');
  perform pg_temp.assert_eq('utbk band rendah',  s->'by_band'->>'UTBK_RENDAH', '1');
  perform pg_temp.assert_eq('utbk order',        s->>'orders_from_tests', '1');
  perform pg_temp.assert_eq('utbk avg pu',       s->'avg_percent'->>'pu', '69');   -- 11/16
  perform pg_temp.assert_eq('utbk avg pk',       s->'avg_percent'->>'pk', '31');   -- 5/16
  perform pg_temp.assert_eq('utbk avg lbi',      s->'avg_percent'->>'lbi', '44');  -- 7/16
  perform pg_temp.assert_eq('utbk recent',       jsonb_array_length(s->'recent')::text, '2');
  perform pg_temp.assert_eq('utbk recent ordered',
    (select r->>'ordered' from jsonb_array_elements(s->'recent') r where r->>'id' = '00000000-0000-0000-0000-0000000000f1'), 'true');
  perform pg_temp.assert_eq('utbk recent band',
    (select r->>'band' from jsonb_array_elements(s->'recent') r where r->>'id' = '00000000-0000-0000-0000-0000000000f2'), 'UTBK_RENDAH');
end $$;

-- ===== hak akses =====
do $$
declare ditolak boolean; s jsonb;
begin
  ditolak := false;
  set local role anon;
  begin perform diagnostic_stats_utbk(); exception when others then ditolak := true; end;
  reset role;
  if not ditolak then raise exception 'GAGAL [anon]: anon bisa memanggil diagnostic_stats_utbk'; end if;

  ditolak := false;
  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000d002', true);
  set local role authenticated;
  begin perform diagnostic_stats_utbk(); exception when others then ditolak := sqlerrm like '%forbidden%'; end;
  reset role;
  if not ditolak then raise exception 'GAGAL [customer]: customer bisa memanggil diagnostic_stats_utbk'; end if;

  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000d001', true);
  set local role authenticated;
  s := diagnostic_stats_utbk();
  reset role;
  perform pg_temp.assert_eq('management diterima', s->>'total_attempts', '2');
end $$;

-- ===== belum ada attempt UTBK =====
do $$
declare s jsonb;
begin
  delete from manual_orders where diagnostic_attempt_id in (select id from diagnostic_attempts where test_code = 'utbk');
  delete from diagnostic_attempts where test_code = 'utbk';
  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000d003', true);
  set local role authenticated;
  s := diagnostic_stats_utbk();
  reset role;
  perform pg_temp.assert_eq('kosong total', s->>'total_attempts', '0');
  perform pg_temp.assert_eq('kosong avg null', jsonb_typeof(s->'avg_percent'->'pu'), 'null');
end $$;

do $$ begin raise notice ' OK: utbk_stats.test.sql (Task 3)'; end $$;

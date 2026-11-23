-- Uji RPC submit_diagnostic_attempt dan diagnostic_stats (Task 2).
--   supabase/tests/run.sh diagnostic_rpc.test.sql
-- Fixture: tes 'rpc_test' berisi 24 soal aktif (6 per level), semua kunci = indeks 0.

create or replace function pg_temp.assert_eq(label text, got text, want text) returns void
language plpgsql as $$
begin
  if got is distinct from want then
    raise exception 'GAGAL [%]: dapat %, seharusnya %', label, coalesce(got, 'NULL'), want;
  end if;
end $$;

-- Susun jawaban: untuk tiap level, `benar[i]` soal pertama dijawab benar (indeks 0), sisanya salah (indeks 1).
create or replace function pg_temp.answers(p_test text, benar int[]) returns jsonb
language sql as $$
  select jsonb_object_agg(id::text, case when rn <= benar[lvl] then 0 else 1 end)
  from (
    select id,
           array_position(array['A1','A2','B1','B2'], level) as lvl,
           row_number() over (partition by level order by position) as rn
    from diagnostic_questions where test_code = p_test and is_active
  ) t
$$;

create or replace function pg_temp.attempts() returns int language sql as
  $$ select count(*)::int from diagnostic_attempts $$;

-- ===== Fixture =====
insert into diagnostic_questions (test_code, position, skill, level, stem, options, correct_index, explanation)
select 'rpc_test', g, 'grammar', (array['A1','A2','B1','B2'])[((g - 1) / 6) + 1],
       'Soal ' || g, '["benar","salah1","salah2","salah3"]', 0, 'Penjelasan rahasia ' || g
from generate_series(1, 24) g;

insert into packages (id, package_name, price)
values ('00000000-0000-0000-0000-00000000f001', 'Paket B1', 150000);
insert into diagnostic_rules (test_code, level, package_id, reason)
values ('rpc_test', 'B1', '00000000-0000-0000-0000-00000000f001', 'Cocok untuk level B1');
-- sengaja tidak ada aturan untuk B2

insert into tutors (id, full_name, subjects, verification_status, is_featured, rating) values
  ('00000000-0000-0000-0000-00000000c001', 'Tutor Featured', '{ing}',            'verified', true,  4.0),
  ('00000000-0000-0000-0000-00000000c002', 'Tutor Rating',   '{"Bahasa Inggris"}', 'verified', false, 4.9),
  ('00000000-0000-0000-0000-00000000c003', 'Tutor Pending',  '{ing}',            'pending',  true,  5.0),
  ('00000000-0000-0000-0000-00000000c004', 'Tutor Mtk',      '{mtk}',            'verified', true,  5.0),
  ('00000000-0000-0000-0000-00000000c005', 'Tutor Lima',     '{ing}',            'verified', false, 3.0),
  ('00000000-0000-0000-0000-00000000c006', 'Tutor Enam',     '{ing}',            'verified', false, 2.0);

insert into users (id, role) values
  ('00000000-0000-0000-0000-00000000d001', 'management'),
  ('00000000-0000-0000-0000-00000000d002', 'customer');

-- ===== Penilaian, level, kebocoran, hak anon =====
do $$
declare
  jwb jsonb; ans jsonb; n0 int := pg_temp.attempts();
begin
  ans := pg_temp.answers('rpc_test', array[6,6,6,6]);
  set local role anon;                                   -- pengunjung anonim boleh memanggil
  jwb := submit_diagnostic_attempt('rpc_test', 'sess-penuh', ans);
  reset role;

  perform pg_temp.assert_eq('level semua benar', jwb->>'level', 'B2');
  perform pg_temp.assert_eq('skor semua benar',  jwb->>'score', '24');
  perform pg_temp.assert_eq('total soal',        jwb->>'total', '24');
  perform pg_temp.assert_eq('attempt tersimpan', (pg_temp.attempts() - n0)::text, '1');
  perform pg_temp.assert_eq('per_level B2',      jwb->'per_level'->>'B2', '6');
  -- B2 tidak punya aturan -> package null (Review Focus 3)
  perform pg_temp.assert_eq('package null tanpa aturan', jsonb_typeof(jwb->'package'), 'null');
  -- kunci jawaban tidak bocor
  if jwb::text like '%correct_index%' or jwb::text like '%explanation%' or jwb::text like '%Penjelasan rahasia%' then
    raise exception 'GAGAL [kebocoran]: respons memuat kunci atau penjelasan';
  end if;
  -- tutor: hanya verified + English, maks 3, featured dulu, tidak ada pending/mtk
  perform pg_temp.assert_eq('jumlah tutor maks 3', jsonb_array_length(jwb->'tutors')::text, '3');
  perform pg_temp.assert_eq('tutor pertama featured', jwb->'tutors'->0->>'full_name', 'Tutor Featured');
  perform pg_temp.assert_eq('tutor kedua rating tertinggi', jwb->'tutors'->1->>'full_name', 'Tutor Rating');
  if jwb->'tutors' @> '[{"full_name":"Tutor Pending"}]' or jwb->'tutors' @> '[{"full_name":"Tutor Mtk"}]' then
    raise exception 'GAGAL [tutor]: tutor pending atau non-English ikut direkomendasikan';
  end if;
end $$;

-- paket dari aturan: level B1 (A1 6, A2 6, B1 4, B2 3)
do $$
declare jwb jsonb;
begin
  jwb := submit_diagnostic_attempt('rpc_test', 'sess-b1', pg_temp.answers('rpc_test', array[6,6,4,3]));
  perform pg_temp.assert_eq('level B1',       jwb->>'level', 'B1');
  perform pg_temp.assert_eq('skor B1',        jwb->>'score', '19');
  perform pg_temp.assert_eq('paket B1',       jwb->'package'->>'package_name', 'Paket B1');
  perform pg_temp.assert_eq('alasan paket',   jwb->'package'->>'reason', 'Cocok untuk level B1');
  perform pg_temp.assert_eq('attempt menyimpan paket', (select recommended_package_id::text from diagnostic_attempts where id = (jwb->>'attempt_id')::uuid), '00000000-0000-0000-0000-00000000f001');
end $$;

-- ===== Review Focus 1: jawaban dimanipulasi / tidak lengkap =====
do $$
declare
  n0 int := pg_temp.attempts();
  valid jsonb := pg_temp.answers('rpc_test', array[6,6,6,6]);
  kasus text; bad jsonb; pesan text;
begin
  for kasus, bad in
    select * from (values
      ('indeks di luar rentang',  jsonb_set(valid, array[(select id::text from diagnostic_questions where test_code='rpc_test' and position=1)], '99')),
      ('indeks negatif',          jsonb_set(valid, array[(select id::text from diagnostic_questions where test_code='rpc_test' and position=1)], '-1')),
      ('nilai bukan angka',       jsonb_set(valid, array[(select id::text from diagnostic_questions where test_code='rpc_test' and position=1)], '"a"')),
      ('id soal tak dikenal',     (valid - (select id::text from diagnostic_questions where test_code='rpc_test' and position=1)) || '{"11111111-1111-1111-1111-111111111111": 0}'::jsonb),
      ('kurang satu jawaban',     valid - (select id::text from diagnostic_questions where test_code='rpc_test' and position=1)),
      ('kosong',                  '{}'::jsonb),
      ('bukan objek',             '[]'::jsonb)
    ) v(kasus, bad)
  loop
    pesan := null;
    begin
      perform submit_diagnostic_attempt('rpc_test', 'sess-bad-' || kasus, bad);
    exception when others then pesan := sqlerrm;
    end;
    if pesan is distinct from 'invalid_answers' then
      raise exception 'GAGAL [jawaban % ]: pesan error = %, seharusnya invalid_answers', kasus, coalesce(pesan, 'tidak ada error');
    end if;
  end loop;
  perform pg_temp.assert_eq('tidak ada attempt tersimpan dari jawaban buruk', (pg_temp.attempts() - n0)::text, '0');
end $$;

-- tes tak dikenal dan sesi kosong
do $$
declare pesan text;
begin
  begin perform submit_diagnostic_attempt('tidak_ada', 'sess-x', '{}');
  exception when others then pesan := sqlerrm; end;
  perform pg_temp.assert_eq('tes tak dikenal', pesan, 'unknown_test');

  pesan := null;
  begin perform submit_diagnostic_attempt('rpc_test', '', pg_temp.answers('rpc_test', array[1,1,1,1]));
  exception when others then pesan := sqlerrm; end;
  perform pg_temp.assert_eq('sesi kosong', pesan, 'invalid_session');
end $$;

-- ===== Review Focus 2: batas laju 5 attempt / jam / sesi =====
do $$
declare pesan text; ans jsonb := pg_temp.answers('rpc_test', array[2,2,2,2]);
begin
  for i in 1..5 loop
    perform submit_diagnostic_attempt('rpc_test', 'sess-spam', ans);
  end loop;
  begin perform submit_diagnostic_attempt('rpc_test', 'sess-spam', ans);
  exception when others then pesan := sqlerrm; end;
  perform pg_temp.assert_eq('attempt ke-6 ditolak', pesan, 'rate_limited');
  -- sesi lain tidak terpengaruh
  perform submit_diagnostic_attempt('rpc_test', 'sess-lain', ans);
  -- attempt lama (> 1 jam) tidak dihitung
  update diagnostic_attempts set created_at = now() - interval '2 hours' where client_session_id = 'sess-spam';
  perform submit_diagnostic_attempt('rpc_test', 'sess-spam', ans);
end $$;

-- ===== Review Focus 3: tidak ada tutor English terverifikasi =====
do $$
declare jwb jsonb;
begin
  delete from tutors;
  jwb := submit_diagnostic_attempt('rpc_test', 'sess-tanpa-tutor', pg_temp.answers('rpc_test', array[6,6,4,3]));
  perform pg_temp.assert_eq('tutors kosong', (jwb->'tutors')::text, '[]');
end $$;

-- ===== diagnostic_stats =====
insert into manual_orders (name, whatsapp, subject, jenjang, diagnostic_attempt_id)
select 'Murid Uji', '0800', 'Bahasa Inggris', 'SMA', id from diagnostic_attempts where client_session_id = 'sess-b1';

do $$
declare ditolak boolean := false; s jsonb;
begin
  -- anon ditolak
  set local role anon;
  begin perform diagnostic_stats(); exception when others then ditolak := true; end;
  reset role;
  if not ditolak then raise exception 'GAGAL [stats anon]: anon bisa memanggil diagnostic_stats'; end if;

  -- customer ditolak
  ditolak := false;
  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000d002', true);
  set local role authenticated;
  begin perform diagnostic_stats(); exception when others then ditolak := true; end;
  reset role;
  if not ditolak then raise exception 'GAGAL [stats customer]: customer bisa memanggil diagnostic_stats'; end if;

  -- management diterima
  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000d001', true);
  set local role authenticated;
  s := diagnostic_stats();
  reset role;
  perform pg_temp.assert_eq('stats total', s->>'total_attempts', (select count(*)::text from diagnostic_attempts));
  perform pg_temp.assert_eq('stats order dari tes', s->>'orders_from_tests', '1');
  perform pg_temp.assert_eq('stats B1', s->'by_level'->>'B1', (select count(*)::text from diagnostic_attempts where level = 'B1'));
  perform pg_temp.assert_eq('stats recent ada', (jsonb_array_length(s->'recent') > 0)::text, 'true');
  perform pg_temp.assert_eq('stats recent ordered', (select (r->>'ordered') from jsonb_array_elements(s->'recent') r
                              where r->>'id' = (select id::text from diagnostic_attempts where client_session_id = 'sess-b1')), 'true');
end $$;

select 'OK: diagnostic_rpc.test.sql (Task 2)' as hasil;

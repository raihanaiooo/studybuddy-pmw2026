-- Study Buddy — Migration 003: Diagnostic UTBK mini
-- Hanya menambah kolom dan melonggarkan batas pada tabel 002; data English tidak tersentuh.
-- Aman dijalankan ulang.

-- ---------- Skema: soal ----------
alter table public.diagnostic_questions drop constraint if exists diagnostic_questions_skill_check;
alter table public.diagnostic_questions
  add constraint diagnostic_questions_skill_check
  check (skill in ('grammar', 'vocabulary', 'reading', 'pu', 'pk', 'lbi'));

alter table public.diagnostic_questions drop constraint if exists diagnostic_questions_level_check;
alter table public.diagnostic_questions alter column level drop not null;
alter table public.diagnostic_questions
  add constraint diagnostic_questions_level_check
  check (level is null or level in ('A1', 'A2', 'B1', 'B2'));

-- ---------- Skema: aturan paket ----------
alter table public.diagnostic_rules drop constraint if exists diagnostic_rules_level_check;
alter table public.diagnostic_rules
  add constraint diagnostic_rules_level_check
  check (level in ('PRE_A1', 'A1', 'A2', 'B1', 'B2', 'UTBK_RENDAH', 'UTBK_SEDANG', 'UTBK_TINGGI'));

-- ---------- Skema: attempts ----------
alter table public.diagnostic_attempts alter column level drop not null;
alter table public.diagnostic_attempts add column if not exists result jsonb;

-- ---------- Pita dari jumlah benar ----------
-- Rendah: di bawah 40%; tinggi: 70% ke atas; sisanya sedang. Hitungan bulat agar tanpa pembulatan.
create or replace function public.diagnostic_utbk_band(p_correct int, p_total int)
returns text language plpgsql immutable
as $$
begin
  if p_total is null or p_total <= 0 then raise exception 'invalid_total'; end if;
  if p_correct * 10 < p_total * 4 then return 'UTBK_RENDAH'; end if;
  if p_correct * 10 >= p_total * 7 then return 'UTBK_TINGGI'; end if;
  return 'UTBK_SEDANG';
end $$;

-- ---------- RPC: submit_utbk_attempt ----------
-- Menilai try out UTBK di server; kunci jawaban dan penjelasan tidak pernah dikembalikan.
-- p_answers: {"<question_id>": <indeks opsi>} untuk SEMUA soal aktif tes 'utbk'.
-- Error (pesan = kode): invalid_session, unknown_test, rate_limited, invalid_answers.
create or replace function public.submit_utbk_attempt(p_client_session_id text, p_answers jsonb)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  c_test         constant text := 'utbk';
  c_max_per_hour constant int  := 5;   -- sama dengan English; dihitung gabungan semua tes
  v_total   int;
  v_pu      int;
  v_pk      int;
  v_lbi     int;
  v_score   int;
  v_band    text;
  v_min     int;
  v_weakest jsonb;
  v_pkg_id  uuid;
  v_package jsonb;
  v_result  jsonb;
  v_attempt uuid;
begin
  if p_client_session_id is null or btrim(p_client_session_id) = '' or length(p_client_session_id) > 100 then
    raise exception 'invalid_session';
  end if;

  select count(*) into v_total from diagnostic_questions where test_code = c_test and is_active;
  if v_total = 0 then raise exception 'unknown_test'; end if;

  if (select count(*) from diagnostic_attempts
       where client_session_id = p_client_session_id and created_at > now() - interval '1 hour') >= c_max_per_hour then
    raise exception 'rate_limited';
  end if;

  -- Validasi: objek, jumlah kunci = jumlah soal aktif, tiap soal punya jawaban bilangan bulat dalam rentang opsinya.
  if p_answers is null or jsonb_typeof(p_answers) <> 'object'
     or (select count(*) from jsonb_object_keys(p_answers)) <> v_total
     or exists (
       select 1 from diagnostic_questions q
       where q.test_code = c_test and q.is_active
         and case
               when not (p_answers ? q.id::text) then true
               when jsonb_typeof(p_answers -> q.id::text) <> 'number' then true
               when (p_answers ->> q.id::text) !~ '^[0-9]{1,6}$' then true
               else (p_answers ->> q.id::text)::int >= jsonb_array_length(q.options)
             end
     ) then
    raise exception 'invalid_answers';
  end if;

  select count(*) filter (where q.skill = 'pu'  and (p_answers ->> q.id::text)::int = q.correct_index),
         count(*) filter (where q.skill = 'pk'  and (p_answers ->> q.id::text)::int = q.correct_index),
         count(*) filter (where q.skill = 'lbi' and (p_answers ->> q.id::text)::int = q.correct_index)
    into v_pu, v_pk, v_lbi
  from diagnostic_questions q where q.test_code = c_test and q.is_active;

  v_score := v_pu + v_pk + v_lbi;
  v_band  := diagnostic_utbk_band(v_score, v_total);

  -- Subtes terlemah: semua yang benarnya paling sedikit; kosong bila ketiganya sama.
  v_min := least(v_pu, v_pk, v_lbi);
  if v_pu = v_pk and v_pk = v_lbi then
    v_weakest := '[]'::jsonb;
  else
    v_weakest := to_jsonb(array_remove(array[
      case when v_pu  = v_min then 'pu'  end,
      case when v_pk  = v_min then 'pk'  end,
      case when v_lbi = v_min then 'lbi' end], null));
  end if;

  select p.id,
         jsonb_build_object('id', p.id, 'package_name', p.package_name, 'price', p.price, 'reason', r.reason)
    into v_pkg_id, v_package
  from diagnostic_rules r
  join packages p on p.id = r.package_id and p.is_active
  where r.test_code = c_test and r.level = v_band;

  v_result := jsonb_build_object(
    'band', v_band,
    'per_subtest', jsonb_build_object(
      'pu',  jsonb_build_object('correct', v_pu,  'total', (select count(*) from diagnostic_questions where test_code = c_test and is_active and skill = 'pu')),
      'pk',  jsonb_build_object('correct', v_pk,  'total', (select count(*) from diagnostic_questions where test_code = c_test and is_active and skill = 'pk')),
      'lbi', jsonb_build_object('correct', v_lbi, 'total', (select count(*) from diagnostic_questions where test_code = c_test and is_active and skill = 'lbi'))),
    'weakest', v_weakest);

  insert into diagnostic_attempts (test_code, client_session_id, answers, score, level, result, recommended_package_id)
  values (c_test, p_client_session_id, p_answers, v_score, null, v_result, v_pkg_id)
  returning id into v_attempt;

  return v_result || jsonb_build_object(
    'attempt_id', v_attempt,
    'score',      v_score,
    'total',      v_total,
    'package',    v_package);
end $$;

revoke all on function public.submit_utbk_attempt(text, jsonb) from public;
grant execute on function public.submit_utbk_attempt(text, jsonb) to anon, authenticated;

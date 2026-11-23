-- ============================================================
-- Study Buddy — Migration 002: Diagnostic (tes level English)
-- Spec: docs/superpowers/specs/2026-11-23-diagnostic-english-design.md
-- Bergantung pada tabel yang sudah ada: public.packages, public.manual_orders.
-- ============================================================

-- Teks bacaan untuk soal reading (satu teks dipakai beberapa soal)
create table public.diagnostic_passages (
  id   uuid primary key default gen_random_uuid(),
  text text not null
);

create table public.diagnostic_questions (
  id            uuid primary key default gen_random_uuid(),
  test_code     text not null,
  position      int  not null,
  skill         text not null check (skill in ('grammar', 'vocabulary', 'reading')),
  level         text not null check (level in ('A1', 'A2', 'B1', 'B2')),
  stem          text not null,
  passage_id    uuid references public.diagnostic_passages (id),
  options       jsonb not null,
  correct_index int  not null check (correct_index >= 0),
  explanation   text not null,
  is_active     boolean not null default true,
  unique (test_code, position)
);

-- Aturan level -> paket. package_id boleh null (belum dipetakan).
create table public.diagnostic_rules (
  test_code  text not null,
  level      text not null check (level in ('PRE_A1', 'A1', 'A2', 'B1', 'B2')),
  package_id uuid references public.packages (id) on delete set null,
  reason     text not null,
  primary key (test_code, level)
);

create table public.diagnostic_attempts (
  id                     uuid primary key default gen_random_uuid(),
  test_code              text not null,
  client_session_id      text not null,
  answers                jsonb not null,
  score                  int  not null,
  level                  text not null,
  recommended_package_id uuid references public.packages (id) on delete set null,
  created_at             timestamptz not null default now()
);
create index diagnostic_attempts_session_idx on public.diagnostic_attempts (client_session_id, created_at);
create index diagnostic_attempts_created_idx on public.diagnostic_attempts (created_at desc);

-- Tautkan order ke hasil tes (nullable: order lama tidak terpengaruh)
alter table public.manual_orders
  add column if not exists diagnostic_attempt_id uuid references public.diagnostic_attempts (id) on delete set null,
  add column if not exists package_id uuid references public.packages (id) on delete set null;

-- Level = level tertinggi berurutan A1 -> B2 yang benar >= ambang;
-- berhenti di level pertama yang gagal (level di atasnya diabaikan).
create or replace function public.diagnostic_level(
  p_a1 int, p_a2 int, p_b1 int, p_b2 int, p_threshold int default 4
) returns text
language plpgsql immutable
as $$
begin
  if p_a1 < p_threshold then return 'PRE_A1'; end if;
  if p_a2 < p_threshold then return 'A1'; end if;
  if p_b1 < p_threshold then return 'A2'; end if;
  if p_b2 < p_threshold then return 'B1'; end if;
  return 'B2';
end $$;

-- ---------- Keamanan ----------
-- Tabel dasar tertutup untuk pengunjung. Tanpa policy untuk anon, RLS menolak semuanya;
-- hak dicabut juga sebagai lapisan kedua.
alter table public.diagnostic_passages  enable row level security;
alter table public.diagnostic_questions enable row level security;
alter table public.diagnostic_rules     enable row level security;
alter table public.diagnostic_attempts  enable row level security;

revoke all on public.diagnostic_passages, public.diagnostic_questions,
              public.diagnostic_rules, public.diagnostic_attempts from anon, authenticated;

-- Admin (users.role 'admin' dipakai web admin, 'management' ada di migration 001) boleh membaca attempts.
grant select on public.diagnostic_attempts to authenticated;
create policy diagnostic_attempts_admin_read on public.diagnostic_attempts
  for select to authenticated
  using (exists (select 1 from public.users u where u.id = auth.uid() and u.role in ('admin', 'management')));

-- View publik: hanya soal aktif, tanpa correct_index dan explanation.
-- Berjalan dengan hak pemilik (security_invoker = false) agar bisa membaca tabel yang tertutup.
create view public.diagnostic_questions_public
  with (security_invoker = false) as
select q.id, q.test_code, q.position, q.skill, q.level, q.stem,
       p.text as passage, q.options
from public.diagnostic_questions q
left join public.diagnostic_passages p on p.id = q.passage_id
where q.is_active;

revoke all on public.diagnostic_questions_public from anon, authenticated;
grant select on public.diagnostic_questions_public to anon, authenticated;

-- ---------- RPC: submit_diagnostic_attempt ----------
-- Menilai jawaban di server. Kunci jawaban dan penjelasan tidak pernah dikembalikan.
-- p_answers: {"<question_id>": <indeks opsi>} untuk SEMUA soal aktif tes tersebut.
-- Error (pesan = kode): invalid_session, unknown_test, rate_limited, invalid_answers.
create or replace function public.submit_diagnostic_attempt(
  p_test_code text, p_client_session_id text, p_answers jsonb
) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  c_threshold    constant int := 4;   -- benar minimal per level (dari 6 soal)
  c_max_per_hour constant int := 5;   -- batas attempt per sesi per jam
  v_total   int;
  v_a1 int; v_a2 int; v_b1 int; v_b2 int;
  v_level   text;
  v_package jsonb;
  v_pkg_id  uuid;
  v_tutors  jsonb;
  v_attempt uuid;
begin
  if p_client_session_id is null or btrim(p_client_session_id) = '' or length(p_client_session_id) > 100 then
    raise exception 'invalid_session';
  end if;

  select count(*) into v_total from diagnostic_questions where test_code = p_test_code and is_active;
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
       where q.test_code = p_test_code and q.is_active
         and case
               when not (p_answers ? q.id::text) then true
               when jsonb_typeof(p_answers -> q.id::text) <> 'number' then true
               when (p_answers ->> q.id::text) !~ '^[0-9]{1,6}$' then true
               else (p_answers ->> q.id::text)::int >= jsonb_array_length(q.options)
             end
     ) then
    raise exception 'invalid_answers';
  end if;

  select count(*) filter (where q.level = 'A1' and (p_answers ->> q.id::text)::int = q.correct_index),
         count(*) filter (where q.level = 'A2' and (p_answers ->> q.id::text)::int = q.correct_index),
         count(*) filter (where q.level = 'B1' and (p_answers ->> q.id::text)::int = q.correct_index),
         count(*) filter (where q.level = 'B2' and (p_answers ->> q.id::text)::int = q.correct_index)
    into v_a1, v_a2, v_b1, v_b2
  from diagnostic_questions q where q.test_code = p_test_code and q.is_active;

  v_level := diagnostic_level(v_a1, v_a2, v_b1, v_b2, c_threshold);

  select p.id,
         jsonb_build_object('id', p.id, 'package_name', p.package_name, 'price', p.price, 'reason', r.reason)
    into v_pkg_id, v_package
  from diagnostic_rules r
  join packages p on p.id = r.package_id and p.is_active
  where r.test_code = p_test_code and r.level = v_level;

  select coalesce(jsonb_agg(jsonb_build_object('id', t.id, 'full_name', t.full_name,
                                               'university', t.university, 'avatar_url', t.avatar_url)
                            order by t.is_featured desc nulls last, t.rating desc nulls last, t.full_name), '[]'::jsonb)
    into v_tutors
  from (
    select id, full_name, university, avatar_url, is_featured, rating
    from tutors
    where verification_status = 'verified'
      and exists (select 1 from unnest(coalesce(subjects, '{}')) s
                  where lower(s) in ('ing', 'bahasa inggris', 'english'))
    order by is_featured desc nulls last, rating desc nulls last, full_name
    limit 3
  ) t;

  insert into diagnostic_attempts (test_code, client_session_id, answers, score, level, recommended_package_id)
  values (p_test_code, p_client_session_id, p_answers, v_a1 + v_a2 + v_b1 + v_b2, v_level, v_pkg_id)
  returning id into v_attempt;

  return jsonb_build_object(
    'attempt_id', v_attempt,
    'score',      v_a1 + v_a2 + v_b1 + v_b2,
    'total',      v_total,
    'level',      v_level,
    'package',    v_package,
    'tutors',     v_tutors,
    'per_level',  jsonb_build_object('A1', v_a1, 'A2', v_a2, 'B1', v_b1, 'B2', v_b2)
  );
end $$;

revoke all on function public.submit_diagnostic_attempt(text, text, jsonb) from public;
grant execute on function public.submit_diagnostic_attempt(text, text, jsonb) to anon, authenticated;

-- ---------- RPC: diagnostic_stats (hanya admin/management) ----------
create or replace function public.diagnostic_stats() returns jsonb
language plpgsql security definer
set search_path = public
as $$
begin
  if not exists (select 1 from users where id = auth.uid() and role in ('admin', 'management')) then
    raise exception 'forbidden';
  end if;

  return jsonb_build_object(
    'total_attempts', (select count(*) from diagnostic_attempts),
    'by_level', (select jsonb_build_object(
        'PRE_A1', count(*) filter (where level = 'PRE_A1'),
        'A1',     count(*) filter (where level = 'A1'),
        'A2',     count(*) filter (where level = 'A2'),
        'B1',     count(*) filter (where level = 'B1'),
        'B2',     count(*) filter (where level = 'B2'))
      from diagnostic_attempts),
    'orders_from_tests', (select count(*) from manual_orders where diagnostic_attempt_id is not null),
    'recent', (select coalesce(jsonb_agg(x order by x_created desc), '[]'::jsonb) from (
        select jsonb_build_object('id', a.id, 'level', a.level, 'score', a.score, 'created_at', a.created_at,
                 'ordered', exists (select 1 from manual_orders o where o.diagnostic_attempt_id = a.id)) as x,
               a.created_at as x_created
        from diagnostic_attempts a order by a.created_at desc limit 20) r)
  );
end $$;

revoke all on function public.diagnostic_stats() from public;
grant execute on function public.diagnostic_stats() to authenticated;

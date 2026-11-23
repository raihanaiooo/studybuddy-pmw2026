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

-- Admin (users.role = 'management') boleh membaca attempts.
grant select on public.diagnostic_attempts to authenticated;
create policy diagnostic_attempts_admin_read on public.diagnostic_attempts
  for select to authenticated
  using (exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'management'));

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

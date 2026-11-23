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

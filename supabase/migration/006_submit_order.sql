-- ============================================================
-- Study Buddy — Migration 006: order dari landing lewat RPC bervalidasi
-- Sebelumnya form order menulis langsung ke manual_orders dengan kunci publik, tanpa validasi
-- dan tanpa batas laju (bisa dispam). Sekarang pengunjung hanya lewat submit_order;
-- admin (pengguna login) tetap menulis langsung lewat panel.
-- ============================================================

alter table public.manual_orders add column if not exists client_session_id text;
create index if not exists manual_orders_session_idx on public.manual_orders (client_session_id, created_at desc);

-- Kode kesalahan: invalid_session, invalid_data, rate_limited, invalid_input:<kolom>, duplicate.
create or replace function public.submit_order(p_client_session_id text, p_data jsonb)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  c_max_per_hour constant int := 5;
  v_name    text;
  v_wa      text;
  v_subject text;
  v_jenjang text;
  v_notes   text;
  v_attempt uuid;
  v_package uuid;
  v_id      uuid;
begin
  if p_client_session_id is null or btrim(p_client_session_id) = '' or length(p_client_session_id) > 100 then
    raise exception 'invalid_session';
  end if;
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'invalid_data';
  end if;

  if (select count(*) from manual_orders
       where client_session_id = p_client_session_id and created_at > now() - interval '1 hour') >= c_max_per_hour then
    raise exception 'rate_limited';
  end if;

  if jsonb_typeof(p_data -> 'nama') is distinct from 'string' then raise exception 'invalid_input:nama'; end if;
  v_name := btrim(p_data ->> 'nama');
  if length(v_name) < 2 or length(v_name) > 100 then raise exception 'invalid_input:nama'; end if;

  if jsonb_typeof(p_data -> 'wa') is distinct from 'string' then raise exception 'invalid_input:wa'; end if;
  v_wa := regexp_replace(p_data ->> 'wa', '[\s\-\.\(\)]', '', 'g');
  v_wa := regexp_replace(v_wa, '^\+', '');
  if v_wa ~ '^0' then v_wa := '62' || substr(v_wa, 2); end if;
  if v_wa !~ '^62[0-9]{8,13}$' then raise exception 'invalid_input:wa'; end if;

  if jsonb_typeof(p_data -> 'mapel') is distinct from 'string' then raise exception 'invalid_input:mapel'; end if;
  v_subject := btrim(p_data ->> 'mapel');
  if length(v_subject) < 1 or length(v_subject) > 50 then raise exception 'invalid_input:mapel'; end if;

  if jsonb_typeof(p_data -> 'jenjang') is distinct from 'string' then raise exception 'invalid_input:jenjang'; end if;
  v_jenjang := btrim(p_data ->> 'jenjang');
  if length(v_jenjang) < 1 or length(v_jenjang) > 30 then raise exception 'invalid_input:jenjang'; end if;

  if p_data ? 'notes' and jsonb_typeof(p_data -> 'notes') <> 'null' then
    if jsonb_typeof(p_data -> 'notes') <> 'string' or length(p_data ->> 'notes') > 500 then raise exception 'invalid_input:notes'; end if;
    v_notes := nullif(btrim(p_data ->> 'notes'), '');
  end if;

  if p_data ? 'diagnostic_attempt_id' and jsonb_typeof(p_data -> 'diagnostic_attempt_id') <> 'null' then
    if jsonb_typeof(p_data -> 'diagnostic_attempt_id') <> 'string'
       or (p_data ->> 'diagnostic_attempt_id') !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
      raise exception 'invalid_input:diagnostic_attempt_id';
    end if;
    v_attempt := (p_data ->> 'diagnostic_attempt_id')::uuid;
    if not exists (select 1 from diagnostic_attempts where id = v_attempt) then raise exception 'invalid_input:diagnostic_attempt_id'; end if;
  end if;

  if p_data ? 'package_id' and jsonb_typeof(p_data -> 'package_id') <> 'null' then
    if jsonb_typeof(p_data -> 'package_id') <> 'string'
       or (p_data ->> 'package_id') !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
      raise exception 'invalid_input:package_id';
    end if;
    v_package := (p_data ->> 'package_id')::uuid;
    if not exists (select 1 from packages where id = v_package and is_active) then raise exception 'invalid_input:package_id'; end if;
  end if;

  if exists (select 1 from manual_orders
              where whatsapp = v_wa and subject = v_subject and status = 'pending' and created_at > now() - interval '1 hour') then
    raise exception 'duplicate';
  end if;

  insert into manual_orders (name, whatsapp, subject, jenjang, notes, status, diagnostic_attempt_id, package_id, client_session_id)
  values (v_name, v_wa, v_subject, v_jenjang, v_notes, 'pending', v_attempt, v_package, p_client_session_id)
  returning id into v_id;

  return jsonb_build_object('order_id', v_id);
end $$;

revoke all on function public.submit_order(text, jsonb) from public;
grant execute on function public.submit_order(text, jsonb) to anon, authenticated;

-- Pengunjung tidak lagi menulis atau membaca manual_orders langsung. Pengguna login tidak terpengaruh.
revoke insert, select on public.manual_orders from anon;

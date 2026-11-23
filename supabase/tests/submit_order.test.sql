-- Uji migration 006: order dari landing lewat RPC bervalidasi; anon tidak lagi menulis langsung ke manual_orders.
create schema th;
grant usage on schema th to anon, authenticated;

create or replace function th.ok(p_session text, p_override jsonb default '{}'::jsonb) returns jsonb
language sql as $f$
  select public.submit_order(p_session,
    jsonb_build_object('nama','Rani','wa','0812-3456-7890','mapel','Matematika','jenjang','SMA') || p_override)
$f$;

create or replace function th.msg(p_session text, p_override jsonb) returns text
language plpgsql as $f$
begin
  perform th.ok(p_session, p_override); return 'tidak ada error';
exception when others then return sqlerrm;
end $f$;

do $$
declare r jsonb; n int; m text; ditolak boolean;
  v_attempt uuid := '00000000-0000-0000-0000-0000000000c1';
  v_pkg     uuid := '00000000-0000-0000-0000-0000000000d1';
  v_pkg_off uuid := '00000000-0000-0000-0000-0000000000d2';
begin
  grant execute on function th.ok(text, jsonb), th.msg(text, jsonb) to anon, authenticated;
  insert into public.packages (id, package_name, price, is_active) values (v_pkg, 'Paket Uji', 100000, true), (v_pkg_off, 'Paket Mati', 100000, false);
  insert into public.diagnostic_attempts (id, test_code, client_session_id, answers, score, level)
  values (v_attempt, 'english', 'sesi-tes', '{}'::jsonb, 10, 'A2');

  -- sukses: WhatsApp dinormalkan ke 62..., status pending, sesi tersimpan
  set local role anon;
  r := th.ok('o-ok');
  reset role;
  if r->>'order_id' is null then raise exception 'GAGAL [sukses]: tanpa order_id: %', r; end if;
  select count(*) into n from public.manual_orders
   where id = (r->>'order_id')::uuid and status = 'pending' and whatsapp = '6281234567890'
     and name = 'Rani' and subject = 'Matematika' and jenjang = 'SMA' and client_session_id = 'o-ok';
  if n <> 1 then raise exception 'GAGAL [simpan]: baris order tidak sesuai'; end if;

  -- sukses dengan tautan tes, paket aktif, dan catatan
  set local role anon;
  r := th.ok('o-link', jsonb_build_object('wa', '081300000001', 'diagnostic_attempt_id', v_attempt, 'package_id', v_pkg, 'notes', 'Tutor pilihan: Alya'));
  reset role;
  select count(*) into n from public.manual_orders
   where id = (r->>'order_id')::uuid and diagnostic_attempt_id = v_attempt and package_id = v_pkg and notes = 'Tutor pilihan: Alya';
  if n <> 1 then raise exception 'GAGAL [tautan]: attempt, paket, atau catatan tidak tersimpan'; end if;

  -- validasi
  set local role anon;
  m := th.msg('o-v1', '{"nama":" "}');
  if m <> 'invalid_input:nama' then reset role; raise exception 'GAGAL [nama]: %', m; end if;
  m := th.msg('o-v2', '{"wa":"123"}');
  if m <> 'invalid_input:wa' then reset role; raise exception 'GAGAL [wa]: %', m; end if;
  m := th.msg('o-v3', '{"mapel":""}');
  if m <> 'invalid_input:mapel' then reset role; raise exception 'GAGAL [mapel]: %', m; end if;
  m := th.msg('o-v4', jsonb_build_object('mapel', repeat('x', 51)));
  if m <> 'invalid_input:mapel' then reset role; raise exception 'GAGAL [mapel panjang]: %', m; end if;
  m := th.msg('o-v5', '{"jenjang":""}');
  if m <> 'invalid_input:jenjang' then reset role; raise exception 'GAGAL [jenjang]: %', m; end if;
  m := th.msg('o-v6', jsonb_build_object('notes', repeat('x', 501)));
  if m <> 'invalid_input:notes' then reset role; raise exception 'GAGAL [notes]: %', m; end if;
  m := th.msg('o-v7', '{"diagnostic_attempt_id":"bukan-uuid"}');
  if m <> 'invalid_input:diagnostic_attempt_id' then reset role; raise exception 'GAGAL [attempt bukan uuid]: %', m; end if;
  m := th.msg('o-v8', '{"diagnostic_attempt_id":"00000000-0000-0000-0000-0000000000ff"}');
  if m <> 'invalid_input:diagnostic_attempt_id' then reset role; raise exception 'GAGAL [attempt tak ada]: %', m; end if;
  m := th.msg('o-v9', jsonb_build_object('package_id', v_pkg_off));
  if m <> 'invalid_input:package_id' then reset role; raise exception 'GAGAL [paket nonaktif]: %', m; end if;
  m := th.msg('', '{}');
  if m <> 'invalid_session' then reset role; raise exception 'GAGAL [sesi kosong]: %', m; end if;
  reset role;

  -- ganda: WhatsApp dan mapel sama, masih pending dalam 1 jam
  set local role anon;
  m := th.msg('o-dup', '{}');
  reset role;
  if m <> 'duplicate' then raise exception 'GAGAL [duplikat]: %', m; end if;

  -- batas laju: 5 order per jam per sesi
  set local role anon;
  perform th.ok('o-rate', '{"wa":"081400000001"}');
  perform th.ok('o-rate', '{"wa":"081400000002"}');
  perform th.ok('o-rate', '{"wa":"081400000003"}');
  perform th.ok('o-rate', '{"wa":"081400000004"}');
  perform th.ok('o-rate', '{"wa":"081400000005"}');
  m := th.msg('o-rate', '{"wa":"081400000006"}');
  reset role;
  if m <> 'rate_limited' then raise exception 'GAGAL [laju]: %', m; end if;

  -- anon tidak boleh menulis atau membaca manual_orders langsung
  set local role anon;
  ditolak := false;
  begin
    insert into public.manual_orders (name, whatsapp, subject, jenjang) values ('Spam', '1', 'x', 'y');
  exception when insufficient_privilege then ditolak := true; end;
  reset role;
  if not ditolak then raise exception 'GAGAL [insert langsung]: anon masih bisa menulis ke manual_orders'; end if;

  -- pengguna login (admin lewat web) tetap bisa menulis langsung
  set local role authenticated;
  insert into public.manual_orders (name, whatsapp, subject, jenjang) values ('Dari admin', '62811', 'Fisika', 'SMP');
  reset role;

  raise notice ' OK: submit_order.test.sql (migration 006)';
end $$;

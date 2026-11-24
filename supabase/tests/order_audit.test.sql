-- Uji migration 009 (bagian audit): setiap perubahan penting tercatat; log hanya bisa dibaca admin.
\i order_stubs.sql
\i ../migration/009_order_inti.sql

do $$
declare
  admin_id uuid := '00000000-0000-0000-0000-00000000ad01';
  user_id  uuid := '00000000-0000-0000-0000-0000000000b1';
  tutor_id uuid := '00000000-0000-0000-0000-0000000000d1';
  ord uuid := '00000000-0000-0000-0000-0000000000a1';
  m text; n bigint; r record;
begin
  insert into public.users (id, role, full_name) values (admin_id, 'admin', 'Admin'), (user_id, 'buddy', 'Buddy');
  insert into public.tutors (id, user_id, full_name) values (tutor_id, user_id, 'Tutor A');
  delete from public.audit_log;

  -- [insert tercatat]
  m := th.as_user('authenticated', admin_id, format($q$insert into public.orders (id, form_no, buddy_name, service_name, sessions_total, price_per_session) values (%L, 'FO001', 'Budi', 'Kelas', 3, 1000)$q$, ord));
  if m <> 'ok' then raise exception 'GAGAL [insert order]: %', m; end if;
  select * into r from public.audit_log where table_name = 'orders' and row_id = ord::text and action = 'insert';
  if not found then raise exception 'GAGAL [insert tercatat]'; end if;
  if r.new_row ->> 'form_no' <> 'FO001' or r.old_row is not null then raise exception 'GAGAL [insert isi]'; end if;
  if r.actor is distinct from admin_id then raise exception 'GAGAL [insert pelaku]: %', r.actor; end if;

  -- [update tercatat]
  m := th.as_user('authenticated', admin_id, format($q$update public.orders set notes = 'baru' where id = %L$q$, ord));
  select * into r from public.audit_log where table_name = 'orders' and action = 'update' and row_id = ord::text;
  if not found or r.old_row ->> 'notes' is not null or r.new_row ->> 'notes' <> 'baru' then raise exception 'GAGAL [update tercatat]'; end if;

  -- [tanpa perubahan tidak dicatat]
  select count(*) into n from public.audit_log where table_name = 'orders' and action = 'update';
  m := th.as_user('authenticated', admin_id, format($q$update public.orders set notes = 'baru' where id = %L$q$, ord));
  if (select count(*) from public.audit_log where table_name = 'orders' and action = 'update') <> n then raise exception 'GAGAL [update kosong dicatat]'; end if;

  -- [hapus lunak]
  m := th.as_user('authenticated', admin_id, format($q$update public.orders set deleted_at = now() where id = %L$q$, ord));
  if not exists (select 1 from public.audit_log where table_name = 'orders' and action = 'delete' and row_id = ord::text) then
    raise exception 'GAGAL [hapus lunak tercatat]';
  end if;

  -- [pengaturan memakai kunci sebagai id]
  m := th.as_user('authenticated', admin_id, $q$update public.app_settings set value = '65' where key = 'tutor_pct'$q$);
  if not exists (select 1 from public.audit_log where table_name = 'app_settings' and row_id = 'tutor_pct' and action = 'update') then
    raise exception 'GAGAL [pengaturan tercatat]';
  end if;

  -- [perubahan tutor]
  m := th.as_user('authenticated', admin_id, format($q$update public.tutors set is_featured = true where id = %L$q$, tutor_id));
  if not exists (select 1 from public.audit_log where table_name = 'tutors' and action = 'update' and (new_row ->> 'is_featured') = 'true') then
    raise exception 'GAGAL [perubahan tutor tercatat]';
  end if;


  -- [status online tutor tidak membanjiri log]
  select count(*) into n from public.audit_log where table_name = 'tutors';
  update public.tutors set is_online = true, last_seen = now() where id = tutor_id;
  if (select count(*) from public.audit_log where table_name = 'tutors') <> n then raise exception 'GAGAL [online tercatat]'; end if;

  -- [perubahan pelamar]
  insert into public.tutor_applications (full_name) values ('Calon');
  update public.tutor_applications set status = 'ditolak' where full_name = 'Calon';
  if not exists (select 1 from public.audit_log where table_name = 'tutor_applications' and action = 'update') then
    raise exception 'GAGAL [pelamar tercatat]';
  end if;

  -- [log hanya dibaca admin]
  select count(*) into n from public.audit_log;
  if n = 0 then raise exception 'GAGAL [log kosong]'; end if;
  if th.count_as('authenticated', admin_id, 'select count(*) from public.audit_log') <> n then raise exception 'GAGAL [admin baca log]'; end if;
  if th.count_as('authenticated', user_id, 'select count(*) from public.audit_log') <> 0 then raise exception 'GAGAL [bukan admin baca log]'; end if;
  m := th.as_user('anon', null, 'select count(*) from public.audit_log');
  if m not like 'permission denied%' then raise exception 'GAGAL [anon baca log]: %', m; end if;
  m := th.as_user('authenticated', admin_id, $q$insert into public.audit_log (table_name, row_id, action) values ('x', 'y', 'insert')$q$);
  if m not like 'permission denied%' then raise exception 'GAGAL [admin tulis log]: %', m; end if;
  m := th.as_user('authenticated', admin_id, 'update public.audit_log set action = ''x''');
  if m not like 'permission denied%' then raise exception 'GAGAL [admin ubah log]: %', m; end if;
  m := th.as_user('authenticated', admin_id, 'delete from public.audit_log');
  if m not like 'permission denied%' then raise exception 'GAGAL [admin hapus log]: %', m; end if;

  raise notice ' OK: order_audit.test.sql (migration 009 bagian audit)';
end $$;

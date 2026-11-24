-- Study Buddy — Migration 010: tutor tanpa akun dan penerimaan pelamar dalam satu transaksi
-- Tutor tidak perlu akun (dikonfirmasi tim 2026-11-24): profil tutor dibuat admin tanpa Auth dan tanpa email.
-- accept_application menggantikan alur "Verifikasi dan buat akun" (edge function create-tutor tetap ada untuk tambah manual).
-- Aman dijalankan berulang. Berlaku setelah migration 009.

-- ============================================================
-- 1. Tabel tutors: boleh tanpa akun, dan atribut operasional
-- ============================================================
alter table public.tutors alter column user_id drop not null;
alter table public.tutors add column if not exists is_outsourced boolean not null default false;
alter table public.tutors add column if not exists application_id uuid references public.tutor_applications(id) on delete set null;
create unique index if not exists tutors_application_id_key on public.tutors (application_id) where application_id is not null;

-- Data pribadi tutor (WhatsApp, email, rekening pembayaran) di tabel terpisah yang hanya bisa dibaca admin:
-- tabel tutors bisa dibaca semua pengguna yang login (policy tutors_select_all), jadi tidak boleh memuat data ini.
create table if not exists public.tutor_private (
  tutor_id       uuid primary key references public.tutors(id) on delete cascade,
  whatsapp       text,
  email          text,
  payout_account text,
  updated_at     timestamptz not null default now()
);
alter table public.tutor_private enable row level security;
revoke all on public.tutor_private from anon, authenticated;
grant select, insert, update on public.tutor_private to authenticated;
drop policy if exists tutor_private_admin on public.tutor_private;
create policy tutor_private_admin on public.tutor_private for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
drop trigger if exists trg_audit on public.tutor_private;
create trigger trg_audit after insert or update or delete on public.tutor_private
  for each row execute function public.audit_row();

-- Dokumen pelamar yang diterima tidak disalin: barisnya menunjuk ke berkas di bucket tutor-applications.
alter table public.tutor_documents add column if not exists storage_bucket text not null default 'documents';

-- ============================================================
-- 2. accept_application: semua atau tidak sama sekali
-- ============================================================
-- Kode kesalahan: bukan_admin, harga_tidak_valid, pelamar_tidak_valid.
-- Dokumen: baris yang sudah ditabur trigger (fn_seed_tutor_documents) diperbarui, bila belum ada ditambahkan,
-- sehingga tidak pernah ada dua baris untuk jenis dokumen yang sama.
create or replace function public.accept_application(p_id uuid, p_price numeric) returns uuid
language plpgsql security definer
set search_path = public
as $$
declare
  v_app    public.tutor_applications%rowtype;
  v_tutor  uuid;
  v_type   text;
  v_path   text;
  v_label  text;
  v_rows   int;
begin
  if not public.is_admin() then raise exception 'bukan_admin'; end if;
  if p_price is null or p_price <= 0 then raise exception 'harga_tidak_valid'; end if;

  select * into v_app from public.tutor_applications where id = p_id for update;
  if not found or v_app.status <> 'baru' then raise exception 'pelamar_tidak_valid'; end if;

  insert into public.tutors (full_name, university, subjects, jenjang_diajar, price_per_hour,
                             verification_status, account_status, is_featured, application_id)
  values (v_app.full_name, v_app.university, v_app.subjects, v_app.jenjang, p_price,
          'verified', 'active', false, v_app.id)
  returning id into v_tutor;
  insert into public.tutor_private (tutor_id, whatsapp, email) values (v_tutor, v_app.whatsapp, v_app.email);

  for v_type, v_path in select key, value from jsonb_each_text(v_app.documents) loop
    v_label := case v_type
      when 'transkrip' then 'Transkrip Nilai'
      when 'kartu_identitas_pelajar' then 'KTM / Kartu Tanda Pelajar'
      when 'sertifikat_prestasi' then 'Sertifikat Prestasi'
      when 'sertifikat_bahasa' then 'Sertifikat Bahasa'
    end;
    continue when v_label is null or v_path is null;

    update public.tutor_documents
       set file_url = v_path, storage_bucket = 'tutor-applications', status = 'terverifikasi',
           rejection_note = null, label = v_label, uploaded_at = now()
     where tutor_id = v_tutor and jenis_dokumen = v_type;
    get diagnostics v_rows = row_count;
    if v_rows = 0 then
      insert into public.tutor_documents (tutor_id, jenis_dokumen, label, file_url, storage_bucket, status, uploaded_at)
      values (v_tutor, v_type, v_label, v_path, 'tutor-applications', 'terverifikasi', now());
    end if;
  end loop;

  update public.tutor_applications
     set status = 'diterima', handled_by = auth.uid(), handled_at = now()
   where id = p_id;

  return v_tutor;
end $$;
revoke execute on function public.accept_application(uuid, numeric) from public, anon;
grant execute on function public.accept_application(uuid, numeric) to authenticated;

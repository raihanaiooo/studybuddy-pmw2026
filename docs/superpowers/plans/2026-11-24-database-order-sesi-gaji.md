# Database Order, Sesi, dan Gaji (Tahap 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tabel, aturan bisnis, dan fungsi di database untuk order resmi, sesi per tutor, penyesuaian, pembayaran, komplain, pengaturan, audit, tutor tanpa akun, terima pelamar, dan payroll bulanan, lengkap dengan uji SQL dan berkas apply/verify/rollback untuk Rifky.

**Architecture:** Tiga migration berurutan (009 inti order, 010 tutor tanpa akun, 011 payroll) yang diuji di PostgreSQL lokal sekali pakai dengan pola `supabase/tests`. Aturan hitung (jumlah sesi, status selesai, pembagian 70/30, payroll) hidup di trigger dan fungsi SQL, bukan di browser. Semua tabel baru hanya bisa dibaca dan ditulis admin (`is_admin()`).

**Tech Stack:** PostgreSQL (Supabase), PL/pgSQL, uji SQL `run-each.sh`.

**Spec:** `docs/superpowers/specs/2026-11-24-order-sesi-gaji-design.md` (bagian 5, 6, 10, 11).

## Global Constraints

- Tanpa perubahan di `web/` pada tahap ini; Rifky yang menjalankan SQL di Supabase SQL Editor. Jangan menyentuh database nyata.
- Bahasa Indonesia untuk komentar SQL, pesan uji, dan nama berkas apply. Nama tabel dan kolom mengikuti spec bagian 5 (Inggris).
- Setiap tabel baru: `enable row level security`, `revoke all ... from anon, authenticated`, lalu `grant select, insert, update` ke `authenticated` (tanpa `delete`) dan satu policy `for all to authenticated using (public.is_admin()) with check (public.is_admin())`. Hapus lewat kolom `deleted_at`.
- Uang `numeric(14,2)`, jumlah sesi `int`, waktu `timestamptz`, tanggal `date`. Bagi hasil bawaan 70% tutor (kunci `tutor_pct`); pembulatan 2 desimal per baris.
- Fungsi `security definer` wajib `set search_path = public` dan memeriksa `public.is_admin()` di awal (kecuali trigger).
- Migration idempotent (`if not exists`, `create or replace`, `drop ... if exists`) agar aman dijalankan dua kali, seperti 008.
- Uji dijalankan di PostgreSQL sekali pakai: `PGHOST=localhost PGPORT=54329 PGUSER=postgres bash supabase/tests/run-each.sh <berkas>` dari root repo (server dijalankan dengan `pg_ctl -D <scratchpad>/pgtest start -o "-p 54329"`, dan dihentikan di akhir).
- Komit hanya bila Rifky meminta.

## Review Focus

- Sesi hasil impor yang tanggalnya teks bebas (`session_date` kosong) tetap masuk payroll, memakai tanggal order sebagai jatuh tempo.
- `generate_payroll` dipanggil dua kali untuk bulan yang sama tidak menggandakan sesi; payroll yang sudah ada transfernya tidak berubah, dan sesi yang telat dibawa ke bulan berikutnya.
- Sesi atau penyesuaian berstatus `deleted_at` tidak ikut hitungan (ringkasan order, payroll, status selesai).
- `accept_application` tidak menghasilkan dokumen ganda walau trigger `fn_seed_tutor_documents` (isinya belum dibaca) sudah membuat baris dokumen kosong; pelamar yang bukan `baru` dan pemanggil non-admin ditolak.
- Penerima `kas` (FO033) tidak pernah masuk payroll tutor, tetapi tetap dihitung di pendapatan order.

---

### Task 1: Tabel inti, pengaturan awal, dan kerangka uji

**Files:**
- Create: `supabase/tests/order_stubs.sql` (stub tambahan: `payroll_records`, `tutor_documents` dengan trigger penabur dokumen kosong, `tutor_applications`, kolom `packages`/`users`/`tutors` seperti di database nyata, `tutors.user_id` NOT NULL, `is_admin()`), `supabase/migration/009_order_inti.sql`, `supabase/tests/order_inti.test.sql`

**Interfaces:**
- Produces tabel (kolom persis spec bagian 5): `orders`, `order_sessions`, `order_adjustments` (+ kolom `payroll_id uuid` yang tidak ada di spec, untuk mencegah hitung ganda), `order_payments`, `order_complaints`, `app_settings`; kolom baru `packages.category text`, `packages.kind text default 'paket' check in ('paket','lepas')`, `packages.default_duration_minutes int`.
- `app_settings` berisi nilai awal: `tutor_pct`=70, `reschedule_hours`=6, `late_tolerance_minutes`=15, `payout_day`=null, `wa_templates`={}, `business`={}.
- `public.setting_num(p_key text, p_default numeric) returns numeric` (membaca `app_settings.value`; bawaan bila kunci tidak ada).
- Batasan: `order_sessions.recipient in ('tutor','kas')` dan `tutor_id` wajib bila `tutor` (check); `sessions_count >= 1`; `status` sesuai spec; `orders.status in ('progress','done','batal')`; `orders.form_no` unik.

- [ ] **Step 1: Tulis uji gagal** `order_inti.test.sql` (memuat `\i order_stubs.sql` dan `\i ../migration/009_order_inti.sql`) dengan pemeriksaan bernama: `[rls aktif]` semua tabel baru `relrowsecurity`; `[anon tertutup]` peran `anon` tidak bisa `select` tiap tabel baru; `[bukan admin tertutup]` `authenticated` tanpa `role='admin'` melihat 0 baris dan gagal `insert`; `[admin boleh]` admin bisa insert order, sesi, penyesuaian, pembayaran, komplain; `[tanpa delete]` `authenticated` admin gagal `delete from orders` (izin ditolak); `[kas tanpa tutor]` sesi `recipient='kas'` tanpa `tutor_id` diterima, `recipient='tutor'` tanpa `tutor_id` ditolak; `[sesi minimal 1]` `sessions_count = 0` ditolak; `[setting awal]` `setting_num('tutor_pct', 0)` = 70 dan `setting_num('tidak_ada', 5)` = 5; `[idempotent]` memuat 009 dua kali tanpa galat. Pola tiap pemeriksaan mengikuti `hak_akses.test.sql` (pesan `GAGAL [nama]` bila salah, `OK` di akhir).
- [ ] **Step 2: Jalankan** `run-each.sh order_inti.test.sql`. Expected: gagal (berkas 009 belum ada).
- [ ] **Step 3: Tulis** `order_stubs.sql` dan `009_order_inti.sql` sesuai Interfaces dan Global Constraints.
- [ ] **Step 4: Jalankan** perintah yang sama. Expected: baris `OK` tanpa `GAGAL`/`ERROR`.

### Task 2: Aturan order (nomor FO, jatuh tempo, pendapatan sesi, selesai otomatis, ringkasan)

**Files:**
- Modify: `supabase/migration/009_order_inti.sql`
- Test: `supabase/tests/order_aturan.test.sql`

**Interfaces:**
- Consumes: tabel dan `setting_num` dari Task 1.
- Produces: `public.next_form_no() returns text` (`FO` + angka terbesar dari `form_no` + 1, minimal 3 digit; `FO001` bila kosong); trigger `before insert` pada `orders` yang mengisi `form_no` bila kosong, `valid_until` bila kosong (= `ordered_at::date` + `packages.validity_days` bila `package_id` ada, selain itu `null`), `reschedule_quota` bila kosong (dari paket, selain itu 0), `total_price` bila kosong (= `price_per_session * sessions_total`); trigger `before insert or update` pada `order_sessions` yang mengisi `rate` dari order bila kosong, `tutor_pct` dari `setting_num('tutor_pct',70)` bila kosong, dan `amount = round(rate * sessions_count, 2)`; `public.refresh_order_status(p_order uuid) returns void` (order berstatus `progress` menjadi `done` dengan `completed_at = now()` bila jumlah `sessions_count` sesi `selesai` tak terhapus >= `sessions_total`; kembali ke `progress` bila turun; `batal` tidak disentuh), dipanggil trigger `after insert or update or delete` pada `order_sessions`; view `public.order_summary` (`security_invoker = true`) berkolom `order_id, form_no, sessions_total, sessions_done, sessions_left, revenue_total, tutor_share_total, company_share_total, paid_total, refund_total, payment_status, is_expired, reschedule_used, reschedule_over`.
  - `revenue_total` = jumlah `amount` sesi tak terhapus + jumlah penyesuaian `extend` tak terhapus; `tutor_share_total`/`company_share_total` = bagian tutor (`amount * tutor_pct/100`, penerima `kas` 0) dan sisanya; `payment_status` = `belum` (paid 0), `lunas` (paid >= `total_price` + extend), selain itu `sebagian`; `is_expired` = `status='progress'`, `valid_until < current_date`, dan `sessions_left > 0`; `reschedule_used` = jumlah `reschedule_count` sesi; `reschedule_over` = `reschedule_used > reschedule_quota`.

- [ ] **Step 1: Tulis uji gagal** `order_aturan.test.sql` dengan nilai dari spreadsheet: `[form_no otomatis]` order kosong pertama `FO001`, setelah memasukkan `FO062` manual berikutnya `FO063`; `[fo033]` order paket 16 sesi dengan `price_per_session = 24000`, sesi dibagi ke 4 penerima (3 tutor masing-masing 4 sesi dan 1 `kas` 4 sesi) memberi `amount` 96000 per baris dan `revenue_total` 384000, `tutor_share_total` 288000, `company_share_total` 96000; `[pembulatan]` `rate = 95333.33` dengan 1 sesi menyimpan `amount = 95333.33`; `[jatuh tempo]` order dari paket 35 hari memiliki `valid_until = ordered_at::date + 35`; `[selesai otomatis]` order 3 sesi menjadi `done` dengan `completed_at` terisi hanya setelah ketiganya `selesai`, kembali `progress` bila satu dibatalkan; `[sesi terhapus]` sesi dengan `deleted_at` tidak dihitung `sessions_done`; `[status bayar]` `belum`, `sebagian`, `lunas` (termasuk `extend` menaikkan target lunas); `[hangus]` `is_expired` true bila `valid_until` kemarin dan masih ada sisa sesi, false bila `done`; `[reschedule]` `reschedule_over` true bila `reschedule_count` total melebihi kuota; `[batal tetap]` order `batal` tidak menjadi `done`.
- [ ] **Step 2: Jalankan** `run-each.sh order_aturan.test.sql`. Expected: gagal.
- [ ] **Step 3: Implementasikan** fungsi, trigger, dan view di `009_order_inti.sql` sesuai Interfaces.
- [ ] **Step 4: Jalankan** uji Task 1 dan Task 2. Expected: `OK` pada keduanya.

### Task 3: Hapus lunak dan log audit

**Files:**
- Modify: `supabase/migration/009_order_inti.sql`
- Test: `supabase/tests/order_audit.test.sql`

**Interfaces:**
- Consumes: semua tabel Task 1.
- Produces: tabel `audit_log` (`id`, `table_name`, `row_id`, `action`, `old_row jsonb`, `new_row jsonb`, `actor uuid`, `at`); hanya `select` untuk admin (policy), tanpa `insert/update/delete` untuk `authenticated`; fungsi trigger `public.audit_row() returns trigger` (`security definer`, `search_path = public`) yang menulis satu baris per `insert/update/delete` dengan `actor = auth.uid()`, dipasang `after insert or update or delete` pada `orders`, `order_sessions`, `order_adjustments`, `order_payments`, `order_complaints`, `app_settings`, `payroll_records`, `payroll_transfers`, `tutors`, `tutor_applications`. Pembaruan yang hanya mengisi `deleted_at` dicatat dengan `action = 'delete'`.

- [ ] **Step 1: Tulis uji gagal** `order_audit.test.sql`: `[insert tercatat]` insert order menambah satu baris audit dengan `action='insert'`, `new_row` memuat `form_no`, dan `actor` = id admin penguji; `[update tercatat]` ubah `notes` menghasilkan `old_row` dan `new_row` berbeda; `[hapus lunak]` mengisi `deleted_at` menghasilkan `action='delete'`; `[admin hanya baca]` admin gagal `insert`, `update`, `delete` pada `audit_log`; `[bukan admin]` pengguna biasa dan `anon` tidak melihat baris; `[perubahan tutor]` mengubah `tutors.is_featured` tercatat.
- [ ] **Step 2: Jalankan** `run-each.sh order_audit.test.sql`. Expected: gagal.
- [ ] **Step 3: Implementasikan** `audit_log`, `audit_row`, dan pemasangan trigger (tabel `payroll_transfers` dipasang di Task 5, tabel lain yang belum ada ditunda dengan pemeriksaan `to_regclass` agar migration idempotent dan urutan-aman).
- [ ] **Step 4: Jalankan** uji Task 1 sampai 3. Expected: `OK` semuanya.

### Task 4: Tutor tanpa akun dan terima pelamar

**Files:**
- Create: `supabase/migration/010_tutor_tanpa_akun.sql`
- Test: `supabase/tests/terima_pelamar.test.sql`

**Interfaces:**
- Consumes: `is_admin()`, `audit_row()`, stub `tutor_applications` (kolom `documents` berbentuk `{"transkrip": "<uuid>/transkrip.pdf", ...}`) dan `tutor_documents` (stub memasang trigger penabur 4 baris `belum_upload` per tutor baru, meniru `fn_seed_tutor_documents`).
- Produces: `tutors.user_id` boleh kosong; kolom baru `tutors.whatsapp text`, `email text`, `is_outsourced boolean not null default false`, `payout_account text`, `application_id uuid` (unik, boleh kosong); `tutor_documents.storage_bucket text not null default 'documents'`; `public.accept_application(p_id uuid, p_price numeric) returns uuid` (id tutor baru).
- Perilaku `accept_application`: hanya admin (`raise exception 'bukan_admin'`); pelamar harus ada dan berstatus `baru` (`'pelamar_tidak_valid'`); `p_price` > 0 (`'harga_tidak_valid'`); membuat baris `tutors` (`user_id` null, `verification_status='verified'`, `account_status='active'`, data dari pelamar: `full_name`, `university`, `whatsapp`, `email`, `subjects`, `jenjang_diajar` = `jenjang`, `price_per_hour` = `p_price`, `application_id`); untuk tiap jenis dokumen di `documents`: bila baris dokumen jenis itu sudah ada untuk tutor tersebut (hasil trigger penabur) diubah, bila tidak ada ditambahkan, dengan `file_url` = path berkas, `storage_bucket='tutor-applications'`, `status='terverifikasi'`, `uploaded_at=now()`, `label` seperti di `create-tutor/tutorRow.ts` (`Transkrip Nilai`, `KTM / Kartu Tanda Pelajar`, `Sertifikat Prestasi`, `Sertifikat Bahasa`); mengubah pelamar menjadi `diterima` dengan `handled_by = auth.uid()` dan `handled_at = now()`. Satu transaksi: galat di tengah tidak meninggalkan tutor atau dokumen.

- [ ] **Step 1: Tulis uji gagal** `terima_pelamar.test.sql` (memuat `order_stubs.sql` dan 010; fungsi dijalankan sebagai admin lewat `set local role authenticated` + `request.jwt.claim.sub`): `[terima normal]` pelamar dengan 2 dokumen menghasilkan 1 tutor `verified` tanpa `user_id`, `price_per_hour` sesuai, pelamar `diterima`, `handled_by` terisi; `[tanpa dokumen ganda]` jumlah baris `tutor_documents` per `(tutor_id, jenis_dokumen)` selalu 1 walau trigger penabur sudah membuat baris kosong, dan baris yang punya berkas bernilai `terverifikasi` dengan `storage_bucket='tutor-applications'`; `[bukan admin]` pemanggil biasa mendapat `bukan_admin` dan data tidak berubah; `[sudah diproses]` pelamar `diterima` atau `ditolak` mendapat `pelamar_tidak_valid`; `[harga]` `0` dan `null` mendapat `harga_tidak_valid`; `[atomik]` dengan `documents` berisi nilai yang bukan teks (memicu galat di tengah) jumlah tutor dan status pelamar tetap seperti sebelum panggilan; `[dua kali]` memanggil dua kali untuk pelamar yang sama gagal pada panggilan kedua dan tidak membuat tutor kedua; `[anon]` `anon` tidak punya hak `execute`; `[tutor tanpa akun]` admin bisa `insert` tutor baru tanpa `user_id` langsung.
- [ ] **Step 2: Jalankan** `run-each.sh terima_pelamar.test.sql`. Expected: gagal.
- [ ] **Step 3: Tulis** `010_tutor_tanpa_akun.sql`: ubah kolom, tambah kolom, `create or replace function accept_application` (`revoke execute ... from public, anon`; `grant execute ... to authenticated`).
- [ ] **Step 4: Jalankan** semua uji Task 1 sampai 4. Expected: `OK` semuanya.

### Task 5: Payroll bulanan dan transfer

**Files:**
- Create: `supabase/migration/011_payroll_baru.sql`
- Test: `supabase/tests/payroll_baru.test.sql`

**Interfaces:**
- Consumes: `order_sessions`, `order_adjustments`, `orders`, `setting_num`, stub `payroll_records` (kolom nyata: `id, tutor_id, period_month, period_year, total_sessions, total_gross, total_commission, status ('pending'|'paid'), paid_at, paid_by, notes, created_at`; dengan unik `(tutor_id, period_month, period_year)` di stub).
- Produces: kolom baru `payroll_records.total_bonus`, `total_deductions`, `total_due`, `total_transferred` (semua `numeric(14,2) not null default 0`); tabel `payroll_transfers` (`id`, `payroll_id`, `amount > 0`, `transferred_at date`, `note`, `created_by`, `created_at`; RLS admin); `public.generate_payroll(p_month int, p_year int) returns setof public.payroll_records` (hanya admin).
- Aturan `generate_payroll`:
  - **Calon sesi:** `order_sessions` tak terhapus, `recipient='tutor'`, `payroll_id` kosong, `status='selesai'`, dan siap dibayar (order `kind='lepas'` begitu sesinya `selesai`; `kind='paket'` setelah order `done`), dengan **tanggal jatuh tempo** `coalesce(session_date, orders.ordered_at::date)` <= hari terakhir bulan itu.
  - **Penyesuaian tutor:** `order_adjustments` tak terhapus, `payroll_id` kosong, `tutor_id` terisi, `created_at::date` <= hari terakhir bulan itu: `bonus_tutor` masuk `total_bonus` (100%), `potongan` masuk `total_deductions`, `extend` dengan `tutor_id` menambah `total_gross` dan dibagi dengan `tutor_pct` bawaan; `refund` diabaikan.
  - **Hitungan per tutor:** `total_sessions` = jumlah `sessions_count`; `total_gross` = jumlah `amount` (+ extend); `total_commission` = `total_gross` dikurangi bagian tutor (jumlah `amount * tutor_pct/100` per baris, dibulatkan 2 desimal); `total_due = total_gross - total_commission + total_bonus - total_deductions`.
  - **Rekam dan kunci:** satu baris `payroll_records` per tutor per bulan (dibuat bila belum ada, diperbarui bila ada); tiap sesi dan penyesuaian yang terhitung ditandai `payroll_id`. Payroll yang sudah punya transfer **tidak diubah**; sesi yang tertinggal tetap `payroll_id` kosong dan terbawa ke payroll bulan berikutnya.
  - **Hasil:** baris payroll yang dibuat atau diperbarui; bulan tanpa calon sesi menghasilkan 0 baris.
- Trigger pada `payroll_transfers` (`after insert or update or delete`): `total_transferred` payroll = jumlah transfer; `status='paid'` dan `paid_at = now()` bila `total_transferred >= total_due` dan `total_due > 0`, selain itu `pending`; transfer yang membuat `total_transferred` melebihi `total_due` ditolak (`'transfer_melebihi_hak'`).

- [ ] **Step 1: Tulis uji gagal** `payroll_baru.test.sql` dengan data: `[bagi 70/30]` tutor A dengan 2 sesi `selesai` bernilai Rp100.000 dan Rp95.333,33 pada order `lepas`, `generate_payroll` menghasilkan `total_gross = 195333.33`, `total_commission` = 30% hasil bulat 2 desimal, `total_due` bagian tutor; `[paket belum selesai]` sesi `selesai` dari order `paket` berstatus `progress` tidak masuk, dan masuk setelah order `done`; `[tanggal teks]` sesi dengan `session_date` kosong dan `ordered_at` di bulan itu tetap masuk, sedangkan bila `ordered_at` bulan depan tidak masuk; `[dua kali]` pemanggilan kedua tidak mengubah total dan tidak menambah baris; `[kas]` sesi penerima `kas` tidak membuat payroll; `[terhapus]` sesi `deleted_at` tidak masuk; `[bonus dan potongan]` `bonus_tutor` 30000 menambah `total_due` penuh, `potongan` mengurangi, `refund` tidak berpengaruh; `[kunci]` setelah satu transfer, sesi baru yang selesai untuk bulan itu tidak mengubah payroll tersebut tetapi masuk saat `generate_payroll` bulan berikutnya; `[transfer]` dua transfer yang jumlahnya sama dengan `total_due` mengubah status menjadi `paid`, satu transfer sebagian tidak; transfer berlebih ditolak; `[bukan admin]` pemanggil non-admin ditolak dan `anon` tanpa hak `execute`; `[bulan kosong]` bulan tanpa sesi menghasilkan 0 baris; `[lintas tahun]` bulan Januari tidak menarik sesi Desember tahun yang sama sebelum jatuh tempo, tetapi menarik sesi Desember tahun lalu yang tertinggal.
- [ ] **Step 2: Jalankan** `run-each.sh payroll_baru.test.sql`. Expected: gagal.
- [ ] **Step 3: Tulis** `011_payroll_baru.sql` sesuai Interfaces; pasang trigger audit pada `payroll_transfers` memakai `audit_row`.
- [ ] **Step 4: Jalankan** semua uji (`order_inti`, `order_aturan`, `order_audit`, `terima_pelamar`, `payroll_baru`, serta `hak_akses` yang sudah ada) dengan satu perintah `run-each.sh`. Expected: `OK` untuk semuanya, tanpa `GAGAL`/`ERROR`.

### Task 6: Berkas untuk Rifky dan dokumen

**Files:**
- Create: `D:\StudyBuddy\supabase-apply\operasional-1-apply.sql`, `operasional-2-verify.sql`, `operasional-3-rollback.sql`, `D:\StudyBuddy\supabase-apply\inspect-seed-dokumen.sql`
- Modify: `docs/superpowers/specs/2026-11-24-order-sesi-gaji-design.md`

**Interfaces:**
- Consumes: migration 009, 010, 011 (urutan ini).
- Produces: `operasional-1-apply.sql` = komentar kepala (tujuan, urutan, aman diulang) + isi 009, 010, 011 berurutan dalam satu transaksi; `operasional-2-verify.sql` = pemeriksaan katalog yang menghasilkan satu tabel `pemeriksaan | hasil` (`OK`/`GAGAL`): tabel baru ada dengan RLS aktif dan tanpa hak `anon`; fungsi `accept_application`, `generate_payroll`, `next_form_no`, `audit_row` ada; `tutors.user_id` boleh kosong; trigger audit terpasang pada tabel yang disebut Task 3; `app_settings` memuat 6 kunci; tidak ada baris `orders` (baru/kosong); `operasional-3-rollback.sql` = menghapus view, fungsi, trigger, tabel baru, dan kolom baru (`packages`, `tutors`, `tutor_documents`, `payroll_records`); **menolak berjalan** (`raise exception`) bila ada baris `tutors` dengan `user_id` kosong atau baris di tabel order, agar data nyata tidak hilang tanpa disadari; mengembalikan `tutors.user_id` ke NOT NULL setelah pemeriksaan itu; `inspect-seed-dokumen.sql` = satu `select pg_get_functiondef(...)` untuk `fn_seed_tutor_documents` dan daftar trigger di `tutors` (hanya membaca).

- [ ] **Step 1: Susun** berkas apply, verify, rollback dari migration (apply = gabungan; jangan menyalin ulang logika yang berbeda).
- [ ] **Step 2: Uji di database lokal sekali pakai** (basis: stub + 008 diterapkan lebih dulu): apply, verify (semua baris `OK`), apply lagi (idempotent), rollback pada database kosong (berhasil), lalu apply lagi. Lalu isi satu order dan jalankan rollback: harus ditolak dengan pesan jelas. Expected: urutan itu berjalan persis seperti ditulis.
- [ ] **Step 3: Perbarui spec:** tandai tahap 1 selesai dan catat tiga penyesuaian (kolom `order_adjustments.payroll_id`; jatuh tempo payroll memakai `coalesce(session_date, ordered_at)`; rollback menolak bila ada data).
- [ ] **Step 4: Hentikan** server uji lokal. Laporkan ke Rifky urutan menjalankan di SQL Editor: (1) `inspect-seed-dokumen.sql` dan kirim hasilnya, (2) `operasional-1-apply.sql`, (3) `operasional-2-verify.sql`; jangan menjalankannya tanpa kabar darinya.

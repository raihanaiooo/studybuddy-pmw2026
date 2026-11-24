# Rancangan: Web Admin Study Buddy — Order, Sesi, Pembayaran, Tutor, dan Gaji

Tanggal: 2026-11-24 (diperbarui setelah keputusan struktur menu). Status: **menunggu persetujuan Rifky**. Ukuran: proyek (beberapa tahap).

## 1. Tujuan dan alasan

Study Buddy dijalankan lewat WhatsApp dan spreadsheet: pelanggan mengisi Formulir Pesanan, admin menugaskan tutor,
sesi berjalan, pendapatan dibagi 70% tutor dan 30% tim inti, gaji tutor dibayar bulanan. Tutor **tidak punya akun**
(dikonfirmasi tim, 2026-11-24). Aplikasi mobile **ditahan** (hold): hanya target akhir di SRS.

Web admin menjadi satu-satunya tempat kerja manajemen, menggantikan spreadsheet
`Rekapitulasi Pendapatan Study Buddy_Juli - Oktober 2026.xlsx`: calon pelanggan, order, jadwal sesi, pembayaran, komplain,
tutor (dari pelamar sampai aktif), payroll, slip gaji, dan rekap. Fitur yang tadinya bergantung pada data mobile
(Booking, Transaksi, Reschedule, Komplain, Token, Payroll lama) **dibangun ulang di web** dari data order dan sesi,
dan menu mobile disingkirkan.

Tujuan akhirnya memudahkan manajemen: tidak ada lagi rumus yang salah jumlah, nama tutor tidak konsisten, tanggal pelaksanaan
berupa teks bebas, atau menu yang kosong dan membingungkan.

**Bukti dari data nyata (Jul-Okt 2026):** 43 formulir (FO020-FO062), 65 baris kelas, 82 sesi, sekitar 20 tutor,
pendapatan Rp6.460.000, tutor Rp4.522.000 + bonus Rp30.000. 10 dari 44 formulir dikerjakan lebih dari satu tutor.
Sheet asli salah jumlah di dua tempat (refund Agustus Rp76.000; baris progress September Rp272.000).

## 2. Tujuan, bukan-tujuan, anti-tujuan

**Tujuan**
- Satu tempat mencatat order resmi (nomor FO), sesi per tutor, penyesuaian, pembayaran pelanggan, komplain, dan gaji.
- Angka rekap sistem cocok dengan spreadsheet Jul-Okt 2026 setelah diimpor.
- Satu menu Tutor untuk seluruh siklus: pelamar, diperiksa, diterima, aktif.
- Pengaturan yang bisa diubah admin tanpa developer: layanan dan harga, aturan, template pesan WA, info bisnis.
- Data tidak hilang karena salah klik (hapus lunak) dan perubahan penting tercatat (audit).

**Bukan-tujuan (tahap ini)**
- Akun atau portal tutor; notifikasi otomatis ke tutor dan pelanggan (WA tetap manual, tombolnya berisi pesan siap kirim).
- Pembayaran online, QRIS, webhook; fitur mobile; kalender; peran Keuangan terpisah dari Admin (menyusul bila perlu).
- Menambah admin baru lewat undangan email (tahap ini admin baru dibuat manual di Supabase).

**Anti-tujuan:** sistem yang lebih ribet dari spreadsheet. Mengisi satu order dengan 3 sesi harus lebih cepat dari mengetik tiga baris di Excel.

## 3. Pendekatan yang dipertimbangkan

| | Pendekatan | Keputusan |
|---|---|---|
| A | Perluas `manual_orders`, tambah tabel sesi | Tidak: calon pelanggan dan order resmi tercampur; nomor FO dan pendapatan ambigu |
| **B** | **Pisahkan calon (`manual_orders`) dari order resmi (tabel baru)** | **Dipilih Rifky** |
| C | Pakai `bookings`, `payments`, `tokens` mobile | Tidak: wajib akun pelanggan, satu paket tidak bisa dibagi ke banyak tutor |

## 4. Struktur menu

```
Dashboard
OPERASIONAL   Calon Pelanggan · Order · Jadwal · Pembayaran · Komplain
TUTOR         Tutor (tab: Pelamar baru | Aktif | Ditolak | Semua) · Payroll
LAPORAN       Rekap
LANDING PAGE  Konten · Diagnostic
SISTEM        Pengaturan
```

Dari 14 menu menjadi 11. Yang dihapus dari menu dan rute: Bookings, Transaksi, Reschedule, Komplain (lama), Token Buddy, Payroll (lama),
Pelamar Tutor dan Verifikasi Tutor (digabung jadi Tutor), Paket Belajar (pindah ke Pengaturan), halaman Performa dan Pengaturan yang kosong.
Berkas halaman mobile tidak dihapus dari repo (agar mudah dihidupkan lagi); README diberi catatan bahwa fitur mobile ditahan.
Data lama di database tidak disentuh.

| Menu lama | Menjadi |
|---|---|
| Orderan Masuk | **Calon Pelanggan** (tombol "Jadikan Order") |
| Bookings | **Jadwal**: daftar sesi per tanggal |
| Transaksi | **Pembayaran** per order |
| Reschedule | Bagian dari sesi: alasan ubah jadwal dan hitungan berapa kali; peringatan bila melewati kuota paket |
| Komplain | **Komplain** ringan, terkait order dan tutor |
| Token Buddy | **Sisa sesi** per order dan tanggal hangus; daftar "hampir hangus" |
| Pelamar Tutor + Verifikasi Tutor | **Tutor** (satu menu, empat tab) |
| Paket Belajar | **Pengaturan > Layanan & Harga** |
| Payroll | **Payroll** baru dari sesi |
| Performa tutor | Ringkasan di detail tutor (sesi selesai dan pendapatan per bulan; rating belum ada karena tanpa aplikasi) |

## 5. Model data

Semua tabel baru: RLS aktif, hanya admin (`is_admin()`); `anon` tanpa hak apa pun; `authenticated` tanpa hak DELETE.
Penghapusan lewat `deleted_at`. Setiap perubahan tercatat di `audit_log`.

**`orders`** (order resmi = satu Formulir Pesanan)
`id`, `form_no` (unik, `FO###`, otomatis = terbesar + 1, boleh diisi manual untuk impor), `lead_id` → `manual_orders` (opsional),
`buddy_name`, `age`, `grade`, `school`, `whatsapp`, `service_category`, `service_name`, `subject`, `kind` (`paket` atau `lepas`),
`package_id` → `packages` (opsional), `sessions_total`, `price_per_session` (numeric 14,2), `total_price`, `reschedule_quota`
(salinan dari layanan), `valid_until` (tanggal hangus; bawaan = tanggal order + masa berlaku layanan, bisa diubah),
`status` (`progress`, `done`, `batal`), `ordered_at`, `completed_at`, `notes`, `created_by`, `created_at`, `deleted_at`.
Status pembayaran (belum, sebagian, lunas) **dihitung** dari jumlah pembayaran dibanding total + extend, tidak disimpan.

**`order_sessions`** (satu baris = satu kelompok sesi oleh satu penerima, sesuai baris spreadsheet)
`id`, `order_id`, `recipient` (`tutor` atau `kas`), `tutor_id` (wajib bila `tutor`), `sessions_count` (>= 1),
`session_date`, `start_time`, `tz`, `date_note` (teks bebas, untuk impor), `duration_minutes`, `rate` (salinan dari order),
`amount` (= `rate` x `sessions_count`, 2 desimal), `tutor_pct` (bawaan dari Pengaturan, disalin per baris), `status`
(`terjadwal`, `selesai`, `batal`), `reschedule_count`, `reschedule_note`, `payroll_id`, `created_at`, `deleted_at`.

**`order_adjustments`**: `id`, `order_id`, `session_id` (opsional), `tutor_id` (opsional), `kind` (`extend`, `bonus_tutor`, `potongan`, `refund`),
`amount`, `note`, `created_at`, `deleted_at`.
Aturan (mengikuti spreadsheet): `extend` menambah pendapatan lalu dibagi 70/30; `bonus_tutor` 100% ke tutor; `potongan` mengurangi hak tutor tertentu;
`refund` dicatat dan dilaporkan terpisah, tidak mengubah pembagian sesi (informasional).

**`order_payments`** (pembayaran dari pelanggan; bisa dicicil): `id`, `order_id`, `amount`, `paid_at`, `method` (`transfer`, `qris`, `tunai`, `lainnya`),
`note`, `created_by`, `created_at`, `deleted_at`.

**`order_complaints`**: `id`, `order_id`, `tutor_id` (opsional), `category`, `description`, `status` (`baru`, `diproses`, `selesai`, `ditolak`),
`handling_note`, `handled_by`, `handled_at`, `created_at`, `deleted_at`.

**`app_settings`** (kunci dan nilai JSON; hanya admin): `key`, `value`, `updated_by`, `updated_at`. Kunci: `tutor_pct` (70), `reschedule_hours` (6),
`late_tolerance_minutes` (15), `payout_day`, `wa_templates` (konfirmasi jadwal, penugasan tutor, follow up, slip gaji; dengan isian seperti `{nama}`, `{jadwal}`),
`business` (nama usaha, nomor WA admin, rekening pembayaran, kepala dan kaki slip gaji).

**`packages`** (tabel yang ada, dipakai sebagai katalog "Layanan & Harga"): tambah `category`, `kind` (`paket` atau `lepas`), `default_duration_minutes`.
Harga per sesi = `price` / `session_count`. Baris lama dari uji mobile dibiarkan.

**`tutors`** (tabel yang ada, diubah)
- `user_id` boleh kosong. Tutor dibuat langsung oleh admin tanpa Auth dan tanpa email.
- Kolom baru: `whatsapp`, `email` (opsional), `is_outsourced`, `payout_account` (teks bebas: bank atau e-wallet, nomor, atas nama).
- Baris tutor dari pelamar menyimpan `application_id` asal.

**`tutor_documents`** (tabel yang ada): tambah `storage_bucket` (bawaan `documents`). Dokumen pelamar yang diterima **tidak disalin**; barisnya menunjuk ke
berkas di bucket `tutor-applications`, sehingga penerimaan bisa atomik. Penghapusan berkas pelamar yang ditolak tetap seperti sekarang.

**`payroll_records`** (tabel yang ada, sumber data diganti dari `bookings` ke `order_sessions`): tambah `total_bonus`, `total_deductions`, `total_due`, `total_transferred`.
Unik per (`tutor_id`, bulan, tahun) tetap.

**`payroll_transfers`**: `id`, `payroll_id`, `amount`, `transferred_at`, `note`, `created_by`. Sisa bayar = `total_due` - jumlah transfer.

**`audit_log`** (tulis hanya lewat trigger; admin hanya membaca): `id`, `table_name`, `row_id`, `action`, `old_row`, `new_row`, `actor` (`auth.uid()`), `at`.

## 6. Aturan bisnis (di database, bukan di browser)

- **Pendapatan sesi** = `rate` x `sessions_count`; bagi hasil bawaan 70% tutor, 30% tim inti. Pendapatan paket dibagi rata per sesi
  (contoh FO033: Rp24.000 per sesi, 16 sesi dibagi ke 4 penerima).
- **Order selesai otomatis** bila jumlah sesi `selesai` sama dengan `sessions_total`; `completed_at` terisi.
- **Sisa sesi** = `sessions_total` dikurangi sesi `selesai`. Sisa sesi yang melewati `valid_until` ditandai hangus dan tidak bisa dijadwalkan (admin bisa memperpanjang dengan catatan).
- **Reschedule:** `reschedule_count` per order dibanding `reschedule_quota`; peringatan, bukan penghalang keras (admin yang memutuskan).
- **Siap dibayar:** layanan `lepas` begitu sesinya `selesai`; `paket` setelah order `done` (SRS FR-PAYR-01).
- **Payroll bulanan** (`generate_payroll(bulan, tahun)`, satu transaksi, hanya admin): mengambil sesi siap dibayar yang `payroll_id`-nya kosong dan jatuh tempo sampai akhir bulan itu.
  Satu sesi tidak mungkin terhitung dua kali. Payroll yang sudah ada transfernya terkunci.
- **Terima pelamar** (`accept_application(id, harga)`, satu transaksi, hanya admin): membuat tutor (`user_id` kosong), baris dokumen, dan mengubah status pelamar menjadi `diterima`; semua atau tidak sama sekali.
- **Slip gaji** per tutor per bulan: rincian (tanggal kelas, nama buddy, materi, jumlah sesi, rate, subtotal, potongan, hak tutor, keterangan)
  + rekonsiliasi (total hak, sudah ditransfer, sisa).
- **Pembulatan:** hitung dan simpan 2 desimal per baris (seperti spreadsheet: 95.333,33), tampil dibulatkan ke rupiah.

## 7. Halaman

- **Dashboard** (dari order dan sesi): order berjalan, sesi minggu ini, pembayaran belum lunas, sesi hampir hangus, gaji belum dibayar, pendapatan bulan ini.
- **Calon Pelanggan**: daftar kiriman landing (nama, WA, mapel, jenjang, catatan, hasil tes) dan status tindak lanjut; tombol **Jadikan Order** membuka formulir 9 isian
  yang sudah terisi dari calon.
- **Order**: daftar (cari nomor FO atau nama; filter bulan, status, tutor) dan detail: isian formulir, sesi (tambah, ubah, ganti tutor), penyesuaian, pembayaran,
  sisa sesi dan tanggal hangus, ringkasan pendapatan (total, 30%, 70%), tombol WA dari template.
- **Jadwal**: sesi per tanggal (hari ini, minggu ini, semua), ubah status, ubah jadwal dengan alasan.
- **Pembayaran**: daftar pembayaran dan order yang belum lunas.
- **Komplain**: daftar, status, penanganan.
- **Tutor**: tab Pelamar baru (periksa data dan dokumen, Terima atau Tolak dengan alasan), Aktif (unggulan, rekening, outsourcing, dokumen, riwayat sesi dan gaji), Ditolak, Semua; tombol Tambah tutor.
- **Payroll**: buat per bulan, daftar per tutor, slip (cetak atau PDF lewat browser, salin teks WA), catat transfer.
- **Rekap**: pendapatan bulanan dan per kategori (menggantikan "Rekap Eksekutif"), ekspor CSV.
- **Konten** dan **Diagnostic**: tetap seperti sekarang.
- **Pengaturan**, tab:
  1. **Layanan & Harga** (katalog: kategori, nama, harga, jumlah sesi, masa berlaku, kuota reschedule, bisa refund, aktif)
  2. **Aturan** (persen tutor, batas reschedule, toleransi terlambat, tanggal gajian)
  3. **Template WA**
  4. **Info Bisnis** (nama, WA admin, rekening pembayaran, kepala dan kaki slip)
  5. **Admin** (daftar admin dan tombol nonaktifkan; tambah admin manual lewat Supabase untuk saat ini)
  6. **Log Aktivitas** (dari `audit_log`, dengan filter tabel, pelaku, tanggal)
  7. **Ekspor Data** (unduh order, sesi, pembayaran, payroll sebagai CSV untuk cadangan)

## 8. Impor data Jul-Okt 2026

Satu kali jalan: skrip membaca sheet "Database Transaksi" dan menghasilkan berkas SQL yang ditinjau sebelum dijalankan.
- Memetakan nama tutor ke satu orang (mis. "tutor tiara", "(outsourcing)", "(outsource)" menjadi satu tutor outsourcing). Daftar pemetaan dicetak untuk disetujui dulu;
  baris "KAS INTERNAL" menjadi penerima `kas`; baris "-" ditangani eksplisit.
- Baris `REFUND` menjadi penyesuaian `refund`; tanggal berupa teks disimpan di `date_note`.
- **Bukti lulus:** total pendapatan per bulan dan kumulatif sama dengan "Rekap Eksekutif" (Rp6.460.000; 70% = Rp4.522.000; bonus Rp30.000); skrip mencetak selisih bila ada.

## 9. Tahap pengerjaan

0. **Rapikan menu (dikerjakan pertama, disetujui Rifky 2026-11-24):** sidebar baru, menu mobile disingkirkan dari menu dan rute,
   Pelamar Tutor dan Verifikasi Tutor digabung jadi satu menu **Tutor** bertab (masih memakai alur dan tabel yang sekarang), halaman
   **Pengaturan** dengan Layanan & Harga (dari tabel `packages`), serta penghapusan menu yang halamannya kosong.
   Penyesuaian saat dikerjakan: menu Tutor memakai lima tab (ditambah "Menunggu" untuk tutor yang sudah dibuat tapi belum diverifikasi),
   dan tab Info Bisnis dipindah ke tahap 3 karena belum ada tempat penyimpanan tanpa database.
   Tanpa perubahan database dan tanpa SQL untuk Rifky; tidak ada fitur yang hilang selain menu mobile yang ditahan.
1. **Database:** tabel baru, perubahan tabel lama, RLS, audit, fungsi payroll dan terima pelamar, uji SQL, berkas apply/verify/rollback.
2. **Impor Excel** dan pencocokan angka.
3. **Pengaturan lanjutan:** Info Bisnis, Aturan, Template WA; tab Tutor memakai fungsi terima pelamar tanpa akun.
4. **Operasional:** Calon Pelanggan, Order, Jadwal, Pembayaran, Komplain.
5. **Payroll** baru dengan slip.
6. **Rekap, Dashboard baru, Log Aktivitas, Ekspor Data**, pembersihan akhir.

Tiap tahap bisa dipakai sendiri. Tahap 0 dikerjakan lebih dulu karena kelihatan, aman, dan menghilangkan kebingungan menu;
sesudahnya data benar dulu (tahap 1-2), tampilan sesudahnya.

## 10. Batasan dan cara uji

- Database Supabase yang ada; keamanan mengikuti migrasi 008 (`is_admin()`, `anon` tanpa hak tulis, penjaga di tabel sensitif).
- Web: Vite + React + Tailwind (CSS dibuat ulang dengan `npm run css:build`); teks antarmuka bahasa Indonesia; zona waktu WIB.
- SQL diuji dulu di database uji lokal (pola `supabase/tests/run.sh`), logika murni di Vitest, lalu `-1-apply`, `-2-verify`, `-3-rollback` untuk Rifky.
- Rifky menjalankan SQL sendiri di Supabase; tidak ada perubahan di database sungguhan tanpa persetujuannya.
- Pembangun membaca dulu isi fungsi `fn_seed_tutor_documents` (trigger saat tutor dibuat) agar tidak terjadi dokumen ganda.

## 11. Pertanyaan terbuka (nilai bawaan sementara)

| # | Pertanyaan | Bawaan sampai dijawab |
|---|---|---|
| 1 | FO022: harga Rp336.875 untuk `45x14` | Diimpor apa adanya, ditandai "perlu cek" |
| 2 | Arti "KAS INTERNAL" (FO033) | Penerima `kas`: tidak masuk payroll tutor, tampil di rekap |
| 3 | Dampak refund ke bagian tutor | Hanya dicatat; tidak mengubah hak tutor |
| 4 | Lokasi dan format data rekening tutor | Kolom teks bebas opsional |
| 5 | Format slip gaji asli | Struktur SRS 3.9 (FR-PAYR-06) |
| 6 | Pembayaran dan Komplain benar-benar dipakai? | Ya (sesuai persetujuan struktur menu); Komplain bisa diperkecil bila jarang |
| 7 | Tanggal batch gaji tiap bulan | Admin menekan "Buat payroll" kapan pun; tanggal di Pengaturan hanya pengingat |
| 8 | Peran Keuangan terpisah | Ditunda; semua admin punya akses penuh |
| 9 | Tambah admin lewat undangan email | Ditunda; admin baru dibuat manual di Supabase |

## 12. Hal yang diserahkan ke pembangun

Nama kolom dan indeks persis, tampilan form dan tabel, teks bawaan template WA, strategi paginasi, format cetak slip, dan cara
menyimpan berkas halaman mobile yang ditahan, selama mengikuti aturan bisnis bagian 6 dan keamanan bagian 5 dan 10.

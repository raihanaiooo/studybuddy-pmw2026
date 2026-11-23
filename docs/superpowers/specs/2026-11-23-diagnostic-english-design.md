# Diagnostic English (Language Class) — Design

**Tanggal:** 23 Nov 2026
**Status:** Draf menunggu persetujuan. Belum ada kode yang ditulis.
**Pemilik:** Tim IT (Rifky, Raihana)

## 1. Tujuan dan alasan

Calon murid mengerjakan tes singkat di landing page Study Buddy. Hasilnya berupa level bahasa Inggris, satu paket yang disarankan, dan beberapa tutor yang cocok. Dua tujuan, berurutan:

1. **Membantu calon murid memilih paket.** Orang yang belum tahu levelnya tidak tahu harus ambil paket apa.
2. **Jadi demo yang nyata saat monev** (awal Desember 2026). Halaman admin menampilkan angka sungguhan: jumlah tes, sebaran level, dan berapa yang lanjut order.

Latar: permintaan dari Ocha lewat Aul (12 dan 21 Nov), dan tim memutuskan teknologi Study Buddy berpusat di landing page, bukan aplikasi mobile.

## 2. Tujuan, bukan-tujuan, anti-tujuan

**Tujuan**
- Tes English pilihan ganda yang dinilai otomatis, kurang dari 10 menit.
- Level hasil tes selaras dengan CEFR (A1, A2, B1, B2).
- Rekomendasi paket dan tutor yang bisa dijelaskan: aturan sederhana, bukan AI.
- Hasil dan funnel terlihat di admin.

**Bukan-tujuan (versi ini)**
- Tes UTBK atau mapel lain.
- Tes speaking, writing, atau listening.
- Editor soal di admin (soal diisi lewat SQL).
- Sertifikat, pembayaran, atau login pengunjung.

**Anti-tujuan (dianggap gagal walau jalan)**
- Soal disalin dari tes pihak lain (hak cipta).
- Kunci jawaban terkirim ke browser.
- Pengunjung dipaksa mengisi data diri sebelum melihat hasil.
- Rekomendasi tidak bisa dijelaskan saat monev.

## 3. Batasan

- Stack tetap: React 19, Vite, TypeScript, Tailwind v4, Supabase.
- Waktu: demo harus siap sebelum monev awal Desember. Biaya IT di RAB hampir nol, jadi tidak boleh menambah layanan berbayar.
- Migration `supabase/migration/001_init.sql` hanya memuat 5 dari sekitar 15 tabel. Fitur ini menambah migration baru dan tidak menyentuh tabel lama.
- Anak di bawah umur: tes tidak mengumpulkan data pribadi. Nama dan WhatsApp baru diminta saat memesan (keputusan D-09 di `docs/decision-register.md` tetap terbuka dan tidak dilanggar).
- Soal harus orisinal. Tidak ada soal dari EF SET, Cambridge, TOEFL, atau tes placement lain.

## 4. Pendekatan yang dipertimbangkan

| | Cara | Kelebihan | Kekurangan |
|---|---|---|---|
| A | Soal statis di kode, skor di browser | Tercepat (±1 hari) | Kunci bocor ke browser, ubah soal butuh deploy |
| **B** | **Soal di database, skor di server (RPC), halaman hasil di admin** | Kunci tidak bocor, angka nyata untuk monev, soal bisa diubah via SQL | ±3–4 hari, butuh akses Supabase |
| C | B + editor soal di admin | Tutor/admin bisa kelola soal sendiri | ±1,5–2 minggu, berlebihan untuk 24 soal |

**Dipilih: B** (keputusan Rifky, 23 Nov 2026). A dinilai kurang meyakinkan untuk monev, C terlalu lama dibanding manfaatnya.

## 5. Alur pengguna

```
Landing / TutorFinder → "Cek level English kamu"  (halaman /tes-english)
  → layar pembuka: durasi ±8 menit, tanpa daftar, tombol Mulai
  → 24 soal, satu soal per layar, bisa kembali, ada progres
  → kirim jawaban → hasil:
        Level (mis. B1 · Intermediate) + penjelasan "kamu bisa..."
        Paket yang disarankan (1) + alasan satu kalimat
        Tutor yang cocok (maks. 3)
        Tombol "Pesan paket ini"
  → form order yang sudah ada (OrderForm) terisi mapel + paket
```

Hasil tampil tanpa data diri. Nama dan WhatsApp baru diisi saat "Pesan paket ini".

## 6. Rancangan teknis

### 6.1 Data (migration baru, mis. `supabase/migration/002_diagnostic.sql`)

- `diagnostic_questions`: `id`, `test_code` (`english`), `position`, `skill` (`grammar` | `vocabulary` | `reading`), `level` (`A1`..`B2`), `stem`, `passage_id` (nullable), `options` (jsonb, daftar teks pilihan), `correct_index` (int), `explanation`, `is_active`.
- `diagnostic_passages`: `id`, `text` untuk soal membaca yang berbagi satu teks.
- `diagnostic_rules`: `test_code`, `level`, `package_id` (FK ke `packages`), `reason` (teks alasan yang ditampilkan).
- `diagnostic_attempts`: `id`, `test_code`, `client_session_id`, `answers` (jsonb), `score`, `level`, `recommended_package_id`, `created_at`.
- `manual_orders`: tambah kolom nullable `diagnostic_attempt_id` dan `package_id`.

### 6.2 Keamanan

- RLS aktif di semua tabel baru.
- Pengunjung anonim hanya boleh membaca soal aktif lewat **view** tanpa `correct_index` dan `explanation`. Tabel `diagnostic_questions` sendiri tidak terbuka untuk `anon`.
- Pengunjung tidak menulis langsung ke `diagnostic_attempts`. Semua lewat fungsi RPC.
- Admin (role `management`) boleh membaca attempts dan statistik.

### 6.3 Fungsi RPC `submit_diagnostic_attempt(test_code, client_session_id, answers)`

`SECURITY DEFINER`. Menilai jawaban dengan `correct_index`, menghitung skor dan level, memilih paket dari `diagnostic_rules`, memilih tutor, menyimpan attempt, lalu mengembalikan: level, skor, paket, daftar tutor, dan `attempt_id`. Kunci jawaban dan penjelasan tidak pernah dikirim ke browser.

### 6.4 Penentuan level (aturan sederhana)

Soal 24 = 6 per level A1, A2, B1, B2. Level = level tertinggi yang jawaban benarnya paling sedikit 4 dari 6 dan semua level di bawahnya terpenuhi. Jika A1 pun kurang dari 4, level = "Pre-A1 / Pemula". Aturan ini mudah dijelaskan dan diuji.

### 6.5 Rekomendasi tutor

Tutor dengan `verification_status` terverifikasi dan `subjects` memuat bahasa Inggris, dibatasi 3. Urutan sementara: tutor yang `is_featured` dulu, lalu berdasarkan rating bila kolomnya ada. Nilai `subjects` di data nyata belum terverifikasi (kode memakai `ing` di `TutorFinder` dan `Bahasa Inggris` di `OrderForm`); pencocokan harus menangani keduanya.

### 6.6 Front-end

- Halaman publik baru `/tes-english` dengan komponen soal, progres, dan hasil. Memakai token desain landing yang ada.
- `TutorFinder` mendapat tautan ke tes. Penggantian pencocokan "Cocok 95%" bawaan dengan hasil nyata ada di luar versi ini.
- `OrderForm` menerima parameter dari hasil tes (mapel, paket, `attempt_id`).
- Halaman admin baru `/diagnostics`: jumlah tes, sebaran level, tes yang berlanjut jadi order, daftar attempt terbaru.

### 6.7 Isi soal

24 soal English orisinal, ditulis dengan acuan deskriptor CEFR Companion Volume, masing-masing berlabel level dan keahlian, dengan penjelasan jawaban. Satu tutor bahasa Inggris Study Buddy mereview kunci jawaban dan tingkat kesulitan sebelum dipakai (±1 jam). Sumber acuan:
- Council of Europe, CEFR Companion Volume (2020).

### 6.8 Tahap berikutnya: UTBK mini (di luar versi ini)

Aul membagikan bahan UTBK 2026 (soal latihan PU/PM/PK dari pihak lain dan bank soal hasil ingatan peserta). Keputusan 23 Nov 2026: **English dulu**, UTBK menyusul. Bahan itu hanya acuan format dan topik; isinya tidak boleh dimasukkan ke web karena hak cipta pihak lain. Soal UTBK akan ditulis orisinal dan direview tutor UTBK. Skema (`test_code`) sudah mendukung tes kedua tanpa perubahan arsitektur; yang perlu diputuskan nanti hanya kategori level dan pemetaan paket UTBK.

## 7. Keputusan yang saya ambil sendiri (mohon dikoreksi)

- 24 soal, 6 per level, 3 keahlian (grammar, vocabulary, reading).
- Satu soal per layar, tanpa batas waktu ketat (estimasi 8 menit).
- Tanpa login dan tanpa data pribadi sebelum order.
- Ambang level 4 dari 6.
- Satu paket per level, bukan daftar paket.
- Tutor maksimal 3.
- Kolom order baru bersifat nullable agar order lama tetap jalan.

## 8. Yang masih terbuka dan milik tim

- **Paket mana untuk tiap level.** Katalog `packages` di database nyata belum saya lihat. Aul dan Dhimas yang menentukan pemetaan level → paket. Sampai itu terjawab, `diagnostic_rules` diisi data contoh.
- **Akses Supabase dan `.env`** dari Rifky atau Rai untuk menjalankan migration dan menguji RLS. Tanpa itu, fitur diuji di proyek Supabase lokal/terpisah.
- **Reviewer soal.** Tutor English mana yang me-review.

## 9. Kriteria selesai

1. Pengunjung anonim dapat menyelesaikan 24 soal dan melihat level, paket, dan tutor tanpa login.
2. Respons API soal tidak berisi `correct_index` maupun `explanation` (diverifikasi).
3. Pengunjung anonim tidak bisa membaca atau menulis `diagnostic_attempts` langsung.
4. Aturan level punya tes otomatis untuk kasus batas (semua salah, semua benar, 3/6 vs 4/6 per level).
5. "Pesan paket ini" mengisi `manual_orders` dengan `diagnostic_attempt_id` dan `package_id`.
6. Halaman admin menampilkan jumlah tes, sebaran level, dan jumlah order dari tes.
7. `npm run build` dan `npm run lint` bersih.

## 10. Risiko

- Spam attempt oleh bot. Mitigasi: batasi per `client_session_id` di RPC (angka diputuskan saat implementasi).
- Kualitas soal buatan AI tanpa review. Mitigasi: review tutor wajib sebelum rilis.
- Skema database nyata berbeda dari asumsi (migration tidak lengkap). Mitigasi: tarik skema dari database nyata sebelum menulis migration 002.

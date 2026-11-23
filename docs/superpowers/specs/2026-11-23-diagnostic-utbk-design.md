# Diagnostic UTBK mini (try out singkat) — Design

**Tanggal:** 23 Nov 2026
**Status:** Draf menunggu persetujuan. Belum ada kode yang ditulis.
**Pemilik:** Tim IT (Rifky, Raihana)
**Lanjutan dari:** `2026-11-23-diagnostic-english-design.md` (bagian 6.8)

## 1. Tujuan dan alasan

Calon Buddy mengerjakan try out UTBK singkat di landing page Study Buddy dan mendapat skor per subtes, subtes yang perlu diperkuat, dan satu paket SNBT sebagai gambaran awal. Tes ini berdampingan dengan tes English, tidak menggantikannya.

Dua tujuan, berurutan:
1. Membantu calon Buddy UTBK memilih paket. Tiga dari lima paket di katalog adalah paket SNBT, jadi ini pasar utama.
2. Jadi demo yang nyata saat monev (awal Desember 2026). Satu tes saja terlihat sempit, dan UTBK adalah yang paling dekat dengan bisnis.

## 2. Tujuan, bukan-tujuan, anti-tujuan

**Tujuan**
- 24 soal pilihan ganda, dinilai otomatis di server, kurang dari 15 menit.
- Hasil: skor total, skor per subtes, subtes terlemah, satu paket SNBT, dan disclaimer.
- Hasil dan funnel tampil di halaman admin yang sama dengan English.
- English yang sudah berjalan di Supabase nyata tidak berubah perilakunya.

**Bukan-tujuan (versi ini)**
- Skor ala UTBK asli (IRT), peringkat, atau prediksi lolos PTN.
- Subtes lain: PPU, PBM, Literasi Inggris, Penalaran Matematika.
- Soal pilihan ganda kompleks atau isian. Hanya satu jawaban benar.
- Rekomendasi tutor (versi English punya; UTBK menyusul).
- Editor soal di admin.

**Anti-tujuan (dianggap gagal walau jalan)**
- Soal disalin atau diparafrase dekat dari bahan Aul atau try out pihak lain (hak cipta).
- Kunci jawaban terkirim ke browser.
- Hasil terbaca sebagai prediksi atau jaminan. Disclaimer wajib tampil.
- Mengubah perilaku tes English.

## 3. Batasan

- Stack tetap: React 19, Vite, TypeScript, Tailwind v4, Supabase.
- Siap sebelum monev awal Desember. Tidak boleh menambah layanan berbayar.
- Database nyata sudah berisi migration 002. Perubahan hanya lewat migration baru (003) yang aman dijalankan di atas data English yang ada.
- Soal orisinal. Bahan Aul hanya acuan format dan topik.
- Tanpa login dan tanpa data pribadi sebelum order (sama seperti English).

## 4. Pendekatan yang dipertimbangkan

| | Cara | Untung | Rugi |
|---|---|---|---|
| 1 | Tabel dan fungsi baru khusus UTBK | English tidak tersentuh | Kode kembar; admin harus menggabungkan dua sumber |
| **2** | **Tabel yang sama, kolom ditambah, satu fungsi penilai baru untuk UTBK** | Soal dan hasil berdampingan; satu halaman admin; fungsi English tidak diubah | Tabel sedikit lebih rumit; satu fungsi statistik English perlu disesuaikan |
| 3 | Ubah fungsi penilai English agar menilai dua jenis tes | Paling rapi di atas kertas | Paling berisiko merusak English yang sudah jalan |

**Dipilih: 2** (keputusan Rifky, 23 Nov 2026).

## 5. Alur pengguna

```
Landing / TutorFinder → "Cek kesiapan UTBK kamu"  (halaman /tes-utbk)
  → layar pembuka: ±15 menit, 24 soal, tanpa daftar, disclaimer
  → 24 soal, satu per layar, bisa kembali, ada progres
  → kirim → hasil:
        Skor total dan per subtes (batang)
        Subtes yang perlu diperkuat
        Paket SNBT yang disarankan + alasan satu kalimat
        Disclaimer
        Tombol "Pesan paket ini"
  → form order yang sudah ada, terisi paket
```

Sketsa hasil:
```
Skor kamu: 15 dari 24
Penalaran Umum         ████░░░░  4/8
Pengetahuan Kuantitatif ██████░░  6/8
Literasi Bahasa Indonesia █████░░░  5/8
Perlu diperkuat: Penalaran Umum
Paket yang disarankan: Bundling SNBT — Juara (7 sesi)
Ini gambaran awal dari try out singkat, bukan penentu. Paket yang
paling pas tergantung target dan kebutuhan Buddy; admin membantu
memastikannya.
[Pesan paket ini]
```

## 6. Rancangan teknis

### 6.1 Subtes dan isi soal

Tiga subtes, 8 soal masing-masing (24 total). Label di layar memakai nama resmi dengan penjelasan singkat:
- `pu`: Penalaran Umum (logika dan penalaran)
- `pk`: Pengetahuan Kuantitatif (hitungan)
- `lbi`: Literasi Bahasa Indonesia (bacaan; berbagi teks dalam `diagnostic_passages`)

Tiap subtes berisi campuran mudah, sedang, dan sulit (3, 3, 2) supaya skor membedakan Buddy. Tingkat kesulitan hanya pedoman penulisan, tidak disimpan.

Pilihan jawaban ada 5 (A sampai E) seperti UTBK asli.

**Verifikasi kunci jawaban:**
- `pk`: kunci dihitung dengan skrip (disimpan di repo sebagai uji), bukan hanya dibaca.
- `pu`: kunci diverifikasi dengan skrip bila soalnya bisa diformalkan (urutan, logika), selebihnya dibaca ulang.
- `lbi`: wajib dibaca satu orang manusia yang pernah ikut UTBK (Rifky akan meminta) sebelum diaktifkan.
- Soal masuk `is_active = false`; aktif setelah pembaca selesai.

### 6.2 Data (migration baru `003_diagnostic_utbk.sql`, hanya menambah atau melonggarkan)

- `diagnostic_questions`: batas `skill` diperluas dengan `pu`, `pk`, `lbi`; kolom `level` boleh null (soal UTBK tanpa level). Soal English tetap valid.
- `diagnostic_attempts`: kolom `level` boleh null; tambah `result jsonb` (skor per subtes, pita, subtes terlemah). Attempt English tidak berubah.
- `diagnostic_rules`: batas `level` diperluas dengan kunci pita `UTBK_TINGGI`, `UTBK_SEDANG`, `UTBK_RENDAH` agar aturan paket UTBK memakai tabel yang sama. Isinya diisi lewat seed, `package_id` terpetakan ke paket SNBT.
- View `diagnostic_questions_public` tetap tanpa `correct_index` dan `explanation`.

### 6.3 Penilaian

Fungsi baru `submit_utbk_attempt(p_client_session_id, p_answers)`, `SECURITY DEFINER`, dengan batas laju yang sama dengan English (5 per jam per sesi, dihitung gabungan semua tes; satu pengunjung yang mengerjakan English dan UTBK memakai 2 dari 5). Validasi jawaban memakai jumlah opsi tiap soal, jadi 5 pilihan sudah didukung (tampilan punya huruf A sampai F). Fungsi `submit_diagnostic_attempt` untuk English tidak diubah.

Pita ditentukan dari total benar (dari 24):
- Rendah: 0 sampai 9 (di bawah 40%) → SNBT SKS (21 sesi)
- Sedang: 10 sampai 16 → SNBT Juara (7 sesi)
- Tinggi: 17 sampai 24 (di atas 70%) → SNBT Satset (3 sesi)

Subtes terlemah = subtes dengan benar paling sedikit; bila ada yang sama rendah, semuanya disebut; bila ketiganya sama, tidak ada yang disebut ("seimbang"). Respons berisi `attempt_id`, skor, total, `per_subtest`, pita, subtes terlemah, dan paket (atau null bila aturan belum dipetakan). Kunci dan penjelasan tidak pernah dikirim.

### 6.4 Statistik admin

`diagnostic_stats()` untuk English saat ini menghitung semua attempt. Setelah attempt UTBK masuk, angkanya bercampur. Perubahan kecil dan wajib: fungsi itu hanya menghitung `test_code = 'english'`, dengan tes regresi. Fungsi baru `diagnostic_stats_utbk()` mengembalikan total, sebaran pita, rata-rata per subtes, order dari tes, dan attempt terbaru. Keduanya hanya untuk admin (sama seperti sekarang).

### 6.5 Front-end

- Rute baru `/tes-utbk`. Halaman tes dan hook dipakai bersama English (parameter kode tes); yang baru hanya kartu hasil UTBK. Draf jawaban di browser dipisah per kode tes agar tidak bertabrakan.
- Tipe `DiagnosticQuestion.level` menjadi opsional; label subtes dipetakan di front-end.
- `TutorFinder`: tautan "Cek kesiapan UTBK kamu" di samping tautan English.
- `OrderForm`: menerima paket dari hasil UTBK. Opsi mapel "UTBK / SNBT" ditambahkan (keputusan saya, perlu dikoreksi bila tidak cocok dengan data order lama).
- Pesan WhatsApp template menyesuaikan: untuk UTBK menyebut try out UTBK.
- Halaman `/diagnostics`: dua bagian, English dan UTBK.

### 6.6 Disclaimer

Tampil di layar pembuka dan kartu hasil, teks tetap: "Ini try out singkat sebagai gambaran awal, bukan penentu atau prediksi kelulusan. Paket yang paling pas tergantung target dan kebutuhan Buddy; admin akan membantu memastikannya."

(Catatan: permintaan awal berbunyi "untuk eksak paketnya tergantung dari Buddy nya sendiri". Saya membaca "eksak" sebagai "pastinya". Bila yang dimaksud "eksak" sebagai rumpun saintek, pesan ini perlu disesuaikan.)

## 7. Keputusan yang saya ambil sendiri (mohon dikoreksi)

- Tiga subtes (PU, PK, LBI), 8 soal tiap subtes, 5 pilihan.
- Ambang pita 40% dan 70% (dalam hitungan: 0 sampai 9, 10 sampai 16, 17 sampai 24).
- Satu paket per pita.
- Tanpa rekomendasi tutor di versi ini.
- Opsi mapel "UTBK / SNBT" di OrderForm.
- Batas laju gabungan, sama dengan English.

## 8. Yang masih terbuka dan milik tim

- **Pembaca soal UTBK.** Rifky akan meminta; soal `lbi` tidak diaktifkan tanpa pembaca.
- **Persetujuan Aul atau Dhimas** atas ambang pita dan pemetaan pita ke paket SNBT (Satset, Juara, SKS).
- **Apakah ambang cocok** setelah ada data pemakaian (ditinjau setelah ±30 tes).

## 9. Kriteria selesai

1. Pengunjung anonim menyelesaikan 24 soal dan melihat skor per subtes, subtes terlemah, paket, dan disclaimer tanpa login.
2. Respons soal dan hasil tidak memuat `correct_index` maupun `explanation`.
3. Pengunjung anonim tidak bisa membaca atau menulis `diagnostic_attempts` langsung.
4. Aturan pita punya tes otomatis untuk batas (9/10 dan 16/17), semua salah, dan semua benar; aturan subtes terlemah termasuk kasus seri.
5. Semua tes SQL English yang ada tetap lulus; `diagnostic_stats()` tidak menghitung attempt UTBK.
6. Kunci `pk` terverifikasi skrip; soal `lbi` dibaca manusia sebelum aktif.
7. "Pesan paket ini" mengisi `manual_orders` dengan `diagnostic_attempt_id` dan `package_id`.
8. Halaman admin menampilkan statistik UTBK terpisah dari English.
9. `tsc -b` dan `npm run build` bersih; tes Vitest dan SQL lulus.

## 10. Risiko

- **Soal buatan AI salah kunci**, terutama `pu` dan `lbi`. Mitigasi: verifikasi skrip untuk `pk` dan sebagian `pu`, pembaca manusia untuk `lbi`, soal nonaktif sampai itu selesai.
- **Migration 003 menyentuh tabel yang sudah dipakai English.** Mitigasi: hanya melonggarkan batas dan menambah kolom nullable; uji regresi English; skrip tempel dan rollback disiapkan seperti 002, dicoba dulu di database uji.
- **Hasil dibaca sebagai prediksi.** Mitigasi: disclaimer di dua layar.
- **Waktu.** Penulisan dan verifikasi 24 soal adalah bagian paling lama. Fallback: demo monev dengan English saja, UTBK "segera hadir".

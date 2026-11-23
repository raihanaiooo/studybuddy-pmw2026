# Briefing untuk Aul dan Dhimas: Diagnostic English dan hosting

**Tanggal:** 23 Nov 2026
**Dari:** Rifky (IT)
**Tujuan:** minta empat keputusan supaya fitur tes level English siap didemokan saat monev awal Desember.

## 1. Yang sudah jadi

Calon murid membuka halaman `/tes-english` di web Study Buddy, mengerjakan 24 soal pilihan ganda (±8 menit), lalu mendapat:

- level bahasa Inggris (PRE-A1, A1, A2, B1, atau B2),
- satu paket yang disarankan beserta alasannya,
- sampai 3 tutor English yang cocok,
- tombol "Pesan paket ini" yang mengisi form order, lalu membuka chat WhatsApp admin dengan pesan template.

Admin melihat angkanya di halaman `/diagnostics`: jumlah tes, sebaran level, dan berapa tes yang lanjut jadi order.

Statusnya: sudah berjalan di Supabase nyata dan sudah dicoba end-to-end sampai masuk admin. Data uji sudah dibersihkan.

Soalnya orisinal (tidak disalin dari tes pihak lain) dan sudah dicek kunci jawabannya. Pengecekan itu dilakukan AI, bukan tutor, jadi belum setara tinjauan manusia. Catatannya ada di `docs/superpowers/reviews/2026-11-23-diagnostic-english-soal-review.md`.

## 2. Keputusan yang saya butuhkan

### A. Paket mana untuk tiap level (Aul atau Dhimas)

Katalog paket sekarang hanya 5, dan hanya dua yang masuk akal untuk English. Ini usulan saya:

| Level hasil tes | Paket yang disarankan | Alasan |
|---|---|---|
| PRE-A1, A1, A2 | Bundling Bulanan, 12 sesi, Rp550.000, sampai 4 tutor | Pemula butuh latihan rutin |
| B1, B2 | Bundling Terset, 3 sesi, Rp150.000 | Level tinggi cukup dipoles singkat |

Pertanyaan: setuju, atau ada pemetaan lain? Kalau berubah, saya tinggal ubah satu baris di database.

Catatan: paket lain (SNBT Satset, Juara, SKS) untuk UTBK, bukan English. Kalau tim mau paket khusus English, itu perlu dibuat di katalog dulu.

### B. Tutor English (Aul atau Dhimas)

Saat ini database hanya punya 1 tutor terlihat (Matematika dan Fisika). Selama belum ada tutor English yang terverifikasi, hasil tes tidak menampilkan tutor sama sekali.

Pertanyaan: siapa tutor English yang bisa didaftarkan dan diverifikasi sebelum monev? Minimal 1, idealnya 3.

### C. Tinjauan soal (Aul)

Saya sudah meninjau 24 soal, tapi penulis dan peninjaunya sama-sama AI. Sebelum dipakai ke murid sungguhan, sebaiknya ada satu orang yang nyaman berbahasa Inggris membaca ke-24 soal (±15 menit) dan menjawabnya sendiri. Selisih dengan kunci patut dicek.

Pertanyaan: siapa orangnya?

### D. UTBK masuk demo monev atau tidak (Aul)

Update: UTBK mini sudah dibuat di kode (24 soal orisinal: Penalaran Umum, Pengetahuan Kuantitatif, Literasi Bahasa Indonesia, masing-masing 8). Hasilnya skor total, skor per subtes, subtes terlemah, satu paket SNBT, dan catatan bahwa ini gambaran awal, bukan prediksi kelulusan. Soal masih nonaktif sampai ada yang membaca dan memeriksa kuncinya, terutama soal Literasi Bahasa Indonesia dan Penalaran Umum.

Perlu keputusan Aul dan Dhimas: (1) batas pita skor (0-9 benar = SKS, 10-16 = Juara, 17-24 = Satset) setuju atau diubah; (2) siapa pembaca soal UTBK; (3) UTBK ikut demo monev atau tidak. Soal contoh dari Aul hanya dipakai sebagai acuan format, tidak disalin.

## 3. Hosting

Sampai sekarang fitur ini hanya jalan di laptop. Agar bisa didemokan, web harus ter-deploy.

### Yang sudah ada
- Branch `deployment` di repo sudah punya `Dockerfile`, `nginx.conf`, `docker-compose.yml`, dan workflow GitHub yang membangun image. Langkah deploy ke VPS di workflow itu masih dikomentari dengan catatan "TODO: setelah VPS siap".
- Berkas-berkas itu belum ada di branch `development`, dan branch `deployment` ketinggalan dari `development` (belum ada fitur diagnostic).
- Pengalaman PKM: satu VPS dengan Docker, 8 service, memori 2 GB plus swap (repo `tracer-study-backend`, branch `PKM-KI`, folder `deploy/`). Saya tidak menemukan nama penyedia VPS di berkas itu, jadi tidak bisa memastikan itu Biznet.

### Study Buddy jauh lebih ringan dari PKM
Web ini hanya berkas statis (satu container nginx, ±128 MB). Datanya di Supabase. Tidak ada Laravel, Postgres, atau Redis yang perlu dijalankan sendiri.

### Dua pilihan

| | Opsi 1: hosting statis gratis (Cloudflare Pages / Vercel / Netlify) | Opsi 2: VPS + Docker |
|---|---|---|
| Biaya | Rp0 | Sesuai harga VPS, dan domain bila ingin alamat sendiri |
| Waktu | Sekitar setengah hari | 1 sampai 2 hari (VPS, domain, HTTPS) |
| HTTPS | Otomatis | Perlu disiapkan (nginx saat ini hanya port 80) |
| Cocok untuk | Demo monev dan tahap awal | Kalau tim ingin semua di satu server sendiri |

Rekomendasi saya: **Opsi 1 dulu untuk monev**, karena biaya IT di RAB hampir nol dan waktunya sempit. Berkas Docker yang sudah ada tidak terbuang; bisa dipakai nanti kalau VPS siap.

Pertanyaan untuk Dhimas:
1. Apakah di RAB ada pos hosting atau VPS? Kalau ada, berapa dan sudah dibayar?
2. Apakah VPS PKM masih aktif dan boleh dipakai bersama?
3. Perlu domain sendiri (mis. `studybuddy.id`) untuk monev, atau alamat gratis dari penyedia sudah cukup?

### Risiko yang perlu diketahui
- **Supabase gratis bisa berhenti sendiri** kalau lama tidak dipakai. Ini sempat terjadi saat saya mengujinya hari ini (proyek tidak terjangkau sampai di-restart). Sebelum monev, pastikan proyek aktif, dan buka tesnya sehari sebelumnya untuk memastikan.
- **Nomor WhatsApp admin** di form order sudah diganti ke +62 899-9303-251. Pastikan nomor itu memang yang dipantau.

## 4. Ringkasan

| # | Keputusan | Siapa | Default bila tidak ada kabar |
|---|---|---|---|
| A | Pemetaan level ke paket | Aul/Dhimas | Pakai usulan di tabel di atas |
| B | Tutor English terverifikasi | Aul/Dhimas | Hasil tes tanpa bagian tutor |
| C | Pembaca soal | Aul | Soal tetap aktif dengan tinjauan AI |
| D | UTBK di demo, pita skor, dan pembaca soal | Aul | Siap dicoba setelah soal dibaca; butuh persetujuan pita |
| E | Hosting: opsi 1 atau 2, domain, biaya | Dhimas | Opsi 1 |

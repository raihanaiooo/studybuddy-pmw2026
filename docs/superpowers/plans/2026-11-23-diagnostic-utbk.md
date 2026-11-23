# Diagnostic UTBK mini Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pengunjung anonim mengerjakan try out UTBK 24 soal di `/tes-utbk`, lalu melihat skor per subtes, subtes terlemah, satu paket SNBT, dan disclaimer, dan bisa memesan paket itu.

**Architecture:** Memakai tabel diagnostic yang sudah ada (migration `003` hanya menambah kolom dan melonggarkan batas). Penilaian lewat fungsi RPC baru `submit_utbk_attempt`; fungsi English tidak diubah. Halaman tes dijadikan satu `TestRunner` yang dipakai English dan UTBK; halaman admin mendapat bagian UTBK.

**Tech Stack:** Supabase (Postgres, RLS, RPC), React 19, Vite, TypeScript, Tailwind v4, react-router-dom 7, Vitest, Python 3 (hanya untuk skrip pembangun seed).

**Spec:** `docs/superpowers/specs/2026-11-23-diagnostic-utbk-design.md` (dan `2026-11-23-diagnostic-english-design.md` untuk bagian yang sudah ada).

## Global Constraints

- 24 soal: subtes `pu`, `pk`, `lbi`, masing-masing 8; 5 pilihan (A sampai E); satu jawaban benar; soal masuk `is_active = false`; `level` soal UTBK = null.
- Pita dari total benar (dari 24): rendah 0 sampai 9 (`UTBK_RENDAH`, paket SNBT SKS), sedang 10 sampai 16 (`UTBK_SEDANG`, SNBT Juara), tinggi 17 sampai 24 (`UTBK_TINGGI`, SNBT Satset). Rumus umum: rendah bila `correct*10 < total*4`, tinggi bila `correct*10 >= total*7`.
- Batas laju gabungan semua tes: 5 attempt per jam per `client_session_id`. Kode error RPC: `invalid_session`, `unknown_test`, `rate_limited`, `invalid_answers`, `forbidden`.
- Respons dan view publik tidak pernah memuat `correct_index` atau `explanation`.
- Disclaimer (teks tetap): "Ini try out singkat sebagai gambaran awal, bukan penentu atau prediksi kelulusan. Paket yang paling pas tergantung target dan kebutuhan Buddy; admin akan membantu memastikannya."
- Opsi mapel baru di OrderForm: `UTBK / SNBT`. Tanpa rekomendasi tutor untuk UTBK.
- Perilaku tes English tidak boleh berubah. Semua uji English yang ada tetap lulus.
- Soal orisinal; bahan Aul (`D:\StudyBuddy\_utbk_extract`) hanya acuan format dan topik, tidak disalin atau diparafrase dekat.
- Migration baru hanya aman-jalan di atas database yang sudah memuat 002; tidak ada `service_role` di kode web; `web/.env` tidak masuk git.
- Komit lokal di branch fitur; tidak ada push. Pesan komit diakhiri baris atribusi yang berlaku.

## Review Focus

1. **English tidak berubah setelah 003:** validasi `skill`/`level` English tetap menolak nilai ngawur; `diagnostic_stats()` tidak menghitung attempt UTBK; semua uji SQL English lulus dengan 003 terpasang (Task 1, 3).
2. **Batas laju gabungan:** Buddy yang sudah 5 kali tes English ditolak (`rate_limited`) di UTBK (Task 2).
3. **Pita di batas:** 9 vs 10 dan 16 vs 17; `total = 0` ditolak, bukan membagi nol (Task 1).
4. **Paket belum dipetakan:** aturan tanpa `package_id` menghasilkan `package: null`, hasil tetap tampil dengan pesan "admin akan membantu" (Task 2, 6).
5. **Draf antar tes tidak bocor:** draf English yang tersimpan tidak terbaca di UTBK, dan sebaliknya (Task 5).

---

### Task 1: Migration 003 (skema) dan fungsi pita

**Files:**
- Create: `supabase/migration/003_diagnostic_utbk.sql`
- Modify: `supabase/tests/run.sh` (terapkan 003 setelah 002 kecuali `--no-migration`)
- Test: `supabase/tests/utbk.test.sql`

**Interfaces:**
- Produces: `diagnostic_questions.skill` mengizinkan `pu`,`pk`,`lbi` selain nilai English; `diagnostic_questions.level` boleh null (bila tidak null tetap A1..B2); `diagnostic_attempts.level` boleh null dan kolom `result jsonb` (null di attempt English); `diagnostic_rules.level` mengizinkan `UTBK_RENDAH`,`UTBK_SEDANG`,`UTBK_TINGGI` selain nilai CEFR; fungsi `public.diagnostic_utbk_band(p_correct int, p_total int) returns text` (`immutable`, raise `invalid_total` bila `p_total <= 0`).

- [ ] **Step 1: Tulis `utbk.test.sql`** dengan pola `pg_temp.assert_eq` seperti `diagnostic.test.sql`. Pernyataan: `diagnostic_utbk_band` untuk total 24 memberi `UTBK_RENDAH` di 0 dan 9, `UTBK_SEDANG` di 10 dan 16, `UTBK_TINGGI` di 17 dan 24; `diagnostic_utbk_band(0,0)` melempar `invalid_total`; insert soal `skill='pu', level=null` berhasil; insert soal `skill='xyz'` ditolak; insert soal `level='C1'` ditolak; insert soal English `skill='grammar', level='A1'` tetap berhasil; insert rule `level='UTBK_SEDANG'` berhasil dan `level='Z9'` ditolak; insert attempt dengan `level=null` dan `result='{}'` berhasil; kolom `correct_index`/`explanation` tetap tidak ada di `diagnostic_questions_public`.
- [ ] **Step 2: Ubah `run.sh`** agar mengapung `../migration/003_diagnostic_utbk.sql` setelah 002 (berkas belum ada).
- [ ] **Step 3: Jalankan** `bash supabase/tests/run.sh utbk.test.sql` (env PG sementara: `PGHOST=localhost PGPORT=54329 PGUSER=postgres`, PATH berisi `C:\Program Files\PostgreSQL\17\bin`; start klaster sementara bila mati). Harapan: gagal karena berkas 003 tidak ada.
- [ ] **Step 4: Tulis `003_diagnostic_utbk.sql`:** buang dan buat ulang constraint bernama default `diagnostic_questions_skill_check`, `diagnostic_questions_level_check` (izinkan null), `diagnostic_rules_level_check`; `alter column level drop not null` pada questions dan attempts; `add column if not exists result jsonb` pada attempts; fungsi `diagnostic_utbk_band` dengan rumus di Global Constraints. Seluruh berkas boleh dijalankan ulang tanpa error.
- [ ] **Step 5: Jalankan** `bash supabase/tests/run.sh utbk.test.sql diagnostic.test.sql diagnostic_rpc.test.sql`. Harapan: ketiganya `OK` (uji English tetap hijau dengan 003).
- [ ] **Step 6: Komit** (`feat(db): skema diagnostic UTBK dan fungsi pita`).

### Task 2: RPC `submit_utbk_attempt`

**Files:**
- Modify: `supabase/migration/003_diagnostic_utbk.sql`
- Test: `supabase/tests/utbk_rpc.test.sql`

**Interfaces:**
- Consumes: kolom dan `diagnostic_utbk_band` dari Task 1; tabel `packages`, `diagnostic_questions`, `diagnostic_rules`, `diagnostic_attempts`.
- Produces: `public.submit_utbk_attempt(p_client_session_id text, p_answers jsonb) returns jsonb`, `security definer`, `set search_path = public`, execute untuk `anon, authenticated`. Respons: `attempt_id`, `score`, `total`, `band`, `per_subtest` (`{"pu":{"correct":n,"total":n},"pk":...,"lbi":...}`), `weakest` (array kode subtes), `package` (`{id, package_name, price, reason}` atau null). Kolom `result` di attempt menyimpan `{band, per_subtest, weakest}`; `test_code='utbk'`, `level=null`, `score` = total benar, `recommended_package_id` terisi bila ada paket.

- [ ] **Step 1: Tulis `utbk_rpc.test.sql`.** Fixture: 24 soal `test_code='utbk'` aktif (8 per skill `pu`,`pk`,`lbi`, 5 opsi, `level` null, `correct_index` bervariasi 0..4), 3 paket stub, 3 rules (satu per pita, `package_id` terisi). Helper membangun jawaban dengan `n` benar per subtes. Pernyataan: semua benar → `score=24`, `band=UTBK_TINGGI`, `weakest=[]` (ketiganya sama); semua salah → `UTBK_RENDAH`, `weakest=[]`; total benar 9 → `UTBK_RENDAH`, 10 → `UTBK_SEDANG`, 16 → `UTBK_SEDANG`, 17 → `UTBK_TINGGI`; benar pu=2, pk=5, lbi=5 → `weakest=["pu"]`; benar pu=3, pk=3, lbi=6 → `weakest=["pu","pk"]` (seri, urutan pu, pk, lbi); paket sesuai pita; respons dan teks JSON tidak memuat `correct_index` maupun `explanation`; attempt tersimpan `level` null, `result->>'band'` benar; sesi kosong → `invalid_session`; jawaban kurang satu soal → `invalid_answers`; indeks opsi 5 → `invalid_answers`; tanpa soal aktif → `unknown_test`; rule tanpa `package_id` → `package` null namun hasil tetap kembali; 5 attempt English dari sesi yang sama membuat panggilan UTBK ke-6 ditolak `rate_limited`; `anon` boleh memanggil.
- [ ] **Step 2: Jalankan** `bash supabase/tests/run.sh utbk_rpc.test.sql`. Harapan: gagal (fungsi belum ada).
- [ ] **Step 3: Implementasikan `submit_utbk_attempt`** di 003 dengan pola validasi dan batas laju yang sama persis dengan `submit_diagnostic_attempt` (salin pola, bukan memanggilnya), lalu hitung benar per `skill`, pita lewat `diagnostic_utbk_band(total_benar, total_soal)`, subtes terlemah (semua subtes dengan benar paling sedikit; kosong bila ketiganya sama), paket dari `diagnostic_rules` (`test_code='utbk'`, `level=band`, join `packages` aktif).
- [ ] **Step 4: Jalankan** `bash supabase/tests/run.sh utbk.test.sql utbk_rpc.test.sql diagnostic_rpc.test.sql`. Harapan: semuanya `OK`.
- [ ] **Step 5: Komit** (`feat(db): RPC penilaian UTBK`).

### Task 3: Statistik admin (English difilter, UTBK baru)

**Files:**
- Modify: `supabase/migration/003_diagnostic_utbk.sql`
- Test: `supabase/tests/utbk_stats.test.sql`

**Interfaces:**
- Consumes: attempt dari Task 2.
- Produces: `diagnostic_stats()` (create or replace, nama dan hak sama) kini hanya menghitung `test_code='english'` di `total_attempts`, `by_level`, `recent`, dan `orders_from_tests` (order yang `diagnostic_attempt_id`-nya milik attempt English). Fungsi baru `public.diagnostic_stats_utbk() returns jsonb` (admin/management only, raise `forbidden` selain itu): `total_attempts`, `by_band` (`UTBK_RENDAH`,`UTBK_SEDANG`,`UTBK_TINGGI` → bilangan), `avg_percent` (`pu`,`pk`,`lbi` → bilangan bulat 0..100, null bila belum ada attempt), `orders_from_tests`, `recent` (maks 20: `id`, `band`, `score`, `created_at`, `ordered`). Execute hanya untuk `authenticated`.

- [ ] **Step 1: Tulis `utbk_stats.test.sql`.** Pernyataan: setelah menyisipkan attempt English dan UTBK, `diagnostic_stats()->>'total_attempts'` hanya menghitung English; `by_level` tidak berubah oleh attempt UTBK; order yang menaut attempt UTBK tidak dihitung di `orders_from_tests` English, tetapi dihitung di UTBK; `diagnostic_stats_utbk` mengembalikan `by_band` dan `avg_percent` yang benar untuk dua attempt contoh; kosong → `avg_percent->>'pu'` null; `anon` dan role `customer`/`buddy` melempar `forbidden`; `admin` dan `management` berhasil.
- [ ] **Step 2: Jalankan** `bash supabase/tests/run.sh utbk_stats.test.sql`. Harapan: gagal.
- [ ] **Step 3: Implementasikan** perubahan di 003. Hak execute `diagnostic_stats()` tetap `authenticated`.
- [ ] **Step 4: Jalankan** `bash supabase/tests/run.sh utbk.test.sql utbk_rpc.test.sql utbk_stats.test.sql diagnostic.test.sql diagnostic_rpc.test.sql`. Harapan: semuanya `OK`.
- [ ] **Step 5: Komit** (`feat(db): statistik UTBK dan statistik English hanya menghitung English`).

### Task 4: 24 soal UTBK orisinal dan skrip pembangun seed

**Files:**
- Create: `supabase/seed/utbk_questions.json` (sumber soal), `supabase/seed/build_utbk_seed.py` (validasi dan generator), `supabase/seed/test_build_utbk_seed.py` (uji validator), `supabase/seed/diagnostic_utbk.sql` (hasil generator, ikut dikomit)
- Test: `supabase/seed/test_build_utbk_seed.py`, `supabase/tests/diagnostic_utbk_seed.test.sql`

**Interfaces:**
- Produces: format `utbk_questions.json`: `{"passages":[{"id","text"}], "questions":[{"position":1..24,"skill":"pu|pk|lbi","stem","passage_id":null|id,"options":[5 teks berbeda],"correct_index":0..4,"explanation","verify":null|"ekspresi Python"}]}`. `build_utbk_seed.py` mengekspos `validate(data: dict) -> list[str]` (daftar pelanggaran; kosong = lolos) dan CLI `python -I build_utbk_seed.py` yang melempar bila `validate` tidak kosong, lalu menulis `diagnostic_utbk.sql`. Aturan `validate`: 24 soal, posisi 1..24 unik, 8 per skill (pu 1 sampai 8, pk 9 sampai 16, lbi 17 sampai 24), 5 opsi berbeda, `correct_index` 0..4 dan tiap indeks dipakai minimal 3 dan maksimal 7 kali, setiap soal `pk` wajib `verify` yang hasilnya (dievaluasi dengan `fractions.Fraction` dan `math` saja, tanpa builtin lain) sama dengan teks `options[correct_index]`, setiap soal `lbi` wajib `passage_id` yang ada, penjelasan tidak kosong. `diagnostic_utbk.sql`: insert passages dan questions (`test_code='utbk'`, `level` null, `is_active=false`, `on conflict do nothing`), 3 rules (`UTBK_RENDAH`,`UTBK_SEDANG`,`UTBK_TINGGI`, kalimat alasan berbahasa Indonesia, `package_id` null lalu diisi lewat `update ... set package_id = (select id from packages where package_name ilike '%SNBT%SKS' limit 1)` untuk rendah, `%Juara` untuk sedang, `%Satset` untuk tinggi), aman dijalankan ulang.

- [ ] **Step 1: Tulis `test_build_utbk_seed.py`** (`unittest`): data valid minimal lolos; masing-masing pelanggaran berikut menghasilkan pesan: jumlah soal salah, subtes tak seimbang, opsi kembar, `correct_index` 5, indeks jawaban timpang, soal `pk` tanpa `verify`, `verify` yang hasilnya tak sama dengan kunci, `verify` yang mencoba `__import__`/`open` ditolak, soal `lbi` tanpa passage.
- [ ] **Step 2: Jalankan** `python -I -m unittest supabase/seed/test_build_utbk_seed.py`. Harapan: gagal (modul belum ada).
- [ ] **Step 3: Implementasikan `validate` dan CLI** di `build_utbk_seed.py`.
- [ ] **Step 4: Jalankan** uji Python. Harapan: lulus.
- [ ] **Step 5: Tulis `diagnostic_utbk_seed.test.sql`** (setelah 002, 003, seed): ada 24 soal `utbk`, 8 per skill, semuanya nonaktif, 5 opsi tiap soal, `correct_index` < 5, 3 rules punya `reason`, seed dijalankan dua kali tetap 24 soal dan 3 rules, `diagnostic_questions_public` untuk `utbk` kosong (belum aktif), seed English tidak terpengaruh. Jalankan `bash supabase/tests/run.sh ../seed/diagnostic_english.sql ../seed/diagnostic_utbk.sql diagnostic_utbk_seed.test.sql`. Harapan: gagal (seed belum ada).
- [ ] **Step 6: Tulis 24 soal orisinal** di `utbk_questions.json`: 8 `pu` (silogisme dan deduksi, pola dan urutan, analogi, penalaran analitik; 3 mudah, 3 sedang, 2 sulit berurutan naik), 8 `pk` (aritmetika, persentase, perbandingan, aljabar dasar, geometri dasar, peluang sederhana, statistik sederhana, laju/jarak; tiap soal punya `verify`), 8 `lbi` (3 teks pendek orisinal, tiap teks 2 sampai 3 soal: gagasan utama, simpulan, makna kata dalam konteks, kalimat efektif). Bahasa Indonesia, tanpa menyalin bahan Aul; penjelasan singkat dan mengarah ke alasan jawaban.
- [ ] **Step 7: Jalankan CLI** `python -I supabase/seed/build_utbk_seed.py`. Harapan: lolos validasi dan `diagnostic_utbk.sql` terbentuk. Bila gagal, perbaiki soal, bukan validator.
- [ ] **Step 8: Jalankan uji SQL seed** dari Step 5. Harapan: `OK`.
- [ ] **Step 9: Komit** (`feat(db): 24 soal UTBK orisinal dan skrip pembangun seed`).

### Task 5: Logika front-end (tipe, API, draf per tes, helper)

**Files:**
- Modify: `web/src/types/diagnostic.ts`, `web/src/lib/api/diagnostic.ts`, `web/src/lib/diagnostic/session.ts`, `web/src/lib/diagnostic/order.ts`, `web/src/lib/diagnostic/stats.ts`, `web/src/lib/whatsapp.ts`, `web/src/hooks/useDiagnosticTest.ts`
- Create: `web/src/lib/diagnostic/utbk.ts`
- Test: `web/src/lib/diagnostic/utbk.test.ts`; perbarui `session.test.ts`, `order.test.ts`, `stats.test.ts`, `web/src/lib/whatsapp.test.ts`

**Interfaces:**
- Produces (tipe): `DiagnosticSkill` ditambah `'pu'|'pk'|'lbi'`; `DiagnosticQuestion.level` menjadi `DiagnosticQuestionLevel | null`; `UtbkSubtest = 'pu'|'pk'|'lbi'`; `UtbkBand = 'UTBK_RENDAH'|'UTBK_SEDANG'|'UTBK_TINGGI'`; `UtbkResult { attempt_id; score; total; band: UtbkBand; per_subtest: Record<UtbkSubtest,{correct:number;total:number}>; weakest: UtbkSubtest[]; package: DiagnosticPackage | null }`; `UtbkStats { total_attempts; by_band: Record<UtbkBand,number>; avg_percent: Record<UtbkSubtest, number | null>; orders_from_tests; recent: {id;band;score;created_at;ordered}[] }`.
- Produces (fungsi): `session.ts`: `saveDraft(testCode: string, answers: Draft)`, `loadDraft(testCode: string): Draft`, `clearDraft(testCode: string)` dengan kunci `sb_diag_draft_<testCode>`. `api/diagnostic.ts`: `submitUtbkAttempt(answers: Record<string,number>): Promise<UtbkResult>` (RPC `submit_utbk_attempt`, pesan error ramah sama dengan English), `fetchUtbkStats(): Promise<UtbkStats>` (RPC `diagnostic_stats_utbk`). `utbk.ts`: `UTBK_TEST_CODE = 'utbk'`, `UTBK_DISCLAIMER` (teks tetap di Global Constraints), `SUBTEST_INFO: Record<UtbkSubtest,{title:string;hint:string}>` (pu: "Penalaran Umum" / "logika dan penalaran"; pk: "Pengetahuan Kuantitatif" / "hitungan"; lbi: "Literasi Bahasa Indonesia" / "bacaan"), `BAND_INFO: Record<UtbkBand,{label:string}>`, `subtestPercent(r: {correct:number;total:number}): number`, `weakestText(weakest: UtbkSubtest[]): string` (kosong → "Kemampuanmu relatif seimbang di ketiga subtes"; satu atau lebih → "Perlu diperkuat: <judul, judul>"). `stats.ts`: `bandShares(stats: UtbkStats): {band:UtbkBand;count:number;percent:number}[]` dengan urutan RENDAH, SEDANG, TINGGI. `order.ts`: `UTBK_SUBJECT = 'UTBK / SNBT'`, `buildOrderPath(attemptId, packageId, subject = ENGLISH_SUBJECT)`, `KNOWN_SUBJECTS` memuat `UTBK_SUBJECT`. `whatsapp.ts`: `buildAdminWaUrl(order, tes: 'english' | 'utbk' | null)`; English tetap menyebut tes level English; `utbk` menyebut "try out UTBK" dan paket SNBT. `useDiagnosticTest<R>(testCode: string, submitFn: (answers: Record<string, number>) => Promise<R>)` mengembalikan `result: R | null`.

- [ ] **Step 1: Tulis dan perbarui tes (RED).** `utbk.test.ts`: `weakestText([])` seimbang, `["pu"]` menyebut "Penalaran Umum", `["pu","pk"]` menyebut keduanya, `subtestPercent({correct:3,total:8})` = 38 (dibulatkan), `UTBK_DISCLAIMER` persis teks spec. `session.test.ts`: draf English tidak terbaca saat `loadDraft('utbk')` dan sebaliknya; `clearDraft('utbk')` tidak menghapus draf English. `order.test.ts`: `buildOrderPath('<uuid>', null, UTBK_SUBJECT)` memuat `subject=UTBK%20%2F%20SNBT`; `parseOrderParams` menerima subject itu dan tetap membuang subject tak dikenal. `stats.test.ts`: `bandShares` menjumlah 100 untuk data berisi, semua 0 bila kosong. `whatsapp.test.ts`: `'utbk'` memuat "try out UTBK", `'english'` tetap memuat "tes level English", `null` tidak memuat keduanya.
- [ ] **Step 2: Jalankan** `cd web && npx vitest run`. Harapan: gagal pada berkas yang diubah.
- [ ] **Step 3: Implementasikan** semua antarmuka di atas; perbarui pemanggil `saveDraft/loadDraft/clearDraft` di `useDiagnosticTest` (kunci memakai `testCode`) dan `OrderForm` memanggil `buildAdminWaUrl(successData, tes)` dengan `tes` = `null` bila tidak dari tes, `'utbk'` bila `fromTest.subject === UTBK_SUBJECT`, selain itu `'english'`; `DiagnosticTestPage` memakai hook dengan fungsi kirim English `(a) => submitAttempt('english', a)`.
- [ ] **Step 4: Jalankan** `cd web && npx vitest run && npx tsc -b`. Harapan: semua uji lulus, `tsc` tanpa error. (Nilai `level` opsional memaksa pemeriksaan null di tempat yang membacanya.)
- [ ] **Step 5: Komit** (`feat(web): logika UTBK, draf per tes, dan helper`).

### Task 6: Halaman tes UTBK dan kartu hasil

**Files:**
- Create: `web/src/components/diagnostic/TestRunner.tsx`, `web/src/components/diagnostic/UtbkResultCard.tsx`, `web/src/pages/UtbkTestPage.tsx`
- Modify: `web/src/pages/DiagnosticTestPage.tsx`, `web/src/components/diagnostic/QuestionCard.tsx`, `web/src/App.tsx`, `web/src/components/landing/TutorFinder.tsx`, `web/src/components/landing/OrderForm.tsx`

**Interfaces:**
- Consumes: `useDiagnosticTest<R>`, `UtbkResult`, `SUBTEST_INFO`, `UTBK_DISCLAIMER`, `weakestText`, `subtestPercent`, `buildOrderPath`, `UTBK_SUBJECT`.
- Produces: `TestRunner<R>(props: { testCode: string; submitFn: (a: Record<string,number>) => Promise<R>; intro: { title: string; body: string; extra?: ReactNode }; renderResult: (result: R, restart: () => void) => ReactNode; questionBadge?: (q: DiagnosticQuestion) => string | undefined })` memuat seluruh alur (loading, error, intro, soal, kirim, hasil) yang sekarang ada di `DiagnosticTestPage`. `QuestionCard` menerima prop opsional `badge?: string` yang tampil di atas soal. Rute `/tes-utbk` → `UtbkTestPage`. `UtbkResultCard({ result: UtbkResult; onRestart })`: skor total, tiga batang per subtes (`subtestPercent`), `weakestText`, kartu paket (atau pesan "Admin kami akan membantu memilihkan paket" bila `package` null), disclaimer, tautan `buildOrderPath(attempt_id, package?.id ?? null, UTBK_SUBJECT)`.

- [ ] **Step 1: Refaktor tanpa mengubah perilaku.** Pindahkan isi `DiagnosticTestPage` ke `TestRunner`; halaman English menjadi pemanggil tipis dengan teks intro dan `ResultCard` yang sama seperti sekarang. Jalankan `cd web && npx tsc -b && npx vitest run` (harapan: bersih), lalu verifikasi English di browser (Step 6) sebelum lanjut.
- [ ] **Step 2: Buat `UtbkTestPage`**: intro berjudul "Cek kesiapan UTBK kamu" menyebut 24 soal, sekitar 15 menit, tanpa daftar, plus `UTBK_DISCLAIMER`; `questionBadge` mengembalikan `SUBTEST_INFO[q.skill].title` untuk skill UTBK dan `undefined` untuk skill English; `submitFn = submitUtbkAttempt`; `renderResult` memakai `UtbkResultCard`. Daftarkan rute `/tes-utbk` di `App.tsx`.
- [ ] **Step 3: Buat `UtbkResultCard`** sesuai Interfaces; disclaimer tampil di dalam kartu hasil, bukan hanya di intro.
- [ ] **Step 4: Landing dan form order.** `TutorFinder`: di panel "Belum tahu level bahasa Inggrismu?" tambahkan tautan kedua "Cek kesiapan UTBK kamu" ke `/tes-utbk` (tanpa mengubah logika filter). `OrderForm`: tambahkan `<option>UTBK / SNBT</option>` di select Mapel.
- [ ] **Step 5: Jalankan** `cd web && npx tsc -b && npx vitest run && npm run build`. Harapan: bersih dan lulus.
- [ ] **Step 6: Verifikasi di browser (Playwright, REST ditiru; dev server di port 5199).** Pantau permintaan: (a) `/tes-english` masih berjalan penuh seperti sebelum refaktor (intro, 24 soal, hasil); (b) `/tes-utbk`: intro menampilkan disclaimer, soal menampilkan label subtes, soal `lbi` menampilkan teks, kirim hanya memanggil RPC `submit_utbk_attempt` sekali walau tombol diklik dua kali, hasil menampilkan tiga batang, kalimat subtes terlemah, paket, dan disclaimer; (c) respons `package: null` menampilkan pesan admin; (d) refresh di tengah tes UTBK memulihkan jawaban dan tidak memuat draf English; (e) tombol "Pesan paket ini" menuju `/?attempt=...&package=...&subject=UTBK%20%2F%20SNBT#order` dengan Mapel terpilih "UTBK / SNBT"; (f) tautan di landing membuka `/tes-utbk`. Pastikan isi kedua respons soal tidak mengandung `correct_index` maupun `explanation`.
- [ ] **Step 7: Komit** (`feat(web): tes dan hasil UTBK, TestRunner bersama`).

### Task 7: Halaman admin: bagian UTBK

**Files:**
- Create: `web/src/hooks/useUtbkStats.ts`, `web/src/components/diagnostic/UtbkStatsSection.tsx`
- Modify: `web/src/pages/DiagnosticAdminPage.tsx`, `web/src/components/layout/Sidebar.tsx`
- Test: `web/src/lib/diagnostic/stats.test.ts` (sudah memuat `bandShares` dari Task 5)

**Interfaces:**
- Consumes: `fetchUtbkStats`, `UtbkStats`, `bandShares`, `SUBTEST_INFO`, `conversionPercent`.
- Produces: `useUtbkStats(): { stats: UtbkStats | null; loading: boolean; error: string | null; reload: () => void }` (pola `reloadKey` yang sama dengan `useDiagnosticStats`); `UtbkStatsSection()` menampilkan total tes, order dari tes, konversi, sebaran pita (`bandShares`), rata-rata persen benar per subtes (`avg_percent`; "-" bila null), dan 20 tes terbaru. Judul halaman menjadi "Diagnostic" dengan dua bagian ber-judul "English" dan "UTBK"; label sidebar menjadi "Diagnostic".

- [ ] **Step 1: Implementasikan** hook dan komponen; bagian English tetap persis seperti sekarang, hanya dibungkus judul bagian. Kegagalan satu bagian tidak menyembunyikan bagian lain.
- [ ] **Step 2: Jalankan** `cd web && npx tsc -b && npx vitest run && npm run build`. Harapan: bersih.
- [ ] **Step 3: Verifikasi di browser (Playwright, REST ditiru dan sesi admin ditiru seperti pada tes English sebelumnya).** `/diagnostics`: dua bagian tampil dengan angka dari respons tiruan; respons `diagnostic_stats_utbk` gagal menampilkan pesan error hanya di bagian UTBK sementara bagian English tetap tampil; data kosong menampilkan "Belum ada yang mengerjakan tes" dan "-" di rata-rata.
- [ ] **Step 4: Komit** (`feat(web): statistik UTBK di halaman admin`).

### Task 8: Paket tempel, uji coba kering, dokumen, verifikasi akhir

**Files:**
- Create (di luar repo): `D:\StudyBuddy\supabase-apply\utbk-1-apply.sql`, `utbk-2-verify.sql`, `utbk-3-rollback.sql`
- Modify: `docs/briefing-aul-dhimas-2026-11-23.md`, `docs/superpowers/specs/2026-11-23-diagnostic-utbk-design.md`

**Interfaces:**
- Consumes: `003_diagnostic_utbk.sql`, `diagnostic_utbk.sql`.
- Produces: `utbk-1-apply.sql` = `begin;` + 003 + seed UTBK + `commit;`. `utbk-2-verify.sql`: blok `do $$` yang gagal dengan `raise exception` bila: soal `utbk` tidak 24 atau ada yang aktif; kurang dari 3 aturan UTBK; view publik membocorkan kunci; `anon` bisa memanggil `diagnostic_stats_utbk` atau `diagnostic_stats`; `anon` bisa membaca `diagnostic_attempts`; jumlah soal English berubah dari 24. `utbk-3-rollback.sql`: hapus soal, aturan, dan attempt `utbk` (beserta kaitan `manual_orders.diagnostic_attempt_id` menjadi null), drop `submit_utbk_attempt`, `diagnostic_stats_utbk`, `diagnostic_utbk_band`, kembalikan `diagnostic_stats()` ke versi 002, kembalikan tiga constraint ke versi 002 dan `not null`/`drop column result` hanya bila tidak ada baris yang melanggar (jika ada, berhenti dengan pesan jelas).

- [ ] **Step 1: Susun tiga berkas** dari berkas sumber dan cek isinya tidak memuat rahasia.
- [ ] **Step 2: Uji coba kering di database sementara** (`dry`): stub, `002_diagnostic.sql`, seed English, satu attempt English dan satu order tiruan; lalu `utbk-1-apply.sql` → `utbk-2-verify.sql` (harapan: lolos) → `utbk-3-rollback.sql` (harapan: attempt English dan order tiruan tetap ada, objek UTBK hilang) → `utbk-1-apply.sql` dan `utbk-2-verify.sql` lagi (harapan: lolos). Hapus database sementara.
- [ ] **Step 3: Perbarui dokumen.** Briefing: poin D menjadi "UTBK mini sudah dibangun, soal nonaktif sampai ada pembaca"; tambahkan permintaan persetujuan ambang pita dan pemetaan SKS/Juara/Satset serta catatan bahwa soal `lbi` butuh pembaca. Spec UTBK: ubah status menjadi "Disetujui, dibangun" dan catat penyimpangan dari rancangan bila ada.
- [ ] **Step 4: Verifikasi akhir:** semua uji SQL (`utbk*.test.sql`, `diagnostic*.test.sql`, seed English dan UTBK), `python -I -m unittest supabase/seed/test_build_utbk_seed.py`, `cd web && npx vitest run && npx tsc -b && npm run build`. Harapan: semuanya lulus; cantumkan hasilnya apa adanya.
- [ ] **Step 5: Komit** (`docs: briefing dan spec UTBK diperbarui`). Jangan push dan jangan merge; serahkan keputusan itu ke Rifky.

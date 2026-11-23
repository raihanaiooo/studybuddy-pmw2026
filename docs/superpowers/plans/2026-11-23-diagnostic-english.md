# Diagnostic English Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pengunjung anonim mengerjakan tes English 24 soal di `/tes-english`, lalu melihat level CEFR, satu paket, dan maksimal 3 tutor, dan bisa memesan paket itu. Admin melihat statistiknya di `/diagnostics`.

**Architecture:** Soal disimpan di Supabase. Browser hanya membaca soal lewat view tanpa kunci jawaban. Penilaian, penentuan level, rekomendasi, dan penyimpanan attempt dilakukan satu fungsi RPC `SECURITY DEFINER`. Front-end React memakai pola yang ada (`lib/api/*.ts`, `hooks/use*.ts`, halaman di `pages/`).

**Tech Stack:** Supabase (Postgres, RLS, RPC), React 19, Vite, TypeScript, Tailwind v4, react-router-dom 7, Vitest (baru, hanya untuk helper murni).

**Spec:** `docs/superpowers/specs/2026-11-23-diagnostic-english-design.md`

## Global Constraints

- Stack tetap; tidak ada layanan berbayar baru.
- Soal English 100% orisinal; tidak ada soal dari EF SET, Cambridge, TOEFL, atau tes placement lain.
- Level: `A1`, `A2`, `B1`, `B2`, ditambah `PRE_A1` bila A1 pun di bawah ambang.
- 24 soal: 6 per level; keahlian `grammar`, `vocabulary`, `reading`.
- Ambang level: minimal **4 dari 6** benar per level, dan semua level di bawahnya juga terpenuhi.
- Tanpa login dan tanpa data pribadi sebelum order (nama dan WhatsApp baru saat "Pesan paket ini").
- `correct_index` dan `explanation` tidak pernah dikirim ke `anon`.
- Pengunjung anonim tidak boleh membaca atau menulis `diagnostic_attempts` secara langsung.
- Kolom baru di `manual_orders` nullable agar order lama tetap jalan.
- Tutor yang direkomendasikan: `verification_status = 'verified'`, `subjects` memuat `ing` atau `Bahasa Inggris`, maksimal 3.
- Admin = `users.role = 'management'`.
- Commit hanya setelah Rifky mengizinkan.

## Review Focus

Kondisi yang disiratkan spec tetapi tidak disebut eksplisit; tiap baris punya tes di task pemiliknya.

1. **Jawaban dimanipulasi atau tidak lengkap** (indeks di luar rentang, ID soal tidak dikenal, kurang dari 24 jawaban): RPC menolak dengan error `invalid_answers` dan tidak menyimpan attempt. (Task 2)
2. **Kirim ganda / spam** dari satu `client_session_id`: lebih dari 5 attempt per jam ditolak dengan `rate_limited`. (Task 2)
3. **Tidak ada tutor English terverifikasi atau tidak ada aturan paket untuk level itu**: hasil tetap tampil, `tutors` kosong dan `package` null, tanpa error. (Task 2, 6)
4. **localStorage/sessionStorage diblokir** (mode privat): `client_session_id` jatuh ke ID acak di memori, tes tetap bisa selesai. (Task 4)
5. **Halaman di-refresh di tengah tes**: jawaban yang sudah diisi pulih dari `sessionStorage`; tes tidak mulai dari nol. (Task 5)

---

## File Structure

| File | Tanggung jawab |
|---|---|
| `supabase/migration/002_diagnostic.sql` | Tabel, view soal publik, RLS, fungsi level, RPC `submit_diagnostic_attempt`, RPC `diagnostic_stats`, kolom baru `manual_orders` |
| `supabase/tests/00_stubs.sql` | Tabel minimal (`users`, `tutors`, `packages`, `manual_orders`) untuk uji lokal; bukan migration |
| `supabase/tests/diagnostic.test.sql` | Uji SQL: level, RLS, RPC |
| `supabase/seed/diagnostic_english.sql` | 24 soal orisinal + aturan paket contoh; soal masuk dengan `is_active = false` |
| `supabase/tests/diagnostic_seed.test.sql` | Validasi isi seed (jumlah, distribusi, indeks kunci) |
| `web/src/types/diagnostic.ts` | Tipe `DiagnosticQuestion`, `DiagnosticResult`, `DiagnosticStats` |
| `web/src/lib/diagnostic/session.ts` | `getClientSessionId`, `loadDraft`, `saveDraft`, `clearDraft` (murni, ditest) |
| `web/src/lib/api/diagnostic.ts` | `fetchQuestions`, `submitAttempt`, `fetchDiagnosticStats`, `fetchRecentAttempts` |
| `web/src/hooks/useDiagnosticTest.ts` | State tes: indeks, jawaban, kirim, hasil |
| `web/src/hooks/useDiagnosticStats.ts` | Data halaman admin |
| `web/src/components/diagnostic/{QuestionCard,ProgressBar,ResultCard}.tsx` | UI tes dan hasil |
| `web/src/pages/DiagnosticTestPage.tsx` | Halaman publik `/tes-english` |
| `web/src/pages/DiagnosticAdminPage.tsx` | Halaman admin `/diagnostics` |
| Modifikasi | `App.tsx`, `Sidebar.tsx`, `OrderForm.tsx`, `TutorFinder.tsx`, `package.json` |

---

### Task 1: Skema, view publik, RLS, dan fungsi level

**Files:**
- Create: `supabase/migration/002_diagnostic.sql`, `supabase/tests/00_stubs.sql`, `supabase/tests/diagnostic.test.sql`

**Interfaces:**
- Produces: tabel `diagnostic_passages`, `diagnostic_questions`, `diagnostic_rules`, `diagnostic_attempts`; view `diagnostic_questions_public` (tanpa `correct_index`, `explanation`); fungsi `diagnostic_level(p_a1 int, p_a2 int, p_b1 int, p_b2 int, p_threshold int default 4) returns text`; kolom `manual_orders.diagnostic_attempt_id uuid null`, `manual_orders.package_id uuid null`.
- Kolom `diagnostic_questions`: `id uuid pk`, `test_code text`, `position int`, `skill text check in ('grammar','vocabulary','reading')`, `level text check in ('A1','A2','B1','B2')`, `stem text`, `passage_id uuid null`, `options jsonb`, `correct_index int`, `explanation text`, `is_active bool default true`.
- `diagnostic_rules`: `test_code text`, `level text` (termasuk `PRE_A1`), `package_id uuid null references packages`, `reason text`, primary key `(test_code, level)`.
- `diagnostic_attempts`: `id uuid pk`, `test_code`, `client_session_id text`, `answers jsonb`, `score int`, `level text`, `recommended_package_id uuid null`, `created_at timestamptz`.

- [ ] **Step 1: Tulis `00_stubs.sql`** — buat `public.users(id, role)`, `public.tutors(id, full_name, subjects text[], verification_status text, is_featured bool, rating numeric)`, `public.packages(id, package_name, price, is_active)`, dan `public.manual_orders(id, name, whatsapp, subject, jenjang, status)` dengan kolom minimal yang dibaca fitur ini.
- [ ] **Step 2: Tulis uji `diagnostic_level` yang gagal** di `diagnostic.test.sql` (blok `DO` yang `RAISE EXCEPTION` bila tidak sama). Kasus:
  - `diagnostic_level(0,0,0,0) = 'PRE_A1'`
  - `diagnostic_level(3,6,6,6) = 'PRE_A1'` (A1 di bawah ambang meski level atas penuh)
  - `diagnostic_level(4,0,0,0) = 'A1'`
  - `diagnostic_level(6,3,6,6) = 'A1'` (A2 gagal, level di atasnya diabaikan)
  - `diagnostic_level(6,4,4,3) = 'B1'`
  - `diagnostic_level(6,6,6,6) = 'B2'`
  - batas ambang: `(4,4,4,4) = 'B2'` dan `(4,4,4,3) = 'B1'`
- [ ] **Step 3: Tulis uji RLS** yang gagal: sebagai role `anon`, `select` dari `diagnostic_questions` dan `diagnostic_attempts` ditolak (0 baris atau `insufficient_privilege`), `insert` ke `diagnostic_attempts` ditolak, `select` dari `diagnostic_questions_public` berhasil dan tidak punya kolom `correct_index` maupun `explanation`.
- [ ] **Step 4: Jalankan, pastikan gagal.** Run: `psql "$DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/00_stubs.sql -f supabase/tests/diagnostic.test.sql` terhadap database lokal kosong (Supabase CLI: `supabase start`, lalu `supabase db reset`). Expected: error `function diagnostic_level does not exist`.
- [ ] **Step 5: Tulis `002_diagnostic.sql`**: tabel dan constraint di atas, `diagnostic_level` (hitung level tertinggi berurutan A1→B2 yang lulus ambang), view `diagnostic_questions_public` dengan `security_invoker = false` dan hak `select` untuk `anon, authenticated` (hanya baris `is_active`), `enable row level security` di empat tabel tanpa policy untuk `anon`, policy `select` di `diagnostic_attempts` untuk `users.role = 'management'`, dan `alter table manual_orders add column if not exists ...`.
- [ ] **Step 6: Jalankan uji lagi.** Expected: semua blok `DO` selesai tanpa exception.
- [ ] **Step 7: Commit** (setelah diizinkan): `feat(db): skema diagnostic English, view publik, RLS`.

### Task 2: RPC `submit_diagnostic_attempt` dan `diagnostic_stats`

**Files:**
- Modify: `supabase/migration/002_diagnostic.sql`, `supabase/tests/diagnostic.test.sql`

**Interfaces:**
- Consumes: tabel dan `diagnostic_level` dari Task 1.
- Produces: `submit_diagnostic_attempt(p_test_code text, p_client_session_id text, p_answers jsonb) returns jsonb`. `p_answers` berbentuk `{"<question_id>": <option_index>}`. Mengembalikan `{"attempt_id": uuid, "score": int, "total": int, "level": text, "package": {"id","package_name","price","reason"} | null, "tutors": [{"id","full_name","university","avatar_url"}], "per_level": {"A1":int,"A2":int,"B1":int,"B2":int}}`. Hak `execute` untuk `anon, authenticated`.
- Produces: `diagnostic_stats() returns jsonb` hanya untuk `management`: `{"total_attempts","by_level":{"A1":n,...},"orders_from_tests":n,"recent":[{"id","level","score","created_at","ordered":bool}]}`.

- [ ] **Step 1: Tulis uji RPC yang gagal.** Fixture di dalam uji: 1 tes dengan 8 soal aktif (2 per level), 2 tutor English `verified`, 1 tutor `pending`, 1 tutor Matematika `verified`, 1 paket, aturan untuk `B1`. Kasus:
  - semua benar → `level = 'B2'`, `score = 8`, attempt tersimpan satu baris
  - tutor yang dikembalikan hanya yang `verified` dan English; maksimal 3, `is_featured` lebih dulu
  - **(Review Focus 1)** indeks opsi di luar rentang, ID soal tak dikenal, dan jumlah jawaban kurang dari jumlah soal aktif → exception `invalid_answers` dan `count(*)` attempt tidak bertambah
  - **(Review Focus 2)** panggilan ke-6 dalam satu jam dengan `client_session_id` sama → exception `rate_limited`; `client_session_id` lain tetap diterima
  - **(Review Focus 3)** level tanpa baris di `diagnostic_rules` dan database tanpa tutor English → hasil tidak error, `package` bernilai `null`, `tutors` = `[]`
  - respons tidak memuat kunci `correct_index` maupun `explanation`
  - `diagnostic_stats()` oleh `anon` ditolak; oleh `management` mengembalikan hitungan yang cocok dengan fixture
- [ ] **Step 2: Jalankan, pastikan gagal.** Expected: `function submit_diagnostic_attempt does not exist`.
- [ ] **Step 3: Implementasikan kedua fungsi** di `002_diagnostic.sql`. Validasi jawaban dulu, baru hitung skor per level dan panggil `diagnostic_level`. Batas laju 5 attempt per jam per `client_session_id` (keputusan saya; ubah di satu konstanta di fungsi).
- [ ] **Step 4: Jalankan uji.** Expected: semua lulus.
- [ ] **Step 5: Commit**: `feat(db): RPC penilaian dan statistik diagnostic`.

### Task 3: Seed 24 soal English orisinal

**Files:**
- Create: `supabase/seed/diagnostic_english.sql`, `supabase/tests/diagnostic_seed.test.sql`

**Interfaces:**
- Consumes: skema Task 1.
- Produces: 24 baris `diagnostic_questions` (`test_code = 'english'`, `is_active = false`), beberapa baris `diagnostic_passages` untuk soal reading, dan 5 baris `diagnostic_rules` contoh (`PRE_A1`, `A1`, `A2`, `B1`, `B2`) dengan `package_id` null dan `reason` terisi.

- [ ] **Step 1: Tulis uji validasi seed yang gagal**: tepat 24 soal; tepat 6 per level; tiap level punya minimal 1 soal per keahlian (grammar, vocabulary, reading); 3 soal reading minimal per level B1 dan B2 memakai `passage_id`; tiap soal punya 4 opsi dan `correct_index` antara 0 dan 3; `stem` dan `explanation` tidak kosong; tidak ada dua soal dengan `stem` sama.
- [ ] **Step 2: Jalankan, pastikan gagal.** Expected: jumlah soal 0.
- [ ] **Step 3: Tulis 24 soal** acuan deskriptor CEFR Companion Volume (A1: kalimat dasar dan kosakata sehari-hari; A2: tense sederhana dan preposisi; B1: kondisional dan teks pendek; B2: nuansa kosakata dan teks argumentatif). Semua orisinal. Sebarkan `correct_index` merata (jangan semua 0), hindari pola yang mudah ditebak.
- [ ] **Step 4: Jalankan uji.** Expected: lulus.
- [ ] **Step 5: Gerbang tinjauan manual.** Serahkan file ke satu tutor English Study Buddy untuk memeriksa kunci dan tingkat kesulitan. Soal tetap `is_active = false` sampai ada persetujuannya; mengaktifkan dilakukan dengan `update diagnostic_questions set is_active = true where test_code = 'english'`.
- [ ] **Step 6: Commit**: `feat(db): seed 24 soal English orisinal`.

### Task 4: Tipe, API, helper sesi, dan Vitest

**Files:**
- Create: `web/src/types/diagnostic.ts`, `web/src/lib/diagnostic/session.ts`, `web/src/lib/diagnostic/session.test.ts`, `web/src/lib/api/diagnostic.ts`
- Modify: `web/package.json` (devDependency `vitest`, script `"test": "vitest run"`)

**Interfaces:**
- Produces (`session.ts`): `getClientSessionId(): string`; `saveDraft(answers: Record<string, number>): void`; `loadDraft(): Record<string, number>`; `clearDraft(): void`.
- Produces (`api/diagnostic.ts`): `fetchQuestions(testCode: string): Promise<DiagnosticQuestion[]>` (dari view publik, urut `position`, menyertakan teks passage); `submitAttempt(testCode: string, answers: Record<string, number>): Promise<DiagnosticResult>` (memanggil RPC dengan `getClientSessionId()`); `fetchDiagnosticStats(): Promise<DiagnosticStats>`.
- Tipe `DiagnosticQuestion`: `{ id: string; position: number; skill: 'grammar'|'vocabulary'|'reading'; level: 'A1'|'A2'|'B1'|'B2'; stem: string; passage: string | null; options: string[] }`.

- [ ] **Step 1: Tulis uji `session.test.ts` yang gagal** (pakai `localStorage`/`sessionStorage` tiruan):
  - `getClientSessionId()` dua kali berturut-turut mengembalikan nilai sama
  - **(Review Focus 4)** bila `localStorage.setItem` melempar error, tetap mengembalikan string tak kosong dan stabil selama modul yang sama
  - **(Review Focus 5)** `saveDraft({a: 1})` lalu `loadDraft()` mengembalikan `{a: 1}`; JSON rusak di storage mengembalikan `{}`; `clearDraft()` mengosongkan
- [ ] **Step 2: Jalankan.** Run: `cd web && npm install && npx vitest run src/lib/diagnostic/session.test.ts`. Expected: FAIL (modul belum ada).
- [ ] **Step 3: Implementasikan `session.ts`** dengan fallback ke variabel modul saat storage melempar error.
- [ ] **Step 4: Jalankan uji.** Expected: PASS.
- [ ] **Step 5: Tulis `types/diagnostic.ts` dan `api/diagnostic.ts`** mengikuti pola `lib/api/packages.ts` (lempar error Supabase, tanpa `any`).
- [ ] **Step 6: Verifikasi tipe.** Run: `cd web && npx tsc -b`. Expected: tanpa error.
- [ ] **Step 7: Commit**: `feat(web): tipe, API, dan helper sesi diagnostic`.

### Task 5: Halaman tes `/tes-english`

**Files:**
- Create: `web/src/hooks/useDiagnosticTest.ts`, `web/src/components/diagnostic/QuestionCard.tsx`, `web/src/components/diagnostic/ProgressBar.tsx`, `web/src/pages/DiagnosticTestPage.tsx`
- Modify: `web/src/App.tsx` (rute publik `/tes-english`)

**Interfaces:**
- Consumes: `fetchQuestions`, `submitAttempt`, `loadDraft`, `saveDraft`, `clearDraft` (Task 4).
- Produces: `useDiagnosticTest(testCode: string)` mengembalikan `{ status: 'loading'|'intro'|'in_progress'|'submitting'|'done'|'error'; questions; index; answers; answer(questionId: string, optionIndex: number): void; next(): void; prev(): void; submit(): Promise<void>; result: DiagnosticResult | null; error: string | null }`.

- [ ] **Step 1: Implementasikan hook.** Jawaban disimpan ke draft tiap kali berubah dan dibaca saat mount **(Review Focus 5)**. `submit()` aktif hanya bila semua soal terjawab dan memblokir klik ganda selama `submitting`. Setelah berhasil, `clearDraft()`.
- [ ] **Step 2: Implementasikan `QuestionCard`, `ProgressBar`, dan halaman** dengan token desain landing (`var(--blue)`, `var(--ink)`, dll.) mengikuti gaya `OrderForm`: layar pembuka (durasi ±8 menit, tanpa daftar), satu soal per layar, tombol Kembali/Lanjut, passage ditampilkan di atas soal reading.
- [ ] **Step 3: Daftarkan rute `/tes-english`** di blok *PUBLIC ROUTES* `App.tsx`.
- [ ] **Step 4: Verifikasi.** Run: `cd web && npm run build && npm run lint`. Expected: bersih. Lalu `npm run dev`, buka `/tes-english` dengan soal aktif di database lokal: selesaikan 24 soal, refresh di soal ke-10 dan pastikan jawaban 1–9 pulih.
- [ ] **Step 5: Commit**: `feat(web): halaman tes English`.

### Task 6: Hasil, rekomendasi, dan handoff ke order

**Files:**
- Create: `web/src/components/diagnostic/ResultCard.tsx`
- Modify: `web/src/pages/DiagnosticTestPage.tsx`, `web/src/components/landing/OrderForm.tsx`

**Interfaces:**
- Consumes: `DiagnosticResult` (Task 2/4).
- Produces: `ResultCard({ result, onOrder }: { result: DiagnosticResult; onOrder: () => void })`. `OrderForm` membaca query `?attempt=<uuid>&package=<uuid|empty>&subject=Bahasa%20Inggris` dan mengisi `manual_orders.diagnostic_attempt_id`, `package_id`, serta menetapkan mapel "Bahasa Inggris". Tombol "Pesan paket ini" mengarah ke `/?attempt=...&package=...#order`.

- [ ] **Step 1: Implementasikan `ResultCard`**: level beserta kalimat "kamu bisa ..." per level, paket dan alasannya, daftar tutor (nama, kampus). **(Review Focus 3)** Bila `package` null, tampilkan pesan netral "Admin akan membantu memilih paket" dan tombol tetap aktif; bila `tutors` kosong, sembunyikan bagian tutor tanpa error.
- [ ] **Step 2: Ubah `OrderForm`** agar membaca parameter di atas, memilih mapel "Bahasa Inggris" otomatis, dan menyertakan kedua kolom baru saat `insert` ke `manual_orders`. Tanpa parameter, perilaku lama tidak berubah.
- [ ] **Step 3: Verifikasi.** Run: `cd web && npm run build && npm run lint`. Lalu manual: selesaikan tes, klik "Pesan paket ini", kirim form, dan pastikan baris `manual_orders` memuat `diagnostic_attempt_id` dan `package_id`. Kirim form tanpa parameter dan pastikan kolom itu null.
- [ ] **Step 4: Commit**: `feat(web): hasil tes dan handoff ke order`.

### Task 7: Halaman admin `/diagnostics`

**Files:**
- Create: `web/src/hooks/useDiagnosticStats.ts`, `web/src/pages/DiagnosticAdminPage.tsx`
- Modify: `web/src/App.tsx` (rute di dalam blok `ProtectedRoute`), `web/src/components/layout/Sidebar.tsx` (item "Diagnostic English")

**Interfaces:**
- Consumes: `fetchDiagnosticStats` (Task 4). `StatCard` dan `Card` dari `components/ui`.
- Produces: `useDiagnosticStats(): { stats: DiagnosticStats | null; loading: boolean; error: string | null; reload(): void }`.

- [ ] **Step 1: Implementasikan hook dan halaman**: kartu total tes, sebaran level (batang sederhana), jumlah order dari tes beserta persentase konversi, tabel 20 attempt terbaru (level, skor, waktu, sudah order atau belum). Pakai `PageHeader`, `StatCard`, dan `Card` yang ada.
- [ ] **Step 2: Tambahkan rute dan item sidebar.**
- [ ] **Step 3: Verifikasi.** Run: `cd web && npm run build && npm run lint`. Lalu masuk sebagai akun `management` dan pastikan angka cocok dengan data uji; akun non-`management` mendapat error dari RPC dan halaman menampilkan pesan, bukan layar kosong.
- [ ] **Step 4: Commit**: `feat(web): halaman admin diagnostic`.

### Task 8: Pintu masuk landing, verifikasi akhir, dan dokumen

**Files:**
- Modify: `web/src/components/landing/TutorFinder.tsx`, `docs/superpowers/specs/2026-11-23-diagnostic-english-design.md`

- [ ] **Step 1: Tambahkan tautan "Cek level English kamu"** ke `/tes-english` di `TutorFinder` (tanpa mengubah logika filter yang ada).
- [ ] **Step 2: Verifikasi seluruh kriteria spec bagian 9.** Run: `psql ... -f supabase/tests/diagnostic.test.sql -f supabase/tests/diagnostic_seed.test.sql`, `cd web && npx vitest run && npm run build && npm run lint`. Expected: semua lulus. Lalu telusuri satu alur penuh anonim di browser dari landing sampai baris `manual_orders` dan statistik admin.
- [ ] **Step 3: Pemeriksaan kebocoran kunci.** Di DevTools tab Network, pastikan respons `diagnostic_questions_public` tidak memuat `correct_index` atau `explanation`.
- [ ] **Step 4: Perbarui spec** bila ada keputusan yang berubah saat implementasi (batas laju, nama kolom).
- [ ] **Step 5: Commit**: `feat(web): tautan tes di landing dan verifikasi akhir`.

---

## Catatan eksekusi

- Uji SQL membutuhkan Supabase CLI dan Docker (`supabase start`). Migration 002 diterapkan ke database nyata hanya setelah Rifky atau Rai memberi akses dan skema nyata ditarik (`supabase db dump`) untuk membandingkan nama kolom `tutors`, `packages`, dan `manual_orders` dengan stub.
- Soal baru boleh diaktifkan di produksi hanya setelah Task 3 Step 5 selesai.

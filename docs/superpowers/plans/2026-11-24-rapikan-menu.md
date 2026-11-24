# Rapikan Menu Web Admin (Tahap 0) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sidebar admin yang ringkas: menu mobile disingkirkan (ditahan), Pelamar Tutor dan Verifikasi Tutor jadi satu menu **Tutor** bertab, dan halaman **Pengaturan** berisi Layanan & Harga.

**Architecture:** Daftar menu hidup di satu modul murni (`navigation.ts`) yang diuji; Sidebar hanya menampilkannya. Menu Tutor memakai halaman daftar tutor yang ada, ditambah satu tab "Pelamar baru" yang memuat isi halaman pelamar yang dipindah menjadi komponen. Halaman paket dipindah menjadi tab Layanan & Harga di Pengaturan. Tanpa perubahan database.

**Tech Stack:** React 19, react-router-dom 7, Tailwind 4 (CSS dibuat ulang), Vitest 3, TypeScript.

**Spec:** `docs/superpowers/specs/2026-11-24-order-sesi-gaji-design.md` (bagian 4 dan tahap 0).

## Global Constraints

- Teks antarmuka bahasa Indonesia; dialog memakai `showAlert`/`showPrompt` dari `src/lib/dialogs.ts` seperti kode sekitarnya.
- Tanpa perubahan database, tanpa SQL, tanpa dependensi baru.
- Berkas halaman mobile (booking, payment, reschedule, complaint, payroll, tokens, performance) **tidak dihapus**; hanya dilepas dari menu dan rute.
- Setelah menulis kelas Tailwind baru jalankan `npm run css:build` (hasilnya `src/tailwind-generated.css` ikut dikomit).
- Jangan menambah `any` baru. `npm run lint` sudah punya 82 temuan lama; tidak perlu dibereskan di sini.
- Perubahan di folder `web/`; perintah dijalankan dari `web/`. Komit atau dorong ke git hanya bila Rifky meminta.

## Review Focus

- Tautan atau penanda lama (`/tutor-applications`, `/packages`, `/settings`) tidak boleh berujung 404; harus mengalihkan ke halaman baru.
- Alamat mobile yang ditahan (mis. `/bookings`) menampilkan halaman "tidak ditemukan", bukan layar putih atau galat.
- `?tab=` yang salah atau kosong pada halaman Tutor jatuh ke tab Pelamar baru, tidak crash.
- Jumlah pelamar baru gagal dimuat: menu Tutor tetap bisa dipakai, angka di tab tidak tampil.
- Halaman detail tutor (`/tutors/:id`) tetap menyorot menu Tutor di sidebar.

---

### Task 1: Modul navigasi

**Files:**
- Create: `src/lib/navigation.ts`
- Test: `src/lib/navigation.test.ts`

**Interfaces:**
- Produces:
  - `type NavIconKey = 'dashboard' | 'orders' | 'tutors' | 'content' | 'diagnostics' | 'settings'`
  - `interface NavItem { path: string; label: string; icon: NavIconKey }`
  - `interface NavSection { heading: string | null; items: NavItem[] }`
  - `const NAV_SECTIONS: NavSection[]` urutan: Dashboard (tanpa judul); `OPERASIONAL`: Orderan Masuk `/orders`; `TUTOR`: Tutor `/tutors`; `LANDING PAGE`: Manajemen Konten `/content`, Diagnostic `/diagnostics`; `SISTEM`: Pengaturan `/pengaturan`
  - `const HELD_MOBILE_PREFIXES: readonly string[]` = `/bookings`, `/payments`, `/reschedules`, `/complaints`, `/payroll`, `/tokens`, `/performance`
  - `const LEGACY_REDIRECTS: Record<string, string>` = `{'/tutor-applications': '/tutors?tab=pelamar', '/packages': '/pengaturan', '/settings': '/pengaturan'}`
  - `function isHeldPath(pathname: string): boolean` (cocok bila sama dengan awalan atau diawali awalan + `/`)

- [ ] **Step 1: Write the failing tests** in `navigation.test.ts` dengan empat kasus: (a) `NAV_SECTIONS memuat 6 item dan path unik`; (b) `tidak ada item menu yang jalurnya ditahan` (`isHeldPath(item.path)` false untuk semua); (c) `isHeldPath('/bookings/123')` true, `isHeldPath('/bookings')` true, `isHeldPath('/bookingsx')` false, `isHeldPath('/tutors/1')` false; (d) `LEGACY_REDIRECTS` memetakan `/tutor-applications` ke `/tutors?tab=pelamar`, `/packages` dan `/settings` ke `/pengaturan`, dan tidak ada target yang ditahan.
- [ ] **Step 2: Run** `npx vitest run src/lib/navigation.test.ts`. Expected: FAIL (modul belum ada).
- [ ] **Step 3: Implement** `navigation.ts` sesuai Interfaces di atas.
- [ ] **Step 4: Run** perintah yang sama. Expected: PASS.

### Task 2: Menu Tutor bertab (gabungan Pelamar dan Verifikasi)

**Files:**
- Create: `src/lib/tutorTabs.ts`, `src/lib/tutorTabs.test.ts`, `src/components/tutor/ApplicantsPanel.tsx`
- Modify: `src/pages/tutor/TutorListPage.tsx`, `src/lib/api/tutorApplications.ts`
- Delete: `src/pages/tutor/TutorApplicationsPage.tsx` (isinya pindah ke `ApplicantsPanel`)

**Interfaces:**
- Produces:
  - `type TutorTab = 'pelamar' | 'pending' | 'verified' | 'rejected' | 'all'`
  - `const TUTOR_TABS: Array<{ key: TutorTab; label: string }>` = Pelamar baru, Menunggu, Terverifikasi, Ditolak, Semua
  - `function parseTutorTab(value: string | null): TutorTab` (tidak dikenal atau null menghasilkan `'pelamar'`)
  - `function tabToVerificationFilter(tab: TutorTab): VerificationStatus | 'all' | null` (`null` untuk `'pelamar'`)
  - `function countNewApplications(): Promise<number>` di `tutorApplications.ts` (`select` jumlah, `status = 'baru'`; melempar `Error` bila gagal)
  - `function ApplicantsPanel(props: { onChanged?: () => void }): JSX.Element` (isi halaman pelamar tanpa `PageHeader`; memanggil `onChanged` setelah tolak atau terima berhasil)
- Consumes: `fetchApplications`, `updateApplication`, `deleteApplicationDocuments`, `signedDocumentUrl` (sudah ada), `useTutors` (sudah ada).

- [ ] **Step 1: Write the failing tests** `tutorTabs.test.ts`: `parseTutorTab('verified')` = `'verified'`; `parseTutorTab(null)`, `parseTutorTab('')`, `parseTutorTab('ngawur')` = `'pelamar'`; `tabToVerificationFilter('pelamar')` = `null`, `('pending')` = `'pending'`, `('all')` = `'all'`; `TUTOR_TABS` memuat lima kunci unik dengan `pelamar` pertama.
- [ ] **Step 2: Run** `npx vitest run src/lib/tutorTabs.test.ts`. Expected: FAIL.
- [ ] **Step 3: Implement** `tutorTabs.ts` dan `countNewApplications`.
- [ ] **Step 4: Run** perintah yang sama. Expected: PASS.
- [ ] **Step 5: Pindahkan** isi `TutorApplicationsPage` (tanpa `PageHeader`) menjadi `ApplicantsPanel`, tanpa mengubah perilakunya; panggil `onChanged` di `reload()` pasca aksi.
- [ ] **Step 6: Ubah `TutorListPage`:** judul "Tutor" dengan subjudul tentang pelamar sampai tutor aktif; tab dibaca dari `useSearchParams` (`tab`) lewat `parseTutorTab`; deretan tombol filter lama diganti `TUTOR_TABS` (tab Pelamar baru menampilkan angka dari `countNewApplications`, angka disembunyikan bila gagal atau 0); tab `pelamar` merender `<ApplicantsPanel onChanged={...}/>` dan menyembunyikan pencarian dan pilihan tampilan; tab lain memanggil `setFilter(tabToVerificationFilter(tab))`. Tombol "Tambah Tutor Manual" tetap.
- [ ] **Step 7: Verify:** `npx tsc -b` tanpa galat.

### Task 3: Halaman Pengaturan (Layanan & Harga)

**Files:**
- Create: `src/pages/SettingsPage.tsx`, `src/components/settings/ServicesPanel.tsx`
- Delete: `src/pages/PackageListPage.tsx` (isinya pindah)

**Interfaces:**
- Produces: `function ServicesPanel(): JSX.Element` (isi `PackageListPage` yang sekarang: pencarian, tampilkan nonaktif, kartu paket, `PackageFormModal`, ubah dan aktifkan/nonaktifkan; **tanpa** kartu statistik "Token Terjual" dan "Total Revenue" yang berasal dari data mobile; kartu "Total Paket" dan "Paket Aktif" dihitung dari daftar paket di halaman, bukan dari `fetchPackageStats`); judul bagian "Layanan & Harga" dengan tombol "Tambah Layanan".
- `SettingsPage`: `PageHeader` "Pengaturan" + `ServicesPanel`. Tab lain ditambahkan di tahap berikutnya, jadi sekarang tanpa deretan tab.

- [ ] **Step 1: Pindahkan** `PackageListPage` menjadi `ServicesPanel` dengan perubahan di atas; konfirmasi nonaktifkan paket tetap dipertahankan.
- [ ] **Step 2: Buat** `SettingsPage`.
- [ ] **Step 3: Verify:** `npx tsc -b` tanpa galat.

### Task 4: Sidebar, rute, dan catatan

**Files:**
- Modify: `src/components/layout/Sidebar.tsx`, `src/App.tsx`, `README.md` (di `web/`)

**Interfaces:**
- Consumes: `NAV_SECTIONS`, `LEGACY_REDIRECTS`, `NavIconKey` dari `src/lib/navigation.ts`; `TutorListPage`, `SettingsPage`.

- [ ] **Step 1: Sidebar** merender `NAV_SECTIONS`: judul bagian huruf kecil kapital kecil berwarna `--mute` (hanya bila `heading` ada), item memakai `NavLink` seperti sekarang; peta ikon `NavIconKey` ke ikon lucide: `LayoutDashboard`, `ShoppingCart`, `GraduationCap`, `FileText`, `ClipboardCheck`, `Settings`.
- [ ] **Step 2: App.tsx:** hapus impor dan rute booking, payment, reschedule, complaint, payroll, tokens, performance, package list, dan tutor-applications; tambah `/pengaturan` → `SettingsPage`; untuk tiap pasangan `LEGACY_REDIRECTS` tambah `<Route path={from} element={<Navigate to={to} replace />} />` di dalam grup admin; rute lain tidak berubah.
- [ ] **Step 3: README** (`web/README.md`): bagian "Fitur mobile ditahan" berisi tabel menu lama → berkas halaman (`src/pages/booking/`, `payment/`, `reschedule/`, `complaint/`, `payroll/`, `TokenListPage.tsx`, `PerformancePage.tsx`) dan cara menghidupkan lagi (impor dan rute di `App.tsx`, entri di `navigation.ts`).
- [ ] **Step 4: Verify:** `npx vitest run` (semua lulus), `npx tsc -b`, `npm run css:build`, `npm run build` (tanpa galat).

### Task 5: Pemeriksaan akhir dan dokumen

**Files:**
- Modify: `docs/superpowers/specs/2026-11-24-order-sesi-gaji-design.md`

- [ ] **Step 1: Jalankan** `npm run dev`; periksa dengan akun admin: sidebar berisi 6 menu dengan judul bagian; `/tutors?tab=pelamar` dan `/tutor-applications` menampilkan pelamar; tab Menunggu, Terverifikasi, Ditolak, Semua menampilkan tutor sesuai status; tombol Tambah Tutor Manual masih membuka formulir; `/tutors/<id>` menyorot menu Tutor; `/pengaturan` dan `/packages` menampilkan Layanan & Harga (tambah, ubah, nonaktifkan paket jalan); `/bookings` menampilkan "tidak ditemukan".
- [ ] **Step 2: Perbarui spec:** di tahap 0 dan bagian 4, catat dua penyesuaian: tab Tutor memakai lima tab (ditambah "Menunggu" untuk tutor yang sudah dibuat tapi belum diverifikasi), dan tab **Info Bisnis** dipindah ke tahap 3 karena belum ada tempat penyimpanan tanpa database.
- [ ] **Step 3: Laporkan** hasil ke Rifky beserta daftar periksa langkah 1; minta izin sebelum komit.

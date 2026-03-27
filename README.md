# 📚 Study Buddy

> **Bahasa / Language:** [🇮🇩 Indonesia](#-indonesia) · [🇬🇧 English](#-english)

---

## 🇮🇩 Indonesia

**Study Buddy** adalah platform belajar berbasis peer-tutoring yang menghubungkan mahasiswa sebagai customer dengan tutor sesama mahasiswa berprestasi. Platform ini terdiri dari **aplikasi mobile Flutter** untuk customer & tutor, serta **web panel manajemen Next.js** untuk tim internal.

---

### 🏗️ Tech Stack & Arsitektur

#### Mobile App (Flutter)
| Layer | Teknologi |
|---|---|
| Framework | Flutter |
| Arsitektur | MVC (Model–View–Controller) |
| State Management | GetX |
| Backend | Supabase (PostgreSQL) |
| Auth | Supabase Auth |
| Realtime | Supabase Realtime |
| Storage | Supabase Storage |
| Notifikasi | Firebase Cloud Messaging (FCM) |
| Deep Link (Sesi) | Google Meet (url_launcher) |

#### Web Manajemen (Next.js)
| Layer | Teknologi |
|---|---|
| Framework | Next.js 16 (App Router) |
| Bahasa | TypeScript |
| Styling | Tailwind CSS v4 |
| Backend | Supabase (shared dengan Flutter) |
| Auth | Supabase Auth (role: management) |

#### Design Pattern (Gang of Four)
- **Singleton** → `SupabaseService`, `NotificationService`
- **Factory Method** → `fromMap()` di semua Model
- **Observer** → Supabase Realtime + GetX `.obs`
- **Repository** → Service layer (auth, realtime) sebagai data access layer
- **Dependency Injection** → GetX `Get.lazyPut()`

---

### 📁 Struktur Folder

```
studybuddy/                          ← Root monorepo
│
├── lib/                             ← Flutter app
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                 ← MaterialApp setup
│   │   └── routes.dart              ← Routing & binding
│   ├── core/
│   │   ├── constants/               ← Warna, text style, Supabase config
│   │   ├── services/                ← Supabase, Auth, FCM, Realtime
│   │   └── utils/                   ← Date & validator utils
│   ├── models/                      ← User, Tutor, Booking, Session, Review
│   ├── controllers/                 ← Auth, Dashboard, Tutor, Booking, Session, Review
│   └── views/
│       ├── auth/                    ← Splash, Login, Register
│       ├── customer/                ← Dashboard, TutorList, Detail, Booking, Schedule
│       ├── tutor/                   ← Dashboard, Schedule, Profile tutor
│       ├── session/                 ← Session screen, Review screen
│       └── shared/widgets/          ← BottomNav, TutorCard, StatusBadge, Loading
│
├── studybuddy_web/                  ← Next.js management web
│   ├── app/
│   │   ├── globals.css
│   │   └── layout.tsx
│   ├── components/
│   │   ├── layout/                  ← Sidebar, TopBar, DashboardLayout
│   │   ├── ui/                      ← StatCard, StatusBadge, ConfirmModal
│   │   └── tutor/                   ← ApprovalCard, TutorListItem
│   ├── hooks/                       ← useAuth, useOprec
│   ├── lib/
│   │   └── supabaseClient.ts
│   ├── pages/
│   │   ├── login.tsx
│   │   └── dashboard/
│   │       ├── index.tsx            ← Statistik
│   │       ├── approvals.tsx        ← Approval tutor
│   │       ├── tutors.tsx           ← Manajemen tutor aktif
│   │       └── oprec.tsx            ← Kelola jadwal oprec
│   └── types/
│       └── index.ts
│
└── supabase/
    └── migrations/
        └── 001_init.sql             ← Schema database lengkap
```

---

### ⚙️ Setup & Instalasi

#### Prasyarat
- Flutter SDK ≥ 3.x
- Node.js ≥ 18.x & npm
- Akun [Supabase](https://supabase.com)
- Akun [Firebase](https://console.firebase.google.com)

---

#### 1. Clone Repository
```bash
git clone https://github.com/username/studybuddy.git
cd studybuddy
```

---

#### 2. Setup Supabase

1. Buat project baru di [supabase.com](https://supabase.com)
2. Buka **SQL Editor** → paste & jalankan `supabase/migrations/001_init.sql`
3. Jalankan juga SQL RLS policies berikut:

```sql
-- Users
CREATE POLICY "users_read_own" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "users_update_own" ON public.users FOR UPDATE USING (auth.uid() = id);

-- Tutors
CREATE POLICY "tutors_read_all" ON public.tutors FOR SELECT USING (true);
CREATE POLICY "tutors_update_own" ON public.tutors FOR UPDATE USING (auth.uid() = user_id);

-- Bookings
CREATE POLICY "bookings_read_own" ON public.bookings FOR SELECT
  USING (auth.uid() = customer_id OR auth.uid() = (SELECT user_id FROM tutors WHERE id = tutor_id));
CREATE POLICY "bookings_insert_customer" ON public.bookings FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "bookings_update_own" ON public.bookings FOR UPDATE
  USING (auth.uid() = customer_id OR auth.uid() = (SELECT user_id FROM tutors WHERE id = tutor_id));

-- Sessions
CREATE POLICY "sessions_read_own" ON public.sessions FOR SELECT USING (
  booking_id IN (SELECT id FROM bookings WHERE customer_id = auth.uid()
    OR tutor_id IN (SELECT id FROM tutors WHERE user_id = auth.uid())));
CREATE POLICY "sessions_insert" ON public.sessions FOR INSERT WITH CHECK (true);
CREATE POLICY "sessions_update" ON public.sessions FOR UPDATE USING (true);

-- Reviews
CREATE POLICY "reviews_read_all" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "reviews_insert_customer" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- Oprec
CREATE POLICY "oprec_read_all" ON public.oprec_schedules FOR SELECT USING (true);
CREATE POLICY "oprec_management_write" ON public.oprec_schedules FOR ALL
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'management'));
```

4. Copy **Project URL** dan **anon key** dari *Settings → API*

---

#### 3. Setup Flutter

```bash
# Install dependencies
flutter pub get
```

Isi konfigurasi Supabase di `lib/core/constants/supabase_constants.dart`:
```dart
static const String supabaseUrl     = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

Setup Firebase (FCM):
```bash
dart pub global activate flutterfire_cli
flutterfire configure
# Pilih platform: android, ios
```

Tambahkan inisialisasi Firebase di `lib/main.dart`:
```dart
import 'firebase_options.dart';
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

Download font **Nunito** & **Poppins** dari [Google Fonts](https://fonts.google.com) dan taruh di `assets/fonts/`.

Jalankan app:
```bash
flutter run
```

---

#### 4. Setup Web Manajemen

```bash
cd studybuddy_web
npm install
```

Buat file `.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Jalankan:
```bash
npm run dev
# Buka http://localhost:3000
```

Buat akun admin di Supabase Dashboard → **Authentication → Users → Add user**, lalu set role-nya:
```sql
UPDATE public.users SET role = 'management' WHERE email = 'admin@email.com';
```

---

#### 5. Konfigurasi Android

Di `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId = "com.studybuddy.app"
    minSdk = 21
    targetSdk = 34
}
```

Di `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

---

### 🔑 Fitur MVP

| Fitur | Status |
|---|---|
| Auth (Login/Register customer & tutor) | ✅ |
| Dashboard & discovery tutor online | ✅ |
| Profil & portofolio tutor | ✅ |
| Booking tutor (min. H-5 jam) | ✅ |
| Sesi belajar (Google Meet & chat timer) | ✅ |
| Rating & ulasan setelah sesi | ✅ |
| Tombol "Butuh tutor sekarang?" | ✅ |
| Web panel approval tutor | ✅ |
| Web panel kelola jadwal oprec | ✅ |

---

---

## 🇬🇧 English

**Study Buddy** is a peer-tutoring platform that connects students as customers with high-achieving fellow students as tutors. The platform consists of a **Flutter mobile app** for customers & tutors, and a **Next.js management web panel** for the internal team.

---

### 🏗️ Tech Stack & Architecture

#### Mobile App (Flutter)
| Layer | Technology |
|---|---|
| Framework | Flutter |
| Architecture | MVC (Model–View–Controller) |
| State Management | GetX |
| Backend | Supabase (PostgreSQL) |
| Auth | Supabase Auth |
| Realtime | Supabase Realtime |
| Storage | Supabase Storage |
| Notifications | Firebase Cloud Messaging (FCM) |
| Session Links | Google Meet (url_launcher) |

#### Management Web (Next.js)
| Layer | Technology |
|---|---|
| Framework | Next.js 16 (App Router) |
| Language | TypeScript |
| Styling | Tailwind CSS v4 |
| Backend | Supabase (shared with Flutter) |
| Auth | Supabase Auth (role: management) |

#### Design Patterns (Gang of Four)
- **Singleton** → `SupabaseService`, `NotificationService`
- **Factory Method** → `fromMap()` in all Models
- **Observer** → Supabase Realtime + GetX `.obs`
- **Repository** → Service layer as data access layer
- **Dependency Injection** → GetX `Get.lazyPut()`

---

### 📁 Folder Structure

```
studybuddy/                          ← Monorepo root
│
├── lib/                             ← Flutter app
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                 ← MaterialApp setup
│   │   └── routes.dart              ← Routing & bindings
│   ├── core/
│   │   ├── constants/               ← Colors, text styles, Supabase config
│   │   ├── services/                ← Supabase, Auth, FCM, Realtime
│   │   └── utils/                   ← Date & validator utilities
│   ├── models/                      ← User, Tutor, Booking, Session, Review
│   ├── controllers/                 ← Auth, Dashboard, Tutor, Booking, Session, Review
│   └── views/
│       ├── auth/                    ← Splash, Login, Register
│       ├── customer/                ← Dashboard, TutorList, Detail, Booking, Schedule
│       ├── tutor/                   ← Dashboard, Schedule, Profile
│       ├── session/                 ← Session screen, Review screen
│       └── shared/widgets/          ← BottomNav, TutorCard, StatusBadge, Loading
│
├── studybuddy_web/                  ← Next.js management web
│   ├── app/
│   │   ├── globals.css
│   │   └── layout.tsx
│   ├── components/
│   │   ├── layout/                  ← Sidebar, TopBar, DashboardLayout
│   │   ├── ui/                      ← StatCard, StatusBadge, ConfirmModal
│   │   └── tutor/                   ← ApprovalCard, TutorListItem
│   ├── hooks/                       ← useAuth, useOprec
│   ├── lib/
│   │   └── supabaseClient.ts
│   ├── pages/
│   │   ├── login.tsx
│   │   └── dashboard/
│   │       ├── index.tsx            ← Statistics
│   │       ├── approvals.tsx        ← Tutor approvals
│   │       ├── tutors.tsx           ← Active tutor management
│   │       └── oprec.tsx            ← Open recruitment schedule
│   └── types/
│       └── index.ts
│
└── supabase/
    └── migrations/
        └── 001_init.sql             ← Full database schema
```

---

### ⚙️ Setup & Installation

#### Prerequisites
- Flutter SDK ≥ 3.x
- Node.js ≥ 18.x & npm
- [Supabase](https://supabase.com) account
- [Firebase](https://console.firebase.google.com) account

---

#### 1. Clone Repository
```bash
git clone https://github.com/username/studybuddy.git
cd studybuddy
```

---

#### 2. Supabase Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Open **SQL Editor** → paste and run `supabase/migrations/001_init.sql`
3. Run the RLS policies SQL (see Indonesian section above)
4. Copy your **Project URL** and **anon key** from *Settings → API*

---

#### 3. Flutter Setup

```bash
flutter pub get
```

Fill in `lib/core/constants/supabase_constants.dart`:
```dart
static const String supabaseUrl     = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

Setup Firebase:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
# Select platforms: android, ios
```

Add Firebase init to `lib/main.dart`:
```dart
import 'firebase_options.dart';
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

Download **Nunito** & **Poppins** fonts from [Google Fonts](https://fonts.google.com) and place them in `assets/fonts/`.

Run the app:
```bash
flutter run
```

---

#### 4. Management Web Setup

```bash
cd studybuddy_web
npm install
```

Create `.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Run:
```bash
npm run dev
# Open http://localhost:3000
```

Create an admin account in Supabase Dashboard → **Authentication → Users → Add user**, then set the role:
```sql
UPDATE public.users SET role = 'management' WHERE email = 'admin@email.com';
```

---

#### 5. Android Configuration

In `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId = "com.studybuddy.app"
    minSdk = 21
    targetSdk = 34
}
```

In `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

---

### 🔑 MVP Features

| Feature | Status |
|---|---|
| Auth (Login/Register customer & tutor) | ✅ |
| Dashboard & online tutor discovery | ✅ |
| Tutor profile & portfolio | ✅ |
| Booking (min. 5 hours in advance) | ✅ |
| Study session (Google Meet & chat timer) | ✅ |
| Rating & review after session | ✅ |
| "Need a tutor now?" on-demand button | ✅ |
| Web panel tutor approval | ✅ |
| Web panel open recruitment schedule | ✅ |

---

*Study Buddy · 2026*

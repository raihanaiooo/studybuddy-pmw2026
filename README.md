# Study Buddy PMW 2026

Monorepo untuk aplikasi Study Buddy.

## Struktur

- `mobile/` — Aplikasi mobile Flutter (Buddy & Tutor)
- `web/` — Web admin (internal, React + Vite)
- `supabase/` — Migration & konfigurasi database
- `docs/` — Dokumentasi

## Branch Strategy

| Branch | Fungsi |
|---|---|
| `development` | Default branch, tempat kerja sehari-hari |
| `deployment` | Trigger deploy ke VPS |
| `main` | Production mirror |

## Setup

### Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter run
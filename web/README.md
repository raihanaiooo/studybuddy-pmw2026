# React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Oxc](https://oxc.rs)
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/)

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type-aware lint rules:

```js
export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...

      // Remove tseslint.configs.recommended and replace with this
      tseslint.configs.recommendedTypeChecked,
      // Alternatively, use this for stricter rules
      tseslint.configs.strictTypeChecked,
      // Optionally, add this for stylistic rules
      tseslint.configs.stylisticTypeChecked,

      // Other configs...
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])

```

You can also install [eslint-plugin-react-x](https://npmx.dev/package/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://npmx.dev/package/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])

```

## Fitur mobile ditahan

Menu dan rute berikut dilepas dari web admin (2026-11-24) karena datanya berasal dari aplikasi mobile yang belum dipakai.
Berkas halamannya masih ada; data di database tidak diubah.

| Menu lama | Berkas |
|---|---|
| Bookings | `src/pages/booking/` |
| Transaksi | `src/pages/payment/` |
| Reschedule | `src/pages/reschedule/` |
| Komplain | `src/pages/complaint/` |
| Payroll (versi lama) | `src/pages/payroll/` |
| Token Buddy | `src/pages/TokenListPage.tsx` |
| Performa tutor | `src/pages/PerformancePage.tsx` |

Menghidupkan lagi: impor halaman dan tambahkan `<Route>` di `src/App.tsx`, lalu tambahkan item di `NAV_SECTIONS`
(`src/lib/navigation.ts`) dan keluarkan awalannya dari `HELD_MOBILE_PREFIXES`.
Alamat lama yang digabung (`/tutor-applications`, `/packages`, `/settings`) dialihkan lewat `LEGACY_REDIRECTS`.

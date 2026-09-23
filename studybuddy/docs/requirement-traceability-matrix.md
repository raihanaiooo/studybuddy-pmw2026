# Requirement Traceability Matrix — Study Buddy

**Document type:** Formal Requirement Traceability Matrix (RTM)
**Status:** Living document. Rev 1 was analysis-only. Rev 2 records the Wave 1 fixes and is re-derived from verified code and test evidence.
**Date:** 23 September 2026
**Baseline analysed:** branch `ui-merge` (HEAD `1f1fba5 Wire up cross-module entry points now that all UI branches are merged`; the Wave 1 change set is uncommitted in the working tree)
**Requirement source:** *Software Requirements Specification for Study Buddy*, Version 1.0 `<approved>`, 06 Agustus 2026 (supplied as text; see §1 — the SRS is **not** committed to this repository)
**Code baseline:** `lib/` — 69 Dart files, ~9,022 LOC (rev 2 modifies 6 of them, adds no new file); `test/` — 9 files (8 functional smoke tests + 1 dead default that fails — see §1.6)

| Rev | Date | Change | Evidence |
|---|---|---|---|
| 1 | 23 Sep 2026 | Initial analysis of the `ui-merge` baseline | 74 requirement rows, §2–§10 |
| 2 | 23 Sep 2026 | Wave 1 audit: affected rows, defect table, summary counts and §10 re-derived; §1.6 added | `test/review_smoke_test.dart` (8 tests, all passing) · `flutter analyze`: 0 errors · full `flutter test`: 41 passed / 1 pre-existing failure |
**Requirement wording is unchanged in rev 2.** Only implementation status, gap descriptions, evidence and counts were updated.

---

## 0. How to use this document

* This matrix is the **source of truth for the implementation plan**. Every implementation task must reference one or more requirement IDs from this file.
* **No requirement may be implemented while its "Decision needed" cell is open** — see §4 (Assumptions log traceability) and §5 (Open issues traceability).
* Nothing in the "Required change" column invents behaviour beyond what the SRS states. Where the SRS is silent, the cell says so and points to the decision register instead of proposing a design.
* Rows are ordered by requirement ID. Wave assignments are consolidated in §10.

### 0.1 Status taxonomy (primary status — exactly one per requirement)

| Status | Meaning |
|---|---|
| **A** — Implemented and aligned | Behaviour observed in code matches the SRS statement (minor cosmetic/naming debt may still be noted). |
| **P** — Partially implemented | Some of the requirement's clauses are met; others are not. |
| **M** — Implemented but not aligned | Code exists and does something, but it contradicts or materially diverges from the SRS clause. |
| **U** — UI only / mock | Presentation exists; the data behind it is hardcoded, in-memory, or simulated. |
| **X** — Missing | No UI and/or no logic and/or no data path exists. |
| **?** — Ambiguous / needs clarification | The SRS itself declares the requirement tentative/undecided, so a correct implementation cannot be judged or written yet. |

### 0.2 Layer legend (the five separations requested)

The `Layer state` column reads `UI <n> · Logic <n> · Data <n>`:

1. **UI** = presentation that already exists (screens, widgets, layout, copy).
2. **Logic** = business/application logic that exists.
3. **Data** = data access / backend integration that exists (Supabase Auth/DB/Realtime/Storage, payment gateway, platform services).

Symbols: `✅` exists in full · `◐` exists partially · `✗` absent. `n/a` = not applicable to that layer.

Requirements that are **contradicted by existing code** are additionally marked with `⚠ contradicts SRS` in the Gap column, and requirements whose rules are **entirely absent** are marked `∅ no logic`.
§9 consolidates the five groups (UI exists / logic exists / data access exists / logic missing / logic contradicts).

### 0.3 Column meanings

| Column | Meaning |
|---|---|
| Implementation | File › symbol of the current implementation, or `—` if none. |
| Gap vs SRS | Difference between the SRS clause and current behaviour. |
| Required change | Minimal change needed to satisfy the clause, expressed only in terms the SRS provides. |
| Depends on | Other requirement IDs that must be settled first. |
| Wave / Prio | Implementation wave (§10) and priority `P1` (MVP core) / `P2` (MVP completeness) / `P3` (deferred or SRS-optional). |
| Decision needed | `—` when the SRS is sufficient; otherwise a decision that must be taken before implementation. |

---

## 1. Baseline scope, version conflict and caveats

### 1.1 The SRS file is absent from the repository

`git ls-files` matches `pubspec.lock`, `pubspec.yaml` for the pattern `srs|docs|spec|requirement`. `README.md` is the unmodified Flutter starter stub. **The SRS v1.0 supplied in the conversation is the only requirement source; nothing in the repo versions or validates it.** Consequence: there is no machine-checkable link between requirements and code, which is precisely what this RTM adds.

### 1.2 Version conflict — the code was written against a *different, later* SRS

The code cites requirement IDs and SRS sections that **do not exist in SRS v1.0**. These modules are fully scaffolded in the UI but have no counterpart in the analysed SRS, including its entity list (§4.1).

| Cited in code | Claimed SRS location | Present in SRS v1.0? |
|---|---|---|
| `FR-PKG-01..07` (Paket & Token) | "SRS 3.4 Sistem Paket & Token" | ✗ |
| `FR-PAYR-01..07` (Payroll / Honor Tutor) | "modul Payroll di 3.9" | ✗ |
| `FR-RESCH-01..09` (Reschedule) | entity "Reschedule di SRS 4.1" | ✗ |
| `FR-PAY-08..14` | Payment module beyond v1.0's 01..07 | ✗ |
| `FR-PROF-11..12` | Profile module beyond v1.0's 01..10 | ✗ |
| "Web Panel Manajemen", "modul 3.22–3.24" | Admin dashboard sections | ✗ |

**Consequence for this RTM:** these modules are **out of scope of the analysed SRS** and therefore carry no FR rows below. They are logged in §7 as *surplus implementation* that must be either (a) promoted into a ratified SRS version, or (b) removed. **They must not silently drive the target architecture.**

### 1.3 No backend contract artefacts exist in the repository

There are **no SQL migrations, schema files, RLS policies, edge functions or API contracts** anywhere in the repo. Every "Data" judgement below is therefore about *client-side* data access calls only; the existence/correctness of tables, columns, constraints and RLS on the Supabase side is **unverifiable from this repository** and is owned by the Back-End role per SRS §6.

### 1.4 Known code-level defects that distort requirement status

These are recorded here because they make an otherwise "present" requirement behave incorrectly, and are cited in the rows below:

Resolved defects are retained here (marked **RESOLVED**, with the wave that fixed them) so the audit trail survives.

| Ref | Defect | Location |
|---|---|---|
| D1 | `booking.sessionType == 'video' ? null : null` — both branches null, so the Google Meet link is **never** provided to the launcher. | `views/session/session_screen.dart › initState` |
| D2 | **RESOLVED (W1-1, rev 2).** Was: review submitted with `tutorId: ''` and `subject: ''`, so review rows were written against an empty tutor id and the rating roll-up targeted `''`. Now fixed by carrying the booking's Tutor/subject into the review route. | `views/session/review_screen.dart`, `controllers/review_controller.dart`, `controllers/session_controller.dart`, `views/session/session_screen.dart` |
| D3 | **RESOLVED (W1-2, rev 2).** Was: "Lewati" (skip) submitted a **1-star** review instead of skipping. Now performs no write at all. | `views/session/review_screen.dart` › `TextButton.onPressed` |
| D4 | Rating roll-up is computed and written **from the client** with a fragile `as int` cast. | `controllers/review_controller.dart › _recalculateTutorRating` |
| D5 | Booking is created with status `'pending'` after payment, then requires manual Tutor confirmation — contradicting the SRS "no manual confirmation" clause. | `controllers/booking_controller.dart › createBooking`; `views/tutor/tutor_dashboard_screen.dart` (Konfirmasi/Tolak) |
| D6 | Buddy profile save mutates in-memory `Rx<UserModel>` only; nothing is persisted. | `controllers/profile_controller.dart › saveBuddyProfile` |
| D7 | Document "upload" writes the sentinel string `'pending-upload'` and performs no file picker or Storage call. | `controllers/profile_controller.dart › uploadDocument` |
| D8 | **RESOLVED (W1-4, rev 2).** Was: debug `print()` of the auth response (including `response.session`), the user payload, the insert result and stack traces in the sign-up path. All removed with no behaviour change; the residual auth-path logging was audited and classified in `docs/wave-1-completion-report.md` Part A. | `core/services/auth_service.dart › signUp` |
| D9 | Role is resolved from **two different sources** (DB `users.role` in `AuthController`, GoTrue session metadata in `SplashScreen`). | `controllers/auth_controller.dart`; `views/auth/splash_screen.dart` |
| D10 | Presenter performs its own Supabase read, bypassing the controller. | `views/auth/splash_screen.dart › _checkSession` |

### 1.5 Dead / unused artefacts (affect completeness claims)

| Artefact | State |
|---|---|
| `views/shared/screens/error_screen.dart` | **0-byte file**, unused |
| `views/shared/widgets/loading_overlay.dart` | Defined, never referenced |
| `core/services/realtime_service.dart › subscribeBookings` | Defined, never called |
| `core/services/notification_service.dart` | Defined; `initialize()` is commented out in `main.dart`, so FCM is inert |
| `controllers/tutor_controller.dart › getRecommendations` | Defined, never called |
| `controllers/profile_controller.dart › toggleEditing` | Defined, never called |
| `cached_network_image` (pubspec) | Declared, never imported (`TutorCard` uses `Image.network`) |
| `PayrollPortfolio` / package / token / reschedule modules | See §1.2 |

### 1.6 Wave 1 change set — the evidence behind rev 2

The four Wave 1 items the Wave 0 plan classified as *genuinely unblocked* (`docs/wave-0-plan.md` §D) were implemented in the working tree (no commit, no migration, no schema/RLS/storage/gateway change, no architecture refactor, no UI redesign):

| Item | Files | What changed |
|---|---|---|
| W1-1 | `controllers/session_controller.dart`, `views/session/session_screen.dart`, `views/session/review_screen.dart`, `controllers/review_controller.dart` | `SessionController` now stores the `BookingModel` it was started from (`currentBooking`); `endSession()` routes to the review screen with `{sessionId, tutorId, subject}`; the screen submits those real values; `submitReview` refuses an empty session/tutor id before touching data |
| W1-2 | `views/session/review_screen.dart` | "Lewati" writes nothing and exits to the Buddy dashboard |
| W1-3 | `core/services/auth_service.dart`, `controllers/auth_controller.dart` | `AuthService.resetPassword()` → Supabase Auth `resetPasswordForEmail`; `AuthController.resetPassword()` + `resetEmailSent`. **Mechanism only** — no user-facing entry point, screen, deep link or new-password flow |
| W1-4 | `core/services/auth_service.dart` | Removed all sign-up debug logging (D8); the `try/catch` that existed only to print was removed — the exception still propagates to `AuthController` exactly as before |
| Tests | `test/review_smoke_test.dart` *(new)* | 8 tests (5 widget + 3 controller-logic) covering context plumbing, the true skip, and the empty-context guard |

Verification commands and results are recorded in `docs/wave-1-completion-report.md`. **Not done, by design:** forgot-password UI, reset screen, deep-link configuration, Supabase project configuration, and D1 (the `: null` Google Meet link) — the last is a session-delivery item outside the Wave 1 scope that was executed.

---

## 2. Functional requirements

### 2.1 Auth & Onboarding (SRS §3.1 FR-AUTH-01..07)

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| FR-AUTH-01 | Registration with role selection: Buddy or Tutor | `views/auth/register_screen.dart` (role tabs) › `controllers/auth_controller.dart › register` › `core/services/auth_service.dart › signUp` | UI ✅ · Logic ✅ · Data ✅ | **P** | Role vocabulary is `customer`/`tutor` (plus an unconsumed `'management'` in `UserModel` docs), not `Buddy`/`Tutor`; tutor tab additionally shows an "oprec approval" notice that the SRS does not describe | Agree the canonical role vocabulary and apply it consistently across registration, routing and queries | — | W1 / P1 | Role identifier set vs SRS role names (§4.1 "role") |
| FR-AUTH-02 | Collect name, email, phone, and grade level (Buddy) at registration | `register_screen.dart` (name/email/password only) › `signUp` | UI ◐ · Logic ◐ · Data ◐ | **P** | Phone and education level are not collected at registration; password is collected but is not part of this clause; `UserModel` fields `phone`/`usia`/`kelas`/`asal_sekolah`/`mata_pelajaran_diminati` are mapped but the `users` column contract is unconfirmed | Add phone + grade level to the registration flow and persist them with the account | FR-AUTH-06, FR-PROF-01 | W1 / P1 | `users` column contract for phone/grade (BE) |
| FR-AUTH-03 | Authenticate with email & password via Supabase Auth | `auth_service.dart › signIn/signUp` | UI ✅ · Logic ✅ · Data ✅ | **A** | D8 **resolved in rev 2 (W1-4)**: the sign-up path no longer logs the auth response (`response.session`), the user payload or stack traces, and no behaviour changed. The single auth-path log line that remains records an exception message only and is audited/justified in `docs/wave-1-completion-report.md` (Part A) | None outstanding | — | Maintain | — |
| FR-AUTH-04 | Login for existing accounts | `views/auth/login_screen.dart` › `auth_controller.dart › login` | UI ✅ · Logic ✅ · Data ✅ | **A** | All failures collapse to "Email atau password salah"; acceptable but coarse | None required by SRS | — | Maintain | — |
| FR-AUTH-05 | Forgot password (reset via email) | `core/services/auth_service.dart › resetPassword` (→ Supabase Auth `resetPasswordForEmail`); `controllers/auth_controller.dart › resetPassword` + `resetEmailSent` | UI ✗ · Logic ◐ · Data ◐ | **P** | **Rev 2 (W1-3): the mechanism now exists** — the email-reset call is wired to Supabase Auth, the same dependency FR-AUTH-03 names, with loading/error/success state. **Still incomplete:** there is **no user-facing entry point** (no link, route or screen), no reset-token handling or deep-link configuration, and no new-password step, so a Buddy cannot reach the mechanism yet — the two new methods are currently **uncalled from the UI**. Delivery also depends on the Supabase project's redirect/Site URL, which is not verifiable from this repository (§1.3). Deliberately **not** marked aligned | Add the entry point and the reset flow UI on top of the existing mechanism, keeping Supabase Auth as the only mechanism; confirm the redirect target with the Back-End owner | FR-AUTH-03 | W1 / P1 (mechanism done; user-facing flow pending) | Screen copy/steps = D-42 (explicitly non-blocking). **Newly discovered:** which Supabase redirect/Site URL the reset email returns to (project configuration) — recorded in `docs/wave-1-completion-report.md` (Remaining blockers) |
| FR-AUTH-06 | Validate grade level restricted to SMP, SMA/sederajat, S1, Lulusan — SD not available | `views/customer/profile_screen.dart` (dropdown) | UI ◐ · Logic ✗ · Data ✗ | **M** ⚠ contradicts SRS | Choice exists only in the *profile edit* sheet, not in registration/onboarding where the clause applies; the option list also offers **"Umum"**, which is not one of the four permitted values (and SD is correctly absent) | Enforce the permitted set where grade level is captured, and remove non-permitted options | FR-AUTH-02 | W1 / P1 | Whether "Umum" is a legitimate 5th value ratified by the founders |
| FR-AUTH-07 | Role-specific onboarding routing (Buddy → complete basic profile; Tutor → document verification flow) | `auth_controller.dart › _redirectByRole`; tutor warning banner in `register_screen.dart` | UI ◐ · Logic ◐ · Data ✗ | **P** | Both roles land on a dashboard; the Tutor is not routed into the verification document flow, and no Buddy basic-profile completion step exists | Route Tutor accounts into the verification flow (FR-PROF-05..07) and Buddy accounts into basic profile completion (FR-PROF-01) | FR-PROF-01, FR-PROF-05, FR-PROF-07 | W2 / P1 | What "lengkapi profil dasar" must contain; whether it is blocking |

### 2.2 Profil (SRS §3.1 FR-PROF-01..10)

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| FR-PROF-01 | Buddy profile page: name, photo, email, phone, grade level, subjects of interest | `views/customer/profile_screen.dart` › `AuthController.currentUser` | UI ✅ · Logic ◐ · Data ✗ | **U** | Page shows name/email/phone/age/grade/school/interests, but "foto profil" is an initial-letter avatar (no image), `age`/`school` are extra fields not in the clause, and **nothing is persisted** (D6) | Add profile photo handling and a persistence path for the clause's fields only | FR-AUTH-02, NFR-PROF-01 | W2 / P1 | Storage/column contract for `avatar_url` (BE) |
| FR-PROF-02 | Buddy can edit own profile at any time, except email | `profile_screen.dart › _openEditSheet` › `ProfileController.saveBuddyProfile` | UI ✅ · Logic ◐ · Data ✗ | **U** | Edit form exists and email is correctly non-editable, but the save is in-memory only (D6) — changes are lost on restart | Persist Buddy profile edits; keep email read-only | FR-PROF-01 | W2 / P1 | — |
| FR-PROF-03 | Show short activity history on Buddy profile (completed sessions, average rating given) — *optional for MVP* | `controllers/profile_controller.dart › completedSessions = 12`, `avgRatingGiven = 4.6` | UI ✅ · Logic ✗ · Data ✗ | **U** | Two hardcoded constants presented as real statistics | Derive from bookings/reviews, or hide the block until derivable | FR-RATE-02, FR-BOOK-07 | W4 / P3 | Whether to include in MVP at all (SRS marks it optional) |
| FR-PROF-04 | Tutor profile completion form: bio, subjects taught, grade levels taught | `views/tutor/tutor_profile_screen.dart` (bio, subjects, extraSkills) › `saveTutorProfile` | UI ◐ · Logic ◐ · Data ✗ | **P** | "Jenjang yang bisa diajar" is absent; `extraSkills` is an extra field with no SRS basis; save is in-memory only | Add grade-levels-taught to the Tutor profile and persist the form | FR-DISC-03 | W2 / P1 | Data shape for "jenjang yang bisa diajar" (not in SRS §4.1 entity attributes) |
| FR-PROF-05 | Upload Tutor documents: (a) transcript, (b) student ID (KTM/KTS), (c) achievement certificate, (d) language certificate (only for foreign-language tutors) | `controllers/profile_controller.dart › _dummyDocuments`; `views/shared/widgets/document_tile.dart` | UI ◐ · Logic ◐ · Data ✗ | **M** ⚠ contradicts SRS | Only 4 documents are specified, of which 3 are required; the code lists **6**, adds **"Skor/Kartu UTBK"** and **"CV / Portfolio"** (invented), and classifies **achievement certificate as *optional*** whereas the SRS requires it. No file is ever selected or uploaded (D7) | Correct the document catalogue to the four SRS documents with SRS correct required/optional classification, then implement selection + upload | NFR-PROF-01, NFR-PROF-02, NFR-PROF-03 | W2 / P1 | Whether UTBK/CV documents are ratified additions |
| FR-PROF-06 | Visually distinguish required documents from optional ones at upload | `document_tile.dart › _requirementLabel` (`Wajib`/`Bersyarat`/`Opsional`) | UI ✅ · Logic ◐ · Data ✗ | **P** | The distinction mechanism exists and is correct in form, but it renders the wrong classification from FR-PROF-05 | Keep the widget; feed it the corrected catalogue | FR-PROF-05 | W2 / P1 | — |
| FR-PROF-07 | Show Tutor verification status: Menunggu Verifikasi / Terverifikasi / Ditolak (with reason) | `views/shared/widgets/verification_badge.dart`; `TutorModel.verificationStatus`, `rejectionReason`; `tutor_profile_screen.dart › _pendingBanner` | UI ✅ · Logic ◐ · Data ✗ | **U** | Badge covers all three states plus "Belum Upload"; the underlying status is dummy and no actor can change it | Bind status to the persisted verification record once the verification process is decided | FR-PROF-08, FR-ADM-02 | W2 / P1 | Who verifies, and the SLA (Bab 8 #1) |
| FR-PROF-08 | Tutor cannot receive bookings until documents are Terverifikasi | — | UI ✗ · Logic ✗ · Data ✗ | **X** | ∅ no logic: no verification check in discovery, booking creation, or slot publication. Verified and unverified tutors are indistinguishable to a Buddy | Enforce the verification gate on the Tutor-side paths that make a Tutor bookable | FR-PROF-07, FR-DISC-01 | W2 / P1 | Meaning of "receive booking" (excluded from search vs blocked at booking) + Bab 8 #1 |
| FR-PROF-09 | Tutor self-service editing incl. bio, subjects, and adding/replacing certificates after initial verification | `tutor_profile_screen.dart` (edit sheet, per-document `Upload`/`Ganti`) › `ProfileController.saveTutorProfile`/`uploadDocument` | UI ✅ · Logic ◐ · Data ✗ | **U** | UI affordances exist for all three actions, but nothing persists (D6, D7). Post-verification document replacement silently sets status back to `menunggu` | Persist the edits; define what re-verification means when a certificate is added/replaced after approval | FR-PROF-05, FR-PROF-07 | W2 / P1 | Whether adding a certificate re-triggers verification (not addressed by SRS) |
| FR-PROF-10 | Public Tutor profile: photo, name, campus/institution, subjects, average rating, completed sessions, achievement badge (e.g. "Top Tutor") | `views/customer/tutor_detail_screen.dart`; `views/shared/widgets/tutor_card.dart` | UI ✅ · Logic ◐ · Data ✅ (read) | **P** | Shows name, university, subjects, rating, sessions, reviews; **photo is an initial-letter avatar** and **no achievement badge is shown on the public profile** (the "Tutor of the Month" badge exists only on the Tutor's own screen) | Add photo + public achievement badge to the public profile | FR-PROF-01, FR-RATE-02 | W2 / P2 | Badge rule/criteria ("misal Top Tutor") undefined by SRS |

### 2.3 Smart Discovery (SRS §3.1 FR-DISC-01..06)

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| FR-DISC-01 | Search page lists only **Terverifikasi** Tutors | `controllers/tutor_controller.dart › fetchAllTutors` (unfiltered select, rating-ordered) | UI ✅ · Logic ✗ · Data ✅ | **X** ⚠ contradicts SRS | The query returns every row in `tutors`; no status filter. Unverified Tutors are presented to Buddies, directly contradicting the clause | Filter the search result set by verified status | FR-PROF-07, FR-PROF-08 | W2 / P1 | — |
| FR-DISC-02 | Filter search by subject/topic | `tutor_controller.dart › searchQuery` + `_applyFilter` (free-text over name and subjects, 300 ms debounce) | UI ◐ · Logic ◐ · Data ✅ | **P** | Only a single free-text field exists; there is no subject/topic filter control | Add an explicit subject/topic filter dimension | — | W2 / P2 | — |
| FR-DISC-03 | Filter search by grade level taught | — | UI ✗ · Logic ✗ · Data ✗ | **X** | ∅ no logic; and no "grade levels taught" attribute exists on the Tutor data (see FR-PROF-04), so the filter has nothing to filter | Introduce grade-levels-taught data, then the filter | FR-PROF-04 | W2 / P2 | Attribute shape (FR-PROF-04 decision) |
| FR-DISC-04 | Automatically recommend Tutors by highest average rating (not a purely random manual list) | `tutor_controller.dart` `.order('rating', ascending: false)`; `dashboard_controller.dart` same | UI ✅ · Logic ✅ · Data ✅ | **A** | Implemented as an ORDER BY on the stored average; the clause is satisfied | None for this clause; extensibility is tracked separately as NFR-DISC-02 | NFR-DISC-02 | Maintain | Additional recommendation factors (Bab 8 #2) |
| FR-DISC-05 | Show Tutor availability indicator in the search list (e.g. "Online" / nearest available schedule) | `TutorModel.isOnline`; `RealtimeService.subscribeOnlineTutors`; `TutorCard` online chip | UI ✅ · Logic ✅ · Data ✅ | **A** | The clause's indicator is given as an example ("misal"), and one such indicator (Online) is implemented and realtime | None required | NFR-BOOK-02 | Maintain | — |
| FR-DISC-06 | Result cards show: photo, name, subject, rating, completed-session count | `views/shared/widgets/tutor_card.dart` (`_buildFull`, `_buildCompact`) | UI ◐ · Logic n/a · Data ✅ | **P** | Full card shows avatar-initial, name, subjects, rating, review count and hourly price; **completed-session count is never displayed**, and the compact card omits subjects and session count | Add the completed-session count to the card and complete the compact variant | FR-PROF-10 | W2 / P2 | — |

### 2.4 Booking & Jadwal (SRS §3.1 FR-BOOK-01..09)

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| FR-BOOK-01 | Tutor manages own availability slots via a calendar (add, edit, delete) | `controllers/tutor_schedule_controller.dart` (`_dummySlots`, `addSlot`, `removeSlot`); `views/tutor/tutor_schedule_screen.dart › _AvailabilityTab` | UI ✅ · Logic ◐ · Data ✗ | **U** | Add and delete exist against an in-memory list; **edit does not exist**; the SRS's "kalender" reference is a list + bottom sheet, and nothing persists or is shared with Buddies | Persist slot CRUD and add the missing edit operation | NFR-BOOK-01, FR-BOOK-02 | W2 / P1 | Calendar-shaped UI is unspecified beyond the word "kalender" |
| FR-BOOK-02 | Show Tutor slots to Buddy in direct-select form (cinema-ticket reference), not a manual schedule-request form | `views/customer/booking_screen.dart › _buildSlotPicker`; `booking_controller.dart › fetchAvailableSlots` | UI ✅ · Logic ◐ · Data ✗ | **U** | Direct-select UX is correctly modelled (date groups, tap-to-select), but the slots are **generated locally** (6 synthetic slots, 300 ms fake delay) on every call; no Tutor data is involved | Serve real Tutor slots through the same UI contract | FR-BOOK-01 | W2 / P1 | — |
| FR-BOOK-03 | Buddy selects an available slot and proceeds to booking **without waiting for manual Tutor confirmation** | `booking_screen.dart › _goToInvoice` → `onPaid` → `booking_controller.createBooking` (status `pending`); `tutor_dashboard_screen.dart` Konfirmasi/Tolak | UI ✅ · Logic ◐ · Data ✅ | **M** ⚠ contradicts SRS | The flow creates the booking as `pending` and the Tutor dashboard then requires Konfirmasi/Tolak — i.e. manual confirmation remains in the happy path, contradicting the clause. The SRS also states confirmation follows successful payment (FR-PAY-03), so the two clauses must be reconciled | Remove the manual Tutor confirmation step from the booking lifecycle and align the resulting status with FR-PAY-03 | FR-PAY-03, FR-SESI-06 | W1 / P1 | Whether Tutor confirmation is retained for any case (reconciliation of FR-BOOK-03 vs FR-PAY-03) |
| FR-BOOK-04 | Lock the slot during booking so another Buddy cannot select it concurrently (no double booking) | `booking_controller.dart › selectSlot` (local `Rx` only) | UI ◐ · Logic ✗ · Data ✗ | **X** | ∅ no logic: `selectSlot` merely stores the selection in memory. There is no lock, no reservation record, and no database constraint or transaction | Implement slot locking that survives concurrent clients (see NFR-BOOK-01) | NFR-BOOK-01, FR-BOOK-01 | W2 / P1 | Lock lifetime/TTL, and its interaction with QR expiry (NFR-PAY-03) |
| FR-BOOK-05 | Remove the slot from the available list once the booking is confirmed | `booking_controller.dart › createBooking` (`availableSlots.removeWhere`) | UI ◐ · Logic ◐ · Data ✗ | **U** | Removal happens only in the local list of one screen after payment, and is lost on reload; the slot is never marked unavailable in storage | Persist the slot's transition to booked as part of the booking transaction | FR-BOOK-04, NFR-PAY-01 | W2 / P1 | — |
| FR-BOOK-06 | Send booking confirmation to both Buddy and Tutor after a successful booking | — (only a `Get.snackbar('Berhasil', 'Booking berhasil dibuat!')`) | UI ✗ · Logic ✗ · Data ✗ | **X** | ∅ no logic; `NotificationService` exists but is never initialised, and its mechanism is explicitly tentative in the SRS (FR-SESI-05) | Implement booking confirmation using the notification mechanism that FR-SESI-05 decides | FR-SESI-05 | W3 / P2 | Notification mechanism (Bab 8 #4 — SRS marks tentative) |
| FR-BOOK-07 | Tab/page "Booking Kamu" with booking history and status (KAI Access reference) | `views/customer/schedule_screen.dart` ("Jadwal Saya") + `booking_controller.myBookings` | UI ✅ · Logic ◐ · Data ✅ | **P** | A list with status badges exists, but it is titled "Jadwal Saya" rather than the SRS's "Booking Kamu", has no filtering, and carries no payment status or Tutor identity; there is no booking detail view | Align the surface with the clause and expose the details required by FR-BOOK-09 | FR-BOOK-09 | W2 / P2 | Whether a rename/tab placement is required or acceptable |
| FR-BOOK-08 | Buddy can cancel before the session starts, with refund consequences per the refund policy | `booking_controller.dart › cancelBooking` (used from the Tutor dashboard "Tolak"); `payment_controller.cancelOrder` (pre-payment only) | UI ◐ · Logic ◐ · Data ✅ | **X** | ∅ for the clause: a Buddy has **no cancel action** on a paid booking, and cancellation is not connected to any refund rule. Adjacent, non-conforming affordances exist (Tutor reject; pre-payment order cancel) | Provide Buddy cancellation on a paid booking and connect it to the refund policy | FR-PAY-04, FR-PAY-05 | W2 / P1 | Refund threshold (Bab 8 #5 — tentative) |
| FR-BOOK-09 | Show booking detail (time, Tutor, subject, payment status) to both parties | `schedule_screen.dart` (subject, datetime, duration, booking status); `session_screen.dart` (subject) | UI ◐ · Logic ◐ · Data ◐ | **P** | Subject/time/duration shown; **Tutor identity is not displayed** even though the query joins `tutors(*)` (the model ignores the join), and **payment status is not shown** | Surface Tutor and payment status in the booking detail | FR-PAY-02, FR-BOOK-07 | W2 / P2 | — |

### 2.5 Pembayaran / QR SB (SRS §3.1 FR-PAY-01..07)

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| FR-PAY-01 | Show QR SB for payment after the Buddy selects a booking slot | `views/customer/invoice_screen.dart › _QrPlaceholder`; `payment_controller.dart › generateInvoice` | UI ◐ · Logic ◐ · Data ✗ | **U** | The "QR" is an `Icons.qr_code_2` placeholder, not a scannable code; the invoice is an in-memory object; the UI additionally asserts a specific provider ("Scan QRIS Dynamic (ShopeePay)") that the SRS does not confirm — SRS §2.5 assumes a Midtrans/Xendit-class gateway and Bab 8 #8 declares the provider unanswered | Render a real QR SB and remove the unconfirmed provider claim from user-facing copy until decided | NFR-PAY-02 | W3 / P2 | Payment provider behind QR SB (Bab 8 #8 — unanswered) |
| FR-PAY-02 | Show payment status: Menunggu Pembayaran / Berhasil / Gagal-Kedaluwarsa | `InvoiceStatus {waiting, paid, expired, cancelled}`; `views/shared/widgets/invoice_status_badge.dart` | UI ✅ · Logic ◐ · Data ✗ | **U** | All three SRS states are represented (plus an extra `cancelled`), but the transition is **simulated**: `checkPaymentStatus()` waits 600 ms then marks paid; no gateway, no webhook, no persistence | Drive status from the real payment source; align the success label with the SRS ("Berhasil" vs current "Lunas") | NFR-PAY-02 | W3 / P2 | Provider + webhook contract (Bab 8 #8) |
| FR-PAY-03 | A new booking is fully confirmed only after payment status is Berhasil | `booking_screen.dart › onPaid: ctrl.createBooking(...)`; `createBooking` inserts `status: 'pending'` | UI ✅ · Logic ◐ · Data ✅ | **M** ⚠ contradicts SRS | The booking is indeed created only after payment, but it is created as `pending` — not "terkonfirmasi penuh". The orchestration also lives in the widget (`onPaid` closure), so the rule is not enforceable outside the UI | Create the booking in the SRS-confirmed state and move the pending→confirmed rule out of the view | FR-BOOK-03, FR-SESI-06 | W1 / P1 | Resulting status value/name once FR-BOOK-03 is reconciled |
| FR-PAY-04 | Refund policy: cancellation >5 h before the session gets a full refund; <5 h gets none. **(SRS: TENTATIF)** | — | UI ✗ · Logic ✗ · Data ✗ | **?** | ∅ no logic; the SRS itself flags the 5-hour threshold as not final (Bab 8 #5), so the rule cannot be implemented as a verified business rule yet | Implement the threshold as a single, injectable policy once the number is confirmed | — | W2 / P1 | Refund threshold value and whether it applies per booking or per package (Bab 8 #5) |
| FR-PAY-05 | Buddy-initiated refund request flow (Shopee/TikTok Shop reference), not an automatic payout | `views/customer/transaction_history_screen.dart › _openRefundSheet`; `payment_controller.dart › requestRefund` | UI ✅ · Logic ✗ · Data ✗ | **U** | The sheet and reason chips render, but submission only shows a snackbar — no request is recorded, no status exists, and no approval path is modelled. The reason list is hardcoded in the view | Record the request and give it a trackable status; keep reasons out of the widget layer | FR-PAY-04 | W2 / P2 | Refund request states/approval owner; relationship to package categories (see §7) |
| FR-PAY-06 | Record the 70 % Tutor / 30 % company revenue split on every successful transaction. **(SRS: BELUM TERJAWAB)** | — | UI ✗ · Logic ✗ · Data ✗ | **?** | ∅ no logic anywhere; payroll dummy data merely assumes an already-split per-session rate. Bab 8 #7 leaves automation vs manual unanswered | Record the split once automation vs manual is decided | NFR-PAY-01 | W3 / P2 | Automated vs manual split (Bab 8 #7) |
| FR-PAY-07 | Show payment history to Buddy and earnings history to Tutor | `transaction_history_screen.dart` + `payment_controller._dummyHistory`; `views/tutor/payroll_screen.dart` + `payroll_controller._dummyRecords`; `tutor_dashboard_controller.monthlyEarnings` | UI ✅ · Logic ✗ · Data ✗ | **U** | Both surfaces exist but every figure is a hardcoded constant or static dummy list; the Tutor's earnings screen belongs to the surplus Payroll module (§1.2) | Serve real transaction and earning records | NFR-PAY-01, FR-PAY-06 | W3 / P2 | Whether the Tutor earnings surface is in scope of SRS v1.0 (§1.2) |

### 2.6 Sesi Belajar (SRS §3.1 FR-SESI-01..07)

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| FR-SESI-01 | Provide the Google Meet link to Buddy and Tutor for confirmed bookings | `controllers/session_controller.dart › startSession/_launchGmeet`; `views/session/session_screen.dart` (D1) | UI ◐ · Logic ◐ · Data ✗ | **P** | ∅ in practice: the launcher and plumbing exist, but the screen passes `null` for the link in **both** branches (D1), `BookingModel` has no Meet field, and `TutorModel.gmeetLink` is never read. The link is therefore never delivered | Fix the link delivery path and resolve the link source | FR-SESI-02, NFR-SESI-01 | W1 / P1 | Link source = varian A or B (Bab 8 #3) |
| FR-SESI-02 | **(SRS: TENTATIF, two variants)** A: platform attaches one of ≥3 permanent Tutor Meet links to the booking. B: Tutor sends the link manually via chat before the session | `tutor_dashboard_controller.dart › gmeetLinks` (3 hardcoded strings, editable via dialog); `tutor_dashboard_screen.dart` | UI ✅ · Logic ◐ · Data ✗ | **?** | Varian A is scaffolded with in-memory-only links (no persistence, no attachment to bookings); varian B is impossible because chat does not exist (FR-SESI-03). The variant is explicitly unresolved | Choose a variant, then implement it end-to-end | FR-SESI-01, FR-SESI-03 | W3 / P2 | Varian A vs B (Bab 8 #3 — tentative) |
| FR-SESI-03 | Chat between Buddy and Tutor (supplementary material / session coordination) | — | UI ✗ · Logic ✗ · Data ✗ | **X** | ∅ no chat feature: no `ChatMessage` entity (absent from SRS §4.1 and from the code), no message UI, no transport | Implement chat once its storage and scope are defined | FR-SESI-04, NFR-SESI-03 | W3 / P2 | Whether chat is realtime/DB-backed, retention, and moderation (SRS says history "sebaiknya tersimpan") |
| FR-SESI-04 | Chat is active **only** during the session window (start→end of the booking); inaccessible outside it | `session_screen.dart` (timer shown for `chat` session type only) | UI ◐ · Logic ✗ · Data ✗ | **X** | ∅ no logic; the timer is decorative and there is no chat to gate | Enforce the window once chat exists | FR-SESI-03 | W3 / P2 | Window boundaries on reschedule/no-show (SRS defines only start→end) |
| FR-SESI-05 | **(SRS: TENTATIF)** Notify/supply the session link shortly before start (option considered: 1 hour) and/or expose it in "Booking Kamu" | `core/services/notification_service.dart` (defined; `initialize()` commented out in `main.dart`) | UI ✗ · Logic ✗ · Data ◐ | **?** | The FCM/local-notification plumbing exists but is inert; no scheduling, no in-app notification surface. The SRS marks the mechanism as tentative | Decide the mechanism, then wire the notification and/or the in-app surface | FR-BOOK-06, FR-BOOK-07 | W3 / P2 | Mechanism and lead time (Bab 8 #4 — tentative) |
| FR-SESI-06 | Session status: Terjadwal, Sedang Berlangsung, Selesai, Dibatalkan | `BookingModel.status` (`pending/confirmed/ongoing/done/cancelled`); `SessionModel.status` (`active/ended`); `views/shared/widgets/status_badge.dart`; `session_screen.dart` (static heading) | UI ✅ · Logic ◐ · Data ✅ | **P** | Two status vocabularies exist across two models, neither matching the SRS terms; the in-session screen hardcodes "Sesi Sedang Berlangsung" regardless of the actual record | Unify the status vocabulary to the SRS states and drive all surfaces from it | FR-BOOK-03, FR-PAY-03 | W3 / P2 | Mapping between the four SRS states and the current booking/session fields |
| FR-SESI-07 | **(SRS: BELUM TERJAWAB)** Handle connection disruption during a session by replicating the current manual SOP: ±30 min wait tolerance, +15 min compensation option, or reschedule if the session is cancelled outright | — | UI ✗ · Logic ✗ · Data ✗ | **?** | ∅ no logic; the SRS states the automation mechanism is undetermined, so no rule can be written yet. A Reschedule module exists but implements an unrelated, non-SRS policy set | Implement after the SOP automation is decided | FR-BOOK-08 | W4 / P3 | Automation mechanism (Bab 8 #11 — unanswered) |

### 2.7 Rating & Review (SRS §3.1 FR-RATE-01..04)

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| FR-RATE-01 | Ask the Buddy for a star rating and text review after the session is Selesai | `views/session/review_screen.dart`; `review_controller.dart › submitReview`; `session_controller.dart › startSession`/`currentBooking`/`endSession` (sets booking `done`, then routes to review with `{sessionId, tutorId, subject}`) | UI ✅ · Logic ✅ · Data ✅ | **A** | **Fixed in rev 2 (W1-1)** — D2 is closed: the prompt still appears after the session, and the write is now attributed to the real Tutor taken from the booking; `submitReview` additionally refuses an empty session/tutor id *before* touching data, so an unattributable review cannot be written. Evidence: `test/review_smoke_test.dart` (context reaches the submit path; empty context is rejected). Residual naming/contract debt only: the row still writes `customer_id` where SRS §4.1 names `buddy_id`, plus an SRS-undefined `subject` column — tracked by D-19 and in `docs/be-contract-request.md` (Rating / Review) | None outstanding for this clause (field-name vocabulary is a Back-End contract item, not a behaviour gap) | FR-BOOK-09, FR-RATE-03 | Maintain | — |
| FR-RATE-02 | Ratings and reviews appear on the related Tutor's public profile | `tutor_controller.dart › _fetchReviews` (top 10); `tutor_detail_screen.dart` (review list) | UI ✅ · Logic ✅ · Data ✅ | **A** | Reads and renders reviews correctly; display uses a hardcoded "Customer" label and an initial-letter avatar (cosmetic). Its correctness dependency (D2) was **fixed in rev 2**, so newly written reviews are now attributable to the Tutor shown here | None required by the clause | FR-RATE-01 | Maintain | Whether reviews must be paginated (D-34, not specified) |
| FR-RATE-03 | System automatically computes the Tutor's average rating from all received reviews | `review_controller.dart › _recalculateTutorRating` (client-computed, writes `tutors.rating` + `total_reviews`) | UI n/a · Logic ◐ · Data ✅ | **M** ⚠ contradicts SRS | The average is still computed and written **by the client** using a fragile `as int` cast (D4) — "automatically by the system" implies a server-owned aggregate. **Rev 2 note:** the roll-up no longer targets an empty id (D2 was fixed in W1-1), so the remaining defect is the ownership/location of the aggregate alone | Move the aggregate to the server side and make it robust to the numeric type of `rating` | FR-RATE-01, NFR-RATE-01 | W2 / P1 | Ownership of the aggregate (server trigger vs edge function) = D-48 (BE) |
| FR-RATE-04 | Rating is optional; skipping must not block access to other features; the system may show a reminder | `review_screen.dart › 'Lewati'` → `Get.offAllNamed(AppRoutes.customerDashboard)` (no write) | UI ✅ · Logic ✅ · Data n/a | **A** | **Fixed in rev 2 (W1-2)** — D3 is closed: skipping performs **no** write (the fabricated 1-star review is gone), leaves the review screen and lands on the Buddy dashboard, so an optional rating blocks nothing. Evidence: `test/review_smoke_test.dart` asserts zero submissions on skip, with and without review context. Residual: no reminder is shown — permitted, since the SRS says the system *may* (`dapat`) show one | None required. A reminder remains optional (D-35) | FR-RATE-01 | Maintain | Whether to add a reminder at all = D-35 (**non-blocking**) |

### 2.8 Dashboard Monitoring — Admin (SRS §3.1 FR-ADM-01..04)

> All four requirements are **entirely absent**. The codebase contains no Admin role handling, route, screen, or guard (`'management'` appears only as a comment in `UserModel`). Their final form is explicitly undecided in the SRS (Bab 8 #10: web vs mobile; §2.5 assumes a module inside the same app for MVP because the budget has no separate admin hosting).

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| FR-ADM-01 | Admin can view all bookings and their statuses (Terjadwal, Berlangsung, Selesai, Dibatalkan) | — | UI ✗ · Logic ✗ · Data ✗ | **X** ∅ | No admin surface at all | Add the Admin booking monitoring surface | NFR-ADM-01, FR-SESI-06 | W4 / P2 | Final form web vs in-app (Bab 8 #10) |
| FR-ADM-02 | Admin can view Tutors with document verification status and change it (Terverifikasi/Ditolak) | — (only the Tutor's own read-only badge exists) | UI ✗ · Logic ✗ · Data ✗ | **X** ∅ | No verification action exists for anyone; the status is dummy | Add the verification queue and status-change action | FR-PROF-07, NFR-ADM-01 | W4 / P2 | Who verifies and the SLA (Bab 8 #1) + form (Bab 8 #10) |
| FR-ADM-03 | Admin can view a payment transaction summary (amount, status) for revenue monitoring | — | UI ✗ · Logic ✗ · Data ✗ | **X** ∅ | Nothing exists; payment data is not persisted to begin with (see NFR-PAY-01) | Add the transaction monitoring view once payment records exist | NFR-PAY-01, FR-PAY-02 | W4 / P2 | Form (Bab 8 #10) |
| FR-ADM-04 | Admin can flag / follow up session complaints (e.g. connection loss, Tutor absence) | — | UI ✗ · Logic ✗ · Data ✗ | **X** ∅ | Nothing exists; there is also no complaint entity in SRS §4.1 | Add complaint intake + follow-up tracking | FR-SESI-07, NFR-ADM-01 | W4 / P2 | Form (Bab 8 #10) and whether a complaint entity is ratified |

---

## 3. Non-functional requirements

### 3.1 Security, auth & data protection

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| NFR-AUTH-01 | Passwords stored encrypted (handled by Supabase Auth; never plain text in any app layer) | Delegated entirely to Supabase Auth (`core/services/auth_service.dart`) | UI n/a · Logic n/a · Data ✅ | **A** | No credential material is persisted app-side, and the rev 2 audit (W1-4) confirms none is **logged** either: the sign-up logging that printed the auth response — including the session object, which carries access/refresh tokens — has been removed across all auth paths | None. The one remaining auth-path log line prints an exception message only; it is classified and justified in the audit | — | Maintain | — |
| NFR-AUTH-02 | Login session persists until explicit logout, using Supabase Auth tokens | `main.dart` (Supabase init); `splash_screen.dart` (session check); `AuthController.logout` | UI ✅ · Logic ◐ · Data ✅ | **A** | Session persistence is provided by the platform. Two caveats: `AuthController._loadCurrentUser` swallows every failure as "not logged in", and role routing reads a second, different source (D9/D10) | None required by this clause; D9/D10 tracked under FR-AUTH-07 and §1.4 | — | Maintain | — |
| NFR-AUTH-03 | **(Related to §2.5 assumption — minor protection)** Provide an integration point for parental consent when a Buddy registers as SMP; full implementation deferred until the founders decide | — | UI ✗ · Logic ✗ · Data ✗ | **?** | ∅ nothing exists — not even the "titik integrasi" the clause asks for. `age` is collected in the profile edit sheet but plays no role, and the grade option set includes an unratified "Umum" | Introduce the consent integration point only after the data-protection decision; avoid inventing a consent model now | FR-AUTH-02, FR-AUTH-06 | W4 / P3 | Parental consent approach (Bab 8 #9 — unanswered) |

### 3.2 Profile documents

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| NFR-PROF-01 | Tutor documents stored in Supabase Storage with restricted access (not a public bucket) — reachable only by the owning Tutor and Admin, using RLS | `core/constants/supabase_constants.dart › bucketDocuments` (declared, never used) | UI n/a · Logic ✗ · Data ✗ | **X** ∅ | No upload, so no storage, and therefore no policy enforcement in the client. Note: **no RLS artefacts exist in this repository** (§1.3) | Implement upload against a private bucket and rely on RLS for owner/Admin-only access | FR-PROF-05, FR-ADM-02 | W2 / P1 | Bucket/RLS policy definitions (BE) |
| NFR-PROF-02 | Limit uploaded document size (recommended max 5 MB per file) | — | UI ✗ · Logic ✗ · Data ✗ | **X** ∅ | No upload path, hence no size limit or feedback | Enforce the limit at selection and before upload | FR-PROF-05 | W2 / P2 | Whether 5 MB is binding (SRS says "disarankan") |
| NFR-PROF-03 | Accepted document formats limited to images (JPG/PNG) and PDF | — | UI ✗ · Logic ✗ · Data ✗ | **X** ∅ | No upload path, hence no format restriction | Restrict the picker and re-validate before upload | FR-PROF-05 | W2 / P2 | — |
| NFR-PROF-04 | **(Related to §2.5 assumption)** If a Tutor indirectly uploads an SMP Buddy's data, the same data-protection rules as NFR-AUTH-03 apply | — | UI ✗ · Logic ✗ · Data ✗ | **?** | ∅ nothing exists; the clause is conditional on a decision that is still open | Defer until the data-protection decision is taken | NFR-AUTH-03 | W4 / P3 | Data-protection decision (Bab 8 #9 — unanswered) |

### 3.3 Discovery performance & recommendation extensibility

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| NFR-DISC-01 | Search/filter results load within a reasonable time (target < 2 s on normal network) | `tutor_controller.fetchAllTutors` (single unordered-by-index select) | UI n/a · Logic ✗ · Data ◐ | **X** | No pagination, no index strategy, no latency measurement anywhere; the client loads the full Tutor table into memory and filters locally | Bound and paginate the result set, then measure against the target | FR-DISC-02, FR-DISC-03 | W4 / P3 | Target conditions to test under (SRS says "kondisi jaringan normal") |
| NFR-DISC-02 | The rating-based recommendation algorithm's weights must be adjustable later **without changing the core data structure** (e.g. adding response rate) | Hardcoded `.order('rating', ascending: false)` duplicated in two controllers | UI n/a · Logic ◐ · Data ✅ | **P** | Ranking exists but only as a stored-column sort duplicated across two controllers; there is no scoring abstraction, so adding a factor means editing query code — the "weights" concept does not exist | Concentrate ranking into a single adjustable scoring unit that reads the same data | FR-DISC-04 | W4 / P3 | Additional ranking factors (Bab 8 #2 — tentative) |

### 3.4 Booking integrity & realtime

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| NFR-BOOK-01 | Slot check + lock must be concurrency-safe, using database transactions/constraints in Supabase | Local `Rx` selection only (`booking_controller.selectSlot`) | UI n/a · Logic ✗ · Data ✗ | **X** ∅ | No transaction, no constraint, no reservation row; two Buddies can select the same slot freely. This is the root cause of FR-BOOK-04 being unimplemented | Implement atomic slot reservation at the data layer | FR-BOOK-04 | W2 / P1 | Reservation/lock duration semantics (interacts with NFR-PAY-03) |
| NFR-BOOK-02 | Booking status changes (booked → confirmed → done/cancelled) must appear in realtime on both sides without manual refresh (Supabase Realtime) | `core/services/realtime_service.dart › subscribeBookings` (**never called**); `subscribeOnlineTutors` used by `DashboardController` | UI n/a · Logic ◐ · Data ◐ | **P** | The realtime service exists but **no booking surface subscribes**; bookings are fetched once in `onInit`/after mutations, so the other party sees stale state (the Tutor must reopen the screen) | Subscribe the booking surfaces to the booking channel and reconcile state on events | FR-BOOK-03, FR-SESI-06 | W2 / P2 | — |
| NFR-BOOK-03 | Tutors should be reminded to refresh availability periodically (optional for MVP) | — | UI ✗ · Logic ✗ · Data ✗ | **X** ∅ | Nothing exists (and the clause is explicitly optional) | Defer; revisit only if schedule accuracy problems appear | FR-BOOK-01, FR-SESI-05 | W4 / P3 | Whether to include in MVP (SRS: optional) |

### 3.5 Payment integrity

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| NFR-PAY-01 | Payment transaction data stored accurately and immutable after "Berhasil" (audit-grade) | — (all invoice data is in-memory `Rx` + static dummy lists) | UI n/a · Logic ✗ · Data ✗ | **X** ∅ | No transaction is persisted at all, so there is no accuracy, no immutability, and nothing to audit. All status changes are simulated | Persist transactions and make the successful record immutable | FR-PAY-02, FR-PAY-06 | W3 / P2 | Transaction table contract + retention (BE) |
| NFR-PAY-02 | **(Related to §2.5 assumption)** If QR SB is processed via a third-party payment gateway (Midtrans/Xendit), handle its callback/webhook to update payment status automatically | — (a code comment references "webhook ShopeePay Merchant" — an unconfirmed provider) | UI ✗ · Logic ✗ · Data ✗ | **X** | ∅ no webhook/ingestion path exists; the client polls a simulated delay instead. The comment asserts a provider the SRS does not confirm | Implement webhook-driven status updates once the provider is fixed | FR-PAY-02 | W3 / P2 | Provider and callback contract (Bab 8 #8 — unanswered) |
| NFR-PAY-03 | QR should expire (e.g. 15–30 minutes) so a slot is not locked forever; the exact value is to be agreed by the team | `payment_controller.dart › _startCountdown` (15-minute client timer, then `expired`) | UI ✅ · Logic ◐ · Data ✗ | **?** | A 15-minute client-side countdown exists and falls inside the stated range, and `cancelOrder` copy claims the slot is reopened — but the slot is never actually locked (FR-BOOK-04) nor reopened. The final value and the server-side expiry authority are undecided | Move expiry to the authoritative side and tie it to the slot lock | FR-BOOK-04, NFR-BOOK-01 | W3 / P2 | Final expiry value + who owns expiry (Bab 8 #6 — unanswered) |

### 3.6 Session delivery

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| NFR-SESI-01 | Do not build native video calling — open the Google Meet link via an external app (technically `url_launcher`) | `core/services`... `session_controller.dart › _launchGmeet` (`url_launcher`, `LaunchMode.externalApplication`) | UI n/a · Logic ✅ · Data ✅ | **A** | Architecturally satisfied: no native call code, `url_launcher` is used as the SRS anticipates. Caveat: it is never reached today because of D1 (FR-SESI-01) | None for this clause; fixing FR-SESI-01 makes it observable | FR-SESI-01 | Maintain | — |
| NFR-SESI-02 | Design so the video-link provider can be swapped later (not hardcoded to one Google account), given the current dependency on a founder's personal account | `TutorModel.gmeetLink` (plain string); UI copy hardcodes "Google Meet" throughout | UI ✗ · Logic ◐ · Data ◐ | **P** | The link is *stored* as an opaque string (good), but there is no provider abstraction, no configuration point, and the brand is embedded in user-facing copy. The link source itself is still undecided (FR-SESI-02) | Introduce a single configurable link/provider indirection and remove hardcoded provider claims from copy | FR-SESI-02 | W3 / P3 | Whether a provider abstraction is warranted for MVP (SRS states the risk, not the design) |
| NFR-SESI-03 | Chat history per session should be retained for audit/complaint purposes, even though chat access closes after the window | — | UI ✗ · Logic ✗ · Data ✗ | **X** ∅ | No chat exists, so no history. Note the SRS says "sebaiknya" (should), and the retention mechanism is unspecified | Define storage/retention together with FR-SESI-03 | FR-SESI-03, FR-SESI-04 | W3 / P3 | Retention scope/duration and access rights (SRS silent) |

### 3.7 Rating integrity & admin isolation

| ID | Requirement (SRS) | Implementation | Layer state | Status | Gap vs SRS | Required change | Depends on | Wave / Prio | Decision needed |
|---|---|---|---|---|---|---|---|---|---|
| NFR-RATE-01 | Each Buddy may give only one rating per session (prevents multiple-rating manipulation) | `review_screen.dart` (submit leaves the route via `Get.offAllNamed`) — no uniqueness guarantee anywhere | UI ✗ · Logic ◐ · Data ✗ | **X** ∅ | Still no uniqueness guarantee: there is no database constraint and no guard keyed on `session_id`. **Rev 2 note:** W1-1/W1-2 removed the two paths that could create reviews without a rating intent (the empty-id write and the fabricated skip review), and a successful submit now exits the review route — but a second submit is still possible if the user returns to the screen, and nothing prevents it server-side | Enforce one review per session at the data layer, with a client-side guard as a secondary check | FR-RATE-01 | W2 / P1 | Enforcement location = D-49 (BE) |
| NFR-ADM-01 | Access to Admin features restricted to accounts with the Admin role (RLS at database level, separate from Buddy/Tutor) | — | UI ✗ · Logic ✗ · Data ✗ | **X** ∅ | No Admin role exists in the client's routing/branching, and the repository contains no RLS artefacts to verify (§1.3). `'management'` appears only in a comment | Introduce the Admin role and enforce it server-side, with client routing as a secondary guard | FR-ADM-01 | W4 / P2 | Role model (is `management` the intended Admin role?) + form (Bab 8 #10) |

---

## 4. Assumptions-log traceability (SRS §2.5)

Each assumption the SRS declares is traced to requirements and to the current reality. **None of these may be silently treated as settled.**

| # | Area (SRS status) | Assumption in SRS | Related reqs | Current reality |
|---|---|---|---|---|
| A1 | Meet link distribution (**Tentatif**) | Tutor provides ≥3 permanent links, auto-attached to bookings | FR-SESI-01, FR-SESI-02 | 3 hardcoded in-memory strings; never attached (FR-SESI-02 = **?**) |
| A2 | Session notification (**Tentatif**) | Automatic notification + "Booking Kamu" tab | FR-BOOK-06, FR-SESI-05 | Both absent; FCM present but disabled (FR-SESI-05 = **?**) |
| A3 | Refund threshold (**Tentatif**) | 5 hours before the session | FR-BOOK-08, FR-PAY-04 | No refund rule exists at all (FR-PAY-04 = **?**) |
| A4 | 70/30 revenue split (**Belum terjawab**) | Automatic via system | FR-PAY-06 | No split logic; dummy payroll assumes an already-split rate (FR-PAY-06 = **?**) |
| A5 | QR SB provider (**Belum terjawab**) | Payment gateway (Midtrans/Xendit, per RAB) | FR-PAY-01, NFR-PAY-02 | UI copy asserts **ShopeePay QRIS** — a provider the SRS never names (both reqs = **X**) |
| A6 | SMP minor data protection (**Belum terjawab**) | Parental consent at registration | NFR-AUTH-03, NFR-PROF-04 | Nothing exists, not even an integration point (both = **?**) |
| A7 | Admin dashboard form (**Belum diputuskan**) | In-app module (not a web panel) for MVP | FR-ADM-01..04, NFR-ADM-01 | No admin surface at all (all = **X**) |
| A8 | Connection-loss handling (**Belum terjawab**) | Replicate manual SOP: ±30 min tolerance, +15 min compensation, reschedule | FR-SESI-07 | Nothing exists; the surplus Reschedule module implements unrelated rules (FR-SESI-07 = **?**) |

---

## 5. Open-issues traceability (SRS Bab 8)

| # | Issue (SRS) | Requirements affected | Effect on this RTM | Owner per SRS |
|---|---|---|---|---|
| 1 | Tutor document verification flow: who verifies, SLA, automatic/manual | FR-PROF-07, FR-PROF-08, FR-ADM-02 | Blocks the verification gate and the Admin verification action | Founder/Admin |
| 2 | Additional Tutor recommendation factors beyond rating | FR-DISC-04, NFR-DISC-02 | Prevents finalising the ranking abstraction | Founder |
| 3 | Meet link distribution mechanism (varian A/B) | FR-SESI-01, FR-SESI-02 | Blocks link delivery end-to-end | Founder |
| 4 | Session & booking notification mechanism | FR-BOOK-06, FR-SESI-05 | Blocks confirmation and reminder features | Founder |
| 5 | Refund time threshold (5 hours) | FR-BOOK-08, FR-PAY-04 | Blocks the refund rule (cannot be tested while tentative) | Dimas (COO/CFO) |
| 6 | Payment QR expiry window | NFR-PAY-03 | Blocks authoritative expiry | Internal (Rifky & Raihana) |
| 7 | 70/30 split automation vs manual | FR-PAY-06 | Blocks split recording and payout surfaces | Founder |
| 8 | Payment provider behind QR SB | FR-PAY-01, FR-PAY-02, NFR-PAY-02 | Blocks QR generation, status polling, webhooks; current code contradicts the assumption | Founder |
| 9 | SMP minor data protection (parental consent) | NFR-AUTH-03, NFR-PROF-04 | Blocks consent work; keep an integration point only | Founder |
| 10 | Final Admin dashboard form (web vs mobile) | FR-ADM-01..04, NFR-ADM-01 | Blocks all Admin work | Internal team & Founder |
| 11 | Automating connection-loss handling | FR-SESI-07 | Blocks the disruption SOP | Internal team & Founder |

---

## 6. Non-requirement constraints stated by the SRS (traceability for compliance)

These rows are **not** numbered requirements. They are binding statements elsewhere in the SRS that constrain the implementation plan, and are recorded so they are not violated while implementing the rows above.

| Ref | SRS statement | Traceable expectation | Current state |
|---|---|---|---|
| C-01 | §1.2 Platform: **Android only**; iOS support out of scope | No iOS-specific commitments or work | iOS/macOS/Linux/web scaffolding exists from the Flutter template (harmless; must not attract iOS feature work) |
| C-02 | §1.2 Out of scope: social features, iOS, AI chatbot/co-pilot, session recording | These must not be introduced | None present — compliant |
| C-03 | §1.2 WA SB channel stays **outside** the system | No WhatsApp integration | None present — compliant |
| C-04 | §1.2 SD is **not** served by the app | Grade option set excludes SD | SD is absent, but an unratified "Umum" option exists (FR-AUTH-06) |
| C-05 | §2.1 App does **not** replace the Admin role | Admin features remain part of scope | No Admin features exist (FR-ADM-01..04) |
| C-06 | §2.4 Budget constrains third-party tool choices; Google Meet via a founder's personal account (control limitation) | Provider choices must follow the approved budget; provider should be swappable | NFR-SESI-02 partly unmet (no abstraction); payment provider asserted in copy without confirmation |
| C-07 | §2.4 Team of two, no dedicated QA; 6-month PMW timeline | Test strategy must be proportionate; regressions carry real cost | 7 smoke tests guard the UI; business rules are largely untested |
| C-08 | §2.4 Android/Play Console budget only | No iOS release work | Compliant |
| C-09 | §6 Role split: Front-End owns UI; Back-End owns schema, RLS, storage, gateway, aggregation | Client must not invent schema/policies | Repository contains **no** schema/RLS artefacts (§1.3); several client-side rules (aggregation D4, invented columns) currently trespass on Back-End ownership |
| C-10 | §7 Release plan (Sprint 0..3 by module) | Implementation order should respect module dependency | Current wave plan (§10) follows the same dependency edges |

---

## 7. Surplus implementation not present in SRS v1.0 (must be resolved explicitly)

These modules are implemented in the UI and are **not traceable to any requirement in the analysed SRS**. They must be either ratified into a new SRS version or removed — they must not be used as justification for architecture decisions, and their dummy data must not be mistaken for working features.

| Module | Code | Suggested disposition |
|---|---|---|
| Package & Token (`FR-PKG-01..07`) | `package_*`, `token_model`, `package_screen`, `my_tokens_screen`, `package_card` | Ratify into SRS (it changes the payment/booking model: prepaid sessions) or remove |
| Reschedule (`FR-RESCH-01..09`) | `reschedule_*`, `reschedule_screen` | Ratify or remove; note its policy set (H-6 h, +2 days, switch-Tutor approval) is **not** in SRS v1.0 and overlaps FR-PAY-04/FR-BOOK-08 |
| Payroll / Honor (`FR-PAYR-01..07`) | `payroll_*`, `payroll_screen`, `slip_gaji_screen` | Ratify or remove; it is the only place a 70/30 split is (implicitly) represented, and it assumes automation that FR-PAY-06 leaves unanswered |
| Invoice with multi-session + discount | `invoice_model` (`InvoiceSessionItem`, `discount`) | SRS describes one Payment per Booking; multi-session invoicing is an unratified extension |
| Tutor pricing (`pricePerHour`, price = hourly × duration) | `TutorModel.pricePerHour`, `booking_screen._goToInvoice` | **Not in SRS §4.1 or any FR.** Pricing is currently invented client-side. Must be ratified before it is relied upon |
| Tutor fields `gpa`, `extraSkills`, `isTutorOfTheMonth`, `verificationStatus` vocabulary | `TutorModel`, `tutor_profile_screen` | Only "achievement badge" and verification status are hinted at; the rest are extensions |
| `sessionType: 'video' | 'chat'` | `BookingModel` | The SRS treats Meet sessions and chat as parallel capabilities of one session, not as alternative types |
| "Umum" grade option; UTBK score & CV documents | `profile_screen.dart`, `_dummyDocuments` | Contradict the SRS option/document sets (see FR-AUTH-06, FR-PROF-05) |
| ShopeePay QRIS copy & webhook comment | `invoice_screen.dart`, `payment_controller.dart` | Contradicts the SRS assumption (Midtrans/Xendit) and Bab 8 #8; must be removed or corrected |

---

## 8. Summary counts

### 8.1 Primary status (74 analysed requirements: 54 FR + 20 NFR)

| Status | FR | NFR | Total | Share |
|---|---|---|---|---|
| **A** — Implemented and aligned | 7 | 3 | **10** | 13.5 % |
| **P** — Partially implemented | 13 | 3 | **16** | 21.6 % |
| **M** — Implemented but not aligned | 5 | 0 | **5** | 6.8 % |
| **U** — UI only / mock | 12 | 0 | **12** | 16.2 % |
| **X** — Missing | 12 | 11 | **23** | 31.1 % |
| **?** — Ambiguous / needs clarification | 5 | 3 | **8** | 10.8 % |
| **Total** | **54** | **20** | **74** | 100 % |

**Rev 2 delta** (rev 1 was A 8 / P 16 / M 6 / U 12 / X 24 / ? 8): FR-RATE-01 **P → A** (W1-1) · FR-RATE-04 **M → A** (W1-2) · FR-AUTH-05 **X → P** (W1-3, mechanism only — deliberately *not* counted as aligned while the user-facing flow is absent). Counts re-derived from the rows above, not re-estimated.

### 8.2 Layer coverage (what exists today)

Computed directly from the `Layer state` column of the 74 requirement rows above (counts therefore sum to 74 per layer):

| Layer | Exists ✅ | Partial ◐ | Absent ✗ | n/a |
|---|---|---|---|---|
| **UI / presentation** | 28 | 14 | 23 | 9 |
| **Business / application logic** | 9 | 32 | 31 | 2 |
| **Data access / backend integration** | 21 | 7 | 45 | 1 |

Read together: **presentation is the most complete layer** (UI exists in 42 of 74 rows), while **business logic is the weakest** (fully present in only 9 of 74 despite 14 controllers — logic is mostly partial, living inside presenters). Data access exists in 28 rows and is concentrated in the areas already wired to Supabase (auth, tutor/discovery reads, bookings, sessions, reviews); it is absent for profile persistence, availability slots, payment, chat, documents and admin. This is the signature of a UI-first merge branch (`ui-merge`) with mock data behind it.

**Rev 2 delta** (rev 1 was UI 27/15/23/9 · Logic 7/31/34/2 · Data 21/6/47/0): FR-RATE-01 Logic ◐→✅ · FR-RATE-04 UI ◐→✅, Logic ✗→✅, Data ✗→n/a (the clause requires *no* write) · FR-AUTH-05 Logic ✗→◐, Data ✗→◐ · NFR-RATE-01 Logic ✗→◐ (the client-side paths that could create a review with no rating intent were removed).

### 8.3 Decisions required before implementation (57 of 74 rows)

Counted from the `Decision needed` column (a cell is "open" whenever it is not `—`). **Rev 2:** the count was 56 in rev 1; **NFR-RATE-01's cell was `—` in rev 1 although the Decision Register already defines a blocking decision for it (D-49, "Enforcement location for one review per session", marked *blocks implementation*)**. The row now cites D-49, so the flagged set is 57 and the un-flagged set is 17. No decision was created, consumed or resolved by Wave 1 — every Wave 1 fix was implemented against requirements whose cells are already `—`.

* **8 requirements carry the primary status `?`** because the SRS itself declares them tentative/undecided, so no correct implementation can be judged yet:
  `FR-SESI-02` (varian A/B, Bab 8 #3) · `FR-SESI-05` (Bab 8 #4) · `FR-SESI-07` (Bab 8 #11) · `FR-PAY-04` (Bab 8 #5) · `FR-PAY-06` (Bab 8 #7) · `NFR-AUTH-03` (Bab 8 #9) · `NFR-PROF-04` (Bab 8 #9) · `NFR-PAY-03` (Bab 8 #6).
* A further **49 rows** have a definitive implementation state but still carry an open decision that must be recorded before their "Required change" can be executed. They cluster into four themes:
  1. **Back-End data/contract questions** (columns, storage, RLS, aggregate ownership, review uniqueness): FR-AUTH-02, FR-PROF-01, FR-PROF-04, FR-RATE-03, NFR-PROF-01, NFR-PAY-01, FR-PROF-03, NFR-RATE-01 (D-49).
  2. **Business-rule values or scope still open** (verification flow, refund categories, locks/TTL, pricing): FR-PROF-07, FR-PROF-08, FR-PROF-09, FR-PAY-05, FR-BOOK-04, FR-BOOK-08, FR-PROF-10, NFR-PROF-02, NFR-BOOK-03, FR-PROF-03.
  3. **Requirement-clause reconciliation inside the SRS itself**: FR-BOOK-03 vs FR-PAY-03 vs FR-BOOK-06, FR-SESI-01 vs FR-SESI-02, FR-AUTH-06 ("Umum"), FR-PROF-05 (document catalogue), FR-DISC-03, FR-AUTH-07, FR-SESI-06, FR-SESI-04, FR-BOOK-07, FR-RATE-03, FR-RATE-04.
  4. **Admin surface decisions**: FR-ADM-01..04 and NFR-ADM-01.
* All 11 Bab 8 open issues and all 8 §2.5 assumptions are represented above. **A5 (payment provider) is already contradicted by shipped copy**; A3 (refund), A4 (revenue split) and A8 (disconnection SOP) have no implementation at all; A1/A2/A6/A7 have scaffolding only.
* Practical reading: **17 of 74 rows carry no open decision at all** — the 10 aligned rows plus 7 rows whose remaining work needs no decision (FR-AUTH-03, FR-AUTH-04, FR-PROF-02, FR-PROF-06, FR-DISC-01, FR-DISC-02, FR-DISC-05, FR-DISC-06, FR-BOOK-02, FR-BOOK-05, FR-BOOK-09, FR-RATE-01, NFR-AUTH-01, NFR-AUTH-02, NFR-PROF-03, NFR-BOOK-02, NFR-SESI-01). **Rev 2:** the four Wave 1 items the Wave 0 plan classified as unblocked are now executed (W1-1, W1-2, W1-4 complete; W1-3 mechanism only) **without consuming or inventing any decision** — Wave 1 itself moved no row in or out of the flagged set. (The rev-2 shift from 56/18 to **57/17** comes solely from the NFR-RATE-01 correction explained above, not from any Wave 1 behaviour change.) FR-SESI-01's `: null` link (D1) remains the next decision-free *plumbing* fix, though the link's *source* still depends on D-03 (Bab 8 #3).

### 8.4 Major implementation gaps (ranked by what blocks the most other work)

1. **No persisted business data for Profile, Booking slots, Payment, Payroll** — the majority of `U` rows share one root cause: controllers keep domain state in memory instead of storage.
2. **No concurrency control for slots** (FR-BOOK-04 + NFR-BOOK-01) — the single largest correctness gap; it also undermines NFR-PAY-03's expiry promise.
3. **No verification gate** (FR-PROF-08 + FR-DISC-01) — unverified Tutors are publicly bookable, contradicting two requirements at once.
4. **No payment integration of any kind** (FR-PAY-01/02, NFR-PAY-01/02) — blocked on Bab 8 #8, and the client currently asserts an unconfirmed provider.
5. **Session delivery is broken end-to-end** (FR-SESI-01 dead ternary, FR-SESI-02 undecided, FR-SESI-03/04 chat absent, FR-SESI-05 notifications disabled).
6. **Rating integrity** — rev 2 closed both write-path defects: reviews are no longer written against an empty Tutor id (D2 → W1-1) and "skip" no longer fabricates a 1-star review (D3 → W1-2). Still open: the average is computed and written client-side (D4, FR-RATE-03) and nothing enforces one review per session (NFR-RATE-01, enforcement location D-49).
7. **Booking lifecycle contradicts the SRS** (FR-BOOK-03 / FR-PAY-03 vs D5: manual Tutor confirmation persists in the happy path).
8. **Admin module entirely absent** (FR-ADM-01..04, NFR-ADM-01), blocked on Bab 8 #10.
9. **No repository-level verification possible** — no schema, migrations or RLS in the repo (§1.3), so no data-layer requirement can be confirmed as done from this repository alone.
10. **Scope conflict** — four fully-built modules (Package/Token, Reschedule, Payroll, multi-session Invoice) plus invented pricing have no SRS basis (§1.2, §7).

---

## 9. Separation of the five categories requested

### 9.1 UI that already exists (presentation is broadly complete)
Auth (login, register, splash), Buddy profile + edit sheet, Tutor profile + edit sheet + document tiles + verification badge, discovery (dashboard, tutor list, tutor detail, reviews), booking (slot picker, invoice, transaction history), session (session screen with timer, review screen), plus the surplus screens (packages, tokens, reschedule, payroll, slip gaji). Navigation, theming, typography and the shared widget kit are in place.

### 9.2 Business/application logic that exists
- Booking creation + the "create only after payment" ordering (`onPaid`) — conceptually correct, wired from the view.
- Booking status update and Tutor accept/reject transition.
- Tutor search filtering by name/subject and rating-descending ordering.
- Review submission with the Tutor/session context carried from the booking, a true "skip" that writes nothing (W1-1/W1-2), and review listing.
- Session start/end and booking→done transition.
- Invoice totals (subtotal/discount/total), 15-minute expiry countdown, cancel-order path.
- Pure-logic units that are already testable today: reschedule policy, payroll totals, invoice totals, `copyWith` null semantics.
- Validation helpers (email/password/required) and the 5-hour lead-time check (an unratified rule, see §7).

### 9.3 Data access / backend integration that exists
- Supabase Auth: sign-in, sign-up, sign-out, current-user fetch.
- Supabase DB reads/writes: `users`, `tutors` (incl. `is_online`/`last_seen`), `bookings`, `sessions`, `reviews`.
- Supabase Realtime: online-tutor channel only (`subscribeBookings` written but unused).
- Firebase: initialised in `main.dart`; FCM token persistence and foreground local notifications exist in code but are never started.
- `url_launcher` for external video links (path exists, never reached).
- Storage buckets are **named only**; no storage call is made anywhere.

### 9.4 Logic that is missing (no implementation at all — 23 requirements)
*(Rev 2: FR-AUTH-05 left this list — its reset mechanism now exists as partial logic; it is tracked as **P** above.)*
FR-PROF-08, FR-DISC-01, FR-DISC-03, FR-BOOK-04, FR-BOOK-06, FR-BOOK-08, FR-SESI-03, FR-SESI-04, FR-ADM-01, FR-ADM-02, FR-ADM-03, FR-ADM-04, NFR-AUTH-03*, NFR-PROF-01, NFR-PROF-02, NFR-PROF-03, NFR-PROF-04*, NFR-DISC-01, NFR-BOOK-01, NFR-BOOK-03, NFR-PAY-01, NFR-PAY-02, NFR-SESI-03, NFR-RATE-01, NFR-ADM-01.
(*NFR-AUTH-03/NFR-PROF-04 are counted under `?`, not `X`; they are listed here because nothing exists.) Note that a **name/route/field existing is not the same as logic existing** — e.g. `gmeetLinks`, `verificationStatus` and `bucketDocuments` exist as data shapes only.

### 9.5 Logic that exists but **contradicts** the SRS (6 requirements + 2 shipped-assumption conflicts)
| Ref | Contradiction |
|---|---|
| FR-AUTH-06 | An option outside the permitted grade set ("Umum") is offered |
| FR-PROF-05 | Achievement certificate demoted to optional (SRS: required) and two invented documents added |
| FR-BOOK-03 | Booking still requires manual Tutor confirmation, which the SRS explicitly removes |
| FR-PAY-03 | Booking is created as `pending`, not "fully confirmed" |
| FR-RATE-03 | Average rating is computed and written by the client |
| FR-DISC-01 | The search query returns unverified Tutors to Buddies — the opposite of the clause (recorded as primary status `X` because the filter does not exist, flagged here because the shipped behaviour actively contradicts the requirement) |
| §7 / A5 | UI copy asserts **ShopeePay QRIS** while the SRS assumes Midtrans/Xendit and leaves the provider unanswered |
| §7 | `pricePerHour`-based pricing is presented as authoritative although pricing appears nowhere in the SRS |

**Rev 2:** FR-RATE-04 has left this table (W1-2) and FR-RATE-01's corrupt write was fixed (W1-1) — both are primary status **A** now. The two shipped-assumption conflicts (ShopeePay QRIS copy, `pricePerHour`) are unchanged, and FR-RATE-03/FR-DISC-01 have no code contradiction left to remove: they are missing or mislocated logic, not fabrications.

---

## 10. Recommended implementation order (waves)

Ordering rule: **decisions precede code; correctness and integrity precede completeness; new capability last.** No wave may begin while its prerequisites are open. Waves are additive and must preserve the existing UI, copy and widget keys; each wave ships behind its own branch (consistent with the repo's existing `ui/<module>` convention) so `ui-merge` stays shippable.

### Wave 0 — Decisions (no code changes)
Reconcile the SRS version and the surplus modules (§1.2, §7); obtain rulings on Bab 8 #1, #3, #4, #5, #6, #7, #8, #10, #11 (§5); obtain the Back-End data contract for the `users` profile columns, Tutor document storage/RLS, chat storage, payment/transaction tables with immutability, and review uniqueness (§1.3). **Output: a ratified SRS version + a BE contract note. Without these, Waves 2–4 cannot be completed correctly, only guessed at.**

### Wave 1 — MVP correctness and integrity fixes (unblocked, no new backend assumptions)
| Order | Requirement | Why here | State in rev 2 |
|---|---|---|---|
| 1.1 | FR-RATE-01 (D2) + NFR-RATE-01 | Fix a data-corrupting write before building anything on top of reviews | FR-RATE-01 ✅ **complete (W1-1)** · NFR-RATE-01 ⧗ still open (needs D-49 for the enforcement location) |
| 1.2 | FR-RATE-04 (D3) | Remove fabricated 1-star reviews (direct SRS violation) | ✅ **complete (W1-2)** |
| 1.3 | FR-AUTH-05 | Self-contained, user-visible missing MVP feature | ◐ **partial (W1-3)** — reset mechanism wired to Supabase Auth; the user-facing entry point, reset screen and deep-link handling are still missing. Not blocked by a decision (D-42 is non-blocking), only by step scope |
| 1.4 | FR-AUTH-02 + FR-AUTH-06 | Registration completeness for Buddies; removes the unratified "Umum" option | ⧗ not started — needs the `users` profile column contract (D-45) and the "Umum" ruling (D-18) |
| 1.5 | FR-SESI-01 (D1) | Makes the session link path observable (needs Wave 0 #3 only for the *source*, not for the plumbing) | ⧗ not started — plumbing remains decision-free; the link source still needs D-03 |
| 1.6 | FR-BOOK-03 + FR-PAY-03 (D5) | Removes the manual-confirmation contradiction and unifies the confirmed state | ⧗ not started — needs the lifecycle ruling (D-20) |
| 1.7 | AUTH role vocabulary (FR-AUTH-01) + D9/D10 | Single source of truth for role before RLS work begins | ⧗ not started — needs D-19 and D-25 |

**W1-4** (auth logging hygiene — not a numbered requirement) is ✅ **complete**; see §1.4 D8 and `docs/wave-1-completion-report.md` Part A. **No Wave 2 work has started:** Wave 2 still requires the Wave 0 decisions (§5) and the Back-End contracts (§1.3, D-45…D-57).

### Wave 2 — Persistence, rules and integrity
| Order | Requirement | Notes |
|---|---|---|
| 2.1 | FR-BOOK-04 + FR-BOOK-05 + NFR-BOOK-01 | Atomic slot reservation — the keystone dependency for payment expiry and the booking lifecycle |
| 2.2 | NFR-BOOK-02 | Realtime booking state so both parties see the same truth |
| 2.3 | FR-PROF-01/02/04/05/06/09 + NFR-PROF-01/02/03 (D6/D7) | Persist profiles and implement real document upload with size/format rules and private storage |
| 2.4 | FR-PROF-07 + FR-PROF-08 + FR-DISC-01 | Verification status becomes real, then gates bookability and search visibility |
| 2.5 | FR-DISC-02/03/06 + FR-BOOK-01/02 | Filters, card completeness, real slots in the existing picker UI |
| 2.6 | FR-BOOK-07/09 | "Booking Kamu" list + detail including Tutor and payment status |
| 2.7 | FR-PAY-04 + FR-BOOK-08 + FR-PAY-05 | Refund policy + Buddy cancellation + refund request tracking |
| 2.8 | FR-RATE-03 + AUTH-07 | Server-owned aggregate; role-specific onboarding |

### Wave 3 — Payment and session capability (requires Wave 0 #3/#4/#5/#6/#7/#8)
Payment: FR-PAY-01, FR-PAY-02, NFR-PAY-01, NFR-PAY-02, NFR-PAY-03, FR-PAY-06, FR-PAY-07.
Session: FR-SESI-02, FR-SESI-03, FR-SESI-04, NFR-SESI-03, FR-SESI-05, FR-BOOK-06, FR-SESI-06, NFR-SESI-02.

### Wave 4 — Scope items and deferrals (requires Wave 0 #1/#2/#9/#10/#11)
FR-ADM-01..04 + NFR-ADM-01; FR-SESI-07; NFR-AUTH-03; NFR-PROF-04; NFR-DISC-01; NFR-DISC-02; FR-PROF-03; NFR-BOOK-03; plus the §7 disposition of surplus modules.

### Wave 5 — Architecture work (explicitly deferred)
Structural refactoring (domain extraction, ports/repositories, controller decomposition, mapper relocation) is **out of scope until this matrix is ratified and Waves 1–2 establish a tested baseline**. The 24 `X` and 6 `M` rows above are behavioural defects; restructuring first would encode them into the new architecture. Refactoring should follow this matrix, using the requirements it makes verifiable as its acceptance criteria.

---

## 11. Traceability maintenance rules

1. Any change to a requirement or to its status **must** update this file in the same change set.
2. New features not traceable to an SRS ID must first be added to the SRS and to §7, or they must not be built.
3. `?` rows must not be "closed" by implementation; they are closed only by a recorded decision (§5).
4. Rows in the `M` group require an explicit note in the change description naming the corrected behaviour.
5. When the SRS is next revised, re-derive §1.2 (version conflict) before re-deriving counts.

*End of matrix.*

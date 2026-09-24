# Wave 1 — Auth Logging Audit & Completion Report

**Document type:** Audit + completion report (documentation only — **no application code was changed to produce this document**)
**Date:** 23 September 2026
**Baseline:** branch `ui-merge`, HEAD `1f1fba5`; the Wave 1 change set is **uncommitted** in the working tree
**Authoritative inputs:** `docs/requirement-traceability-matrix.md` (rev 2), `docs/decision-register.md`, `docs/wave-0-plan.md`, `docs/be-contract-request.md`
**Scope of the audited code:** the 6 files in the Wave 1 change set + `test/review_smoke_test.dart` (new). Nothing else was modified: no migration, schema, RLS, storage bucket, gateway, endpoint or UI-design change; no Decision Register item was resolved by guessing.

---

# Part A — Auth logging audit (TASK 2)

## A.1 Method and evidence

| Check | Command | Result |
|---|---|---|
| Every raw log call in the app | `grep -rn "print(" lib/` | **2 hits total** (`auth_controller.dart:33`, `booking_controller.dart:96`) |
| Any logging framework in use | `grep -rnE "debugPrint\|logger\|log(\|kDebugMode\|kReleaseMode" lib/` | **0 hits** — the project has **no** logging framework (`dialog`-matches only) |
| Sign-up logging before W1-4 | `git show HEAD:studybuddy/lib/core/services/auth_service.dart \| grep -c "print("` | **10 statements**, all inside `signUp` |
| Same file after W1-4 | `grep -c "print(" lib/core/services/auth_service.dart` | **0** |
| Auth UI paths | `grep -ln "print(" lib/views/auth/*.dart` | **no file matches** |

## A.2 Findings, by location

| # | Location | Statement(s) | Class | Rationale | Action |
|---|---|---|---|---|---|
| A-1 | `core/services/auth_service.dart › signUp` (HEAD lines 62–90) | 10 × `print`: the `=== … ===` banners, `response.user`, **`response.session`**, the `userData` map (email / full_name / role), the raw insert result, `Error: $e`, `Stack: $stack` | **A — Must remove** | `response.session` is a full Supabase session object carrying **access and refresh tokens**; the payload dump adds PII (email, name) and the stack trace adds internals. None of it served a product purpose | **REMOVED in W1-4.** The `try/catch` that existed *only* to print was removed with it; behaviour is unchanged because the exception still propagates to `AuthController` |
| A-2 | `controllers/auth_controller.dart:33 › _loadCurrentUser` | `print('AuthController._loadCurrentUser gagal: $e')` (preceded by 3 comment lines explaining the intent and an `// ignore: avoid_print`) | **C — Intentionally retained** | See A.3 — recommended to keep | **Not changed** (per instruction not to remove it automatically) |
| A-3 | `AuthController.login` / `register` / `resetPassword` (new) | none | n/a | Failures are converted into user-facing `errorMessage` text only (`'Email atau password salah'`, `'Registrasi gagal. Coba lagi.'`, `'Gagal mengirim email reset password. Coba lagi.'`); nothing is logged | Verified by inspection — no change |
| A-4 | `AuthService.signIn` / `signOut` / `getCurrentUser` / `resetPassword` / `updateOnlineStatus` | none | n/a | Pure delegation to Supabase Auth / PostgREST; no logging | Verified — no change |
| A-5 | `views/auth/login_screen.dart`, `register_screen.dart`, `splash_screen.dart` | none | n/a | Presentation only; `_checkSession` (D10) performs its read silently | Verified — no change |
| A-6 | `controllers/booking_controller.dart:96 › fetchMyBookings` | `print('BookingController.fetchMyBookings gagal: $e')` — the same pattern as A-2 | **C** (different domain) | Same anti-silent-failure rationale, but **not an auth path**, so it is outside this audit's scope and was left untouched | Reported for completeness only |

## A.3 The retained line: why it stays (classification **C**)

1. **It prevents a silent failure mode.** `_loadCurrentUser`'s `catch` sets `currentUser.value = null`, which is *identical* to the legitimate "no session" state. Without a trace, a transient network/Supabase failure is indistinguishable from being logged out, and the user is silently bounced to the login screen with no diagnosable cause. This is the one place in the auth path where that happens.
2. **It logs an exception message only — no credential material.** It prints `$e` (e.g. `PostgrestException` / `AuthException` text). It does **not** print the session, the token, the response body, or the user payload — the exact things that made A-1 an **A**. After W1-4, the auth path has **zero** statements of that kind.
3. **It is demonstrably deliberate, not leftover scaffolding.** It carries a three-line comment stating the intent and an explicit `// ignore: avoid_print` suppression — i.e. someone consciously decided to keep a raw print rather than add a logging dependency.
4. **It is load-bearing for CI/dev visibility today.** It is the reason the uninitialised-Supabase failures are visible in `flutter test` output, e.g.:
   `AuthController._loadCurrentUser gagal: '…You must initialize the supabase instance before calling Supabase.instance'` — see `test/tutor_screens_smoke_test.dart`/`profile_smoke_test.dart` runs.
5. **There is no framework to migrate to** (A.1: zero `logger`/`debugPrint`/`kDebugMode` usage), and the instruction forbids introducing one. Removing it now would trade a real diagnosis channel for zero benefit.

**Recommended safer replacement (option, not applied):** swap `print(...)` for `debugPrint(...)` from `package:flutter/foundation.dart`. It needs **no new dependency** (Flutter SDK), is the Flutter-sanctioned logging call, is rate-limited on Android instead of truncating, and can be silenced globally in release builds via `debugPrint = (_, __) {}` in `main.dart`. This is a two-line change that resolves the "raw `print` in production code" hygiene objection while keeping the diagnosis channel.

**Decision required from the team (owner per SRS §6: Front-End):** (a) keep A-2 exactly as-is — *recommended*, since it is classified C; (b) replace it with `debugPrint` (and decide whether to override `debugPrint` in release); (c) do nothing and revisit. A proper logging framework is **out of scope** for this wave.

## A.4 Classification totals

| Class | Count | Items |
|---|---|---|
| **A — Must remove** | **10 statements** (1 block) | A-1, all removed in W1-4 |
| **B — Legitimate temporary diagnostic that should be replaced** | **0** | — |
| **C — Intentionally retained** | **1 statement** | A-2 (+ A-6 as the out-of-domain twin, untouched) |

**Verdict:** after W1-4 there is **no credential- or token-bearing logging anywhere in `lib/`**, and no logging framework exists to introduce. The one remaining auth-path log is an exception message with a documented anti-silent-failure purpose; it should remain, optionally converted to `debugPrint` with approval.

---

# Part B — Wave 1 completion report (TASK 3)

## B.1 W1-1 — Review identity/context → **COMPLETE**

| | |
|---|---|
| Defect (RTM §1.4 **D2**) | The review submit path sent `tutorId: ''` and `subject: ''`, so review rows could not be attributed to a Tutor, and the rating roll-up targeted `''` |
| Fix | `SessionController` now stores the `BookingModel` it was started from (`currentBooking`); `endSession()` routes to the review screen with `arguments: {sessionId, tutorId, subject}`; the screen submits those values; `ReviewController.submitReview` **refuses an empty `sessionId`/`tutorId` before touching data** |
| Files | `controllers/session_controller.dart`, `views/session/session_screen.dart`, `views/session/review_screen.dart`, `controllers/review_controller.dart` |
| Guardrail | The empty-context path is now unreachable *and* explicitly refused, so the defect cannot silently return |
| No invention | No new backend field, no new API call, no schema change. The write shape is byte-for-byte the same except the values are real |
| Residual (not a behaviour gap) | The row still writes `customer_id` where SRS §4.1 names `buddy_id`, plus an SRS-undefined `subject` column — already open as D-19 / a Rating-Review contract item in `docs/be-contract-request.md` |

## B.2 W1-2 — "Lewati" → **COMPLETE**

| | |
|---|---|
| Defect (RTM §1.4 **D3**) | "Lewati" called `submitReview(rating: 1, comment: 'Tidak ada ulasan', tutorId: '')`, fabricating a 1-star review and corrupting the Tutor's average |
| Fix | The skip action now performs **no write at all** and exits to the Buddy dashboard (`Get.offAllNamed(AppRoutes.customerDashboard)`), matching the destination of a successful submit |
| Files | `views/session/review_screen.dart` |
| Residual | No rating reminder is shown — expressly permitted (SRS: the system *may* — `dapat` — remind); tracked as the non-blocking D-35 |

## B.3 W1-3 — Forgot password → **PARTIAL (mechanism only) — deliberately not marked implemented**

The premise "correct the existing forgot-password flow" did not hold: **no flow existed** (no link, route, screen or service call — `login_screen.dart` offered only "Daftar sekarang"). What exists now, and what does not:

| Distinction | State |
|---|---|
| Reset **mechanism** in `AuthService` / `AuthController` | **EXISTS** — `AuthService.resetPassword({email})` → `SupabaseClient.auth.resetPasswordForEmail` (verified present in the installed `gotrue 2.19.0`), plus `AuthController.resetPassword()` with `isLoading` / `errorMessage` / `resetEmailSent` state |
| User-facing **entry point** | **DOES NOT EXIST** — no "Lupa password?" link, no route, no screen. The two new methods are currently **uncalled from the UI** |
| Reset **UI** / deep-link / new-password step | **UNIMPLEMENTED** — no reset screen, no token/deep-link handling, no "set new password" form |
| Backend / Supabase **configuration dependency** | **UNVERIFIED** — the emailed link returns to the Supabase project's configured redirect/Site URL. No such configuration is committed to this repository (§1.3 of the RTM), so it could not be checked; the default flow is only correct if that URL is already set to something the app can act on. **Needs the Back-End owner** |
| Auth architecture | Unchanged — Supabase Auth remains the only mechanism (FR-AUTH-03's dependency); no new auth path was invented |
| Blocking | **Not blocked by any decision** — D-42 (screen copy/UX) is explicitly recorded as *non-blocking*, and the register states FR-AUTH-05 is "otherwise ready to implement". The remaining work was excluded purely by this step's strict scope ("do not add the forgot-password UI") |

## B.4 W1-4 — Auth debug logging → **COMPLETE**

* 10 `print` statements removed from `core/services/auth_service.dart › signUp` (Part A, A-1), including the dump of `response.session`.
* The `try/catch` whose only body was the prints was removed as well; the exception still propagates to `AuthController`, so **login/registration behaviour is byte-for-byte unchanged** (the controller's existing `catch` still produces the user-facing message).
* `insertResult` was only ever read by a print, so the insert is now a plain `await` — same call, same data.
* No `print` remains anywhere in `lib/core/services/auth_service.dart` or `lib/views/auth/*`.
* The one remaining auth-path log (A-2) is **intentionally retained** and audited above.

## B.5 Tests

| Check | Command | Result |
|---|---|---|
| Static analysis | `flutter analyze` | **0 errors**, and no new issue attributable to the change set. Two pre-existing notices sit inside touched files: the unused `../models/review_model.dart` import in `review_controller.dart` (present at HEAD — verified with `git show`) and `withOpacity` deprecation in `session_screen.dart:48` (an untouched line; ~30 such notices repo-wide) |
| New focused tests | `flutter test test/review_smoke_test.dart` | **8/8 pass** |
| Full suite | `flutter test` | **41 pass / 1 fail** (the single failure is pre-existing — B.6) |

New tests added (`test/review_smoke_test.dart`, 5 widget + 3 controller-logic), each mapped to a corrected behaviour:

1. Submit button stays disabled until a star is chosen (unchanged behaviour, pinned).
2. **Submit uses the session's real `sessionId`, `tutorId` and `subject`** (W1-1).
3. **"Lewati" submits nothing and leaves the screen** — asserts zero calls on a spy controller and that navigation happened (W1-2; the regression that produced a fake 1-star row).
4. **"Lewati" still exits when no review context exists** (W1-2 + W1-1 degradation).
5. Missing context surfaces a message and submits nothing (W1-1 guard).
6. **Logic: refuses an empty `tutorId` without touching data** (W1-1).
7. **Logic: refuses an empty `sessionId` without touching data** (W1-1).
8. **Logic: a complete context passes the guard and reaches the write path** (proves the guard is not over-blocking).

## B.6 Known pre-existing test failure (not caused by Wave 1)

`test/widget_test.dart › "Counter increments smoke test"` **fails**, and did so before Wave 1. The file is the untouched Flutter template stub: its `pumpWidget(const MyApp())` line is commented out (and `MyApp` does not exist in this project), yet it still asserts `find.text('0')` and taps `Icons.add` — so it fails on a widget tree that was never built. Evidence: the file is unmodified (`git status`), it fails in isolation (`flutter test test/widget_test.dart` → 1 failure), and it imports only `package:studybuddy/main.dart` plus `flutter_test` (it references none of the changed classes). It also triggers an `unused_import` warning. **Recommendation: delete or rewrite this stub in a separate, explicitly approved cleanup — not in Wave 1.**

## B.7 Remaining blockers

1. **W1-3 UI (not decision-blocked, scope-blocked):** entry point + reset screen + reset-token/deep-link handling + new-password step. Plus the Supabase redirect/Site-URL target must be confirmed by the Back-End owner (`docs/be-contract-request.md` → Authentication / Users).
2. **All remaining Wave 1 items** (RTM §10 rows 1.4–1.7): registration completeness (needs D-45, D-18), session link plumbing D1 (plumbing decision-free; the *source* needs D-03), booking/payment lifecycle (D-20), role vocabulary (D-19/D-25).
3. **NFR-RATE-01** (one review per session) — needs D-49, which the register marks *blocks implementation*.
4. **The Wave 1 change set is uncommitted.** No commit, branch or push was created; `git status` shows 6 modified files + 1 new test file. No unrelated file was modified.
5. **Not touched, by instruction/design:** D1 (`: null` Meet link), the client-side rating aggregate (D-04/D-48), Package/Token, Reschedule, Payroll, payment integration, booking lifecycle, Tutor verification, slot locking, chat, Admin, and the surplus `pricePerHour` pricing.

## B.8 RTM rows whose status changed (all re-derived from the evidence above)

| Requirement | Rev 1 → Rev 2 | Basis |
|---|---|---|
| **FR-RATE-01** | **P → A** | D2 closed (W1-1); write is attributed, empty context refused; residual is field-naming debt only |
| **FR-RATE-04** | **M ⚠ → A** | D3 closed (W1-2); skip writes nothing and exits |
| **FR-AUTH-05** | **X → P** | Mechanism exists (W1-3); user-facing flow absent, so **not** A |
| **FR-AUTH-03** | A → A (gap cell rewritten) | D8 removed (W1-4); no functional divergence remains |
| **NFR-AUTH-01** | A → A (evidence added) | Audit confirms nothing credential-related is logged |
| **FR-RATE-02** | A → A (dependency note) | Its correctness dependency D2 is now fixed |
| **FR-RATE-03** | M → M (gap narrowed) | D2 no longer applies; only the client-side aggregate (D4) contradicts the SRS |
| **NFR-RATE-01** | X → X (gap clarified, decision cell now cites D-49) | The two no-intent review paths are gone; server-side uniqueness still missing |
| §1.4 D2 / D3 / D8 | marked **RESOLVED** | Audit trail retained rather than deleted |
| §8.1 / §8.2 / §8.3 | Recounted | A 8→**10**, M 6→**5**, X 24→**23**, P 16 (net unchanged), ? **8**; layer counts re-derived row-by-row and machine-checked against the tables |
| §9.4 / §9.5 / §10 | Updated | FR-AUTH-05 left "missing"; FR-RATE-04 left "contradicts"; Wave 1 rows carry a state column |

## B.9 Decision Register items still blocking future implementation (none resolved here)

| Decision | Blocks | Status |
|---|---|---|
| **D-42** Forgot-password screen copy/UX | The remaining part of W1-3 — **explicitly non-blocking**, so the UI may proceed without it | OPEN |
| **D-49** Enforcement location for one review per session | NFR-RATE-01 ("blocks implementation") | OPEN |
| **D-48** Rating aggregation ownership | FR-RATE-03 | OPEN |
| **D-45, D-46, D-47** Profile field / Tutor record / document storage & RLS contracts | FR-AUTH-02, FR-PROF-01…09, NFR-PROF-01…03 (Wave 2.3–2.4) | OPEN / BLOCKED |
| **D-50, D-51, D-52** Slot entity, Booking↔Payment↔Session, canonical statuses | FR-BOOK-01…05, FR-PAY-03, FR-SESI-06 (Wave 2.1–2.2) | OPEN / BLOCKED |
| **D-01, D-22** Verification flow ownership & lifecycle | FR-PROF-07/08, FR-DISC-01, FR-ADM-02 (Wave 2.4) | OPEN / BLOCKED |
| **D-40, D-06, D-53, D-54** Lock TTL, QR expiry, transaction immutability, expiry authority | FR-BOOK-04/05, NFR-PAY-01/03 (Wave 2.1, Wave 3) | OPEN |
| **D-05, D-30** Refund threshold & request flow | FR-PAY-04, FR-PAY-05, FR-BOOK-08 (Wave 2.7) | OPEN |
| **D-03, D-04, D-08, D-07, D-09, D-10, D-11** Meet variant, notifications, provider, split, consent, Admin form, disconnection SOP | Waves 3–4 in full | OPEN |
| **D-12 … D-16** Package/Token, Reschedule, Payroll, multi-session invoice, `pricePerHour` | The **unratified** surplus modules — still `UNRATIFIED — SRS DECISION REQUIRED`; none was touched, refactored, integrated or deleted | OPEN / BLOCKED |

**Total: 57 decisions, all still OPEN — Wave 1 consumed none and resolved none by guessing.**

## B.10 Cross-document consistency issues discovered — **resolution status: items 1–4 RESOLVED in the reconciliation step; item 5 stands**

1. **RTM rev 1 under-counted its own decision set.** `NFR-RATE-01`'s `Decision needed` cell was `—`, yet the Decision Register defines **D-49** for it and marks it *"Blocks implementation? Yes"*. RTM rev 2 now cites D-49 (57 flagged rows, 17 un-flagged).
2. **Consequence for `docs/decision-register.md` §0.4** — it **stated** "all **56** requirement rows that the RTM flagged … map to at least one decision ID" (corrected to **57** in the reconciliation below); the coverage *claim* itself stayed true, because the row maps to the pre-existing D-49.
3. **`docs/decision-register.md` › D-49 › "Current implementation"** still describes the reviewed state as *"it also submits `tutorId: ''` (RTM defect D2)"* — D2 was fixed in W1-1, so that sentence is now stale. Same class of staleness exists in any decision text quoting D2/D3/D8.
4. **`docs/wave-0-plan.md`** **repeated** the "56 of 74"/"48 rows" figures in §0; with 57 flagged the split becomes 49 + 8 `?` (corrected in the reconciliation below).
5. The above are **documentation drift only** — no decision content, option set or owner is affected. They were left unedited in the Wave 1 step because the register and the Wave 0 plan are authoritative inputs whose change was not requested then.

**Reconciliation applied (items 1–4):**

| Drift | Where it was corrected |
|---|---|
| 1 + 2 — coverage count 56 → 57 | `docs/decision-register.md` §0.4 coverage check, Appendix A heading, the new `NFR-RATE-01 → D-49` row, and the `57 / 57` coverage line. All carry a rev-2 explanation. **No decision was created or resolved** — D-49 already existed and already named NFR-RATE-01 |
| 3 — stale D2 statement in D-49 | `docs/decision-register.md` › D-49 › `Current implementation` now states the original defect → the Wave 1 (W1-1) fix → the current state, and confirms **D-49 remains OPEN** with its options unchanged. The same distinction was added to **D-42** (forgot password) and to `docs/be-contract-request.md` **C-AUTH-06** and **C-RATE-01** |
| 4 — 56/48 figures in the plan | `docs/wave-0-plan.md` §0 now reads 57 of 74 / 8 / 49, §6.1 totals are re-derived (1 READY + 10 MAINTAIN + 41 BLOCKED BY DECISION + 22 BLOCKED BY BACKEND CONTRACT), §6.2 carries the Wave 1 exit state, and §5 P-04 records the current test baseline |
| 5 — statuses to keep consistent | Verified: FR-RATE-01 **A** · FR-RATE-04 **A** · FR-AUTH-05 **P** · FR-AUTH-03 **A** · NFR-AUTH-01 **A** · NFR-RATE-01 **X** across all four documents, with no source, test or backend change |

---

## Appendix — verification snapshot

```
flutter analyze            → 0 errors (68 pre-existing info/warnings repo-wide)
flutter test test/review_smoke_test.dart → 8 passed
flutter test               → 41 passed / 1 failed (test/widget_test.dart — pre-existing stub)
git status --short         →  M lib/controllers/auth_controller.dart
                              M lib/controllers/review_controller.dart
                              M lib/controllers/session_controller.dart
                              M lib/core/services/auth_service.dart
                              M lib/views/session/review_screen.dart
                              M lib/views/session/session_screen.dart
                              ?? test/review_smoke_test.dart
                              ?? docs/            (untracked: Wave 0 documents, RTM rev 2 and this report — no source impact)
```

The audited document set was **not** modified in a way that affects application behaviour: `docs/` gained this report and RTM rev 2, and `lib/` was not touched by this step (the 6 modified files above are the W1-1…W1-4 change set from the previous step, still uncommitted).

*End of report.*

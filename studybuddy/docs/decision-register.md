# Wave 0 — Decision Register

**Document type:** Formal decision register (Wave 0 baseline)
**Status:** Documentation only. **No decision in this file has been made.** No application source code was created, modified or deleted.
**Date:** 23 September 2026
**Revision:** rev 2 (23 Sep 2026) — Wave-1 documentation reconciliation: the RTM-coverage count was corrected to **57 / 57** (`NFR-RATE-01` added to Appendix A against the pre-existing **D-49**), and the `Current implementation` notes in **D-42** and **D-49** were updated to distinguish the original defect, the Wave 1 fix and the current state. **No decision was created, removed, re-worded, re-owned, re-classed or resolved, and no option set, blocking statement or status changed.** All 57 items remain as recorded.
**Sources used (only):**
1. *Software Requirements Specification for Study Buddy*, Version 1.0 `<approved>`, 06 Agustus 2026 (SRS) — §2.5 assumptions, §3.1 FR, §3.2 NFR, §4.1/4.2 data model, §6 roles, §7 release plan, §8 Open Issues & Assumptions Log.
2. `docs/requirement-traceability-matrix.md` (RTM) — status, gap, required change and the `Decision needed` column of all 74 requirements.
**Companion documents:** `docs/wave-0-plan.md`, `docs/be-contract-request.md`.

---

## 0. Rules applied when producing this register

1. **No decision is invented and no option is silently chosen.** Where the SRS offers no option, the entry reads exactly: *Decision required from product/founder/backend owner.*
2. Options are listed **only** where the SRS text itself supports them (e.g. FR-SESI-02 names "Varian A" and "Varian B"; NFR-PAY-03 gives the range "15–30 menit"; FR-SESI-07 names "±30 menit" and "+15 menit").
3. `Current implementation` describes what the code does **today** (evidence is a file › symbol). It is not a proposal.
4. Nothing here authorises implementation. A decision is only actionable once its `Final decision` field is filled in by the named owner.
5. Surplus modules not traceable to SRS v1.0 are marked **`UNRATIFIED — SRS DECISION REQUIRED`** and are not to be refactored, integrated or deleted while that mark stands (see D-12…D-16).

### 0.1 Status definitions

| Status | Meaning |
|---|---|
| **OPEN** | The decision can be taken now by the named owner. Nothing else has to land first. |
| **BLOCKED** | The decision cannot even be formulated yet because it depends on another decision. `Blocked by` names it. |
| **DECIDED** | A decision has been recorded in the `Final decision` field **and** ratified (none yet — all fields are intentionally blank). |

### 0.2 Owner codes used (derived from the SRS, never assumed)

| Code | Meaning | SRS basis |
|---|---|---|
| `FOUNDER` | Founder / CEO / Product owner | Bab 8 "Pihak yang Perlu Dikonfirmasi" = Founder |
| `COO/CFO` | Dimas (COO/CFO) | Bab 8 #5 |
| `ADMIN` | Study Buddy Admin (internal team, possibly CEO/COO merangkap) | §2.3, §2.5, Bab 8 #1 |
| `INT` | Internal dev team (Rifky & Raihana) | Bab 8 #6, #10, #11 |
| `FE` | Front-End / Design (Rifky) | §6 module split |
| `BE` | Back-End / data owner (Raihana) | §6 "Skema database & RLS seluruh modul" |
| `FOUNDER+INT` | Jointly, as listed by the SRS | Bab 8 #10, #11 |

### 0.3 §2.5 assumption coverage (each assumption is a decision)

| Assumption (SRS §2.5) | SRS status | Decision ID |
|---|---|---|
| Meet link distribution: ≥3 permanent links auto-attached | Tentatif | **D-03** |
| Session notification: automatic notification + "Booking Kamu" tab | Tentatif | **D-04** |
| Refund threshold: 5 hours before session | Tentatif | **D-05** |
| 70/30 split: automatic via system | Belum terjawab | **D-07** |
| QR SB provider: payment gateway (Midtrans/Xendit per RAB) | Belum terjawab | **D-08** |
| SMP minor protection: parental consent at registration | Belum terjawab | **D-09** |
| Admin dashboard form: in-app module for MVP | Belum diputuskan | **D-10** |
| Connection loss: replicate SOP ±30 min / +15 min compensation | Belum terjawab | **D-11** |

### 0.4 Summary of this register

| Group | IDs | Count | OPEN | BLOCKED |
|---|---|---|---|---|
| A. SRS Bab 8 open issues | D-01 … D-11 | 11 | 11 | 0 |
| B. Scope reconciliation (SRS v1.0 vs shipped modules) | D-12 … D-16 | 5 | 3 | 2 |
| C. Product / domain / UX decisions still open in the SRS | D-17 … D-44 | 28 | 19 | 9 |
| D. Backend / data contract decisions | D-45 … D-57 | 13 | 7 | 6 |
| **Total** | | **57** | **40** | **17** |

RTM coverage check: all **57** requirement rows that the RTM (rev 2) flags in its `Decision needed` column map to at least one decision ID (see Appendix A). No flagged row was dropped.
*Rev 2 correction:* the figure was 56 because the RTM's rev-1 row for `NFR-RATE-01` left its `Decision needed` cell blank even though **this register already defined a blocking decision for it (`D-49`, marked *"Blocks implementation? Yes"*)**. The RTM row now cites D-49 and the matching Appendix A row was added. This is a coverage-count correction only: **no new decision was created, and none was consumed or resolved.**

---

## A. SRS Bab 8 open issues (D-01 … D-11)

### D-01 — Tutor document verification flow (who verifies, SLA, automatic vs manual)
**Reqs:** FR-PROF-07, FR-PROF-08, FR-ADM-02 · **Class:** Product/SRS (Bab 8 #1) · **Owner (per SRS):** FOUNDER+ADMIN
**Current implementation:** `TutorModel.verificationStatus` / `rejectionReason` are dummy values; `views/shared/widgets/verification_badge.dart` renders the states; no actor can change a status (`controllers/profile_controller.dart` seeds a static "verified" Tutor).
**Why it matters:** FR-PROF-08 forbids a Tutor from receiving bookings before verification, and FR-ADM-02 requires Admin to change the status. Neither clause can be built until the actor, the queue and the turnaround are known. It also determines whether verification is a blocking gate in the Buddy journey or a background process.
**Options explicitly supported by the SRS:** (a) manual verification performed by Admin — this is the only actor the SRS names (FR-ADM-02). (b) Automatic verification: **not specified by the SRS** (Bab 8 #1 explicitly leaves "otomatis/manual" unanswered).
**Consequences:** (a) Admin becomes the bottleneck; an SLA is needed or Tutors can wait indefinitely with no published expectation. (b) If automation is later required, the data model and status lifecycle must already carry the fields for it, otherwise rework.
**Blocks implementation?** Yes — blocks FR-PROF-07, FR-PROF-08, FR-ADM-02 and D-22.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-02 — Tutor recommendation factors beyond rating
**Reqs:** FR-DISC-04, NFR-DISC-02 · **Class:** Product/SRS (Bab 8 #2) · **Owner (per SRS):** FOUNDER
**Current implementation:** `.order('rating', ascending: false)` duplicated in `controllers/tutor_controller.dart › fetchAllTutors` and `controllers/dashboard_controller.dart › _fetchOnlineTutors`; no scoring unit exists.
**Why it matters:** NFR-DISC-02 requires the algorithm's weights to be adjustable later **without changing the core data structure**. Today there is no weighted algorithm at all, only a stored-column sort, so there is nothing to adjust.
**Options explicitly supported by the SRS:** (a) rating-only ranking, as FR-DISC-04 states today. (b) Add further factors later — the SRS names one example only, "response rate" (NFR-DISC-02), with no weight and no rule.
**Consequences:** (a) Satisfies FR-DISC-04 immediately; NFR-DISC-02's extensibility requirement still has to be designed for. (b) Any additional factor changes what "recommended" means to users and can demote highly rated Tutors.
**Blocks implementation?** Partially — blocks the extensibility design for NFR-DISC-02, not the current rating sort (FR-DISC-04 is already aligned).
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-03 — Meet link distribution: Varian A vs Varian B
**Reqs:** FR-SESI-01, FR-SESI-02, and by dependency FR-SESI-03, D-32, D-39 · **Class:** Product/SRS (Bab 8 #3, §2.5) · **Owner (per SRS):** FOUNDER
**Current implementation:** `controllers/tutor_dashboard_controller.dart › gmeetLinks` holds 3 hardcoded, in-memory links editable through a dialog; nothing is attached to a booking; `views/session/session_screen.dart` passes `null` for the link in both branches of a dead ternary (RTM defect D1).
**Why it matters:** This single choice determines whether the product needs chat on day one, and whether the link flows automatically or manually. It also determines the shape of the Session data.
**Options explicitly supported by the SRS:** (a) **Varian A** — the system takes a link from at least 3 permanent Tutor links and attaches it automatically to the booking. (b) **Varian B** — the Tutor sends the link manually through the chat feature before the session starts.
**Consequences:** (a) Requires link storage plus a deterministic attachment rule (which link for which booking is **not specified by the SRS**), and does not depend on chat. (b) Makes chat (FR-SESI-03) a hard prerequisite for session delivery, and transfers a per-session manual action to the Tutor, risking late or missing links.
**Blocks implementation?** Yes — blocks FR-SESI-01, FR-SESI-02, FR-SESI-03 sequencing, D-32, D-39, D-57.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-04 — Session/booking notification mechanism
**Reqs:** FR-BOOK-06, FR-SESI-05 · **Class:** Product/SRS (Bab 8 #4, §2.5) · **Owner (per SRS):** FOUNDER
**Current implementation:** `core/services/notification_service.dart` exists (FCM token persistence, foreground local notification) but `NotificationService.initialize()` is **commented out** in `lib/main.dart`; no scheduling, no in-app notification surface; the bell icon in `dashboard_screen.dart` is decorative.
**Why it matters:** FR-BOOK-06 requires confirmation to both parties and FR-SESI-05 requires the session link/reminder to reach them; both clauses are unbuildable until delivery is chosen. It also decides whether the client needs a background/notification permission flow at all.
**Options explicitly supported by the SRS:** (a) automatic notification. (b) The in-app "Booking Kamu" tab as the delivery surface. (c) Both — the SRS presents the two as a combination. For timing, the SRS records one considered option: **1 hour before the session** (explicitly tentative).
**Consequences:** (a) Push requires a server-side sender and device-token lifecycle; delivery is best-effort and needs permissions. (b) In-app only means users who do not open the app are never reminded, and FR-BOOK-06's "send confirmation" is only nominally met. (c) Most work, best coverage.
**Blocks implementation?** Yes — blocks FR-BOOK-06 and FR-SESI-05.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-05 — Refund threshold
**Reqs:** FR-PAY-04, FR-BOOK-08 · **Class:** Product/SRS (Bab 8 #5, §2.5) · **Owner (per SRS):** COO/CFO
**Current implementation:** None. `controllers/payment_controller.dart › requestRefund` only shows a snackbar; no threshold, no calculation, no record.
**Why it matters:** The threshold *is* the refund rule; FR-BOOK-08's cancellation consequences and FR-PAY-05's request flow both hang off it. It also has a direct financial cost implication per cancelled session.
**Options explicitly supported by the SRS:** The SRS states one value as a **tentative** default: cancellation more than **5 hours** before the session gets a full refund; less than 5 hours gets none (FR-PAY-04, Bab 8 #5, explicitly not final).
**Consequences:** A longer window is friendlier to Buddies but increases refund exposure and Tutor cancellation loss; a shorter window reduces exposure but may be perceived as unfair. Whatever value is chosen must be stored in a single place, since the RTM shows the codebase already contains an unrelated, unratified 5-hour **booking lead-time** rule (`core/utils/date_utils.dart › isBookingTimeValid`).
**Blocks implementation?** Yes — blocks FR-PAY-04 and FR-BOOK-08.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-06 — QR expiry window
**Reqs:** NFR-PAY-03, and by dependency FR-BOOK-04 / NFR-BOOK-01 (slot lock lifetime) · **Class:** Product + internal · **Owner (per SRS):** INT
**Current implementation:** `controllers/payment_controller.dart › _startCountdown` runs a **client-side 15-minute** countdown and flips the invoice to `expired`; the accompanying copy claims the slot is reopened, but no slot is ever locked or reopened.
**Why it matters:** Expiry is what prevents an unpaid slot from being held forever. It is also the natural expiry for the slot reservation (RTM D-40), so it must be settled together with the locking design, and it must be owned server-side to be trustworthy.
**Options explicitly supported by the SRS:** The SRS gives a **range**: 15–30 minutes, and states the exact value "perlu disepakati tim" (NFR-PAY-03).
**Consequences:** A short window frees slots quickly but pressures users to complete payment; a long window holds inventory. Client-side-only expiry can be bypassed by not running the app.
**Blocks implementation?** Yes — blocks NFR-PAY-03 and D-40.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-07 — 70/30 revenue split: automatic vs manual
**Reqs:** FR-PAY-06, and by dependency FR-PAY-07 · **Class:** Product/SRS (Bab 8 #7, §2.5) · **Owner (per SRS):** FOUNDER
**Current implementation:** No split logic anywhere. The unratified Payroll module (`controllers/payroll_controller.dart`) displays dummy per-session amounts that already imply a Tutor share, and `models/payroll_model.dart` states in a comment that `ratePerSession` "sudah bagian 70% Tutor".
**Why it matters:** It decides whether the system must calculate and instruct payouts, or merely record entitlements for a human. It also determines what FR-ADM-03 must display and whether any payout-integration work exists at all.
**Options explicitly supported by the SRS:** (a) automatic via the system — the SRS's stated assumption, to be revised if it turns out to be manual. (b) manual by admin — named only as the alternative that would force a revision.
**Consequences:** (a) Requires entitlement records plus a payout mechanism, and reconciliation when refunds and cancellations occur. (b) Keeps finance manual but still requires per-transaction entitlement records for monitoring, so the recording work exists either way.
**Blocks implementation?** Yes — blocks FR-PAY-06, and blocks the design of FR-PAY-07 / D-31.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-08 — Payment provider behind QR SB
**Reqs:** FR-PAY-01, FR-PAY-02, NFR-PAY-02, and by dependency NFR-PAY-01, D-54, D-40 · **Class:** Product/SRS (Bab 8 #8, §2.5) · **Owner (per SRS):** FOUNDER
**Current implementation:** No gateway integration. `views/customer/invoice_screen.dart` renders an icon placeholder and asserts the provider in user-facing copy ("Scan QRIS Dynamic (ShopeePay)"); `controllers/payment_controller.dart › checkPaymentStatus` simulates success after a 600 ms delay; a code comment refers to a "webhook ShopeePay Merchant".
**Why it matters:** It determines whether the client needs QR generation, a status-polling or callback path, and webhook handling (NFR-PAY-02 is conditional on a third-party gateway being used). **The shipped copy currently asserts a provider that the SRS never names** — this must be corrected either way.
**Options explicitly supported by the SRS:** (a) QR SB processed through a third-party payment gateway — the SRS's tentative assumption names Midtrans/Xendit as the class, per the approved RAB. (b) QR SB not processed via a third-party gateway — NFR-PAY-02's wording ("Jika QR SB ternyata diproses melalui payment gateway pihak ketiga") leaves this open, and the mechanism is otherwise **not specified by the SRS**.
**Consequences:** (a) Requires gateway onboarding, credentials, QR/charge creation, callback verification and idempotency. (b) Removes webhook obligations but leaves the status source undefined, which FR-PAY-02 still requires.
**Blocks implementation?** Yes — blocks FR-PAY-01, FR-PAY-02, NFR-PAY-02, and decisively shapes D-53/D-54.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-09 — SMP / minor parental consent
**Reqs:** NFR-AUTH-03, NFR-PROF-04, FR-AUTH-02 (age/grade capture) · **Class:** Product/SRS (Bab 8 #9, §2.5) · **Owner (per SRS):** FOUNDER
**Current implementation:** Nothing. No consent step, no age gate, not even the "integration point" NFR-AUTH-03 asks for; `age` is captured in the profile edit sheet only and used nowhere.
**Why it matters:** NFR-AUTH-03 asks for an integration point now and defers the full implementation; Bab 8 #9 leaves the approach unanswered. It affects registration flow, data retention and whether SMP registration should be gated at all.
**Options explicitly supported by the SRS:** (a) provide an integration point only; full consent deferred until the founder decides (this is literally what NFR-AUTH-03 states). (b) Full parental-consent mechanism at registration (named as the candidate requirement in §2.5, to be revised per founder decision).
**Consequences:** (a) Keeps MVP scope small but ships a product serving minors without consent, with the legal exposure unresolved. (b) Adds friction and a verification problem (how consent is evidenced is **not specified by the SRS**).
**Blocks implementation?** Yes — blocks NFR-AUTH-03 and NFR-PROF-04.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-10 — Admin dashboard form (web vs in-app)
**Reqs:** FR-ADM-01, FR-ADM-02, FR-ADM-03, FR-ADM-04, NFR-ADM-01 · **Class:** Product/SRS (Bab 8 #10, §2.5) · **Owner (per SRS):** FOUNDER+INT
**Current implementation:** Absent. No Admin route, screen, role branch or guard; `'management'` appears only as a comment in `models/user_model.dart`.
**Why it matters:** All four Admin requirements and the Admin RLS role depend on it. Choosing a separate web panel contradicts the §2.5 assumption and implies infrastructure the approved budget does not cover; choosing an in-app module keeps the work inside the Flutter client but exposes operational features on a shared mobile build.
**Options explicitly supported by the SRS:** (a) a separate web Admin panel. (b) a separate module inside the same application, for MVP, because the RAB has no separate admin hosting allocation (the §2.5 assumption). Bab 8 #10 states the choice is **undecided**.
**Consequences:** (a) New deployment, new credentials, new stack work, outside the current RAB assumption. (b) Faster to ship and consistent with the budget assumption, but Admin capabilities ship to the same store build and must be protected by role checks and RLS.
**Blocks implementation?** Yes — blocks FR-ADM-01…04, NFR-ADM-01, D-41, D-56.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-11 — Automating connection-loss handling
**Reqs:** FR-SESI-07 · **Class:** Product/SRS (Bab 8 #11, §2.5) · **Owner (per SRS):** FOUNDER+INT
**Current implementation:** Nothing. No tolerance window, no compensation mechanism, no absence handling. (The unratified Reschedule module implements unrelated policy and must not be treated as this feature.)
**Why it matters:** The clause is conditional ("sebaiknya") and automation is undetermined, so the current manual SOP cannot be translated into rules without a decision. It also intersects refunds (D-05) and rescheduling.
**Options explicitly supported by the SRS:** Replicate the current manual SOP as system rules: (a) ±30 minutes wait tolerance; (b) optional +15 minutes compensation (additional time); (c) rescheduling if the session is cancelled entirely. The SRS lists these as the SOP content, with automation left open.
**Consequences:** (a)/(b) Requires attendance tracking and evidence of who was absent to avoid disputes. (c) Overlaps the refund and reschedule policies, so the three must be consistent. Doing nothing leaves FR-SESI-07 unmet but is explicitly permitted by its own wording until decided.
**Blocks implementation?** Yes — blocks FR-SESI-07.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

---

## B. Scope reconciliation — SRS v1.0 vs shipped modules (D-12 … D-16)

> These five decisions are about **scope truth**, not about code quality. The modules exist in the UI but have no requirement in SRS v1.0 (RTM §1.2 and §7). Until decided, each is marked **`UNRATIFIED — SRS DECISION REQUIRED`**: do not refactor, do not integrate, do not delete.

### D-12 — Package / Token module
**Reqs affected:** none in SRS v1.0 (code cites `FR-PKG-01..07` and "SRS 3.4") · **Class:** Scope · **Owner (per SRS):** FOUNDER
**Current implementation:** `models/package_model.dart`, `models/token_model.dart`, `controllers/package_controller.dart` (dummy catalogue + dummy token), `views/customer/package_screen.dart`, `views/customer/my_tokens_screen.dart`, `views/shared/widgets/package_card.dart`; entry points from the customer dashboard, and `grantToken()` is invoked from `views/customer/package_screen.dart` on payment success. **Status: `UNRATIFIED — SRS DECISION REQUIRED`.**
**Why it matters:** A token/package model changes the commercial model of the whole product — sessions can be prepaid, consumed, expire and be subject to their own refund rules. It therefore changes Payment (FR-PAY-01/02/05), Booking (FR-BOOK-08), the invoice shape and possibly Rating (which session is being rated).
**Options explicitly supported by the SRS:** **None.** SRS v1.0 contains no package, bundling or token requirement, and §4.1 lists no such entity. Options must come from a new SRS revision.
**Consequences:** Ratifying adds entities, rules (validity, consume-on-booking, refundability) and new failure paths; not ratifying leaves four shipped screens with no specification and no target architecture, and they must not be extended meanwhile.
**Blocks implementation?** Yes — it gates D-15, D-16, D-30 and any Wave 3 payment design that would otherwise be built around a single-booking payment model.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-13 — Reschedule module
**Reqs affected:** none in SRS v1.0 (code cites `FR-RESCH-01..09`); it overlaps FR-BOOK-08 and FR-PAY-04 · **Class:** Scope · **Owner (per SRS):** FOUNDER
**Current implementation:** `models/reschedule_model.dart`, `controllers/reschedule_controller.dart` (dummy requests; policy constants `thresholdHours = 6`, `maxPostponeDays = 2`), `views/customer/reschedule_screen.dart`, reachable from `views/customer/schedule_screen.dart`. **Status: `UNRATIFIED — SRS DECISION REQUIRED`.**
**Why it matters:** Its policy set (H-6 hours, max +2 days, switch-Tutor requiring admin approval, reschedule quota) is **not** in SRS v1.0 and conflicts conceptually with the refund threshold (D-05) and with the unratified package quota (D-12). Two parallel policies for changing a session would confuse users and support.
**Options explicitly supported by the SRS:** **None.** SRS v1.0 treats a Buddy changing plans only through booking cancellation and refund (FR-BOOK-08, FR-PAY-04).
**Consequences:** Ratifying means two distinct mechanisms (cancel+refund vs reschedule) need a single coherent policy and quota model tied to D-12; not ratifying leaves a shipped screen that contradicts the SRS's only authorised plan-change path.
**Blocks implementation?** Yes — blocks D-33 and the policy design of FR-BOOK-08.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-14 — Payroll module
**Reqs affected:** none in SRS v1.0 (code cites `FR-PAYR-01..07`); it overlaps FR-PAY-06 and FR-PAY-07 · **Class:** Scope · **Owner (per SRS):** FOUNDER
**Current implementation:** `models/payroll_model.dart`, `controllers/payroll_controller.dart` (dummy periods, deductions, transfer status), `views/tutor/payroll_screen.dart`, `views/tutor/slip_gaji_screen.dart`, reached from the Tutor dashboard stat card. **Status: `UNRATIFIED — SRS DECISION REQUIRED`.**
**Why it matters:** FR-PAY-07 does require the Tutor to see income history, so *some* earnings surface is in scope — but the payroll period/slip/deduction model is not. If Payroll is ratified, the earnings surface depends on D-07's payout model; if not, FR-PAY-07 must be implemented as a simpler per-transaction view.
**Options explicitly supported by the SRS:** (a) A Tutor income history as FR-PAY-07 states ("riwayat pendapatan"). (b) A payroll-period model with slips — **not specified by the SRS**.
**Consequences:** (a) Small, sufficient for the requirement, no dependency on payout automation. (b) Needs period definitions, transfer tracking, deduction rules and reconciliation with D-07 — all currently invented.
**Blocks implementation?** Yes — blocks the design of FR-PAY-07 (D-31).
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-15 — Multi-session invoice and discount
**Reqs affected:** FR-PAY-01, FR-PAY-02, FR-PAY-03 (SRS describes one Payment per Booking, 1:1 per §4.2) · **Class:** Scope + backend · **Owner (per SRS):** FOUNDER
**Current implementation:** `models/invoice_model.dart` carries `List<InvoiceSessionItem>` and a `discount` field, and totals are derived (`subtotal`, `total`). Invoices are generated in memory by `controllers/payment_controller.dart › generateInvoice`; `views/customer/package_screen.dart` reuses the same invoice for a package purchase with `tutorName: '-'`. **Status: `UNRATIFIED — SRS DECISION REQUIRED`.**
**Why it matters:** SRS §4.2 fixes `Booking → Payment` as **1 to 1**, and FR-PAY-01 issue QR SB "setelah Buddy memilih slot booking" (one slot). Multi-session invoicing exists only to serve the unratified package module, so it cannot be designed before D-12.
**Options explicitly supported by the SRS:** (a) one payment per booking, as §4.2 states. (b) Multi-session invoicing — **not specified by the SRS**.
**Consequences:** (a) Simplifies the payment entity and matches the data model; packages (if ratified) would need their own payment shape. (b) Requires redefining the Booking↔Payment cardinality in the SRS itself.
**Blocks implementation?** Yes — blocks the payment entity design.
**Status:** BLOCKED · **Blocked by:** D-12
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-16 — Pricing model (`pricePerHour`) not defined by the SRS
**Reqs affected:** FR-PAY-01, FR-PAY-02, FR-PAY-03, FR-ADM-03 · **Class:** Scope + product · **Owner (per SRS):** FOUNDER
**Current implementation:** `models/tutor_model.dart › pricePerHour`; `views/customer/booking_screen.dart › _goToInvoice` computes `price = tutor.pricePerHour * durationMinutes / 60`; `views/shared/widgets/tutor_card.dart` and `views/customer/tutor_detail_screen.dart` advertise "Rp…rb/jam". **Status: `UNRATIFIED — SRS DECISION REQUIRED`.**
**Why it matters:** The SRS specifies **no price attribute anywhere** — §4.1 lists TutorProfile key attributes as `user_id, bio, mata_pelajaran, status_verifikasi`, and no FR mentions tariffs. Yet the amount charged, the invoice, the 70/30 split (FR-PAY-06) and the Admin revenue summary (FR-ADM-03) all depend on it. This is currently a client-side invention driving money.
**Options explicitly supported by the SRS:** **None.**
**Consequences:** Whatever is chosen becomes the basis of tutor earnings, refunds and revenue reporting; changing it later invalidates historical amounts. It is also entangled with D-12 (package pricing) and D-07 (split).
**Blocks implementation?** Yes — blocks correct implementation of FR-PAY-01/02/03 amounts and FR-ADM-03.
**Status:** BLOCKED · **Blocked by:** D-12
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

---

## C. Product / domain / UX decisions still open in the SRS (D-17 … D-44)

### D-17 — Tutor document catalogue conflict
**Reqs:** FR-PROF-05, FR-PROF-06, FR-PROF-08 · **Class:** Product/domain · **Owner (per SRS):** FOUNDER
**Current implementation:** `controllers/profile_controller.dart › _dummyDocuments` lists **six** documents — transkrip (required), KTM/KTS (required), sertifikat bahasa (conditional), **skor UTBK (conditional)**, **sertifikat prestasi (optional)**, **CV/Portfolio (optional)** — rendered by `views/shared/widgets/document_tile.dart`.
**Why it matters:** The required set determines what the verification gate (FR-PROF-08, D-01) actually waits for, and FR-PROF-06's required/optional distinction is meaningless if the classification is wrong.
**Options explicitly supported by the SRS:** (a) Exactly four documents with the SRS classification: transkrip (wajib), kartu identitas pelajar — KTM for students / Kartu Tanda Pelajar-Siswa for SMA (wajib), sertifikat prestasi akademik/non-akademik (wajib), sertifikat bahasa (khusus jika Tutor mengajar kelas bahasa asing). (b) Additional documents (UTBK score, CV) — **not specified by the SRS**.
**Consequences:** (a) Conforms, but some Tutors may have no achievement certificate to submit — note the SRS lists it as required even though it calls the document set "fleksibel"; a fallback rule is **not specified by the SRS**. (b) Requires an SRS revision and re-opens the verification gate definition.
**Blocks implementation?** Yes — blocks FR-PROF-05, FR-PROF-06 and the gate in FR-PROF-08.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-18 — "Umum" grade option conflict
**Reqs:** FR-AUTH-06 (with FR-PROF-01 display) · **Class:** Product/domain · **Owner (per SRS):** FOUNDER
**Current implementation:** `views/customer/profile_screen.dart` offers exactly five options: `SMP`, `SMA/sederajat`, `Mahasiswa (S1)`, `Lulusan`, **`Umum`**.
**Why it matters:** FR-AUTH-06 permits only SMP, SMA/sederajat, Mahasiswa (S1) or Lulusan, and explicitly excludes SD. An extra value means the system accepts a grade level the SRS does not allow, which then propagates into discovery filters (FR-DISC-03) and any future age-related rule (D-09).
**Options explicitly supported by the SRS:** (a) Remove `Umum` and enforce the four permitted values. (b) Ratify `Umum` as a fifth value through an SRS revision — **not supported by SRS v1.0**.
**Consequences:** (a) Conforms immediately; any user already assigned `Umum` would need remapping (data question, see D-45). (b) Keeps the current UX but diverges from FR-AUTH-06 and complicates the SMP-minor rules.
**Blocks implementation?** Yes — blocks FR-AUTH-06.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-19 — Role vocabulary (`customer`/`tutor` vs `Buddy`/`Tutor`)
**Reqs:** FR-AUTH-01, §4.1 `User.role` · **Class:** Product/domain · **Owner (per SRS):** FOUNDER (+BE)
**Current implementation:** `models/user_model.dart` documents `'customer' | 'tutor' | 'management'`; `views/auth/register_screen.dart` sends `customer`/`tutor`; `controllers/auth_controller.dart › _redirectByRole` branches on `'tutor'`; `core/services/auth_service.dart › signUp` writes the same values.
**Why it matters:** The role identifier is the key that every authorisation decision reads — routing today, and RLS policies later (NFR-ADM-01). Two vocabularies at once (SRS terms in documents, code terms in data) invites mismatched checks.
**Options explicitly supported by the SRS:** (a) Use the SRS terms verbatim (`Buddy`, `Tutor`, `Admin` — §1.3 and FR-AUTH-01). (b) Keep code terms and maintain one authoritative mapping to the SRS terms — **not specified by the SRS**.
**Consequences:** (a) Requires consistent terminology everywhere and a data migration if any rows exist. (b) Less churn now, but the mapping must be enforced at every boundary (client, database, RLS), which is where drift appears.
**Blocks implementation?** Yes — blocks FR-AUTH-01 cleanliness, D-21, D-25, NFR-ADM-01.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-20 — Booking lifecycle: `pending` vs fully confirmed after payment
**Reqs:** FR-BOOK-03, FR-PAY-03, FR-SESI-06, FR-BOOK-06 · **Class:** Product/domain · **Owner (per SRS):** FOUNDER
**Current implementation:** `views/customer/booking_screen.dart › _goToInvoice` builds the invoice and passes `onPaid: () => ctrl.createBooking(...)`; `controllers/booking_controller.dart › createBooking` inserts `'status': 'pending'`; `views/tutor/tutor_dashboard_screen.dart` then offers **Konfirmasi/Tolak** for pending bookings. Payment success is simulated.
**Why it matters:** FR-BOOK-03 says a Buddy books a slot **without waiting for manual Tutor confirmation**, while FR-PAY-03 says a booking is fully confirmed once payment succeeds. The current `pending` + manual confirm step contradicts FR-BOOK-03 and makes FR-PAY-03's "terkonfirmasi penuh" untrue. Everything downstream — notification content (FR-BOOK-06), displayed statuses (FR-SESI-06) and cancellation rules (FR-BOOK-08) — depends on which lifecycle is correct.
**Options explicitly supported by the SRS:** (a) Confirmed automatically on successful payment (FR-PAY-03), with no manual Tutor confirmation (FR-BOOK-03). (b) Retain a manual Tutor confirmation step in some cases — **not supported by SRS v1.0**.
**Consequences:** (a) Matches both clauses and removes a wait state; the Tutor loses the ability to decline a slot and all changes flow through cancellation/refund rules (D-05, D-13). (b) Keeps today's dashboard behaviour but leaves FR-BOOK-03 unmet and requires an extra status with its own timeouts.
**Blocks implementation?** Yes — blocks FR-BOOK-03, FR-PAY-03, D-28, and the notification content in FR-BOOK-06.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-21 — Canonical Admin role identifier
**Reqs:** NFR-ADM-01, FR-ADM-01…04, §4.1 `User.role` · **Class:** Product/domain · **Owner (per SRS):** FOUNDER (+BE)
**Current implementation:** Only the string `'management'` appears, and only inside a comment in `models/user_model.dart`; nothing in the app branches on it.
**Why it matters:** The identifier must be agreed before RLS policies and client guards are written, because changing it later means touching every authorisation rule and any stored rows.
**Options explicitly supported by the SRS:** (a) `Admin`, as named throughout the SRS (§1.3, §2.3, FR-ADM, NFR-ADM-01). (b) `management`, as the code comment suggests — **not specified by the SRS**.
**Consequences:** (a) Consistent with the SRS and unambiguous versus Buddy/Tutor. (b) Requires a documented justification and still needs to be mapped to the SRS term in documents, repeating D-19's problem.
**Blocks implementation?** Yes — blocks NFR-ADM-01 and D-56.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-22 — Tutor verification ownership, status lifecycle and permissions
**Reqs:** FR-PROF-07, FR-PROF-08, FR-PROF-09, FR-ADM-02 · **Class:** Product/domain · **Owner (per SRS):** FOUNDER+ADMIN
**Current implementation:** Three statuses exist as strings (`'pending' | 'verified' | 'rejected'`) plus document-level values (`belum_upload`, `menunggu`, `terverifikasi`, `ditolak`) mapped in `views/shared/widgets/verification_badge.dart`; `controllers/profile_controller.dart › uploadDocument` resets a document to `menunggu` with the sentinel URL `'pending-upload'`. No transition is possible anywhere, and FR-PROF-08's gate is not enforced.
**Why it matters:** This defines (i) which states exist and who may set them, (ii) what happens when an approved Tutor replaces or adds a certificate (FR-PROF-09 permits this "kapan saja setelah verifikasi awal"), and (iii) exactly what "cannot receive booking" forbids (FR-PROF-08) — hidden from search, blocked at booking, or both.
**Options explicitly supported by the SRS:** (a) Post-verification certificate additions do **not** re-trigger verification (FR-PROF-09's wording: editable after initial verification). (b) Replacement re-triggers verification — **not specified by the SRS**. For the gate, the SRS states only the outcome ("tidak dapat menerima booking"); the mechanism is **not specified by the SRS**.
**Consequences:** (a) Keeps the Tutor unblocked but means unverified new documents are visible to Buddies. (b) Safer for quality but removes a stated self-service guarantee. The gate mechanism choice changes discovery queries and booking validation.
**Blocks implementation?** Yes — blocks FR-PROF-07/08/09 and the Admin verification action.
**Status:** BLOCKED · **Blocked by:** D-01, D-21
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-23 — Grade-levels-taught data shape
**Reqs:** FR-PROF-04, FR-DISC-03 · **Class:** Product/domain · **Owner (per SRS):** FOUNDER (+BE)
**Current implementation:** `models/tutor_model.dart` has `subjects` only; there is no taught-grade field, so the FR-DISC-03 filter has nothing to filter. The Buddy-side grade list (D-18) is a separate, unrelated field.
**Why it matters:** FR-PROF-04 requires the Tutor to declare "jenjang yang bisa diajar" and FR-DISC-03 requires filtering by it. **The two clauses list different value sets**: FR-PROF-04 says "jenjang yang bisa diajar" without enumerating, while FR-DISC-03 enumerates only SMP/SMA/Mahasiswa — omitting "Lulusan", which FR-AUTH-06 does allow. That inconsistency must be resolved or the filter and the profile will disagree.
**Options explicitly supported by the SRS:** (a) Reuse FR-AUTH-06's four values (SMP, SMA/sederajat, Mahasiswa (S1), Lulusan). (b) Use FR-DISC-03's narrower set (SMP/SMA/Mahasiswa). The SRS supports both readings and does not reconcile them.
**Consequences:** (a) One shared vocabulary across Buddy and Tutor sides; the FR-DISC-03 list must be widened (an SRS revision). (b) Follows FR-DISC-03 literally but cannot express a Tutor who teaches graduates.
**Blocks implementation?** Yes — blocks FR-PROF-04 and FR-DISC-03.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-24 — Profile photo and its storage contract
**Reqs:** FR-PROF-01 (foto profil), FR-PROF-10 (foto on the public profile) · **Class:** Backend contract · **Owner (per SRS):** BE
**Current implementation:** `models/user_model.dart › avatarUrl` and `models/tutor_model.dart › avatarUrl` exist; `core/constants/supabase_constants.dart › bucketAvatars` names a bucket; both profile screens render an initial-letter placeholder instead of an image; no upload path exists.
**Why it matters:** The SRS requires a profile photo on both screens but specifies **no** bucket, access rule, format or size limit for avatars (NFR-PROF-02/03 apply to Tutor *documents*, not avatars). Without a contract the client cannot implement it without inventing rules.
**Options explicitly supported by the SRS:** **None** for avatars.
**Consequences:** Freezing an invented avatar policy risks a public-by-default bucket or unsupported sizes; waiting leaves a required field as a placeholder.
**Blocks implementation?** Yes — blocks the photo parts of FR-PROF-01 and FR-PROF-10.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-25 — Role source of truth
**Reqs:** FR-AUTH-01, FR-AUTH-07, NFR-AUTH-02 · **Class:** Backend contract · **Owner (per SRS):** BE (+FOUNDER)
**Current implementation:** Two sources. `controllers/auth_controller.dart › _redirectByRole` reads the role from the `users` row returned by `AuthService.getCurrentUser`; `views/auth/splash_screen.dart › _checkSession` reads `session.user.userMetadata['role']` straight from the auth session (RTM §1.4 D9/D10).
**Why it matters:** Two sources can disagree — the classic case being metadata set at sign-up and never updated. The reader that wins determines the landing screen today and the permission basis later; RLS will read the database value.
**Options explicitly supported by the SRS:** (a) The database record is authoritative (consistent with RLS expecting a stored role). (b) Auth metadata is authoritative. (c) Both, kept synchronised — **not specified by the SRS**.
**Consequences:** (a) Requires the client to always read the profile record and to handle absence. (b) Avoids a query but risks drift from RLS. (c) Most complex, needs a sync guarantee that does not exist client-side.
**Blocks implementation?** Yes — blocks FR-AUTH-07 and any role-based guard.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-26 — Buddy onboarding content ("lengkapi profil dasar")
**Reqs:** FR-AUTH-07 · **Class:** Product/UX · **Owner (per SRS):** FOUNDER
**Current implementation:** `controllers/auth_controller.dart › _redirectByRole` sends every non-Tutor to the dashboard; no onboarding screen or step exists. The Tutor path shows only a static warning banner in `views/auth/register_screen.dart`.
**Why it matters:** FR-AUTH-07 requires distinct role-based onboarding but does not define the Buddy steps, their content, or whether they are mandatory. Skipping this decision produces either an empty screen or an invented requirement.
**Options explicitly supported by the SRS:** (a) Buddy is guided to complete the basic profile (FR-PROF-01 fields) before reaching the dashboard. (b) Onboarding is informational only. Whether it is blocking is **not specified by the SRS**.
**Consequences:** (a) Better profile completeness for discovery and quoting, but adds friction immediately after sign-up. (b) Least work, weakest interpretation of FR-AUTH-07.
**Blocks implementation?** Yes — blocks FR-AUTH-07.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-27 — Achievement badge criteria ("misal Top Tutor")
**Reqs:** FR-PROF-10 · **Class:** Product/domain · **Owner (per SRS):** FOUNDER
**Current implementation:** `models/tutor_model.dart › isTutorOfTheMonth` (a dummy `true`) rendered as "⭐ Tutor of the Month" on the Tutor's **own** screen (`views/tutor/tutor_profile_screen.dart`) only; nothing on the public profile.
**Why it matters:** FR-PROF-10 requests the badge "jika ada" (if any), so its absence is permitted — but the existing label ("Tutor of the Month") and flag imply a rule that does not exist anywhere, and a badge shown only to the Tutor satisfies no clause.
**Options explicitly supported by the SRS:** (a) A public achievement badge/label, with the SRS offering only an example name ("Top Tutor"). (b) No badge for MVP, since the clause is conditional. The criteria are **not specified by the SRS**.
**Consequences:** (a) Requires a computable criterion or a manual flag, plus a decision on who awards it. (b) Nothing to build now; the existing dummy flag should be treated as unratified.
**Blocks implementation?** No — FR-PROF-10's other fields are separately blocked (D-24 for the photo); the badge clause is conditional.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-28 — Mapping between the four SRS session states and current fields
**Reqs:** FR-SESI-06 (with FR-BOOK-07, FR-BOOK-09, NFR-BOOK-02) · **Class:** Product/domain · **Owner (per SRS):** FOUNDER (+BE)
**Current implementation:** Two vocabularies: `models/booking_model.dart` uses `pending | confirmed | ongoing | done | cancelled`, `models/session_model.dart` uses `active | ended`, and `views/shared/widgets/status_badge.dart` translates the booking values into Indonesian labels (`Menunggu`, `Dikonfirmasi`, `Berlangsung`, `Selesai`, `Dibatalkan`). `views/session/session_screen.dart` hardcodes "Sesi Sedang Berlangsung".
**Why it matters:** FR-SESI-06 defines exactly four states — Terjadwal, Sedang Berlangsung, Selesai, Dibatalkan. The current model carries a fifth (`pending`) that has no SRS meaning, and it depends directly on D-20. Admin monitoring (FR-ADM-01) also lists these four states, so the mapping must be settled before that surface is designed.
**Options explicitly supported by the SRS:** (a) Map the stored lifecycle to the four SRS states, with no separate `pending` state if D-20 resolves to automatic confirmation. (b) Store the SRS terms directly. The choice between (a) and (b) is **not specified by the SRS**.
**Consequences:** (a) Minimal data churn, needs a documented mapping in one place. (b) Cleanest semantics, but it is a stored-value change and touches every screen and any existing rows.
**Blocks implementation?** Yes — blocks FR-SESI-06, FR-BOOK-07's status display and FR-ADM-01's status filter.
**Status:** BLOCKED · **Blocked by:** D-20, D-19
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-29 — "Booking Kamu" surface and its placement
**Reqs:** FR-BOOK-07, FR-SESI-05 (the link is offered there as an alternative) · **Class:** Product/UX · **Owner (per SRS):** FOUNDER, design by FE
**Current implementation:** `views/customer/schedule_screen.dart` is titled "Jadwal Saya" and is pushed from the customer bottom navigation (`views/customer/dashboard_screen.dart › _onNavTap`, index 2).
**Why it matters:** FR-BOOK-07 names the surface ("tab/halaman 'Booking Kamu'"), and FR-SESI-05 offers it as a place the session link can be found. The name and placement are small but user-visible, and the surface is also the natural home for booking detail (FR-BOOK-09).
**Options explicitly supported by the SRS:** The SRS names the label and the reference (KAI Access) but not the navigation pattern or whether it is a tab versus a page. **Decision required from product/founder/backend owner** for the pattern; copy and layout are FE-owned per §6.
**Consequences:** Renaming/restructuring touches the bottom navigation and the existing tests that reference the screen; keeping the current label leaves FR-BOOK-07's naming unmet but functional.
**Blocks implementation?** No — but it must be settled before FR-BOOK-07/09 UI work is finalised.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-30 — Refund request flow: states, approval owner, relation to package categories
**Reqs:** FR-PAY-05, FR-PAY-04, FR-BOOK-08 · **Class:** Product/backend · **Owner (per SRS):** FOUNDER (+BE)
**Current implementation:** `views/customer/transaction_history_screen.dart › _openRefundSheet` shows four hardcoded reasons (`Berubah pikiran`, `Jadwal bentrok`, `Salah pilih Tutor`, `Lainnya`) and calls `controllers/payment_controller.dart › requestRefund`, which only shows a snackbar saying finance is processing it.
**Why it matters:** FR-PAY-05 requires a submission flow (explicitly not an automatic payout) with a Shopee/TikTok-style reference. Nothing exists to track a request, and the RTM flags a relationship to package categories — which itself depends on D-12.
**Options explicitly supported by the SRS:** The SRS supports only the general shape: a Buddy-initiated request that is reviewed. The request states, the approver, the SLA and the reason taxonomy are **not specified by the SRS**.
**Consequences:** Without defined states, support cannot tell a user where their refund is; without an owner, requests have nowhere to go. If packages are ratified (D-12), refund rules must also cover unused tokens and non-refundable bundles.
**Blocks implementation?** Yes — blocks FR-PAY-05 and the refund half of FR-BOOK-08.
**Status:** BLOCKED · **Blocked by:** D-12, D-05
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-31 — Tutor earnings surface scope
**Reqs:** FR-PAY-07 (Tutor side) · **Class:** Product/domain · **Owner (per SRS):** FOUNDER
**Current implementation:** `controllers/payroll_controller.dart` serves dummy periods to `views/tutor/payroll_screen.dart` and `views/tutor/slip_gaji_screen.dart`; the Tutor dashboard shows a dummy "Pendapatan Bulan Ini".
**Why it matters:** FR-PAY-07 does require a Tutor income history, so the surface is in scope — but its shape depends on whether Payroll is ratified (D-14) and on how the split is handled (D-07).
**Options explicitly supported by the SRS:** (a) A per-transaction earnings history ("riwayat pendapatan"). (b) Periodic slips/periods — **not specified by the SRS**.
**Consequences:** (a) Directly satisfies FR-PAY-07 with minimal rules. (b) Requires period, deduction and transfer semantics that exist nowhere in the SRS.
**Blocks implementation?** Yes — blocks the design of FR-PAY-07.
**Status:** BLOCKED · **Blocked by:** D-14, D-07
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-32 — Chat mechanics (transport, storage, retention, moderation)
**Reqs:** FR-SESI-03, FR-SESI-04, NFR-SESI-03 · **Class:** Product/backend · **Owner (per SRS):** FOUNDER (+BE)
**Current implementation:** Absent. No chat entity (SRS §4.1 lists `ChatMessage` but the codebase has no model), no UI, no transport. `views/session/session_screen.dart` shows a timer for `chat`-type sessions only.
**Why it matters:** Chat is required for sending materials and coordinating a session (FR-SESI-03) and would become mandatory for session delivery if D-03 resolves to Varian B. NFR-SESI-03 says history "sebaiknya tersimpan" for audit and complaints, which implies a data store and an access policy.
**Options explicitly supported by the SRS:** The SRS requires the capability and the window (FR-SESI-04) but does not specify transport, storage, retention period, moderation or attachments. **Decision required from product/founder/backend owner.**
**Consequences:** Realtime chat with a database backing store serves both the live requirement and the audit clause; an unaudited transient channel satisfies neither NFR-SESI-03 nor complaint handling (FR-ADM-04). Retention also interacts with minor-protection decisions (D-09).
**Blocks implementation?** Yes — blocks FR-SESI-03, FR-SESI-04, NFR-SESI-03 and D-33.
**Status:** BLOCKED · **Blocked by:** D-03
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-33 — Chat window boundaries under reschedule or no-show
**Reqs:** FR-SESI-04 (with unratified reschedule policy D-13) · **Class:** Product/domain · **Owner (per SRS):** FOUNDER
**Current implementation:** Nothing to apply a boundary to; the SRS's only definition of the window is "dari waktu mulai hingga waktu selesai sesi sesuai booking".
**Why it matters:** The window definition is clear for a normal session but undefined when the session is moved, cancelled or missed — exactly the cases where coordination matters most.
**Options explicitly supported by the SRS:** The normal case only (booking start → end). Behaviour under reschedule, cancellation or a missed session is **not specified by the SRS**.
**Consequences:** A strict reading closes chat the moment a session is cancelled, removing the channel needed to arrange a make-up; a permissive reading weakens the SRS's stated restriction.
**Blocks implementation?** Yes — blocks full compliance of FR-SESI-04.
**Status:** BLOCKED · **Blocked by:** D-32, D-13
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-34 — Review list pagination
**Reqs:** FR-RATE-02 · **Class:** Product/UX · **Owner (per SRS):** INT
**Current implementation:** `controllers/tutor_controller.dart › _fetchReviews` limits to the 10 newest reviews; `views/customer/tutor_detail_screen.dart` renders at most 5.
**Why it matters:** FR-RATE-02 only requires reviews to be visible. The limit is an implementation choice; whether a Tutor's full history must be browsable, and how (paging, "see all"), is a product question — and it interacts with NFR-DISC-01's latency target.
**Options explicitly supported by the SRS:** **None.** The SRS does not mention pagination or a review count display rule.
**Consequences:** Very low impact either way; only relevant if Buddies need to audit a Tutor's full history before booking.
**Blocks implementation?** No.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-35 — Rating reminder
**Reqs:** FR-RATE-04 · **Class:** Product/UX · **Owner (per SRS):** FOUNDER
**Current implementation:** No reminder exists; the review screen is reached once, immediately after ending a session.
**Why it matters:** FR-RATE-04 says the system **may** show a reminder ("dapat menampilkan pengingat") — optional by wording. A reminder raises review volume but needs a trigger mechanism, which overlaps D-04's notification decision.
**Options explicitly supported by the SRS:** (a) Show a reminder (no mechanism specified). (b) Do not show one, which the wording permits since rating is optional and must not block anything.
**Consequences:** (a) More reviews improve FR-DISC-04's ranking quality, but needs a delivery channel. (b) Simplest; matches the optional wording.
**Blocks implementation?** No.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-36 — Is the 5 MB document limit binding?
**Reqs:** NFR-PROF-02 · **Class:** Product/backend · **Owner (per SRS):** BE (+INT)
**Current implementation:** Nothing enforced; no upload path exists.
**Why it matters:** NFR-PROF-02 says "disarankan maksimal 5MB per file" — advisory, not mandatory. The value interacts with storage cost (named in the clause's rationale) and with phone-camera file sizes for transcripts and certificates.
**Options explicitly supported by the SRS:** (a) Adopt 5 MB per file as the limit. (b) Adopt a different value — permitted, since the clause is a recommendation, but the value is then **not specified by the SRS**.
**Consequences:** A low limit rejects legitimate multi-page scans; a high limit increases storage cost and upload failures on slow networks.
**Blocks implementation?** Yes — blocks the size validation half of the upload work (NFR-PROF-02).
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-37 — Discovery latency: acceptance conditions for "< 2 detik"
**Reqs:** NFR-DISC-01 · **Class:** Product/technical · **Owner (per SRS):** INT
**Current implementation:** `controllers/tutor_controller.dart › fetchAllTutors` performs a single unfiltered select and filters locally; no pagination or measurement exists.
**Why it matters:** The target is stated as "< 2 detik pada kondisi jaringan normal", and "normal" is undefined, so the requirement is currently untestable and unverifiable.
**Options explicitly supported by the SRS:** The target value only. The measurement conditions (device class, network profile, dataset size) are **not specified by the SRS**.
**Consequences:** Without agreed conditions the requirement can be neither passed nor failed; with them, the team gains a testable acceptance criterion (and likely a pagination requirement).
**Blocks implementation?** No — it blocks *acceptance* of NFR-DISC-01, not the build.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-38 — Tutor availability reminder in MVP
**Reqs:** NFR-BOOK-03 · **Class:** Product · **Owner (per SRS):** FOUNDER+INT
**Current implementation:** Nothing exists.
**Why it matters:** The clause is explicitly "opsional untuk MVP" and exists to keep search results accurate. It needs a notification channel (D-04) and a staleness definition that the SRS does not provide ("periode tertentu").
**Options explicitly supported by the SRS:** (a) Include a reminder. (b) Defer it, since the clause is optional for MVP. The triggering period is **not specified by the SRS**.
**Consequences:** (a) Better slot accuracy at the cost of another notification type and its fatigue risk. (b) Nothing to build now.
**Blocks implementation?** No.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-39 — Video-link provider abstraction in MVP
**Reqs:** NFR-SESI-02 · **Class:** Product/technical · **Owner (per SRS):** INT
**Current implementation:** The link is stored as a plain string (`models/tutor_model.dart › gmeetLink`, and the 3 in-memory values in `tutor_dashboard_controller.dart`), while "Google Meet" appears hardcoded in user-facing copy across several screens.
**Why it matters:** NFR-SESI-02 requires the design to allow replacing the video provider, motivated by the dependency on a founder's personal Google account (§2.4). Whether MVP invests in an abstraction (and reworded copy) is a cost decision.
**Options explicitly supported by the SRS:** (a) Keep the provider as data (link string) and centralise references so it can be swapped. (b) Build an explicit provider abstraction. The SRS states the design goal, not the mechanism.
**Consequences:** (a) Cheap and mostly satisfies the clause; copy still needs neutral wording. (b) Cleaner and future-proof, more work, and no other provider is currently available or budgeted.
**Blocks implementation?** Yes — depends on D-03 for what is being abstracted.
**Status:** BLOCKED · **Blocked by:** D-03
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-40 — Slot reservation TTL semantics
**Reqs:** NFR-BOOK-01, FR-BOOK-04, NFR-PAY-03 · **Class:** Product/backend · **Owner (per SRS):** INT (+BE)
**Current implementation:** `controllers/booking_controller.dart › selectSlot` stores the selection in memory only; nothing is reserved, and `controllers/payment_controller.dart` claims (in copy) to release a slot that was never held.
**Why it matters:** Locking without an expiry can hold a slot forever (precisely what NFR-PAY-03 warns about), while locking with a wrong TTL either blocks legitimate bookings or releases slots mid-payment. The interaction between the reservation and QR expiry must be defined.
**Options explicitly supported by the SRS:** (a) The lock is released when the QR expires (the two clauses imply this relationship). The TTL value itself is **not specified by the SRS** beyond NFR-PAY-03's 15–30 minute range.
**Consequences:** A TTL shorter than the payment window causes double-booking or failed payments; longer holds inventory. The release trigger (expiry, cancellation, failed payment, app closure) must be enumerated.
**Blocks implementation?** Yes — blocks FR-BOOK-04/NFR-BOOK-01 design and D-50.
**Status:** BLOCKED · **Blocked by:** D-06, D-08
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-41 — Complaint/follow-up entity
**Reqs:** FR-ADM-04 (with FR-SESI-07) · **Class:** Product/backend · **Owner (per SRS):** FOUNDER
**Current implementation:** Nothing. No complaint record, no intake surface.
**Why it matters:** FR-ADM-04 requires Admin to flag and follow up session complaints; SRS §4.1 defines no complaint entity, so the workflow has no data model.
**Options explicitly supported by the SRS:** (a) Introduce a complaint/follow-up record (entity shape **not specified by the SRS**). (b) Handle complaints outside the app, which would leave FR-ADM-04 unimplemented.
**Consequences:** (a) Requires a ratified entity plus Admin UI, and interacts with chat retention (D-32) and connection-loss handling (D-11) as evidence sources. (b) Admin cannot track follow-ups in-system.
**Blocks implementation?** Yes — blocks FR-ADM-04.
**Status:** BLOCKED · **Blocked by:** D-10
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-42 — Forgot-password screen copy and UX
**Reqs:** FR-AUTH-05 · **Class:** UX (non-blocking) · **Owner (per SRS):** FE
**Current implementation:** No screen, entry-point link or route exists. **Wave 1 (W1-3)** added the *mechanism* only — `core/services/auth_service.dart › resetPassword` → Supabase Auth `resetPasswordForEmail`, plus `controllers/auth_controller.dart › resetPassword` / `resetEmailSent` — and it is **not reachable from the UI** (both methods are uncalled). Reset-token/deep-link handling and a new-password step do not exist, and the Supabase redirect/Site-URL target cannot be verified from this repository. The copy and steps this decision covers are therefore still unwritten; the requirement stands at RTM status **P**, not **A**.
**Why it matters:** The SRS specifies the behaviour (reset via email) but no copy or flow shape. This is a design detail owned by Front-End per §6, not a business decision — but it should be recorded so it is not treated as an invented requirement later.
**Options explicitly supported by the SRS:** Reset password via email (FR-AUTH-05). Screen copy/steps: **not specified by the SRS**.
**Consequences:** None material; the delivery mechanism is already named.
**Blocks implementation?** No — FR-AUTH-05 is otherwise ready to implement.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-43 — Tutor availability UI shape ("kalender")
**Reqs:** FR-BOOK-01 · **Class:** UX (non-blocking) · **Owner (per SRS):** FE
**Current implementation:** A list of slots with a bottom sheet for adding; editing is missing entirely; deleting is blocked for booked slots (`views/tutor/tutor_schedule_screen.dart › _AvailabilityTab`).
**Why it matters:** FR-BOOK-01 says slots are managed "melalui kalender", which describes a reference rather than a specified interaction. The current list-plus-sheet pattern already exists and is not obviously non-compliant, but it has no edit affordance, and that *is* required (FR-BOOK-01 lists add, edit, delete).
**Options explicitly supported by the SRS:** (a) Keep a list-shaped surface and add the missing edit action. (b) Build a calendar-shaped surface. The SRS does not mandate either.
**Consequences:** (a) Small change, keeps existing UI and tests. (b) Larger redesign and out of scope while "do not modify the UI" stands.
**Blocks implementation?** Partially — the edit action is required regardless; only the presentation is open.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-44 — Buddy activity statistics in MVP
**Reqs:** FR-PROF-03 · **Class:** Product · **Owner (per SRS):** FOUNDER
**Current implementation:** `controllers/profile_controller.dart` holds hardcoded `completedSessions = 12` and `avgRatingGiven = 4.6`, rendered as real statistics in `views/customer/profile_screen.dart`.
**Why it matters:** FR-PROF-03 explicitly says it is optional for MVP, yet the UI presents invented numbers as facts — which is worse than omitting the feature, because it misinforms the user.
**Options explicitly supported by the SRS:** (a) Implement it (completed sessions and average rating given). (b) Omit it for MVP, as the clause permits. (c) Keep the block but derive it from real data.
**Consequences:** (a)/(c) Require aggregation over bookings and reviews, touching Rating and Booking contracts. (b) Removes two fake figures from the product.
**Blocks implementation?** No.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

---

## D. Backend / data contract decisions (D-45 … D-57)

> These are decisions **owned by the Back-End / data owner** (§6: "Skema database & RLS seluruh modul"). Full detail, including what the client currently assumes, is requested in `docs/be-contract-request.md`. This register records only that the decision is open and what it blocks.
> Reminder: **the repository contains no schema, migration, RLS policy or API contract artefact**, so none of these can be verified from the codebase.

### D-45 — User / profile field contract
**Reqs:** FR-AUTH-02, FR-PROF-01, FR-PROF-02 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** `models/user_model.dart › fromMap/toMap` already maps `phone`, `usia`, `kelas`, `asal_sekolah`, `mata_pelajaran_diminati`, `avatar_url`, `fcm_token`, `created_at` **and writes them on sign-up** (`core/services/auth_service.dart › signUp` inserts `id`, `email`, `full_name`, `role`, `created_at`).
**Why it matters:** The client persists to column names that no SRS section specifies (§4.1 lists only `id, nama, email, role, jenjang, created_at`). If they are wrong, profile persistence (FR-PROF-01/02) silently fails.
**Options explicitly supported by the SRS:** (a) The SRS's indicative attribute set for `User` (§4.1: id, nama, email, role, jenjang, created_at). (b) Anything beyond that — **not specified by the SRS**.
**Consequences:** Mismatch means writes are rejected or land in unexpected columns; consent/age fields (D-09) also depend on this contract.
**Blocks implementation?** Yes — blocks FR-AUTH-02 persistence and FR-PROF-01/02.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-46 — Tutor profile and verification record contract
**Reqs:** FR-PROF-04, FR-PROF-07, FR-PROF-08, FR-ADM-02 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** `models/tutor_model.dart` maps `bio`, `subjects`, `rating`, `total_sessions`, `total_reviews`, `is_online`, `price_per_hour`, `gmeet_link`, `university`, `gpa`, `last_seen`, `kemampuan_lain`, `status_verifikasi`, `rejection_reason`, `is_tutor_of_the_month`; only a subset exists in SRS §4.1 (`user_id, bio, mata_pelajaran, status_verifikasi`).
**Why it matters:** Verification status and rejection reason must be readable by Admin and enforced for discovery/booking; the extra fields include unratified ones (D-12, D-16).
**Options explicitly supported by the SRS:** (a) The §4.1 indicative set. (b) The additional fields — **not specified by the SRS**.
**Consequences:** The verification gate and the Admin queue depend entirely on this record and its transition rules.
**Blocks implementation?** Yes — blocks FR-PROF-07/08 and FR-ADM-02.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-47 — Tutor document storage, access rules and RLS
**Reqs:** NFR-PROF-01, NFR-PROF-02, NFR-PROF-03, FR-PROF-05, FR-PROF-09 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** `core/constants/supabase_constants.dart › bucketDocuments = 'documents'` is declared and never used; `controllers/profile_controller.dart › uploadDocument` writes the sentinel `'pending-upload'` and no storage call exists.
**Why it matters:** NFR-PROF-01 requires a **non-public** bucket readable only by the owning Tutor and Admin, enforced with RLS. The client cannot implement upload semantics without knowing the bucket, the access rule and the retention of replaced files.
**Options explicitly supported by the SRS:** (a) Private storage with Tutor-owner + Admin access (NFR-PROF-01). (b) Anything else — **not specified by the SRS**.
**Consequences:** A public or over-permissive bucket would expose identity documents and transcripts, including data of minors (D-09).
**Blocks implementation?** Yes — blocks FR-PROF-05/09 and all three document NFRs.
**Status:** OPEN · **Blocked by:** — (the 5 MB value interacts with D-36)
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-48 — Rating aggregation ownership
**Reqs:** FR-RATE-03, NFR-RATE-01 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** `controllers/review_controller.dart › _recalculateTutorRating` computes the average **on the client**, then updates `tutors.rating` and `tutors.total_reviews`; it uses `data.map((e) => e['rating'] as int)`.
**Why it matters:** FR-RATE-03 requires the system to compute the average automatically. A client-computed aggregate is neither authoritative nor safe (any client with write access can rewrite a Tutor's public rating), and the RTM lists this as a requirement the code currently contradicts.
**Options explicitly supported by the SRS:** (a) Server-owned aggregation (trigger, computed column or scheduled job — mechanism **not specified by the SRS**). (b) Keep client-side aggregation, which contradicts the clause as written.
**Consequences:** Server-owned aggregation makes `rating` trustworthy for FR-DISC-04 ranking; it also removes a client write path that currently reaches Tutor rows.
**Blocks implementation?** Yes — blocks FR-RATE-03.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-49 — Enforcement location for one review per session
**Reqs:** NFR-RATE-01 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** Nothing is enforced: there is no uniqueness guarantee on the review's session reference (this repository contains no schema or constraint artefact — see RTM §1.3), so the review screen can be reached again and would submit another row for the same session.
**State change (original defect → Wave 1 → today):** the submit previously also wrote `tutorId: ''` (RTM defect **D2**), making rows unattributable. Wave 1 (**W1-1**) closed that: the row now carries the real Tutor id taken from the booking, and `submitReview` refuses an empty session/tutor id before touching data (`test/review_smoke_test.dart`). **The duplicated-session problem this decision exists to solve is untouched — D-49 remains OPEN and its options are unchanged.**
**Why it matters:** NFR-RATE-01 exists to prevent rating manipulation, which a client-side guard cannot guarantee.
**Options explicitly supported by the SRS:** (a) A uniqueness guarantee on the review against its session (mechanism **not specified by the SRS**). (b) Client-only guard — insufficient for the stated purpose.
**Consequences:** Without server enforcement the ranking used by FR-DISC-04 can be inflated; with it, the client must handle the rejection gracefully.
**Blocks implementation?** Yes — blocks NFR-RATE-01.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-50 — AvailabilitySlot entity contract
**Reqs:** FR-BOOK-01, FR-BOOK-02, FR-BOOK-04, FR-BOOK-05, NFR-BOOK-01 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** `models/availability_slot_model.dart` maps `tutor_id`, `waktu_mulai`, `waktu_selesai`, `zona_waktu`, `status` (`available | booked`); slots are generated or held purely in memory (`booking_controller.fetchAvailableSlots`, `tutor_schedule_controller._dummySlots`).
**Why it matters:** Slots must be owned by a Tutor, visible to Buddies, removable, and reservable under concurrency (NFR-BOOK-01). SRS §4.1 names `AvailabilitySlot` with key attributes `tutor_id, waktu_mulai, waktu_selesai, status (tersedia/terkunci/terbooking)` — note the SRS includes a **terkunci** state that the client model does not; `zona_waktu` is not in the SRS.
**Options explicitly supported by the SRS:** (a) The §4.1 attribute set including `tersedia/terkunci/terbooking`. (b) Additional attributes such as timezone — **not specified by the SRS**.
**Consequences:** The three-state model is what makes locking expressible; omitting `terkunci` forces locking to be modelled elsewhere.
**Blocks implementation?** Yes — blocks FR-BOOK-01/02/04/05 and NFR-BOOK-01.
**Status:** OPEN · **Blocked by:** — (TTL semantics are D-40)
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-51 — Booking ↔ Payment ↔ Session relationship contract
**Reqs:** FR-BOOK-09, FR-PAY-03, FR-SESI-01, FR-SESI-06, NFR-PAY-01, FR-ADM-03 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** `models/booking_model.dart › fromMap` ignores joined tutor data even though `booking_controller.fetchMyBookings` selects `'*, tutors(*)'`; sessions are created separately by `session_controller.startSession`; invoices are never persisted.
**Why it matters:** SRS §4.2 fixes the cardinality (`AvailabilitySlot → Booking` 1:0..1, `Booking → Payment` 1:1, `Booking → Session` 1:1). Booking detail (FR-BOOK-09) needs the Tutor and payment status joined to the booking, and the payment record must be immutable once successful (NFR-PAY-01).
**Options explicitly supported by the SRS:** (a) The §4.2 cardinalities. (b) Any different cardinality (e.g. multi-session payments) — **not specified by the SRS**.
**Consequences:** This contract determines whether booking detail can be a single query, and whether payment status is derivable where FR-BOOK-09 and FR-ADM-03 need it.
**Blocks implementation?** Yes — blocks FR-BOOK-09, FR-PAY-03 and FR-ADM-03.
**Status:** BLOCKED · **Blocked by:** D-12 (whether multi-session payments exist)
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-52 — Canonical booking statuses and realtime event contract
**Reqs:** FR-SESI-06, NFR-BOOK-02, FR-BOOK-07, FR-ADM-01 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** Stored booking status values are `pending | confirmed | ongoing | done | cancelled` (per `booking_controller` writes and `booking_model` defaults); `core/services/realtime_service.dart › subscribeBookings` exists but is **never called**; no booking screen subscribes, so the other party sees stale state.
**Why it matters:** NFR-BOOK-02 requires status changes to be reflected in real time on both sides without manual refresh, so the client needs to know which values to expect and what a change event carries.
**Options explicitly supported by the SRS:** The four display states of FR-SESI-06. The **stored** values, the event payload shape and the subscription/filter keys are **not specified by the SRS**.
**Consequences:** Without an agreed value set, every screen will need its own mapping and realtime listeners cannot be wired confidently; the mapping decision itself is D-28.
**Blocks implementation?** Yes — blocks NFR-BOOK-02 and FR-ADM-01 status filtering.
**Status:** BLOCKED · **Blocked by:** D-20, D-28
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-53 — Payment transaction entity, immutability and retention
**Reqs:** NFR-PAY-01, FR-PAY-02, FR-PAY-07, FR-ADM-03 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** Nothing persisted. `controllers/payment_controller.dart` keeps the active invoice in memory and seeds a history from a `static final` dummy list.
**Why it matters:** NFR-PAY-01 requires accurate records that **cannot be modified after success** for financial audit; FR-PAY-07 and FR-ADM-03 read those records. SRS §4.1 lists `Payment` attributes `booking_id, jumlah, status, metode, waktu_bayar` — with no immutability mechanism, no provider reference and no refund relationship.
**Options explicitly supported by the SRS:** (a) The §4.1 attribute set. (b) Provider reference, refund link, immutability enforcement — the SRS states the *outcomes* but not the fields or mechanism (**not specified by the SRS**).
**Consequences:** Without immutability enforcement, audit integrity depends on client goodwill; without a provider reference, webhook reconciliation (NFR-PAY-02) is impossible.
**Blocks implementation?** Yes — blocks NFR-PAY-01, FR-PAY-02, FR-PAY-07.
**Status:** BLOCKED · **Blocked by:** D-12 (entity shape depends on whether package payments exist)
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-54 — QR generation and expiry authority
**Reqs:** FR-PAY-01, NFR-PAY-03, NFR-PAY-02 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** `views/customer/invoice_screen.dart › _QrPlaceholder` renders an icon; expiry is a client-side timer in `payment_controller`; status success is a 600 ms simulation.
**Why it matters:** FR-PAY-01 requires a payable QR SB. Whether the QR string is produced by the client from a payment reference or returned by a provider, and who may declare an invoice expired, are both unspecified — and both are required before any payment UI work.
**Options explicitly supported by the SRS:** (a) The status states to be shown (FR-PAY-02) and the expiry range (NFR-PAY-03). The generation and expiry authority are **not specified by the SRS**.
**Consequences:** Client-authoritative expiry can be bypassed by closing the app, leaving locks inconsistent; provider-authoritative expiry requires a callback path (D-08).
**Blocks implementation?** Yes — blocks FR-PAY-01 and NFR-PAY-03.
**Status:** BLOCKED · **Blocked by:** D-08
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-55 — Discovery query contract (verified-only, filters, returned fields)
**Reqs:** FR-DISC-01, FR-DISC-02, FR-DISC-03, FR-DISC-06, FR-PROF-08, NFR-DISC-01 · **Class:** Backend contract · **Owner:** BE (+FOUNDER)
**Current implementation:** `controllers/tutor_controller.dart › fetchAllTutors` selects all rows ordered by `rating` and filters client-side by a single text query; the card reads `subjects`, `rating`, `total_reviews`, `price_per_hour`.
**Why it matters:** FR-DISC-01's verified-only rule must be enforced on the query (or by RLS) so unverified Tutors cannot surface; FR-DISC-02/03 filters and FR-DISC-05's availability indicator must be expressible server-side for NFR-DISC-01's latency target. FR-DISC-06 requires a completed-session count that the query must return.
**Options explicitly supported by the SRS:** The visible outcomes (verified-only, filter by subject, filter by grade, show session count). How they are enforced (view, RLS policy, parameterised query) is **not specified by the SRS**.
**Consequences:** Client-side filtering plus RLS-free access means a client can technically obtain unverified/complete tutor rows, which fails FR-DISC-01's intent even if the UI filters correctly.
**Blocks implementation?** Yes — blocks FR-DISC-01/02/03/06 and NFR-DISC-01 acceptance.
**Status:** OPEN · **Blocked by:** —
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-56 — Admin role, permissions and RLS contract
**Reqs:** NFR-ADM-01, FR-ADM-01…04 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** Nothing; no Admin role value, no policy artefact in the repository.
**Why it matters:** NFR-ADM-01 requires Admin access to be restricted to Admin accounts **with RLS at the database level, separate from Buddy/Tutor**. Without the role identifier (D-21) and the policy set, no Admin feature can be built safely.
**Options explicitly supported by the SRS:** (a) An Admin role separate from Buddy/Tutor, enforced by RLS (NFR-ADM-01). The identifier and the specific policy matrix are **not specified by the SRS**.
**Consequences:** Without server-side enforcement, an in-app Admin module (D-10b) would be protected only by client checks, which is not what the NFR requires.
**Blocks implementation?** Yes — blocks NFR-ADM-01 and all Admin features.
**Status:** BLOCKED · **Blocked by:** D-21, D-10
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

### D-57 — Session entity, Meet link relationship and chat relationship
**Reqs:** FR-SESI-01, FR-SESI-02, FR-SESI-06, FR-SESI-03, NFR-SESI-03 · **Class:** Backend contract · **Owner:** BE
**Current implementation:** `models/session_model.dart` maps `booking_id`, `start_time`, `end_time`, `status` (`active | ended`), `gmeet_link`, `elapsed_seconds`; `session_controller.startSession` inserts a row with `booking_id`, `start_time`, `status`, `gmeet_link`. SRS §4.1 lists `Session` as `booking_id, link_meet, status, waktu_mulai_aktual, waktu_selesai_aktual`, and `ChatMessage` as `session_id, sender_id, isi_pesan, timestamp`.
**Why it matters:** The Meet link's storage and origin depend on D-03, and chat (if retained) hangs off the session via `ChatMessage.session_id` — so the session record is the anchor for both.
**Options explicitly supported by the SRS:** (a) The §4.1 attribute set, including `link_meet` on the session. (b) Tutor-level permanent links (Varian A) stored outside the session — structurally **not specified by the SRS**.
**Consequences:** If links live on the Tutor, a deterministic attachment rule is needed at booking time; if they live on the session, the link must be resolved before the session starts.
**Blocks implementation?** Yes — blocks FR-SESI-01/02/03 and NFR-SESI-03.
**Status:** BLOCKED · **Blocked by:** D-03
**Final decision:** _OPEN — Decision required from product/founder/backend owner._

---

## Appendix A — RTM coverage (all 57 flagged requirement rows map to a decision)

| Requirement (RTM `Decision needed`) | Decision ID(s) |
|---|---|
| FR-AUTH-01 | D-19, D-45 |
| FR-AUTH-02 | D-45 |
| FR-AUTH-05 | D-42 |
| FR-AUTH-06 | D-18 |
| FR-AUTH-07 | D-26, D-25 |
| FR-PROF-01 | D-24, D-45 |
| FR-PROF-03 | D-44 |
| FR-PROF-04 | D-23 |
| FR-PROF-05 | D-17 |
| FR-PROF-07 | D-01, D-22, D-46 |
| FR-PROF-08 | D-01, D-22 |
| FR-PROF-09 | D-22 |
| FR-PROF-10 | D-27, D-24 |
| FR-DISC-03 | D-23, D-55 |
| FR-DISC-04 | D-02 |
| FR-BOOK-01 | D-43 |
| FR-BOOK-03 | D-20 |
| FR-BOOK-04 | D-40, D-50 |
| FR-BOOK-06 | D-04 |
| FR-BOOK-07 | D-29 |
| FR-BOOK-08 | D-05 |
| FR-PAY-01 | D-08, D-16, D-54 |
| FR-PAY-02 | D-08, D-53 |
| FR-PAY-03 | D-20, D-28, D-51 |
| FR-PAY-04 | D-05 |
| FR-PAY-05 | D-30 |
| FR-PAY-06 | D-07 |
| FR-PAY-07 | D-31, D-14 |
| FR-SESI-01 | D-03, D-57 |
| FR-SESI-02 | D-03 |
| FR-SESI-03 | D-32 |
| FR-SESI-04 | D-33 |
| FR-SESI-05 | D-04 |
| FR-SESI-06 | D-28, D-52 |
| FR-SESI-07 | D-11 |
| FR-RATE-02 | D-34 |
| FR-RATE-03 | D-48 |
| FR-RATE-04 | D-35 |
| FR-ADM-01 | D-10, D-52 |
| FR-ADM-02 | D-01, D-10, D-22, D-46 |
| FR-ADM-03 | D-10, D-51, D-53 |
| FR-ADM-04 | D-10, D-41 |
| NFR-AUTH-03 | D-09 |
| NFR-PROF-01 | D-47 |
| NFR-PROF-02 | D-36 |
| NFR-PROF-04 | D-09 |
| NFR-DISC-01 | D-37, D-55 |
| NFR-DISC-02 | D-02 |
| NFR-BOOK-01 | D-40, D-50 |
| NFR-BOOK-03 | D-38 |
| NFR-PAY-01 | D-53 |
| NFR-PAY-02 | D-08, D-53, D-54 |
| NFR-PAY-03 | D-06, D-40, D-54 |
| NFR-SESI-02 | D-39 |
| NFR-SESI-03 | D-32, D-57 |
| NFR-RATE-01 | D-49 |
| NFR-ADM-01 | D-21, D-10, D-56 |

**Coverage:** 57 / 57 flagged RTM rows mapped. *(Rev 2: the added row is `NFR-RATE-01 → D-49`, a coverage correction — D-49 already existed and already named `NFR-RATE-01` as its requirement.)* Additionally, D-12…D-16 and the Appendix B entries below exist because the RTM records surplus modules (§1.2, §7) that the register must resolve even though no FR row carries them.

## Appendix B — Unratified artefacts recorded, not to be touched

Per the Wave 0 scope rule, the following are recorded as **`UNRATIFIED — SRS DECISION REQUIRED`**. They must not be refactored, integrated into the target architecture, or deleted until their corresponding decision is recorded.

| Artefact | Decision | Current location |
|---|---|---|
| Package & Token module | D-12 | `models/package_model.dart`, `models/token_model.dart`, `controllers/package_controller.dart`, `views/customer/package_screen.dart`, `views/customer/my_tokens_screen.dart`, `views/shared/widgets/package_card.dart` |
| Reschedule module | D-13 | `models/reschedule_model.dart`, `controllers/reschedule_controller.dart`, `views/customer/reschedule_screen.dart` |
| Payroll / Honor module | D-14 | `models/payroll_model.dart`, `controllers/payroll_controller.dart`, `views/tutor/payroll_screen.dart`, `views/tutor/slip_gaji_screen.dart` |
| Multi-session invoice + discount | D-15 | `models/invoice_model.dart` (`InvoiceSessionItem`, `discount`, multi-item `sessions`) |
| Hourly pricing (`pricePerHour` × duration) | D-16 | `models/tutor_model.dart`, `views/customer/booking_screen.dart › _goToInvoice`, `views/customer/tutor_detail_screen.dart`, `views/shared/widgets/tutor_card.dart` |
| Tutor fields beyond SRS §4.1 (`gpa`, `extraSkills`, `isTutorOfTheMonth`) | D-27, D-46 | `models/tutor_model.dart`, `views/tutor/tutor_profile_screen.dart` |
| `sessionType: 'video' \| 'chat'` as alternative session types | D-03, D-32 | `models/booking_model.dart`, `views/customer/booking_screen.dart`, `views/session/session_screen.dart` |
| Provider-specific copy ("QRIS Dynamic (ShopeePay)", webhook comment) | D-08 | `views/customer/invoice_screen.dart`, `controllers/payment_controller.dart` |

## Appendix C — Known RTM gaps discovered while building this register

These are recorded so the RTM can be corrected in a later change set; they are **not** decisions.

| Ref | Observation |
|---|---|
| C1 | FR-DISC-01 (verified-only search) has `—` in its RTM `Decision needed` cell and its `Depends on` names FR-PROF-07/08, yet it is in fact blocked by D-01/D-22 **and** by the discovery-query contract (D-55). |
| C2 | FR-PROF-02 has `—` in its decision cell although its gap is "nothing is persisted", which requires the same profile column contract as FR-PROF-01 (D-45). |
| C3 | FR-PROF-06 has `—` but consumes the document catalogue that D-17 must correct first. |
| C4 | FR-PAY-03 and FR-BOOK-03 are cross-referenced in the RTM as depending on each other; both resolve through the single lifecycle decision D-20 (recorded here to avoid a circular dependency). |
| C5 | NFR-SESI-02's decision cell asks whether a provider abstraction is warranted, but that cannot be answered before D-03 fixes what the provider delivers. |
| C6 | NFR-AUTH-02 is marked aligned in the RTM while role resolution has two sources (D-25); the session-persistence clause itself is satisfied, but role routing is not part of that clause — recorded to prevent the RTM being read as "role handling is correct". |

*End of decision register.*

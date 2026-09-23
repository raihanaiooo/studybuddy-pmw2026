# Wave 0 — Decision & Contract Preparation Plan

**Document type:** Wave 0 execution plan (no implementation)
**Status:** Planning only. **Nothing in this plan is authorised to be implemented.** No application source code was created, modified or deleted. No migrations, tables, RLS policies or business logic were created.
**Date:** 23 September 2026
**Revision:** rev 3 (23 Sep 2026) — **contract-coverage reference update only**: the `FR-DISC-02` row in §6.2 (BLOCKED BY BACKEND CONTRACT) now cites the official contract item **`C-X-07`** (`docs/be-contract-request.md` rev 5, §10 Cross-cutting), which closes the confirmed coverage gap G-1. **No classification changed** — the row remains BLOCKED BY BACKEND CONTRACT; no decision was created, resolved or changed (**D-55 stays OPEN**); no Wave 2 item becomes ready merely because `C-X-07` exists. rev 2 (23 Sep 2026) — Wave-1 documentation reconciliation: the requirement counts in §0, the classification totals in §6.1, the Wave 1 table in §6.2, the review row in §6.3 and the test baseline in §5 (P-04) were re-derived from the current RTM (rev 2) and the completed Wave 1 audit. **No Wave 0 item was added, removed, re-owned or resolved, and no classification rule changed.**
**Sources used (only):** SRS v1.0 (06 Agustus 2026) and `docs/requirement-traceability-matrix.md` (RTM, rev 2). Decision IDs (`D-nn`) resolved in `docs/decision-register.md`; contract items requested in `docs/be-contract-request.md`.

---

## 0. Purpose and reading rules

Wave 0 exists for one reason: **the RTM shows that 57 of 74 requirements cannot be implemented correctly yet** — 8 because the SRS itself is tentative, and 49 because a product, scope, domain or backend decision is still open. Wave 0 converts those open items into recorded decisions and a signed-off data contract. It produces documents, not code.

*Rev 2 correction:* the figures were 56 / 8 / 48 in rev 1. The change comes from one coverage correction in the RTM — `NFR-RATE-01`'s `Decision needed` cell was blank although the register already defined a blocking decision for it (**D-49**) — not from Wave 1, which unblocked nothing and resolved no decision. Consequently **17 of 74 rows are free of blocking items** (was 18).

### 0.1 Classification used throughout this plan

| Class | Meaning | Consequence |
|---|---|---|
| **READY TO IMPLEMENT** | No open decision and no missing backend contract is required for the change. | May be scheduled as Wave 1 work. |
| **BLOCKED BY DECISION** | A decision in the register must be recorded first (product, scope, domain or UX). | Must not be started, however complete its UI looks. |
| **BLOCKED BY BACKEND CONTRACT** | The client cannot be written correctly until the data/API owner publishes the contract (or confirms the current assumption). | Must not be started; do not invent the contract client-side. |
| **MAINTAIN** | RTM status = Implemented and aligned. No work required beyond regression protection. | Keep under test; do not restructure. |

### 0.2 Two hard rules for Wave 0

1. **UI existence does not unblock anything.** A screen that already renders is still *blocked* while its rule, status value or persistence contract is undecided. §6.3 lists the modules where this specifically applies.
2. **No decision is invented.** Where the SRS is silent, the plan says so and routes the item to an owner. A missing decision is never resolved by choosing a convenient default in code.

---

## 1. Wave 0 objective, deliverables and exit criteria

**Objective:** record every decision the RTM flags and obtain the backend contract, so Wave 1–3 work can proceed against a fixed requirement baseline without inventing behaviour.

**Deliverables**
1. `docs/decision-register.md` — 57 decisions with options, consequences, owners, blank final-decision fields.
2. `docs/be-contract-request.md` — the precise contract request for the Back-End/data owner.
3. This plan — itemised Wave 0 work, owners, outputs and blocked requirements; plus the classification of all 74 requirements.
4. Ratified SRS version: either SRS v1.0 plus the recorded decisions, **or** a revised SRS that absorbs the surplus modules (D-12…D-16).

**Exit criteria (all must hold before Wave 1 scheduling beyond §6.2)**
- Every `D-01 … D-57` entry in the register has a non-empty `Final decision` field, or is explicitly marked *deferred* with a recorded rationale and a re-open date.
- Every contract item marked `BACKEND DECISION REQUIRED` in the contract request has a written answer or an explicit "not provided — client must not assume".
- The surplus modules are either ratified in the SRS revision or remain marked `UNRATIFIED — SRS DECISION REQUIRED`.
- The classification in §6.1 is re-derived and the newly-READY set is scheduled.

---

## 2. Section A — Product / SRS decisions

Owner codes: `FOUNDER`, `COO/CFO`, `ADMIN`, `INT`, `FE`, `FOUNDER+INT`. "Blocks" lists requirement IDs held up by this decision.

| Item (decision IDs) | Related reqs | Required input | Owner | Output | Blocks |
|---|---|---|---|---|---|
| Tutor verification flow (D-01) | FR-PROF-07, FR-PROF-08, FR-ADM-02 | Founder/Admin ruling: verifying actor, queue, SLA, automatic vs manual (Bab 8 #1) | FOUNDER+ADMIN | Recorded decision + the status transition table | FR-PROF-07, FR-PROF-08, FR-ADM-02, D-22 |
| Recommendation factors (D-02) | FR-DISC-04, NFR-DISC-02 | Founder ruling: rating-only now, or the additional factors to support | FOUNDER | Recorded decision + the factor list (weights can follow) | NFR-DISC-02 design |
| Meet link distribution (D-03) | FR-SESI-01, FR-SESI-02, FR-SESI-03 | Founder ruling: Varian A or Varian B (Bab 8 #3) | FOUNDER | Recorded decision + the chosen attachment rule | FR-SESI-01, FR-SESI-02, FR-SESI-03, D-32, D-39, D-57 |
| Notification mechanism (D-04) | FR-BOOK-06, FR-SESI-05 | Founder ruling: push, in-app surface, or both; and the lead time | FOUNDER | Recorded decision + the delivery list | FR-BOOK-06, FR-SESI-05, D-35, D-38 |
| Refund threshold (D-05) | FR-PAY-04, FR-BOOK-08 | COO/CFO ruling: the final threshold value (Bab 8 #5) | COO/CFO | Recorded value (single constant, plus its basis) | FR-PAY-04, FR-BOOK-08, D-30 |
| QR expiry window (D-06) | NFR-PAY-03 | Internal team agreement on a value in the SRS's 15–30 min range, and who owns expiry | INT | Recorded value + expiry authority | NFR-PAY-03, D-40 |
| 70/30 split automation (D-07) | FR-PAY-06 | Founder ruling: automatic or manual payout (Bab 8 #7) | FOUNDER | Recorded decision + whether payout integration exists | FR-PAY-06, D-31, FR-ADM-03 monitoring shape |
| Payment provider (D-08) | FR-PAY-01, FR-PAY-02, NFR-PAY-02 | Founder ruling: which provider (or none) behind QR SB (Bab 8 #8); approve the resulting cost against the RAB | FOUNDER | Recorded decision + a correction of the shipped provider copy | FR-PAY-01, FR-PAY-02, NFR-PAY-02, D-54, D-40 |
| SMP / minor parental consent (D-09) | NFR-AUTH-03, NFR-PROF-04, FR-AUTH-02 | Founder ruling: integration point only, or full consent flow (Bab 8 #9) | FOUNDER | Recorded decision + data requirements | NFR-AUTH-03, NFR-PROF-04, D-45 |
| Admin dashboard form (D-10) | FR-ADM-01…04, NFR-ADM-01 | Founder + team ruling: web vs in-app (Bab 8 #10), confirming or rejecting the §2.5 assumption | FOUNDER+INT | Recorded decision + hosting/scope note | FR-ADM-01…04, NFR-ADM-01, D-41, D-56 |
| Connection-loss automation (D-11) | FR-SESI-07 | Founder + team ruling: automate ±30 min / +15 min compensation / reschedule, or keep manual (Bab 8 #11) | FOUNDER+INT | Recorded decision + overlap resolution with D-05 and D-13 | FR-SESI-07 |

### 2.1 Additional product/domain decisions (from the register, group C)

| Item (decision IDs) | Related reqs | Required input | Owner | Output | Blocks |
|---|---|---|---|---|---|
| Tutor document catalogue (D-17) | FR-PROF-05, FR-PROF-06, FR-PROF-08 | Ruling on the four SRS documents vs the shipped six, incl. the required/optional classification | FOUNDER | Final catalogue with requirement levels | FR-PROF-05, FR-PROF-06, FR-PROF-08 |
| "Umum" grade option (D-18) | FR-AUTH-06 | Ruling: remove, or ratify by SRS revision | FOUNDER | Final permitted value set | FR-AUTH-06, D-45 |
| Role vocabulary (D-19) | FR-AUTH-01, NFR-ADM-01 | Ruling: SRS terms verbatim, or a documented mapping | FOUNDER (+BE) | Final identifier set + migration implications | FR-AUTH-01, D-21, D-25, NFR-ADM-01 |
| Booking lifecycle (D-20) | FR-BOOK-03, FR-PAY-03, FR-SESI-06, FR-BOOK-06 | Ruling: confirmed on successful payment, or a retained manual confirmation step | FOUNDER | Final lifecycle + state list | FR-BOOK-03, FR-PAY-03, D-28, D-52, FR-BOOK-06 |
| Admin role identifier (D-21) | NFR-ADM-01 | Ruling: `Admin` (SRS) or `management` (code) | FOUNDER (+BE) | Final identifier | NFR-ADM-01, D-56, D-22 |
| Verification lifecycle & permissions (D-22) | FR-PROF-07/08/09 | Ruling: who transitions, meaning of "cannot receive booking", re-verification on new certificates | FOUNDER+ADMIN | Status transition table + gate definition | FR-PROF-07, FR-PROF-08, FR-PROF-09 |
| Grade-levels-taught shape (D-23) | FR-PROF-04, FR-DISC-03 | Ruling on the SRS's own inconsistency (FR-AUTH-06's four values vs FR-DISC-03's three) | FOUNDER | One shared value set | FR-PROF-04, FR-DISC-03 |
| Buddy onboarding content (D-26) | FR-AUTH-07 | Ruling: required fields, blocking or not | FOUNDER | Onboarding step list | FR-AUTH-07 |
| Achievement badge (D-27) | FR-PROF-10 | Ruling: badge criteria, or no badge for MVP (clause is conditional) | FOUNDER | Criteria or explicit deferral | FR-PROF-10 (badge clause only) |
| "Booking Kamu" surface (D-29) | FR-BOOK-07 | Ruling on label/placement; FE owns the design per §6 | FOUNDER + FE | Placement decision | FR-BOOK-07, FR-BOOK-09 UI |
| Refund request flow (D-30) | FR-PAY-05, FR-PAY-04 | Ruling: request states, approval owner, reason taxonomy | FOUNDER | State machine + owner | FR-PAY-05 |
| Tutor earnings surface (D-31) | FR-PAY-07 | Ruling: simple per-transaction history vs payroll periods | FOUNDER | Surface shape | FR-PAY-07 |
| Chat mechanics (D-32) | FR-SESI-03, FR-SESI-04, NFR-SESI-03 | Ruling: transport, storage, retention, moderation, attachments | FOUNDER (+BE) | Chat contract requirements (feeds the BE request) | FR-SESI-03, FR-SESI-04, NFR-SESI-03 |
| Chat window boundaries (D-33) | FR-SESI-04 | Ruling: behaviour on reschedule/no-show/cancellation | FOUNDER | Boundary rule | FR-SESI-04 |
| Review pagination (D-34) | FR-RATE-02 | Optional refinement ruling | INT | Decision or explicit deferral | — (non-blocking) |
| Rating reminder (D-35) | FR-RATE-04 | Ruling: reminder or not (SRS says "dapat") | FOUNDER | Decision | — (non-blocking) |
| 5 MB binding (D-36) | NFR-PROF-02 | Ruling: adopt 5 MB or another value | BE (+INT) | Final limit | NFR-PROF-02 |
| Discovery latency conditions (D-37) | NFR-DISC-01 | Agreement on measurement conditions for "<2 s on a normal network" | INT | Test conditions | NFR-DISC-01 acceptance |
| Availability reminder in MVP (D-38) | NFR-BOOK-03 | Ruling: include or defer (SRS optional) | FOUNDER+INT | Decision | — (optional clause) |
| Provider abstraction in MVP (D-39) | NFR-SESI-02 | Ruling: data-only swap vs explicit abstraction | INT | Decision | NFR-SESI-02 |
| Reservation TTL semantics (D-40) | NFR-BOOK-01, FR-BOOK-04, NFR-PAY-03 | Ruling: TTL, release triggers, interaction with QR expiry | INT (+BE) | Lock lifecycle | FR-BOOK-04, NFR-BOOK-01 |
| Complaint entity (D-41) | FR-ADM-04 | Ruling: in-system complaint record or not | FOUNDER | Decision + entity outline | FR-ADM-04 |
| Forgot-password copy (D-42) | FR-AUTH-05 | Design copy/steps (FE-owned per §6) | FE | Screen copy | — (non-blocking) |
| Availability UI shape (D-43) | FR-BOOK-01 | Ruling: list + edit (current shape) vs calendar view | FE (+FOUNDER) | Decision | — (edit action required regardless) |
| Buddy activity stats (D-44) | FR-PROF-03 | Ruling: derive from real data, keep, or omit (SRS optional) | FOUNDER | Decision | — (non-blocking) |

---

## 3. Section B — Backend / data contract decisions

Full item-level detail is in `docs/be-contract-request.md`. This section lists only what the plan needs: the contract area, who owns it, what the output is, and what stays blocked.

| Contract area | Decision/contract IDs | Related reqs | Required input | Owner | Output | Blocks |
|---|---|---|---|---|---|---|
| Users & auth (role values, profile columns, grade values, persistence, role source of truth) | D-45, D-25 + C-AUTH-* | FR-AUTH-01, FR-AUTH-02, FR-PROF-01, FR-PROF-02 | BE answer to the contract request, or an explicit "unconfirmed" | BE | Column/field contract + write permissions | FR-AUTH-02, FR-PROF-01, FR-PROF-02, D-18, D-19 |
| Tutor profile & verification record | D-46 + C-TUT-* | FR-PROF-04, FR-PROF-07, FR-PROF-08, FR-ADM-02 | Field list, status values, transition rules | BE | Tutor contract + verification record shape | FR-PROF-07, FR-PROF-08, FR-ADM-02 |
| Tutor documents (private bucket, formats, size, ownership, Admin access, RLS) | D-47 + C-DOC-* | NFR-PROF-01/02/03, FR-PROF-05, FR-PROF-09 | Bucket identity + policy statements | BE | Storage contract + RLS expectations | NFR-PROF-01, NFR-PROF-02, NFR-PROF-03, FR-PROF-05, FR-PROF-09 |
| Availability slots (shape, ownership, status values, concurrency, expiry, relation to booking) | D-50, D-40 + C-SLOT-* | FR-BOOK-01…05, NFR-BOOK-01 | Slot record + lock mechanism + constraint | BE | Slot contract + reservation semantics | FR-BOOK-01, FR-BOOK-02, FR-BOOK-04, FR-BOOK-05, NFR-BOOK-01 |
| Booking (canonical statuses, relationships, cancellation, realtime events) | D-52, D-51 + C-BOOK-* | FR-BOOK-03, FR-BOOK-07, FR-BOOK-08, FR-BOOK-09, FR-SESI-06, NFR-BOOK-02 | Status value set + event payload + relationships | BE | Booking contract + realtime contract | FR-BOOK-09, NFR-BOOK-02, FR-ADM-01 |
| Payment (transaction entity, amount, statuses, provider reference, QR, expiry, webhook, immutability, refund link) | D-53, D-54 + C-PAY-* | FR-PAY-01, FR-PAY-02, FR-PAY-03, FR-PAY-05, FR-PAY-06, FR-PAY-07, NFR-PAY-01/02/03 | Provider decision (D-08) then the record + callback contract | BE (+FOUNDER via D-08) | Payment contract + callback contract | FR-PAY-01, FR-PAY-02, FR-PAY-03, FR-PAY-07, NFR-PAY-01, NFR-PAY-02, NFR-PAY-03, FR-ADM-03 |
| Rating/review (entity, uniqueness, relationships, aggregation ownership) | D-48, D-49 + C-RATE-* | FR-RATE-01, FR-RATE-02, FR-RATE-03, NFR-RATE-01 | Entity shape + who computes the average | BE | Review contract + aggregation decision | FR-RATE-03, NFR-RATE-01 |
| Session (entity, Meet link relationship, status values, chat relationship, notification relationship) | D-57 + C-SESS-* | FR-SESI-01…06, NFR-SESI-03 | Session record + link source (needs D-03) + chat linkage | BE | Session contract | FR-SESI-01, FR-SESI-03, NFR-SESI-03 |
| Admin (role, permissions, monitoring reads, complaints, RLS isolation) | D-56 + C-ADM-* | NFR-ADM-01, FR-ADM-01…04 | Role decision (D-21) + policy matrix | BE (+FOUNDER via D-10/D-21) | Admin permission matrix + RLS expectations | NFR-ADM-01, FR-ADM-01…04 |
| Discovery query (verified-only enforcement, filters, returned fields, latency) | D-55 | FR-DISC-01, FR-DISC-02, FR-DISC-03, FR-DISC-06, NFR-DISC-01 | Enforcement mechanism + field list | BE | Query/read contract | FR-DISC-01, FR-DISC-02, FR-DISC-03, FR-DISC-06 |
| Profile photo / avatar storage | D-24 | FR-PROF-01, FR-PROF-10 | Bucket + access + limits for avatars | BE | Avatar contract | FR-PROF-01 (photo), FR-PROF-10 (photo) |

---

## 4. Section C — Scope reconciliation

| Item | Decision ID | Required input | Owner | Output | Blocks |
|---|---|---|---|---|---|
| Package / Token module disposal | D-12 | Ratify into a new SRS version, or leave unratified | FOUNDER | Scope ruling | D-15, D-16, D-30, Wave 3 payment design |
| Reschedule module disposal | D-13 | Ratify or leave unratified; resolve overlap with FR-BOOK-08/FR-PAY-04 | FOUNDER | Scope ruling | D-33 |
| Payroll module disposal | D-14 | Ratify or leave unratified; resolve overlap with FR-PAY-07 | FOUNDER | Scope ruling | D-31 |
| Multi-session invoice + discount | D-15 | Ratify or remove from the target design (SRS §4.2 says Payment:Booking = 1:1) | FOUNDER (+BE) | Scope ruling | Payment entity design (D-53) |
| `pricePerHour` pricing | D-16 | Ratify a pricing model (the SRS defines none) | FOUNDER | Scope ruling | FR-PAY-01/02/03 amounts, FR-ADM-03 |
| Surplus Tutor fields (`gpa`, `extraSkills`, `isTutorOfTheMonth`) | D-27, D-46 | Ratify or leave unratified | FOUNDER (+BE) | Scope ruling | FR-PROF-10 badge clause |
| `sessionType: video \| chat` as alternative types | D-03, D-32 | Ratify the modelling, or treat chat and Meet as parallel capabilities of one session | FOUNDER | Scope ruling | FR-SESI-01, FR-SESI-03 |
| Provider-specific copy ("QRIS Dynamic (ShopeePay)") | D-08 | Correct the copy once the provider is decided | FE+FOUNDER | Copy correction | FR-PAY-01 display |

**Scope rule (binding for Wave 0 and later):** each item above stays marked **`UNRATIFIED — SRS DECISION REQUIRED`**. Do not refactor these modules, do not integrate them into the target architecture, and do not delete them (§5 of the RTM; Appendix B of the register).

---

## 5. Section D — Technical prerequisites

These are not requirements; they are the minimum conditions for any wave to be executed safely.

| # | Prerequisite | Why it is needed | Owner | Output | Blocks |
|---|---|---|---|---|---|
| P-01 | **Ratify the requirement baseline**: SRS v1.0 + recorded decisions, or a revised SRS absorbing D-12…D-16 | The RTM proves the code already implements a superset of v1.0; without a ratified baseline, "done" is undefined | FOUNDER+INT | One authoritative document | Everything |
| P-02 | **Commit the requirement documents to the repository** (`docs/`) and reference them from the README | Currently the SRS exists only outside version control; no requirement can be traced or reviewed | INT | Docs in VCS | Traceability maintenance |
| P-03 | **Confirm the backend repository/artefact location** — the client repo contains no schema, migration, RLS or API contract | The RTM cannot verify any data-layer requirement without it | BE | A pointer to the schema/contract source | All backend-blocked requirements |
| P-04 | **Baseline the test suite**: run `flutter analyze` and `flutter test` and record the result | The 8 smoke tests are the only regression net; `test/widget_test.dart` is a dead default that asserts a non-existent counter and **fails** (pre-existing, unmodified by Wave 1) | INT | Recorded baseline output — **rev 2: `flutter analyze` 0 errors; `flutter test` 41 passed / 1 failed (the dead default), recorded in `docs/wave-1-completion-report.md`** | Safe refactors in later waves |
| P-05 | **Environment/credential inventory** (Supabase project, Firebase/FCM, storage buckets) recorded against the budget | Several requirements need third-party services whose selection the RAB constrains (SRS §2.4) | INT+BE | Inventory note | Wave 3 payment/notification work |
| P-06 | **Decision-recording workflow**: a single place where a `Final decision` field is filled, dated and attributed | The register is inert unless decisions are recorded where the plan reads them | INT | Agreed workflow | All decision-blocked requirements |
| P-07 | **Record the known defects** from RTM §1.4 (D1…D10) as tracked defects, without fixing the blocked ones | Prevents defect fixes being mistaken for requirement work or being lost | INT | Defect list | §6.2 items |
| P-08 | **Confirm that no schema/migration/RLS work is expected from this repository** while Wave 0 stands | The current instruction forbids creating tables/RLS; the plan must not implicitly require it | INT+BE | Confirmation | All backend-blocked requirements |

---

## 6. Section E — Explicitly blocked implementation work

### 6.1 Classification of all 74 requirements

**READY TO IMPLEMENT (1 of 74 — was 3 in rev 1)**

| Requirement | Why it is unblocked | RTM status (rev 2) |
|---|---|---|
| FR-AUTH-05 | Supabase Auth email reset is named by the SRS; no rule, contract or scope question remains (screen copy D-42 is FE-owned and non-blocking). **Wave 1 (W1-3) wired the mechanism** (`AuthService.resetPassword` → Supabase Auth `resetPasswordForEmail`) but **not** the user-facing entry point, so the remaining — and still unblocked — work is the entry point plus the reset flow UI. Email delivery additionally depends on the Supabase project's redirect/Site URL, which is a Back-End configuration question (reported in `docs/wave-1-completion-report.md`), not a recorded decision | **P** (partially implemented) |

**MAINTAIN — aligned, no work required (10 of 74 — was 8 in rev 1)**
FR-AUTH-03 · FR-AUTH-04 · FR-DISC-04 · FR-DISC-05 · FR-RATE-01 · FR-RATE-02 · FR-RATE-04 · NFR-AUTH-01 · NFR-AUTH-02 · NFR-SESI-01
*(Keep under regression test. Do not restructure while Wave 0 stands. Note NFR-AUTH-02 concerns session persistence only; role routing is separately blocked by D-25.)*
*(Rev 2: FR-RATE-01 and FR-RATE-04 moved here from READY TO IMPLEMENT because **Wave 1 completed them** — W1-1 and W1-2 — and the RTM now records both as Implemented and aligned. The classification was re-derived from the current RTM; **nothing became unblocked as a result of Wave 1**.)*

**BLOCKED BY DECISION (41 of 74)**

| Requirement | Blocking decision(s) |
|---|---|
| FR-AUTH-01 | D-19 (role vocabulary) |
| FR-AUTH-06 | D-18 ("Umum") |
| FR-AUTH-07 | D-26 (onboarding content), D-25 (role source of truth) |
| FR-PROF-03 | D-44 (include in MVP) |
| FR-PROF-04 | D-23 (grade-levels-taught shape) |
| FR-PROF-05 | D-17 (document catalogue) |
| FR-PROF-06 | D-17 |
| FR-PROF-07 | D-01, D-22 (verification flow/lifecycle) |
| FR-PROF-08 | D-01, D-22 |
| FR-PROF-09 | D-22 |
| FR-PROF-10 | D-27 (badge) |
| FR-DISC-03 | D-23 |
| FR-BOOK-01 | D-43 (UI shape); edit action required regardless |
| FR-BOOK-03 | D-20 (lifecycle) |
| FR-BOOK-06 | D-04 (notification mechanism) |
| FR-BOOK-07 | D-29 (surface/label) |
| FR-BOOK-08 | D-05 (refund threshold) |
| FR-PAY-04 | D-05 |
| FR-PAY-05 | D-30 (flow/states) |
| FR-PAY-06 | D-07 (split automation) |
| FR-SESI-01 | D-03 (Varian A/B) |
| FR-SESI-02 | D-03 |
| FR-SESI-03 | D-32 (chat mechanics) |
| FR-SESI-04 | D-33 (window boundaries) |
| FR-SESI-05 | D-04 |
| FR-SESI-06 | D-28 (status mapping) |
| FR-SESI-07 | D-11 (connection-loss automation) |
| FR-ADM-01 | D-10 (dashboard form) |
| FR-ADM-02 | D-10, D-01, D-22 |
| FR-ADM-03 | D-10 |
| FR-ADM-04 | D-10, D-41 (complaint entity) |
| NFR-AUTH-03 | D-09 (consent approach) |
| NFR-PROF-04 | D-09 |
| NFR-DISC-02 | D-02 (recommendation factors) |
| NFR-BOOK-03 | D-38 (include in MVP) |
| NFR-SESI-02 | D-39 (provider abstraction) |
| NFR-SESI-03 | D-32 (chat retention) |
| NFR-ADM-01 | D-21 (Admin role), D-10 |
| NFR-PROF-02 | D-36 (is 5 MB binding) |
| NFR-DISC-01 | D-37 (test conditions for acceptance) |
| NFR-BOOK-01 | D-40 (TTL semantics) |

**BLOCKED BY BACKEND CONTRACT (22 of 74)**

| Requirement | Blocking contract (register ID) |
|---|---|
| FR-AUTH-02 | D-45 (profile columns) |
| FR-PROF-01 | D-45, D-24 (avatar contract) |
| FR-PROF-02 | D-45 (no persistence path known) |
| FR-DISC-01 | D-55 (verified-only enforcement) |
| FR-DISC-02 | D-55 (filter contract) · contract item `C-X-07` (official, `docs/be-contract-request.md` rev 5) |
| FR-DISC-06 | D-55 (returned fields incl. session count) |
| FR-BOOK-02 | D-50 (AvailabilitySlot contract) |
| FR-BOOK-04 | D-50 (lock mechanism), D-40 |
| FR-BOOK-05 | D-50 (slot status transition) |
| FR-BOOK-09 | D-51 (booking detail read/join shape) |
| FR-PAY-01 | D-54 (QR generation), D-08 |
| FR-PAY-02 | D-53 (status source) |
| FR-PAY-03 | D-51 (relationships), D-20 |
| FR-PAY-07 | D-53 (records to read) |
| FR-RATE-03 | D-48 (aggregation ownership) |
| NFR-RATE-01 | D-49 (uniqueness enforcement) |
| NFR-PROF-01 | D-47 (bucket + RLS) |
| NFR-PROF-03 | D-47 (accepted formats at the boundary) |
| NFR-BOOK-02 | D-52 (realtime event contract) |
| NFR-PAY-01 | D-53 (immutability + retention) |
| NFR-PAY-02 | D-53, D-54, D-08 (callback contract) |
| NFR-PAY-03 | D-54 (expiry authority), D-06 |

**Totals:** 1 READY + 10 MAINTAIN + 41 BLOCKED BY DECISION + 22 BLOCKED BY BACKEND CONTRACT = **74**. No requirement was reclassified upward because its UI exists.
*(Rev 2: READY 3 → 1 and MAINTAIN 8 → 10, solely because Wave 1 completed FR-RATE-01 and FR-RATE-04. The two blocked lists are **unchanged** — neither FR-RATE-01 nor FR-RATE-04 ever appeared in them, and Wave 1 created no decision and no contract item.)*

### 6.2 Genuinely unblocked Wave 1 correctness fixes (the only work schedulable after Wave 0 starts)

| # | Work item | Requirements | Nature of change | Why it is safe | Depends on | State after Wave 1 |
|---|---|---|---|---|---|---|
| W1-1 | Pass the real Tutor/session identity into the review submission instead of `tutorId: ''` / `subject: ''`; ensure the review screen is reached with the booking context | FR-RATE-01 | Client-side data plumbing; correct write of a field the SRS's `Rating` entity already defines | No rule, status value, provider or schema decision is involved; the value was simply wrong | None | ✅ **Complete** — context carried from the booking, empty context refused; `test/review_smoke_test.dart` |
| W1-2 | Make "Lewati" a true skip: no review row, and navigate the user onward | FR-RATE-04 | Remove a fabricated 1-star record | Restores the SRS's "optional rating" semantics; strictly removes incorrect behaviour | None | ✅ **Complete** — no write on skip, exits to the Buddy dashboard |
| W1-3 | Implement the forgot-password entry point and email reset call | FR-AUTH-05 | New, self-contained flow using the Supabase Auth dependency the SRS already names | No existing behaviour changed; no decision blocks it | None | ◐ **Partial** — email-reset **mechanism** wired (`AuthService.resetPassword` → Supabase Auth, `AuthController.resetPassword`/`resetEmailSent`); **the entry point, reset screen, deep-link/re-token handling and new-password step are NOT implemented** (excluded by that step's scope, not by a decision), and the Supabase redirect/Site-URL target is unconfirmed |
| W1-4 *(hygiene, not a requirement)* | Remove the auth debug logging that prints the sign-up response, user payload and stack traces | supports NFR-AUTH-01 intent | Deletion of log statements only | No behaviour change; reduces credential exposure in logs | None | ✅ **Complete** — 10 statements removed, behaviour unchanged; the one retained auth log line is audited in `docs/wave-1-completion-report.md` Part A |

**Wave 1 exit state (rev 2):** W1-1, W1-2 and W1-4 are complete; W1-3 is partial as described above. Every W1 fix was implemented against a requirement whose `Decision needed` cell is `—`, so **no decision was consumed, resolved or invented**, and none of the Decision Register's 57 items changed status. Full evidence: `docs/wave-1-completion-report.md`.

**Explicitly excluded from Wave 1 even though they look like small fixes**
- Meet-link dead ternary (RTM D1) → needs D-03.
- Single role source of truth (RTM D9/D10) → needs D-25 (and D-19).
- Booking status value change (RTM D5) → needs D-20.
- Applying the document catalogue correction (RTM D7 area) → needs D-17.
- Client-side aggregate removal (RTM D4) → needs D-48.
- Anything touching packages, reschedule or payroll → `UNRATIFIED` (D-12/D-13/D-14).

### 6.3 Modules whose UI already exists but which remain blocked

Recorded so that "the screen is already built" is never used as an argument to start:

| Module | UI state | Blocking item(s) |
|---|---|---|
| Buddy profile (view/edit, interests) | Screens complete | D-45 (persistence contract), D-18, D-24 |
| Tutor profile & documents | Screens complete | D-17, D-22, D-47, D-46 |
| Discovery (list, detail, filters) | Screens complete | D-55, D-23, D-24, D-02 |
| Booking slot picker & booking flow | Screens complete | D-50, D-40, D-20, D-08 |
| Invoice / payment screens | Screens complete | D-08, D-53, D-54, D-16 |
| Session screen (timer, Meet link) | Screen complete | D-03, D-32, D-28 |
| Review screen | Screen complete | *(RATE-01 and RATE-04 were corrected in Wave 1; **all** remaining review work is blocked — D-48 aggregation ownership, D-49 one-review-per-session, D-34 pagination non-blocking)* |
| Tutor availability management | Screen complete | D-50, D-43 |
| Transaction history / earnings | Screens complete | D-53, D-14, D-31 |
| Package / Token, Reschedule, Payroll | Screens complete | `UNRATIFIED` — D-12, D-13, D-14 |
| Admin (monitoring, verification, complaints) | No UI exists | D-10, D-21, D-56, D-41 |

---

## 7. Suggested Wave 0 sequencing (dependency order)

Wave 0 items are not all independent; these edges prevent rework:

1. **D-12 (Package/Token) before D-15, D-16, D-30** — the payment/scope decisions depend on whether prepaid packages exist.
2. **D-01 before D-22** — the verification lifecycle cannot be specified before the actor/SLA is known.
3. **D-20 before D-28 and D-52** — the status vocabulary and the stored/event contract follow the lifecycle.
4. **D-03 before D-32, D-39, D-57** — chat requirements, provider abstraction and the session entity all follow the link-distribution variant.
5. **D-08 before D-54 and D-53** — the QR/expiry authority and the transaction record depend on whether a gateway exists.
6. **D-21 and D-10 before D-56** — the Admin role and permission matrix cannot be designed before the role identifier and the surface form.
7. **D-06 + D-08 before D-40** — reservation TTL must align with QR expiry and the provider's callbacks.
8. **D-05 before D-30** and **D-14/D-07 before D-31** — refund and earnings flows follow the threshold and the split model.
9. **D-17 before the verification gate work** — the gate definition depends on the corrected document catalogue.
10. **P-01/P-02 before everything** — without a ratified, version-controlled baseline, recorded decisions cannot be traced.

---

## 8. Wave 0 must not do (scope guards)

1. Do not modify application source code.
2. Do not create database migrations, Supabase tables, storage buckets or RLS policies.
3. Do not implement business logic, extract domain policies, or introduce repositories/use cases.
4. Do not refactor controllers, models, services or routing.
5. Do not modify existing UI, copy or widget keys.
6. Do not touch the `UNRATIFIED` modules (Package/Token, Reschedule, Payroll, multi-session invoice, `pricePerHour` pricing) — no refactor, no integration, no deletion.
7. Do not invent fallback behaviour to unblock a requirement: an unrecorded decision is not a decision.

*End of Wave 0 plan.*

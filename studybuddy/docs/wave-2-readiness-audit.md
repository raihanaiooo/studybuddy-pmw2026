# Wave 2 Readiness Audit — Study Buddy

**Document type:** Readiness audit (documentation only — **no application source, test, decision, contract or Supabase configuration was changed to produce this document**)
**Date:** 23 September 2026
**Revision:** rev 3 (23 Sep 2026) — **approved corrections applied**: the **D-1 documentation defect is fixed** — the 7 affected §6 item lists are re-derived from the request's actual `Blocks` column; **A-2 is closed** — `FR-DISC-02` was the confirmed coverage gap and is now covered by the official **`C-X-07`** (request rev 5, §10 Cross-cutting), while `FR-DISC-06` was **not** a coverage gap (its only issue was `C-TUT-06`'s `Blocks` declaration, corrected in request rev 5); §7's row 2.5 updated accordingly but **remains BLOCKED**. Wave 2 stays blocked: no requirement became READY solely because `C-X-07` exists — 0 of 81 contract items answered, all 57 decisions OPEN. rev 2 (23 Sep 2026) — finding **A-2 re-validated** after the contract coverage audit (`docs/contract-coverage-audit.md`): the coverage gap is **confirmed for `FR-DISC-02` only** and **withdrawn for `FR-DISC-06`** (already requested by `C-TUT-06`/`C-RATE-05`); §6's two rows and §7's row 2.5 corrected accordingly; a ⚠ note on §6's item column added (finding **D-1**: 7 of its 22 lists disagree with the request's `Blocks` column). rev 1 (23 Sep 2026) — first readiness audit.
**Baseline:** branch `ui-merge`, HEAD `1f1fba5`; the Wave 1 change set is still uncommitted (not committed by this step)
**Scope agreed for this audit:** the union of the four requested sets — RTM §10 Wave 2 rows (2.1–2.8) · unfinished Wave 1 rows (1.4–1.7 plus the 1.3 residue) · all 63 blocked rows (41 decision + 22 contract) · the 8 SRS-tentative (`?`) rows. That union is **every non-aligned requirement: 64 of 74** (74 − the 10 `A` rows).
**Sources used (only):** `docs/requirement-traceability-matrix.md` (rev 2) · `docs/decision-register.md` (rev 2) · `docs/wave-0-plan.md` (rev 2) · `docs/be-contract-request.md` (rev 3) · `docs/wave-1-completion-report.md`. No SRS text is reinterpreted here and no requirement is added or re-worded.

---

## 0. Terms used in this audit

| Term | Meaning |
|---|---|
| **READY NOW** | No open decision and no unanswered contract item is required for the remaining work. Only such rows may be scheduled. |
| **BLOCKED BY DECISION** | A register item (D-01…D-57) must be recorded first. All 57 are still `OPEN`. |
| **BLOCKED BY CONTRACT** | The Back-End/data owner must answer one or more `C-*` items in the contract request first. **0 of 81 have been answered** (81 items since request rev 5 added `C-X-07`). |
| **SRS-TENTATIVE (`?`)** | The SRS itself declares the requirement tentative; it cannot even be judged until the named product decision lands. |

---

## 1. Method and evidence

Every figure below is machine-derived from the documents listed above, not hand-counted:

1. The RTM's 74 requirement rows were re-parsed (status, decision cell, wave/priority).
2. The Wave 0 plan's three classification lists were parsed and reconciled: `1 + 10 + 41 + 22 = 74`.
3. The contract request's 80 items were parsed and **reverse-mapped** (item → requirement) so each Wave 2 row can name the exact items that request its data.
4. Every `D-nn` and requirement ID cited was validated to exist (0 unknown references).
5. Wave 1's completion state was read from the RTM rows and the Wave 1 report (W1-1/W1-2/W1-4 complete, W1-3 partial).

---

## 2. Verdict

**Wave 2 cannot start.** No Wave 2 requirement is READY NOW:

* **57 of 57 decisions are `OPEN`** — not one Wave 0 decision has been recorded, and the Wave 0 exit criteria are therefore unmet (`docs/wave-0-plan.md` §1).
* **0 of 81 contract items have been answered** — the request is unanswered in full, so every contract-blocked row is still blocked, including the slot, booking, verification, document-storage and payment contracts that Wave 2 depends on most.
* **Wave 1 left exactly one requirement with startable work: `FR-AUTH-05`** (the forgot-password UI residue) — and that is Wave 1 work, **not** Wave 2.
* The Wave 2 blockers also overlap the largest correctness gaps in the RTM: slot locking (2.1), the verification gate (2.4), profile/document persistence (2.3) and server-owned rating aggregation (2.8) all need a decision **and** a contract answer.

**Nearest to startable (still blocked):** Wave 2.2 (`NFR-BOOK-02` realtime) needs only `D-52` plus `C-BOOK-06`/`C-X-01` — the realtime plumbing already exists in the client (`realtime_service.dart`), but the event contract is unrequested-and-unanswered, so writing it now would mean inventing the payload.

---

## 3. READY NOW — 1 requirement (Wave 1 residue, not Wave 2)

| Requirement | RTM status | What remains | What is *not* blocking | Watch out for |
|---|---|---|---|---|
| **FR-AUTH-05** — forgot password (reset via email) | **P** | The user-facing entry point, the reset screen, reset-token/deep-link handling and a new-password step. The email-send mechanism already exists (`AuthService.resetPassword` → Supabase Auth `resetPasswordForEmail`, `AuthController.resetPassword`/`resetEmailSent`) | `D-42` (screen copy/steps) is explicitly **non-blocking**, and no contract item gates the *client* work — `C-AUTH-06` asks a configuration question | The emailed link returns to the Supabase project's configured redirect/Site URL. That target is **unverified from this repository**; it is the one non-decision dependency. Confirm before treating the flow as end-to-end complete |

No other requirement in the 64 may be scheduled without first recording a decision or receiving a contract answer.

---

## 4. The 8 SRS-tentative (`?`) rows — cannot even be judged yet

| Requirement | Blocking decision | Contract item(s) requesting its data | Note |
|---|---|---|---|
| FR-SESI-02 | **D-03** (Meet link varian A vs B) | C-SESS-02 | Also depends on chat existing (FR-SESI-03) for varian B |
| FR-SESI-05 | **D-04** (notification mechanism + lead time) | C-SESS-06, C-SESS-07 | FCM plumbing is inert (`initialize()` commented out) |
| FR-SESI-07 | **D-11** (connection-loss SOP automation) | **none — correct by design** (F-7) | No contract can be shaped before the SOP is decided |
| FR-PAY-04 | **D-05** (refund threshold) | **none — correct by design** (F-7) | The refund *record* is `C-PAY-09`, but the rule itself is a value decision |
| FR-PAY-06 | **D-07** (70/30 automatic vs manual) | C-PAY-10 | — |
| NFR-AUTH-03 | **D-09** (minor/parental consent) | C-AUTH-08, C-X-06 | Requires an integration point only, per the SRS |
| NFR-PROF-04 | **D-09** | C-AUTH-08, C-DOC-09, C-X-06 | Conditional on NFR-AUTH-03 |
| NFR-PAY-03 | **D-06** (final expiry value + authority) | C-SLOT-06, C-PAY-06 | Interacts with the slot lock (2.1) |

---

## 5. BLOCKED BY DECISION — 41 rows, inverted by decision (32 decisions)

Presented inverted (decision → the requirements it gates) because that is the unit Wave 2 has to buy: recording one decision unblocks several rows at once.

| Decision | Requirements gated | Wave(s) | Owner per SRS |
|---|---|---|---|
| **D-01** verification flow | FR-PROF-07, FR-PROF-08, FR-ADM-02 | 2.4, 4 | FOUNDER+ADMIN |
| **D-02** recommendation factors | NFR-DISC-02 | 4 | FOUNDER |
| **D-03** Meet varian A/B | FR-SESI-01, FR-SESI-02 | 1.5, 3 | FOUNDER |
| **D-04** notification mechanism | FR-BOOK-06, FR-SESI-05 | 3 | FOUNDER |
| **D-05** refund threshold | FR-BOOK-08, FR-PAY-04 | 2.7 | COO/CFO |
| **D-07** split automation | FR-PAY-06 | 3 | FOUNDER |
| **D-09** minor consent | NFR-AUTH-03, NFR-PROF-04 | 4 | FOUNDER |
| **D-10** Admin dashboard form | FR-ADM-01, FR-ADM-02, FR-ADM-03, FR-ADM-04, NFR-ADM-01 | 4 | FOUNDER+INT |
| **D-11** connection-loss automation | FR-SESI-07 | 4 | FOUNDER+INT |
| **D-17** document catalogue | FR-PROF-05, FR-PROF-06 | 2.3 | FOUNDER |
| **D-18** "Umum" option | FR-AUTH-06 | 1.4 | FOUNDER |
| **D-19** role vocabulary | FR-AUTH-01 | 1.7 | FOUNDER (+BE) |
| **D-20** booking lifecycle | FR-BOOK-03 | 1.6 | FOUNDER |
| **D-21** Admin role identifier | NFR-ADM-01 | 4 | FOUNDER (+BE) |
| **D-22** verification lifecycle/permissions | FR-PROF-07, FR-PROF-08, FR-PROF-09, FR-ADM-02 | 2.3, 2.4, 4 | FOUNDER+ADMIN |
| **D-23** grade-levels-taught shape | FR-PROF-04, FR-DISC-03 | 2.3, 2.5 | FOUNDER |
| **D-25** role source of truth | FR-AUTH-07 | 1.7, 2.8 | BE |
| **D-26** Buddy onboarding content | FR-AUTH-07 | 2.8 | FOUNDER |
| **D-27** achievement badge | FR-PROF-10 | 2 | FOUNDER |
| **D-28** session status mapping | FR-SESI-06 | 3 | INT |
| **D-29** "Booking Kamu" surface | FR-BOOK-07 | 2.6 | FOUNDER+FE |
| **D-30** refund request flow | FR-PAY-05 | 2.7 | FOUNDER |
| **D-32** chat mechanics | FR-SESI-03, NFR-SESI-03 | 3 | FOUNDER (+BE) |
| **D-33** chat window boundaries | FR-SESI-04 | 3 | FOUNDER |
| **D-36** 5 MB binding | NFR-PROF-02 | 2.3 | BE (+INT) |
| **D-37** discovery latency conditions | NFR-DISC-01 | 4 | INT |
| **D-38** availability reminder in MVP | NFR-BOOK-03 | 4 | FOUNDER+INT |
| **D-39** provider abstraction in MVP | NFR-SESI-02 | 3 | INT |
| **D-40** slot reservation TTL | NFR-BOOK-01 | 2.1 | INT (+BE) |
| **D-41** complaint entity | FR-ADM-04 | 4 | FOUNDER |
| **D-43** availability UI shape | FR-BOOK-01 | 2.5 | FE (+FOUNDER) |
| **D-44** Buddy activity stats | FR-PROF-03 | 4 | FOUNDER |

**Wave 2's decision bill is 20 of the 57 register items** — machine-derived from the plan's own lists for the 28 Wave 2 rows (15 decision-blocked rows name 12 items; 13 contract-blocked rows name 9; D-40 appears in both): **D-01, D-05, D-17, D-22, D-23, D-24, D-25, D-26, D-29, D-30, D-36, D-40, D-43, D-45, D-47, D-48, D-50, D-51, D-52, D-55**. They are the `Decisions required` column of §7. The remaining 37 items gate Wave 1.4–1.7, Wave 3, Wave 4, the Admin/consent/notification surfaces and the unratified modules (D-12…D-16).

---

## 6. BLOCKED BY CONTRACT — all 22 rows, each with the items that would unblock it

Reverse-mapped from the contract request, so this is exactly what the Back-End owner must answer for each row. **None is answered.**

⚠ **Accuracy note on the item column (rev 3 — D-1 fixed).** rev 1 assembled this column by hand from the `Blocks` column and **7 of the 22 rows disagreed with the request's own `Blocks` column** (`FR-PAY-01`, `FR-PAY-02`, `FR-PAY-03`, `FR-PAY-07`, `FR-RATE-03`, `NFR-PAY-01`, `NFR-PAY-02` — exact deltas in `docs/contract-coverage-audit.md` §5, finding **D-1**). **Corrected in rev 3 (approved): those seven rows are now derived directly from the request's `Blocks` column.** This changed no requirement's blocked status (all 22 remain blocked — nothing is answered) and created no coverage gap; the substantive per-row verdicts remain in that document's §4.

| Requirement | Contract item(s) | Decision also required |
|---|---|---|
| FR-AUTH-02 | C-AUTH-03 | D-45 (BLOCKED) |
| FR-PROF-01 | C-AUTH-03, C-AUTH-05, C-AUTH-09, C-X-03 | D-24 |
| FR-PROF-02 | C-AUTH-03, C-AUTH-05 | — |
| FR-DISC-01 | C-TUT-05, C-SLOT-08 | — |
| FR-DISC-02 | **`C-X-07`** — official as of request rev 5 (§10 Cross-cutting); closes the former coverage gap A-2/G-1, and is itself unanswered | D-55 (BLOCKED) |
| FR-DISC-06 | `C-TUT-06`, `C-RATE-05` — the data **is** requested (G-2 resolved in request rev 5: `C-TUT-06`'s `Blocks` cell now lists `FR-DISC-06`) | D-55 (BLOCKED) |
| FR-BOOK-02 | C-SLOT-01, C-SLOT-07, C-X-05 | — |
| FR-BOOK-04 | C-SLOT-03, C-SLOT-04, C-SLOT-05, C-SLOT-06, C-PAY-06 | D-40, D-06 |
| FR-BOOK-05 | C-SLOT-03, C-SLOT-07 | D-40 |
| FR-BOOK-09 | C-BOOK-02, C-BOOK-07, C-PAY-03 | — |
| FR-PAY-01 | C-PAY-02, C-PAY-05, C-TUT-08 | D-08 (BLOCKED) |
| FR-PAY-02 | C-PAY-01, C-PAY-03, C-PAY-04, C-PAY-07, C-TUT-08 | D-08 (BLOCKED) |
| FR-PAY-03 | C-BOOK-03, C-PAY-02, C-TUT-08 | D-20 |
| FR-PAY-07 | C-PAY-10, C-PAY-11 | D-31, D-14 |
| FR-RATE-03 | C-TUT-06, C-RATE-04 | D-48 |
| NFR-RATE-01 | C-RATE-02, C-RATE-03 | D-49 |
| NFR-PROF-01 | C-DOC-01, C-DOC-04, C-DOC-05, C-ADM-07, C-X-03 | — |
| NFR-PROF-03 | C-DOC-02 | — |
| NFR-BOOK-02 | C-BOOK-06, C-X-01 | D-52 (BLOCKED) |
| NFR-PAY-01 | C-BOOK-03, C-PAY-01, C-PAY-08, C-ADM-04 | D-53 |
| NFR-PAY-02 | C-PAY-04, C-PAY-07 | D-08 (BLOCKED) |
| NFR-PAY-03 | C-PAY-06, C-SLOT-06 | D-06 |

**Wave 2's contract bill is 41 of the 81 items** — machine-derived as the union of the `Blocks` column over all 28 Wave 2 rows: `C-ADM-02, C-ADM-07, C-AUTH-02, C-AUTH-03, C-AUTH-05, C-AUTH-09, C-BOOK-02, C-BOOK-05, C-BOOK-06, C-BOOK-07, C-BOOK-08, C-DOC-01…C-DOC-08, C-PAY-03, C-PAY-06, C-PAY-09, C-RATE-04, C-SLOT-01…C-SLOT-08, C-TUT-01…C-TUT-06, C-X-01, C-X-03, C-X-05, C-X-07`. None is answered, so every contract-blocked row remains blocked. (`C-X-07` entered this union in rev 3 when it became official in request rev 5; 40 → 41 and 80 → 81 are bookkeeping changes only — no row changed status.)

---

## 7. Wave 2 sub-wave gate table

| Sub-wave | Requirements | Decisions required | Contract items required | Verdict |
|---|---|---|---|---|
| **2.1** Slot integrity | FR-BOOK-04, FR-BOOK-05, NFR-BOOK-01 | D-40, D-50 | C-SLOT-03, C-SLOT-04, C-SLOT-05, C-SLOT-06, C-SLOT-07, C-PAY-06 | **BLOCKED** — the keystone of Wave 2; nothing else in 2.5/2.7 is safe before it |
| **2.2** Realtime booking state | NFR-BOOK-02 | D-52 | C-BOOK-06, C-X-01 | **BLOCKED** — nearest to startable: the only gap is the event payload contract |
| **2.3** Profile & document persistence | FR-PROF-01, FR-PROF-02, FR-PROF-04, FR-PROF-05, FR-PROF-06, FR-PROF-09, NFR-PROF-01, NFR-PROF-02, NFR-PROF-03 | D-17, D-22, D-23, D-24, D-36, D-45, D-47 | C-AUTH-03, C-AUTH-05, C-AUTH-09, C-X-03, C-TUT-01, C-TUT-02, C-DOC-01…C-DOC-08, C-ADM-07 | **BLOCKED** — largest contract surface of the wave |
| **2.4** Verification gate & verified-only search | FR-PROF-07, FR-PROF-08, FR-DISC-01 | D-01, D-22, D-55 | C-TUT-03, C-TUT-04, C-TUT-05, C-DOC-07, C-DOC-08, C-SLOT-08, C-ADM-02 | **BLOCKED** — must land before the discovery filters (2.5) are meaningful |
| **2.5** Filters, cards, real slots | FR-DISC-02, FR-DISC-03, FR-DISC-06, FR-BOOK-01, FR-BOOK-02 | D-23, D-43, D-50, D-55 | C-TUT-02, C-SLOT-01, C-SLOT-02, C-SLOT-07, C-X-05, C-X-07 | **BLOCKED** — the former discovery-filter coverage gap is now closed (official `C-X-07`, request rev 5), but the sub-wave remains blocked by its other decisions/contracts: D-23, D-43, D-50, D-55 are all OPEN and every listed contract item is unanswered |
| **2.6** "Booking Kamu" list & detail | FR-BOOK-07, FR-BOOK-09 | D-29, D-51 | C-BOOK-02, C-BOOK-07, C-BOOK-08, C-PAY-03 | **BLOCKED** |
| **2.7** Refund, cancellation, refund requests | FR-PAY-04, FR-BOOK-08, FR-PAY-05 | D-05, D-30 | C-BOOK-05, C-PAY-09 | **BLOCKED** — the rule value (D-05) and the record shape are both missing |
| **2.8** Server-owned aggregate & onboarding | FR-RATE-03, FR-AUTH-07 | D-25, D-26, D-48 | C-TUT-06, C-RATE-04, C-RATE-05, C-AUTH-02 | **BLOCKED** |

**No sub-wave is startable. There is no READY NOW row inside Wave 2 at all.**

---

## 8. Minimum set to record before any Wave 2 code

1. **Decisions first (12):** D-20 → D-40 → D-50 → D-52 → D-01/D-22 → D-17 → D-23 → D-36 → D-24 → D-29 → D-30 → D-43/D-55 (sequencing per `docs/wave-0-plan.md` §7; D-05 is needed the moment 2.7 starts).
2. **Then the contract answers in this order** (highest leverage first, matching `docs/be-contract-request.md` §11.2): identity/profile (C-AUTH-01/03/04/05) → slots (C-SLOT-03/04/06/07) → verification & private storage (C-TUT-03/04/05, C-DOC-01/04/05/07) → booking status & realtime (C-BOOK-01/06, C-SESS-03, C-X-01) → payment records (C-PAY-01/03/08/09) → discovery (C-X-07, now official — request rev 5) → rating (C-RATE-01…06).
3. **Prerequisites from `docs/wave-0-plan.md` §5:** P-01 (ratify the baseline) and P-02 (commit the requirement docs to VCS) still stand and gate everything; P-04 is now **partly satisfied** (baseline recorded: `flutter analyze` 0 errors, 41 passed / 1 pre-existing failure); P-07 is partly satisfied (defects D1/D4–D7/D9/D10 still tracked, D2/D3/D8 resolved in Wave 1).
4. **Nothing else.** No Wave 2 code, schema, RLS, bucket or gateway work is authorised until the above lands.

---

## 9. Audit findings (this step)

| # | Finding | Type | Status |
|---|---|---|---|
| **A-1** | `docs/be-contract-request.md` §11.1 mis-filed `C-SESS-07` (primary class is IMPLIED, listed under NOT SPECIFIED). Listing counts were also never stated despite the section heading. | Documentation defect | **FIXED** — re-filed; counts restated machine-derived: 67 / 5 / 13 = 85 listings over 80 items |
| **A-2** | *(rev 3 — CLOSED.)* The confirmed coverage gap was **`FR-DISC-02` alone** (finding **G-1**); `FR-DISC-06` was **not** a coverage gap — its data is requested by `C-TUT-06`/`C-RATE-05`, and its only issue was the incomplete `Blocks` declaration on `C-TUT-06` (finding **G-2**, corrected in request rev 5). **`C-X-07` is now an official contract item** (request rev 5, §10 Cross-cutting) **and closes that gap.** Original rev-1 wording, for traceability: *"Two Wave 2 requirements have no contract item requesting them (`FR-DISC-02`, `FR-DISC-06`), although the Wave 0 plan classifies both as BLOCKED BY BACKEND CONTRACT via D-55."* The **subject/topic filter** was the one Wave 2 contract area with no question on the wire. | Coverage gap | **CLOSED in rev 3 (approved)** — `C-X-07` applied as item 81. No Wave 2 requirement became READY as a result: `FR-DISC-02` is still contract-blocked (`C-X-07` unanswered, like all 81 items) and decision-blocked (D-55 OPEN) |
| **A-3** | **D-58 was considered and rejected.** The candidate decision ("which Supabase redirect/Site URL the reset email returns to") is a **configuration fact, not a choice among SRS-supported options**; it is already represented by the existing contract item **C-AUTH-06** (which asks exactly that question) and by **D-42**, which owns FR-AUTH-05's decision surface (OPEN, non-blocking) and already records the unverifiable target. Registering it would create an item with an empty option set — a new question, not a new decision. | Process | **No action** — no D-58, no register edit, no count change |
| **A-4** | Every `D-nn` and requirement ID cited across the five documents resolves (0 unknown references), and the three classification systems agree: RTM 57 flagged / 17 un-flagged ↔ plan 63 blocked + 1 READY + 10 MAINTAIN ↔ register 57/57 coverage. | — | Verified, no action |
| **A-5** | Wave 1 residue is larger than the Wave 2 gate: FR-AUTH-05 is READY NOW, and Wave 1 rows 1.4–1.7 remain blocked by D-18/D-19/D-20/D-45/D-03 (see `docs/wave-0-plan.md` §6.2). | Status | Reported — Wave 1.4–1.7 must not be scheduled ahead of their decisions merely because they were "Wave 1" |

---

## 10. Explicitly not done (scope guards honoured)

1. **No source or test change** — `lib/` and `test/` are untouched by this step; the Wave 1 change set remains uncommitted and **was not committed**.
2. **No Wave 2 implementation** — no slot locking, booking lifecycle, Tutor verification, payment, chat, session/Meet, Admin, Package/Token, Reschedule or Payroll work.
3. **No product decision made and none resolved** — all 57 register items remain `OPEN`; no option was chosen, no owner changed, no status changed.
4. **No contract answered and none invented** — the `` `BACKEND DECISION REQUIRED` `` items remain unassumed; no table, column, policy, endpoint, migration, bucket or Supabase configuration was created or modified.
5. **No forgot-password UI or copy was drafted or implemented**, and the D-58 question was *not* registered.
6. **Documentation changed in this step:** `docs/be-contract-request.md` (rev 3 — §11.1 correction + §11.4 findings) and this new document only.

*End of audit.*

# Contract Coverage Audit — discovery-filter gap (finding A-2)

**Document type:** Read-only audit + **proposal only**. **No requirement, decision, contract item, source file, test, schema, migration, RLS policy, storage bucket or Supabase configuration was created, changed or deleted to produce this document.** Nothing in this document is applied.
**Date:** 23 September 2026
**Revision:** rev 1 (23 Sep 2026) — re-validation of finding **A-2** (`docs/wave-2-readiness-audit.md` §9) and of finding **F-2** (`docs/be-contract-request.md` §11.4); full contract-coverage sweep across the 22 contract-blocked rows.
**Baseline:** branch `ui-merge`, HEAD `1f1fba5`; the Wave 1 change set is still uncommitted (this step did not commit it).
**Sources used (only):** `docs/be-contract-request.md` (rev 3) · `docs/wave-2-readiness-audit.md` (rev 1) · `docs/wave-0-plan.md` (rev 2) · `docs/requirement-traceability-matrix.md` (rev 2) · `docs/decision-register.md` (rev 2). No SRS text is reinterpreted here; no requirement is added, removed or re-worded; **no decision is created or resolved**.

---

## 1. What "coverage" means here, and how it was tested

A contract-blocked requirement is **covered** when at least one item in `docs/be-contract-request.md` *asks the data owner for the data or behaviour that requirement needs*. Three tests were applied to every contract-blocked row, in order:

| Test | Question asked of the source documents |
|---|---|
| **T1 — mention** | Does **any** cell of any `C-*` item (class, SRS basis, current assumption, question, blocks) name this requirement ID? |
| **T2 — substance** | Does the *question* cell of a mentioning item actually ask for what the requirement needs — not merely cite the ID as provenance? |
| **T3 — alternative** | If no single item asks it, does a *different* item's question nevertheless obtain the same data (e.g. a generic "field set" question that subsumes a specific field)? |

**Method note (and why rev 1 of the readiness audit was too harsh).** The reverse map in `docs/wave-2-readiness-audit.md` §6 was built from the `Blocks` column **only**. That column records which requirements an *answer* unblocks; it is not the only place an item can ask for a requirement's data. Scanning the whole row (T1) and then judging substance (T2) changes the *mentioned-by* listing in **9 of the 22 rows**, and shows that §6's item column disagrees with the request's own `Blocks` column in **7** of them (finding **D-1**, §5). Only **one** row turns out to be a coverage gap (§4.3). The verdict for each row below is the T2/T3 judgement, not the mention count.

**Test set:** all **22** rows the Wave 0 plan classifies BLOCKED BY BACKEND CONTRACT (`docs/wave-0-plan.md` §6.2), i.e. the same 22 rows listed in the readiness audit §6.

---

## 2. A-2 validation

`docs/wave-2-readiness-audit.md` §9 **A-2** stated: *"Two Wave 2 requirements have no contract item requesting them (`FR-DISC-02`, `FR-DISC-06`)."* Re-validated against the request itself, **that statement is half right.**

### 2.1 `FR-DISC-02` — filter search by subject/topic → **CONFIRMED COVERAGE GAP**

| Test | Evidence |
|---|---|
| T1 — mention | **Zero.** No `C-*` item names `FR-DISC-02` in any cell (machine-checked over all 80 items). This is the only requirement in the 22-row set with no mention at all. |
| T2 — substance | Not applicable — nothing mentions it. |
| T3 — alternative | **Fails.** The nearest items do not obtain this requirement's data: `C-TUT-01` asks *which* Tutor fields exist and what the display name / key are (a field-*existence* question; it does not establish the subject value basis or how a filter matches); `C-TUT-05` asks only where the **verified-only** rule is enforced; `C-TUT-06`/`C-RATE-05` ask about rating aggregates. |

**The asymmetry that proves the gap is real.** The SRS defines exactly two discovery filters: subject/topic (`FR-DISC-02`) and grade level taught (`FR-DISC-03`). The request has a dedicated item for the **grade-level** filter's basis — `C-TUT-02` ("Grade levels taught (data shape)", explicitly justified as *"FR-DISC-03 filters by it"*). The **subject/topic** filter has no equivalent item. Register decision **D-55** ("Discovery query contract") names `FR-DISC-02` in its `Reqs` line and states that the subject filter "must be expressible server-side" — but a decision records a *choice to be made*, it does not ask the data owner for the value basis or the match semantics. **The gap is real and it is not a decision that is missing; it is a request that is missing.**

Current client state, for the record: `lib/controllers/tutor_controller.dart` (`searchQuery` / `_applyFilter`) matches typed text against `full_name` and `subjects` with a 300 ms debounce; `lib/models/tutor_model.dart` maps `subjects` as a single field; `lib/views/customer/tutor_list_screen.dart` has no subject/topic filter control (RTM row `FR-DISC-02`, status **P**).

### 2.2 `FR-DISC-06` — result card fields → **NOT A COVERAGE GAP (A-2 was wrong about this row)**

| Card element (SRS) | Item that asks for the data | Substance |
|---|---|---|
| average rating | `C-TUT-06` — *"Are these stored aggregates or computed? If stored, who writes them, and may the client write them at all?"* | ✅ asks it |
| completed-session count | `C-TUT-06` (same question; `total_sessions` is named in its current-assumption cell) + `C-RATE-05` ("Tutor aggregate fields used in ranking and display — confirm these fields exist and their authoritative sources") | ✅ asks it |
| name, subjects | `C-TUT-01` (field set; includes the display-name and key questions) | ✅ asks it |
| photo | `C-AUTH-09` (avatar field) + `C-X-03` (bucket inventory and read rules) | ✅ asks it |

`C-TUT-06`'s **class** cell already declares provenance — *"…; FR-DISC-06 shows rating and session count"*. What is missing is only that its **`Blocks` cell** does not list `FR-DISC-06` (it lists `FR-RATE-03, FR-PROF-10, FR-DISC-04`). So the data **is** requested; the declaration is incomplete. That is a documentation defect (**G-2**, §4.2), not a missing request, and it does **not** justify a new item. Finding A-2 is therefore **narrowed to one requirement**, `FR-DISC-02`.

### 2.3 Verdict

| Row | A-2 (rev 1) | Re-validated |
|---|---|---|
| `FR-DISC-02` | coverage gap | **CONFIRMED coverage gap** (G-1) |
| `FR-DISC-06` | coverage gap | **NOT a gap** — asked by `C-TUT-06` (+`C-RATE-05`); `Blocks` cell declaration incomplete (G-2) |

---

## 3. Proposed contract item — `C-X-07`

**Status: PROPOSED — PENDING APPROVAL. Not applied. Not counted. Not official item 81.**

Scope is deliberately the **narrowest set that closes G-1**. Formatted as a drop-in row for the request's tables (7 columns, same column order).

| C-X-07 | Subject/topic filter basis (discovery) | **REQUIRED BY SRS** (FR-DISC-02: filter search by mata pelajaran/topik; §4.1 `TutorProfile.mata_pelajaran`) → value basis and match semantics **NOT SPECIFIED BY SRS** → **`BACKEND DECISION REQUIRED`** | FR-DISC-02 (related decision: D-55) | `controllers/tutor_controller.dart › searchQuery` / `_applyFilter` matches typed text against `full_name` and `subjects`; `models/tutor_model.dart` maps `subjects` as a single field; no filter control exists in `views/customer/tutor_list_screen.dart` | **(1)** In what form are a Tutor's subjects/topics stored — a controlled value set, free text, or a related record? If a controlled set exists, what is it? **(2)** How must a filter match them — exact membership of a stored value, or text/substring matching as the client does today? **(3)** Must the filtering be evaluated on the server (query or read rule), or may the client fetch the searchable fields and filter locally — and is that answer the same one that governs verified-only enforcement (`C-TUT-05`)? | FR-DISC-02 | *(proposal — not part of the request until approved)* |

**Why each question is necessary, and nothing more:**

1. **Q1** — the filter cannot be built without knowing whether subjects are a fixed value set or free text: a value set produces a picker, free text produces a search field. `C-TUT-01` establishes only that the field exists.
2. **Q2** — "filter by subject" can mean exact value membership or substring matching; the two produce different results for the same data, and today's client behaviour (substring) may not be the intended one.
3. **Q3** — decides whether the answer is a query/read rule the client must write or fields the client may read and filter itself. Phrased as a question, not an assumed mechanism, because how filters are enforced is **not specified by the SRS** (the same open question D-55 already owns for verified-only enforcement).

**Explicitly outside the scope of this proposal** — each already requested elsewhere, which is what keeps this item minimal: verified-only enforcement (`C-TUT-05`) · grade-level filter basis (`C-TUT-02` + D-23) · ranking aggregates (`C-TUT-06`/`C-RATE-04`/`C-RATE-05` + D-48) · availability indicator (`C-TUT-07`, `C-X-02`) · result-card field list (`C-TUT-01`, `C-TUT-06`, `C-X-03`, `C-AUTH-09`) · latency acceptance conditions (`NFR-DISC-01` is gated by D-37, not by a contract item).

**ID and placement.** `C-X-07` is proposed in the **Cross-cutting** group (§10) to keep the ID promised by F-2/A-2 traceable. The values themselves live on the Tutor record, so the Tutor group is an equally defensible home; if the team prefers that, the same row may be filed as `C-TUT-09`. One ID must be chosen at approval time — the item is the same either way.

**Count impact if approved:** unique items **80 → 81**; listings **85 → 87** (primary class `REQUIRED BY SRS` 67 → 68, `NOT SPECIFIED` 13 → 14, `IMPLIED` 5 unchanged); dual-class items **5 → 6** (this item would carry a secondary `NOT SPECIFIED` for the value basis, exactly as `C-TUT-02` does). No other item, class, question or blocking relationship changes.

**Does the proposal create a new decision?** No. It names **D-55** as the related decision and does not widen it. One branch of Q1 could reveal a *product* choice (which subjects exist, if the answer is "a free value set we invent"). That branch is **not** registered as a decision here, no `D-58` is created, and none is proposed for creation: like the A-3 candidate, it may turn out to be a data fact the Back-End owner can simply report. **If and only if** the answer is "no set exists and the team must choose one", the correct move would be to widen `D-55` (or add a decision with an explicit justification of the same standard used in A-3) — and that requires explicit approval, exactly like this proposal.

---

## 4. Additional coverage-gap audit (same pattern)

All 22 contract-blocked rows were tested with T1→T2→T3. Result:

| # | Requirement | Existing blocker | Contract item(s) that ask for the needed data | Verdict |
|---|---|---|---|---|
| 1 | `FR-AUTH-02` | C-AUTH-03 · D-45 | `C-AUTH-03` (asks which profile fields exist, incl. `nomor HP`/`jenjang`) | covered |
| 2 | `FR-PROF-01` | C-AUTH-03/05/09, C-X-03 · D-24 | same four items | covered |
| 3 | `FR-PROF-02` | C-AUTH-03, C-AUTH-05 | same | covered |
| 4 | `FR-DISC-01` | C-TUT-05, C-SLOT-08 | same | covered |
| 5 | **`FR-DISC-02`** | none · D-55 | **none — no item mentions it (T1 = 0)** | **GAP (G-1) → C-X-07 proposed** |
| 6 | `FR-DISC-06` | C-TUT-06, C-RATE-05 | `C-TUT-06` (aggregates incl. `total_sessions`), `C-RATE-05`; card's other fields via `C-TUT-01`/`C-X-03` | covered — `Blocks` declaration incomplete (G-2) |
| 7 | `FR-BOOK-02` | C-SLOT-01/07, C-X-05 | same (+`C-BOOK-02`) | covered |
| 8 | `FR-BOOK-04` | C-SLOT-03/04/05/06, C-PAY-06 | same | covered |
| 9 | `FR-BOOK-05` | C-SLOT-03, C-SLOT-07 | same | covered |
| 10 | `FR-BOOK-09` | C-BOOK-02/07, C-PAY-03 | same | covered |
| 11 | `FR-PAY-01` | C-PAY-01/05 | `C-PAY-01` (payment fields), `C-PAY-05` (QR payload), `C-TUT-08` (price source), `C-PAY-02` (amount authority) | covered |
| 12 | `FR-PAY-02` | C-PAY-03, C-PAY-07 | same + `C-PAY-01`, `C-PAY-04` | covered |
| 13 | `FR-PAY-03` | C-BOOK-02, C-PAY-03 | `C-BOOK-03` (booking↔payment), `C-PAY-02/03`, `C-TUT-08` | covered |
| 14 | `FR-PAY-07` | C-PAY-11 | `C-PAY-11` (earnings read shape), `C-PAY-10` (split record) | covered |
| 15 | `FR-RATE-03` | C-TUT-06, C-RATE-04 | same | covered |
| 16 | `NFR-RATE-01` | C-RATE-02, C-RATE-03 | same (uniqueness + cardinality) | covered |
| 17 | `NFR-PROF-01` | C-DOC-01, C-DOC-04/05, C-ADM-07, C-X-03 | same | covered |
| 18 | `NFR-PROF-03` | C-DOC-02 | same (format restriction) | covered |
| 19 | `NFR-BOOK-02` | C-BOOK-06, C-X-01 | same | covered |
| 20 | `NFR-PAY-01` | C-PAY-08 | `C-PAY-08` (immutability/retention) + `C-PAY-01`, `C-BOOK-03`, `C-ADM-04` | covered |
| 21 | `NFR-PAY-02` | C-PAY-07, C-PAY-06 | `C-PAY-07` (callback ingestion), `C-PAY-04` (provider reference), `C-PAY-06` (expiry) | covered |
| 22 | `NFR-PAY-03` | C-PAY-06, C-SLOT-06 | same (expiry value + release) | covered |

### 4.1 `G-1` — the only coverage gap

| Field | Value |
|---|---|
| **Requirement** | `FR-DISC-02` — filter search by subject/topic (RTM status **P**, Wave 2 / P2) |
| **Existing blocker** | None recorded in the RTM's decision column; the Wave 0 plan lists it as contract-blocked via `D-55` (OPEN). Contract item: **none** |
| **Missing contract coverage** | The stored form of a Tutor's subjects/topics, the match semantics of a subject filter, and whether the filter is evaluated server-side |
| **Proposed C-* item** | `C-X-07` (§3), **PROPOSED — PENDING APPROVAL** |
| **Why it is necessary** | The requirement cannot be implemented against unknown data shape: a controlled value set and free text produce different UIs and different queries. `C-TUT-02` covers the sibling filter (`FR-DISC-03`) but nothing covers this one |
| **Changes the item count?** | **Yes, if approved** — 80 → 81 items, 85 → 87 listings (§3) |

### 4.2 `G-2` — declaration defect (not a gap)

| Field | Value |
|---|---|
| **Requirement** | `FR-DISC-06` — result card shows photo, name, subject, rating, completed-session count |
| **Existing blocker** | `C-TUT-06`, `C-RATE-05` (+`C-TUT-01`, `C-X-03`, `C-AUTH-09` for the other elements) |
| **Missing contract coverage** | **None.** `C-TUT-06` asks for exactly the rating and completed-session data, and its class cell already cites `FR-DISC-06` |
| **Proposed C-* item** | **None — a new item would duplicate `C-TUT-06`** |
| **Why it is necessary** | Not a request gap. Recommended one-cell correction: add `FR-DISC-06` to `C-TUT-06`'s `Blocks` cell (its question already answers the requirement), so the reverse map stops reporting it as uncovered. **No count change.** Awaiting approval (§6) |
| **Changes the item count?** | **No** |

### 4.3 Statement required by the scope

**For the pattern "classified BLOCKED BY BACKEND CONTRACT but no `C-*` item actually asks for the contract": `FR-DISC-02` is the ONE AND ONLY gap found.** No second instance exists. The 21 other rows each have at least one item whose *question* asks for the data or rule the requirement needs; `FR-DISC-06` is a declaration defect in one `Blocks` cell, not a missing request.

---

## 5. Further findings discovered while auditing (reported, not applied)

### D-1 — 7 of the 22 item lists in `wave-2-readiness-audit.md` §6 disagree with the request's own `Blocks` column

Rev 1 of §6 was assembled from the `Blocks` column **by hand**, and 7 rows differ from the machine-derived set. Both directions occur:

| Requirement | §6 (rev 1) lists | `Blocks` column says | Δ |
|---|---|---|---|
| `FR-PAY-01` | C-PAY-01, C-PAY-05 | C-PAY-02, C-PAY-05, C-TUT-08 | missing `C-PAY-02`, `C-TUT-08`; extra `C-PAY-01` |
| `FR-PAY-02` | C-PAY-03, C-PAY-07 | C-PAY-01, C-PAY-03, C-PAY-04, C-PAY-07, C-TUT-08 | missing `C-PAY-01`, `C-PAY-04`, `C-TUT-08` |
| `FR-PAY-03` | C-BOOK-02, C-PAY-03 | C-BOOK-03, C-PAY-02, C-TUT-08 | missing `C-BOOK-03`, `C-PAY-02`, `C-TUT-08`; extra `C-BOOK-02`, `C-PAY-03` |
| `FR-PAY-07` | C-PAY-11 | C-PAY-10, C-PAY-11 | missing `C-PAY-10` |
| `FR-RATE-03` | C-TUT-06, C-RATE-04, C-RATE-05 | C-TUT-06, C-RATE-04 | extra `C-RATE-05` |
| `NFR-PAY-01` | C-PAY-08 | C-BOOK-03, C-PAY-01, C-PAY-08, C-ADM-04 | missing `C-BOOK-03`, `C-PAY-01`, `C-ADM-04` |
| `NFR-PAY-02` | C-PAY-07, C-PAY-06 | C-PAY-04, C-PAY-07 | missing `C-PAY-04`; extra `C-PAY-06` |

This does not change any requirement's blocked/unblocked status (all 22 remain blocked, because no item is answered — see the readiness audit §2), and it does not create a coverage gap: the substantive checks in §4 above were run on the whole row, not on this list. It is an accuracy defect in my own audit document. Correction (re-derive the column from the `Blocks` column, or adopt the §4 lists) is **pending approval** — §6 of that document now carries a ⚠ note pointing here.

### D-2 — the RTM's *decision-needed* column and the register's blocking set use different axes

Machine comparison, for the record (both derived from `**Reqs:**` lines of decisions whose `**Blocks implementation?**` is "Yes"):

- **11 requirements** are named by a blocking decision but carry `—` in the RTM's decision column: `FR-BOOK-02`, `FR-BOOK-05`, `FR-BOOK-09`, `FR-DISC-01`, `FR-DISC-02`, `FR-DISC-06`, `FR-PROF-02`, `FR-PROF-06`, `NFR-AUTH-02`, `NFR-BOOK-02`, `NFR-PROF-03`.
- **7 requirements** carry a decision note in the RTM but are named by no blocking decision: `FR-AUTH-05`, `FR-DISC-04`, `FR-PROF-03`, `FR-RATE-02`, `FR-RATE-04`, `NFR-BOOK-03`, `NFR-DISC-02`.

The RTM column is defined as *"`—` when the SRS is sufficient; otherwise a decision that must be taken before implementation"* — i.e. a **product-decision** axis — whereas the register's blocking flag covers **both** product and backend-contract decisions. The two are therefore not the same measurement, and the RTM's "57 flagged" figure is a product-decision count, not the register's blocking count. This is flagged only because §6 of the readiness audit reports `D-55 (BLOCKED)` for rows the RTM shows as unflagged, which reads as a contradiction until the axes are distinguished. **No edit proposed** — reconciling it would change the published 57/17 figures in three documents and needs a deliberate ruling, not a silent fix.

---

## 6. Exact documents and sections that must be approved before anything here is applied

| # | Document · section | What the correction would be | Effect on counts |
|---|---|---|---|
| 1 | `docs/be-contract-request.md` · **§2 Tutor** (new row) or **§10 Cross-cutting** (new row) | Add `C-X-07` (§3) with the approved ID/placement | **changes** 80 → 81 items; 85 → 87 listings; dual-class 5 → 6 |
| 2 | `docs/be-contract-request.md` · **§11.1** | Restate the class tallies and the dual-class list if #1 is applied | follows #1 |
| 3 | `docs/be-contract-request.md` · **§11.4 F-2** | Record the outcome: gap confirmed for `FR-DISC-02`, withdrawn for `FR-DISC-06`; proposal applied/declined | none |
| 4 | `docs/be-contract-request.md` · **revision block** (line 6) | Add the rev-4 line describing whatever is applied | none |
| 5 | `docs/be-contract-request.md` · `C-TUT-06` **`Blocks` cell** | Add `FR-DISC-06` (finding G-2) | none |
| 6 | `docs/wave-2-readiness-audit.md` · **§6** | Re-derive the item column for the 7 rows in D-1, or adopt the §4 lists | none |
| 7 | `docs/wave-2-readiness-audit.md` · **§9 A-2** | Restate as "one requirement (`FR-DISC-02`); `FR-DISC-06` covered by `C-TUT-06`" | none |
| 8 | `docs/wave-2-readiness-audit.md` · **§7 row 2.5** | "two of its rows" → one row, once A-2 is restated | none |
| 9 | `docs/wave-0-plan.md` · **§6.2** (`FR-DISC-02` row) | Point its gating item at `C-X-07` once that item exists | none |
| 10 | `docs/requirement-traceability-matrix.md` · `FR-DISC-02` row | Optional: note the missing contract item in the row's gap cell (the row itself is accurate: status **P**, no decision flagged) | none |
| 11 | `docs/decision-register.md` · **D-55** | **No change proposed.** The proposal does not widen or resolve it, and no new decision is created | none |

**Not proposed at all:** any edit to the SRS, any new decision (`D-58` or otherwise), any register edit, any schema/table/column/type/RLS/bucket/endpoint, any source or test change, any Wave 2 implementation, any forgot-password UI.

---

## 7. Final status

**The contract request is NOT yet coverage-complete.** It has exactly **one** confirmed coverage gap — `FR-DISC-02` (G-1) — closed only by approving a single new item (`C-X-07`, §3), plus **one** declaration defect (`C-TUT-06`'s `Blocks` cell, G-2) that needs a one-cell correction and no new item. Everything else checks out: all 80 unique items parse to 7 columns and are classified, every requirement and `D-nn` reference resolves, and 21 of the 22 contract-blocked rows are substantively covered by at least one item's question.

Status of this step: **audit + proposal only. Nothing applied. Approval required for the eleven items in §6.** Wave 2 has not been started, no decision has been created or resolved, and no code, test, schema or Supabase configuration was touched.

*End of contract coverage audit.*

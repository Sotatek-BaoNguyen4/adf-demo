# Plan Audit — Hard Mode (2026-05-28 19:16)

**Auditor:** code-reviewer subagent
**Scope:** 3 plans under `plans/`
**Mode:** Adversarial / brutal
**Evidence basis:** plan.md + sampled phase files + `lib/` + `test/` + `docs/` cross-check

---

## Plan 1 — `260527-1439-full-home-mvp`

**Verdict: NEEDS REWORK (status drift) — code is good, plan metadata is stale**

Code shipped end-to-end (router, theme, network, storage, DTOs, screen, providers, tests all present). Plan frontmatter never updated to reflect reality. Plan is misleading to anyone reading it cold.

### CRITICAL

- **C1. Status frontmatter contradicts shipped code.** `plan.md` table lists every phase as `pending` (lines 29–35). Individual phase headers: 01 `completed`, 02–05 `pending`, 06 `complete`, 07 `pending` — yet all 7 phases' deliverables exist in `lib/` and `test/`. Anyone running `/plan status` gets garbage.
  - Fix: `plans/260527-1439-full-home-mvp/plan.md:29-35` — set all phases to `completed`; sync each `phase-XX.md` frontmatter `status:` field.
- **C2. Todo checklists fully unchecked despite shipped code.** Phase 02 (8 todos), 03 (10), 04 (11), 05 (13), 07 (17) all show `[ ]` across the board. Total **59 stale open todos** in a "delivered" plan.
  - Fix: tick boxes that map to existing files; flag any genuinely undone item (see HIGH below).

### HIGH

- **H1. Phase-07 success criterion "Coverage ≥ 85% on lib/core/, ≥70% overall" — no evidence.** No `coverage/lcov.info` cited; 20 test files exist but no test count, no coverage report linked. AC unverifiable.
  - Fix: run `flutter test --coverage`; attach summary to plan completion note. If miss, file follow-up.
- **H2. Phase-07 missing tests vs LLD §9 matrix.** Plan lists 15 unit/widget test files. Actual `test/` shows only `home_repository_impl_test.dart` + `home_remote_source_test.dart` under `test/unit/` — **no** `failure_test.dart`, `mock_interceptor_test.dart`, `mock_fixture_loader_test.dart`, `dio_client_test.dart`, `cache_policy_test.dart`, `cache_envelope_test.dart`, `local_cache_test.dart`, `hive_bootstrap_test.dart`, DTO tests. That is 9 missing core unit-test files vs plan promise.
  - Fix: either build the missing tests OR formally descope phase-07 to "widget-tests + repo unit-test" and update success criteria.
- **H3. Phase-07 widget test list mismatches reality.** Promised: `home_screen_test.dart`, `banner_carousel_test.dart`, `movie_rail_test.dart`, `app_navigation_test.dart`. None present under those names; current widget tests are scoped to Phase-2-mockup widgets instead (banner_section_*, trending_*, category_chips_*). `app_navigation_test.dart` (5-tab nav) entirely absent.
  - Fix: add `app_navigation_test.dart` or descope.

### MEDIUM

- **M1. `BannerCarousel` / `MovieCard` / `RatingBadge` are listed in Phase-05 todos as components to build, but mockup-alignment plan (Plan 2) replaced them with `BannerSection`, `NowShowingCard`, `ComingSoonCard`. Plan-05 was never reconciled — reads as if both implementations should exist.
  - Fix: add a "superseded by 260527-1746 phase-02/04" note in phase-05.md.
- **M2. File-size budget violation.** `banner_overlay_content.dart` = **212 LOC** > 200 limit. Plan 1 success criterion #7 ("no file > 200 LOC") technically failed. (Generated freezed files excluded — those are not user code.)
  - Fix: split out helpers or relax the rule for stateful overlay widgets explicitly.
- **M3. Open question (HLD §12) "stale-fallback UX badge" — never resolved nor moved to a follow-up plan.

### LOW

- L1. Inconsistent status vocabulary: `complete` vs `completed` vs `Complete` across phase frontmatter and plan.md table. Pick one.
- L2. `Critical Path` text (line 38) still uses "may run in parallel" present-tense although work is done.

### Stale TODOs (Plan 1) — sample
- phase-02: 8 unchecked
- phase-03: 10 unchecked
- phase-04: 11 unchecked
- phase-05: 13 unchecked (incl. "Manual smoke")
- phase-06: 2 unchecked ("Smoke run on iOS + Android simulator", "Verify tab state preservation")
- phase-07: 17 unchecked

---

## Plan 2 — `260527-1746-home-mockup-alignment`

**Verdict: PASS (with cleanup) — code matches plan; 1 stale todo + duplicate test dir**

Status frontmatter correctly marked `completed` on all 5 phase files. Implementation aligns with plan (router has 5 branches Home/Explore/Tickets/Saved/Profile with redirects; `tickets_fab_tile.dart` exists and reads `AppGradientsExt`; new widgets `banner_*`, `category_chips_*`, `promo_banner`, `trending_*`, `now_showing_card`, `coming_soon_card` all present).

### HIGH

- **H4. Duplicate test directories — drift risk.** Tests exist under BOTH `test/features/home/widgets/` AND `test/features/home/presentation/widgets/`. Both contain `banner_section_swipe_test.dart` + `movie_rail_swipe_test.dart` — `diff` reports they **differ**, so both run but cover slightly different things. Future fixes can update one and forget the other.
  - Fix: pick a canonical path (plan-05 specified `test/features/home/widgets/...`), `git mv` the two files from `presentation/widgets/` into `widgets/`, resolve any duplication, delete empty dir.

### MEDIUM

- **M4. Coming-Soon UX drift from plan wording.** Plan §step 2 says subtitle "Expected: <month day>". Code emits "Expected: <fully formatted date>". Trivial but plan said different format than shipped.
  - Fix: either update plan text or shorten format to mockup convention.
- **M5. AC coverage trace gap.** Plan-05 success criterion "All 10 widget tests pass" + "No regressions on existing home tests". Test count present (≥10 widget tests) but no AC-ID → test-name mapping written down. Cannot prove which test covers which criterion.
  - Fix: add a one-table appendix in phase-05.md mapping AC bullets to test file names.

### LOW

- L3. Phase-05 todo "Manual visual diff vs mockup acceptable" left unchecked despite the rest of the phase marked complete. Either tick or remove.
- L4. Open question (plan.md §Open Questions) "Tickets raised FAB target: keep as placeholder route `/tickets` for now?" — implemented as stub; mark resolved in plan.
- L5. Plan mentions deleting `cinemas_screen.dart` "only if unreferenced" — no follow-up note whether the delete happened. (`grep` shows no cinemas screen file in `lib/`, so likely it never existed; document.)

### Stale TODOs (Plan 2)
- phase-05: 1 unchecked ("Manual visual diff vs mockup acceptable")

---

## Plan 3 — `260528-1418-hld-error-sequence-diagrams`

**Verdict: PASS — small, scoped, delivered, verified**

Docs-only. Single phase. Both `plan.md` and phase-01 marked Complete with checked todos. `grep -c "sequenceDiagram" docs/system-architecture.md` → **4** (matches success criterion).

### MEDIUM

- **M6. AC#2 "Mermaid v11 valid syntax" not verified in plan output.** Phase risk-assessment says "Validate via `/mermaidjs-v11` skill before committing" but no verification artefact noted (run log, screenshot, viewer output). Trust-but-no-evidence.
  - Fix: append a one-line "Verified rendering: <viewer> on 2026-05-28" to phase-01.md success criteria block.

### LOW

- L6. Open question at bottom of phase-01.md ("Should diagrams 5.1 and 5.4 also show provider invalidation?") was self-answered ("Suggest: no"). Promote to "Resolved: no — out of scope" so it doesn't read as still-open.
- L7. Plan/phase use both `✅ Complete` and `Complete` mixed with todo `[x]`. Cosmetic only.

### Stale TODOs (Plan 3)
- None.

---

## Portfolio Health (one-liner each)

| Plan | Code shipped? | Plan accurate? | Action |
|---|---|---|---|
| 260527-1439-full-home-mvp | ✅ Yes | ❌ Stale (status + todos + scope drift) | **REWORK metadata** |
| 260527-1746-home-mockup-alignment | ✅ Yes | ✅ Mostly | **Minor cleanup** |
| 260528-1418-hld-error-sequence-diagrams | ✅ Yes | ✅ Yes | **Close** |

---

## Top 5 Prioritised Actions

1. **[CRITICAL] Reconcile Plan 1 status frontmatter + todo checkboxes** with shipped reality. Edit `plan.md` table + each `phase-XX.md` `status:` line + tick delivered todos. Without this, `/plan status` is unreliable.
2. **[HIGH] Decide on Plan 1 phase-07 test scope.** Either author the 9 missing core unit tests (failure/mock_interceptor/fixture_loader/dio_client/cache_policy/cache_envelope/local_cache/hive_bootstrap/DTO) **or** formally descope and update success criteria. Currently a paper promise.
3. **[HIGH] Collapse duplicate test directories** in Plan 2: merge `test/features/home/widgets/` + `test/features/home/presentation/widgets/` into one canonical path; resolve the two diverging `*_swipe_test.dart` pairs.
4. **[HIGH] Run `flutter test --coverage`** and attach the lcov summary as evidence for Plan 1 phase-07 SC#"≥85% on lib/core/, ≥70% overall". Add results to a closeout report in `plans/reports/`.
5. **[MEDIUM] Modularize `banner_overlay_content.dart` (212 LOC)** to honour Plan 1 SC#7 strict 200-line rule, OR document an explicit exception in `docs/code-standards.md`.

---

## Plans Recommended for Archive

- **`260528-1418-hld-error-sequence-diagrams`** — fully delivered, single phase, verified. Move to `plans/archive/` (or equivalent) after applying M6 fix.

(Plan 1 and Plan 2 are NOT archive-ready: Plan 1 has open promises; Plan 2 has duplicate-test cleanup pending.)

---

## Unresolved Questions

- Q1. Is `test/features/home/widgets/` or `test/features/home/presentation/widgets/` the intended canonical path? Plan-05 said `widgets/...` but predecessor structure suggests `presentation/widgets/...`.
- Q2. Are the 9 missing core unit tests intentionally descoped (mocked at higher level) or genuinely missed? Need product/eng decision.
- Q3. For Plan 1 SC#7 file-size rule: is the 200-LOC budget binding for stateful overlay widgets, or do they get a documented exception?
- Q4. Did `cinemas_screen.dart` ever exist in the predecessor branch? If yes, was it deleted as Plan 2 phase-05 instructed?
- Q5. Plan 1's open backlog items (pagination, cache_stats screen, stale-fallback badge UX) — owner + target plan?

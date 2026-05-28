# Code Review — Session 260528-1916

**Reviewer:** code-reviewer
**Date:** 2026-05-28
**Scope:** 8 files changed this session (docs, tests, CI, config)
**Verdict:** **APPROVE_WITH_FIXES** — multiple test files assert behaviors the code does NOT implement; will fail at runtime.

---

## Per-File Findings

### 1. `docs/project-fsd.md`
- **MEDIUM** — Section 4 (Screen Flows) mermaid still says `Search / Cinemas / Community / Profile`. Inconsistent with new Section 1 (Explore/Tickets/Saved/Profile). Update the mermaid label to match.
- **LOW** — AC table ordering: `AC-HOME-005-03` inserted before `AC-HOME-005-02`. Renumber or reorder for ascending consistency.
- **LOW** — `Data Models > Movie` lists `status` enum but API responses (5.2–5.4) never return `status` — derived client-side. Note as derived or remove.
- **POSITIVE** — AC-HOME-005-03 correctly captures the FAB-in-center-slot design.

### 2. `docs/design-system/component-catalog.md`
- **HIGH** — `TicketsFabTile` description: catalog implies generic raised tile; actual icon is `Icons.confirmation_num_outlined`. Catalog should name the icon so future devs and integration tests pick correct finder. (Also: `_radius = 16`, not documented.)
- **MEDIUM** — `CinemaNavBar` missing the public static `barHeight = 80.0` (used for layout calculations elsewhere).
- **MEDIUM** — `BannerSection` "Tapping a progress bar jumps slides" is true, but catalog implies swipe is supported. Source has **no** `GestureDetector`/`PageView`/horizontal-drag handler. Either add swipe or state "no swipe — progress-bar taps only".
- **LOW** — `MovieRail` says "scroll-end triggers pagination" implied in `MovieRail` usage section context, but `MovieRail` has no scroll listener / pagination. Acceptable since catalog itself doesn't claim it, but verify the FSD AC-HOME-002-01 (`exposes meta.hasNext for pagination on scroll-end`) — currently unimplemented.
- **POSITIVE** — 22 widgets, alphabetical-within-group, source-linked, props/states/tokens covered. Well-structured.

### 3. `.quality-gates/config.yaml`
- **LOW** — Bumping coverage 70→80 without baseline check risks blocking CI if current % is < 80. Verify against `coverage-260528-1916-lcov.md` first.
- **POSITIVE** — Generated files correctly excluded; `file_max_loc: 200` matches CLAUDE.md.

### 4. `test/.../banner_section_swipe_test.dart` (NEW)
- **CRITICAL** — Tests 1 + 2 (`swipe left advances` / `swipe right goes to previous`) WILL FAIL. `BannerSection` source has NO horizontal drag handler. `tester.drag(...)` just bounces off — `_activeIndex` only mutates via `_jumpTo()` (progress-bar tap) and auto-rotation. The AC-HOME-001-03 ("user swipe halts rotation") is **currently unimplemented in product code** — these tests are aspirational, not validating shipped behavior.
- **HIGH** — Test 3 (progress-bar tap) is correctly written and will pass — keep it; drop or `skip:` the swipe tests until BannerSection gains a swipe handler. Recommend filing a follow-up task to wire `GestureDetector.onHorizontalDragEnd` → `_jumpTo(prev/next)` and resetting `_ctrl`.
- **MEDIUM** — `_FakeBannersNotifier.refresh()` empty override — fine for stub, but unused (no test calls it).

### 5. `test/.../movie_rail_swipe_test.dart` (NEW)
- **CRITICAL** — Test 2 contains a cheat: `if (errorButton.evaluate().isEmpty) { retryCalls++; stub.refresh(); }` — the test manually increments the counter then asserts `retryCalls > 0`. This is exactly the "fake/cheat to pass build" pattern banned by project rules. Either implement pagination in `MovieRail` and test the real trigger, or delete this test.
- **HIGH** — `MovieRail` has no `ScrollController` / `NotificationListener` for end-of-list pagination. AC-HOME-002-01 requirement (`pagination on scroll-end`) is unmet — flag as gap.
- **POSITIVE** — Test 1 (horizontal scroll moves rail) is genuine and will pass.

### 6. `integration_test/home_navigation_flow_test.dart` (NEW)
- **HIGH** — `tap Tickets FAB`: `find.byTooltip('Tickets')` returns empty (TicketsFabTile uses bare `GestureDetector`, no Tooltip). Fallback `find.byIcon(Icons.local_activity_outlined)` is also wrong — actual icon is `Icons.confirmation_num_outlined`. Test will fail. Fix: use `find.byType(TicketsFabTile)` or add a `Tooltip` wrapper.
- **MEDIUM** — `find.byIcon(Icons.home)` after boot: home is the active tab so `selectedIcon: Icon(Icons.home)` is rendered — works. But fragile if the destination order changes. Prefer `find.byType(HomeScreen)` or a Key.
- **MEDIUM** — Each test re-invokes `app.main()` which re-registers Hive adapters / `GoRouter` — may throw on second call. Use `setUp` with a single boot OR pump a constrained `ProviderScope` instead of full `app.main()`.
- **LOW** — No assertions on `currentIndex` reaching new branch; only on widget presence. Consider also asserting nav bar `selectedIndex`.

### 7. `pubspec.yaml`
- **POSITIVE** — `integration_test` correctly added under `dev_dependencies` from sdk.
- **LOW** — Font block still commented out (phase-02 TODO). Not a session issue.

### 8. `.github/workflows/ci.yml` (NEW)
- **HIGH** — `integration_test` is NEVER invoked in CI. New integration test added in same session but no job runs it. Either add an emulator-based job (`reactivecircus/android-emulator-runner`) or document it as manual-only and remove the integration_test dep claim of CI gate.
- **MEDIUM** — `lcov --remove` patterns: lcov uses glob-like patterns but `'**/*.g.dart'` with shell-style `**` may not match all generated files reliably. Test locally or use explicit `lib/**/*.g.dart`. Verify exclusion actually trims `.g.dart`.
- **MEDIUM** — Coverage gate uses `awk` BEGIN comparison — if `coverage/lcov.info` is empty or `lf=0`, division-by-zero → `nan` → may unexpectedly pass/fail. Add `if (lf==0) exit 1`.
- **MEDIUM** — `quality-gates` job runs `semgrep` and `trivy` both with `continue-on-error: true` — they're informational only. Decide whether that aligns with the 80% coverage strictness elsewhere.
- **LOW** — `dart format … continue-on-error: true` — same comment; formatting failures should either block or be removed.
- **LOW** — `.fvmrc` has `"flutter": "stable"` (channel, not pinned version). `subosito/flutter-action@v2` will pull latest stable each run → non-reproducible builds. Pin to a version (e.g., `3.27.1`).
- **LOW** — `build` job uses hard-coded `channel: stable` instead of reading `.fvmrc` (inconsistent with `test` job).
- **POSITIVE** — Sensible job split (test / quality-gates / build), `fetch-depth: 0` for gitleaks, artifact retention reasonable, no secrets exposed.

---

## Scores

| Axis | Score | Rationale |
|------|-------|-----------|
| **Correctness** | **5/10** | FSD mermaid drift; 2 new test files assert unimplemented behaviors; integration test finders wrong. |
| **Test Quality** | **4/10** | Cheat in movie_rail test (manual counter bump); swipe tests target non-existent gesture handler; integration FAB finder broken. |
| **Documentation Accuracy** | **7/10** | Catalog is solid structure-wise but misses TicketsFabTile icon, CinemaNavBar.barHeight, and implies swipe support that doesn't exist. |
| **CI Design** | **6/10** | Reasonable shape, but integration_test never runs, coverage gate fragile, formatting/SAST/dep-scans soft-fail dilutes gate value. |
| **Security** | **9/10** | No secrets in diffs, gitleaks wired in, no dangerous patterns, `GITHUB_TOKEN` used scoped, Trivy on CRITICAL/HIGH. Minor: SAST is `continue-on-error`. |
| **Overall** | **5.5/10** | Docs/CI scaffolding is good; test layer has fake-pass patterns and tests targeting unimplemented behavior — violates `DO NOT use fake data / cheats` rule. |

---

## Top 5 Action Items (Ranked)

1. **DELETE or `skip:` the 2 swipe tests in `banner_section_swipe_test.dart`** (or implement `onHorizontalDragEnd` in `BannerSection` then keep them). Currently they will fail CI on first run.
2. **Remove the cheat in `movie_rail_swipe_test.dart` Test 2** (`retryCalls++; stub.refresh();` inside the `if` branch). Either implement real pagination in `MovieRail` and assert via scroll-end, or delete the test.
3. **Fix integration test FAB finder**: use `find.byType(TicketsFabTile)` (and import it) — current `find.byTooltip('Tickets')` and `Icons.local_activity_outlined` both miss.
4. **Add integration_test job to CI** (Android emulator action) OR explicitly mark integration tests as out-of-CI in README, since session added the dep claiming CI coverage.
5. **Sync FSD Section 4 mermaid** to `Explore / Tickets / Saved / Profile` and update catalog to name `Icons.confirmation_num_outlined` for `TicketsFabTile` + add `CinemaNavBar.barHeight` static.

---

## Verdict: APPROVE_WITH_FIXES

Docs and CI design land in good shape. Blocking issue is the test layer: two new files contain tests asserting behavior the product code doesn't implement, and one contains a manual counter bump to force-pass. Per project rules (`DO NOT use fake data, mocks, cheats, tricks, temporary solutions just to pass the build`), these must be fixed before merge. Items 1–3 are non-optional; 4–5 can land in a follow-up.

---

## Unresolved Questions

- Is BannerSection swipe-to-navigate actually in scope for this session, or a future phase? (Determines whether to implement gesture or remove tests.)
- Is `MovieRail` pagination targeted for this MVP? AC-HOME-002-01 says yes; code says no — pick one.
- Should integration tests run in CI? If yes, on Android emulator or iOS simulator? Adds ~10 min to CI.
- Coverage threshold 80% — what's the current measured % from `coverage-260528-1916-lcov.md`? If below 80, CI breaks immediately on next push.

# Chat — /plan full home mvp

**Date:** 2026-05-27 14:39 (Asia/Saigon)
**Command:** `/plan full home mvp`
**Plan produced:** `plans/260527-1439-full-home-mvp/`

---

## User

`/plan full home mvp`

## Assistant

Context loaded. HLD + LLD already exist and lock all foundational decisions. Skipping research/scout and going straight to creating the phased implementation plan.

**Plan location:** `plans/260527-1439-full-home-mvp/`
**Phases (per HLD §11):** 7 phases — bootstrap → theme → core/net+storage → home data → home UI → router/shell → tests

### Investigation steps

1. Read `README.md`, `pubspec.yaml`, `lib/main.dart` (default Flutter counter app, empty project)
2. Read `docs/project-fsd.md` — FR-HOME-001..005, API contracts, NFRs
3. Read `plans/reports/hld-home-mvp.md` — agreed HLD with 7-phase split proposal, dep list, folder layout, cross-cutting concerns
4. Read `docs/lld-home-mvp.md` — locked contracts for core/network + core/storage, fixture schemas, sequence diagrams, testing matrix
5. Read `docs/design-system/component-catalog.md` — M3 widget catalog with Flutter ThemeData mapping
6. Read `docs/usecases/home/uc-home-001-home-banner.md` — main flow, alt flows, exception flows
7. Confirmed plan directory does not exist yet → created `plans/260527-1439-full-home-mvp/{research,reports,visuals}`

### Decision: skip planner agent

HLD + LLD already provide:
- Architecture (feature-first + MVVM-lite, Riverpod 2, go_router, Hive CE, Dio)
- Folder layout (HLD §4.2)
- Dependency set (HLD §6)
- Phase split (HLD §11 proposed 7 phases)
- Contracts (LLD §3-§6 lock every interface)
- Testing matrix (LLD §9)

→ Authored 8 plan files directly (plan.md + 7 phase files). Faster, lower token cost, no information loss.

### Files written

| File | Purpose | LOC |
|---|---|---|
| `plan.md` | Overview, phase index, critical path, success criteria | ~70 |
| `phase-01-bootstrap.md` | pubspec, folder skeleton, lints, build_runner setup | ~80 |
| `phase-02-theme.md` | `tool/gen_theme.dart`, AppTheme.dark/light, ThemeExtensions | ~110 |
| `phase-03-core-network-storage.md` | Dio + MockInterceptor + fixture loader, Hive bootstrap, CachePolicy, Failure | ~120 |
| `phase-04-home-data.md` | Entities, freezed DTOs, fixture JSON, HomeRepositoryImpl w/ SWR | ~130 |
| `phase-05-home-presentation.md` | 4 AsyncNotifier providers, HomeScreen, BannerCarousel, MovieRail, states | ~150 |
| `phase-06-router-shell.md` | go_router StatefulShellRoute, 5 tabs, MaterialApp.router | ~90 |
| `phase-07-tests.md` | LLD §9 unit tests + widget tests, 85% on core, 70% overall | ~110 |

Active plan set via `node .claude/scripts/set-active-plan.cjs`.

### Plan summary delivered

7 phases (per HLD §11 split), all <200 LOC per file, dark-only M3 from tokens.json, mock-first via Dio interceptor:

| # | Phase | Effort | Key Deliverables |
|---|---|---|---|
| 01 | Bootstrap | S | pubspec deps, folder skeleton, lints |
| 02 | Theme codegen | M | `tool/gen_theme.dart` → `core/theme/generated/*`, AppTheme.dark/light |
| 03 | core/network + storage | M | Dio + MockInterceptor + fixture loader, Hive bootstrap, CachePolicy, Failure (LLD-spec) |
| 04 | Home data + domain | M | Movie/Banner entities + freezed DTOs, 4 fixture JSONs, HomeRepositoryImpl w/ SWR |
| 05 | Home presentation | L | 4 AsyncNotifier providers, HomeScreen + BannerCarousel (5s auto-rotate) + MovieRail + states |
| 06 | Router + shell | S | go_router StatefulShellRoute, 5 tabs, ProviderScope+MaterialApp.router |
| 07 | Tests | M | LLD §9 unit matrix + widget tests, 85% on core, 70% overall |

**Critical path:** 01 → (02 ∥ 03) → 04 → 05 → 06 → 07

**Skipped:** research phase (HLD + LLD already provide every decision); audit/validate (lightweight mode given existing rigor).

**Next:** Run `/cook` to start phase 01, or `/plan audit plans/260527-1439-full-home-mvp` for adversarial review first.

---

## User

`save this chat as markdown`

## Assistant

Saved this transcript to `plans/reports/plan-260527-1439-full-home-mvp-chat.md`.

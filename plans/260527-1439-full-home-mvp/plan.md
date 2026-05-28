---
type: implementation-plan
title: Full Home MVP — Implementation Plan
date: 2026-05-27
status: ready
parent_hld: ../reports/hld-home-mvp.md
parent_lld: ../../docs/lld-home-mvp.md
fsd: ../../docs/project-fsd.md
scope: FR-HOME-001..005 (full Home screen + bottom-nav shell)
stack: Flutter 3.10 / Dart 3 / Riverpod 2 / go_router 14 / Dio 5 / Hive CE 2
---

# Plan — Full Home MVP

End-to-end build of the ADF Cinema Home screen MVP: banner carousel, three movie rails (Now Showing / Coming Soon / Recommended), bottom-nav shell, M3 dark theme generated from tokens, local cache + mock HTTP fixtures. Honors HLD + LLD decisions verbatim.

## Inputs
- HLD: [hld-home-mvp.md](../reports/hld-home-mvp.md) — architecture, deps, folder layout, cross-cutting concerns
- LLD: [lld-home-mvp.md](../../docs/lld-home-mvp.md) — core/network + core/storage contracts, fixtures, sequence flows
- FSD: [project-fsd.md](../../docs/project-fsd.md) — API contracts, data models, NFRs
- Design system: [tokens.json](../../docs/design-system/tokens.json) + dark/light themes + [component-catalog.md](../../docs/design-system/component-catalog.md)
- Use case: [uc-home-001](../../docs/usecases/home/uc-home-001-home-banner.md)
- Mockup: [home-screen/index.html](../../docs/design-mockups/home-screen/index.html)

## Phases

| # | Phase | Status | Effort | Depends on |
|---|---|---|---|---|
| 01 | [Project bootstrap](./phase-01-bootstrap.md) — pubspec deps, folder skeleton, lints, build_runner | pending | S | — |
| 02 | [Theme codegen + core/theme](./phase-02-theme.md) — tokens.json → Dart, M3 ColorScheme/TextTheme, dark+light builders | pending | M | 01 |
| 03 | [core/network + core/storage](./phase-03-core-network-storage.md) — Dio, MockInterceptor, Hive bootstrap, CachePolicy, Failure | pending | M | 01 |
| 04 | [Home data + domain](./phase-04-home-data.md) — entities, DTOs (freezed/json), HomeRepository impl, sources, fixtures JSON | pending | M | 03 |
| 05 | [Home presentation](./phase-05-home-presentation.md) — providers, HomeScreen, BannerCarousel, MovieRail, MovieCard, shimmer/empty/error states | pending | L | 02, 04 |
| 06 | [Router + bottom-nav shell](./phase-06-router-shell.md) — go_router StatefulShellRoute, 5 tabs, placeholders, ProviderScope+MaterialApp.router | pending | S | 05 |
| 07 | [Tests](./phase-07-tests.md) — unit (LLD §9) + widget (HomeScreen states, carousel rotate, refresh) | pending | M | 06 |

## Critical Path
01 → 02 + 03 (parallel) → 04 → 05 → 06 → 07. Phases 02 and 03 are independent and may run in parallel.

## Key Dependencies (locked in HLD §6)
- Riverpod 2.5 + riverpod_generator 2.6
- go_router 14
- dio 5
- hive_ce 2.7 + hive_ce_flutter + hive_ce_generator
- freezed 2.5 + json_serializable 6.8
- cached_network_image 3.4, shimmer 3, path_provider 2.1
- dev: build_runner, mocktail

## Cross-Cutting Rules
- **<200 LOC per file** — modularize aggressively (HLD §5 LOC budgets are binding)
- **kebab-case file names** with descriptive purpose
- **No hardcoded hex/sizes in widgets** — read from `Theme.of(context)` + ThemeExtensions only
- **DTO ↔ Entity boundary** — DTOs live in `data/dto/`, Entities in `domain/entities/`; mappers in DTO file
- **No mocks/temp solutions** to pass tests — fix root cause
- **`flutter analyze` clean** before phase complete
- **`flutter test` green** on phase 07 close

## Success Criteria (project-level, HLD §10)
1. Cold start → Home visible < 2s
2. Cached lists render < 500ms warm start
3. Banner auto-rotates 5s (BR-001)
4. All 4 endpoints served via Dio + MockInterceptor
5. Bottom-nav tabs with independent back stacks
6. 100% theme from tokens.json
7. `flutter analyze` clean, `flutter test` green, no file > 200 LOC

## Risks (top 3)
- Hive CE adapter codegen friction → mitigated by keeping DTOs flat
- Theme codegen drift vs tokens.json → run `dart tool/gen_theme.dart` in pre-commit
- File-size creep > 200 LOC → strict per-component budgets in phase files

## Open Questions
- See LLD §12 (carry-overs): pagination in MockInterceptor (deferred), cache_stats debug screen (backlog), stale-fallback UX badge (deferred to features/home).

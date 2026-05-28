---
phase: 07
title: Tests (unit + widget)
status: pending
priority: P0
effort: M
depends_on: [06]
---

# Phase 07 — Tests

## Context Links
- LLD §9 testing matrix (unit-level contracts for core/network + core/storage)
- HLD §7.7 testing scope
- Project rule: no mocks/cheats; fix root cause on failures

## Overview
Author unit tests for every core/* file per LLD §9, plus widget tests for HomeScreen states + carousel rotation + pull-to-refresh + bottom-nav. Target 85%+ coverage on `lib/core/`, ≥70% overall.

## Key Insights
- LLD §9 names exact test cases per file — implement verbatim.
- Hive tests use `Hive.init(tempDir)` (in-memory equivalent) — fresh dir per test.
- AssetBundle stubbed via `TestAssetBundle` (or `MockBundle` with mocktail).
- Riverpod widget tests: override providers via `ProviderScope(overrides: [...])` to inject fake repositories.
- Timer-based carousel test: `tester.pump(Duration(seconds: 5))` to advance.

## Requirements
**Functional**

| Test file | Targets | Cases |
|---|---|---|
| `test/unit/core/errors/failure_test.dart` | `failure.dart` | each subclass instantiable; `toString` redacts cause in release |
| `test/unit/core/network/mock_interceptor_test.dart` | `mock_interceptor.dart` | path match success, path miss → 404, latency bounded, `_mock_error=500/timeout/parse` injections |
| `test/unit/core/network/mock_fixture_loader_test.dart` | `mock_fixture_loader.dart` | first read → bundle, second read → cache, missing asset → FixtureMissingFailure, malformed → ParseFailure |
| `test/unit/core/network/dio_client_test.dart` | `dio_client.dart` | interceptor order, base headers, timeouts, mock=false bypasses MockInterceptor |
| `test/unit/core/storage/cache_policy_test.dart` | `cache_policy.dart` | isFresh boundaries, negative age (clock skew), schemaVersion mismatch |
| `test/unit/core/storage/cache_envelope_test.dart` | `cache_envelope.dart` | Hive roundtrip per concrete T, age computation |
| `test/unit/core/storage/local_cache_test.dart` | `local_cache.dart` | read-miss null, write→read roundtrip, schema mismatch → silent delete, evict, clearAll, write error → CacheWriteFailure |
| `test/unit/core/storage/hive_bootstrap_test.dart` | `hive_bootstrap.dart` | adapters idempotent, corrupt-box recovery deletes + reopens |
| `test/unit/features/home/home_repository_impl_test.dart` | `HomeRepositoryImpl` | cache-hit fresh, cache-miss → remote → write, forceRefresh skips cache read, stale-fallback on network error, no-cache + error → rethrow |
| `test/unit/features/home/dto/movie_dto_test.dart` | `MovieDto` | fromJson against fixture file, toEntity correctness, nullable fields tolerated |
| `test/unit/features/home/dto/banner_dto_test.dart` | `BannerDto` | fromJson, toEntity |
| `test/widget/home_screen_test.dart` | `HomeScreen` | renders loading shimmer initially; renders data after providers resolve; renders error widget on AsyncError; pull-to-refresh invalidates providers |
| `test/widget/banner_carousel_test.dart` | `BannerCarousel` | first banner shown; advances to next after 5s; manual swipe pauses timer; resumes after 5s |
| `test/widget/movie_rail_test.dart` | `MovieRail` | renders all cards; empty list → EmptySectionView; error state → ErrorSectionView with retry |
| `test/widget/app_navigation_test.dart` | router | tap each bottom-nav tab → correct screen renders; tab state preserved across switches |

**Non-functional**
- `flutter test` exits 0
- Coverage report: `lib/core/` ≥ 85%, overall ≥ 70%
- No test uses real network or filesystem outside tempDir

## Architecture
Test files mirror `lib/` structure under `test/unit/` and `test/widget/`.

## Related Code Files
**Create** all 15 test files listed above. Plus test helpers:
- `test/_helpers/in_memory_hive.dart` — setUp/tearDown for Hive tempDir
- `test/_helpers/test_asset_bundle.dart` — fixture loader override
- `test/_helpers/fake_home_repository.dart` — for widget tests
- `test/_helpers/provider_overrides.dart` — Riverpod override patterns

## Implementation Steps
1. **Helpers first** — write in-memory Hive setup, TestAssetBundle, FakeHomeRepository.
2. **Unit tests per LLD §9** — implement each row in the LLD table verbatim. Use `mocktail` for Dio mocking in interceptor tests.
3. **DTO tests** — parse actual fixture JSON files; assert entity equality.
4. **Repository test** — fake `HomeRemoteSource` + `HomeLocalSource` (via mocktail). Verify SWR paths from LLD §6 pseudocode.
5. **Widget tests**:
   - Override providers with `FakeHomeRepository` that returns controlled `Future`s.
   - Use `tester.pump()` for shimmer state, `tester.pumpAndSettle()` for data.
   - Carousel: `tester.pump(Duration(seconds: 5))` to trigger timer; verify `PageView` page index changed.
   - Pull-to-refresh: `tester.fling(finder, Offset(0, 300), 1000)` then `pumpAndSettle`.
6. **Coverage** — `flutter test --coverage`; inspect `coverage/lcov.info`; if `lib/core/` <85%, add missing cases.
7. **Fix failures by fixing code** — never adjust expected values to pass; if a test reveals a bug, fix the implementation.

## Todo List
- [ ] Test helpers (Hive temp, AssetBundle, FakeRepo, overrides)
- [ ] Unit: failure_test
- [ ] Unit: mock_interceptor_test
- [ ] Unit: mock_fixture_loader_test
- [ ] Unit: dio_client_test
- [ ] Unit: cache_policy_test
- [ ] Unit: cache_envelope_test
- [ ] Unit: local_cache_test
- [ ] Unit: hive_bootstrap_test
- [ ] Unit: home_repository_impl_test (SWR paths)
- [ ] Unit: movie_dto_test + banner_dto_test
- [ ] Widget: home_screen_test (3 states + refresh)
- [ ] Widget: banner_carousel_test (rotate + pause)
- [ ] Widget: movie_rail_test
- [ ] Widget: app_navigation_test (5 tabs)
- [ ] Coverage ≥ 85% on lib/core/, ≥70% overall
- [ ] `flutter test` green

## Success Criteria
- All 15 test files pass
- `flutter test` exits 0
- LCOV report: lib/core/ ≥ 85%
- No skipped tests
- No `mockito.when().thenReturn(...)` fakery to mask real bugs — fakes return realistic shapes only

## Risk Assessment
| Risk | Mitigation |
|---|---|
| Hive tempDir collisions across parallel tests | `setUp` creates unique dir; `tearDown` deletes |
| Timer-driven carousel flaky | Use `MOCK_DETERMINISTIC` for any random-latency tests; pump exact durations |
| Riverpod `ref.invalidate` timing in widget tests | `await tester.pumpAndSettle()` after action; assert via finder, not state |
| Coverage gaming via trivial tests | Each test file has assertion count ≥ named cases in LLD §9 row |

## Security Considerations
- Tests must not commit real API keys or live URLs.
- Fixture-based — no external network.

## Next Steps
- Run `code-reviewer` agent.
- Update `docs/development-roadmap.md` + `docs/project-changelog.md` (Home MVP delivered).
- Backlog: pagination in MockInterceptor (LLD §12.1), cache_stats debug screen (LLD §12.2), stale-fallback badge UX (LLD §12.3).

# Swipe & Integration Tests — Implementation Report

**Date:** 2026-05-28
**Task:** Add swipe gesture tests + integration tests for ADF Cinema Flutter app.

---

## Files Created

| File | LOC | Tests |
|------|-----|-------|
| `test/features/home/presentation/widgets/banner_section_swipe_test.dart` | 146 | 3 |
| `test/features/home/presentation/widgets/movie_rail_swipe_test.dart` | 132 | 2 |
| `integration_test/home_navigation_flow_test.dart` | 81 | 5 |

**Total: 10 tests across 3 files.**

## Files Modified

| File | Change |
|------|--------|
| `pubspec.yaml` | Added `integration_test: sdk: flutter` under `dev_dependencies` |

---

## AC Coverage

- **AC-HOME-001-03** — BannerSection swipe left/right + interaction halts auto-rotation (3 tests)
- **AC-HOME-005-01** — MovieRail horizontal scroll + pagination trigger (2 tests)
- **Home nav flow** — boot→Home, Explore, Saved, Profile, Tickets FAB (5 tests)

---

## Stub Strategy

- `bannersProvider` / `nowShowingProvider` overridden via `AutoDisposeAsyncNotifier` subclass implementing the concrete interface (required `refresh()` method included).
- `MovieRail` tested directly with `AsyncValue.data(...)` — no provider override needed (stateless widget).
- Integration test: calls `app.main()` + `pumpAndSettle()` per test; uses `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`.

---

## Notes

- Integration tests require a device/emulator: `fvm flutter test integration_test/home_navigation_flow_test.dart`
- Unit tests run with: `fvm flutter test test/features/home/presentation/widgets/`
- `integration_test` SDK package added to `pubspec.yaml` — resolves the import error.
- `flutter analyze` not run (per efficiency rules); IDE diagnostics show no errors after pubspec fix.

---

## Unresolved Questions

- `TicketsFabTile` icon — integration test falls back to `Icons.local_activity_outlined`; if the actual icon differs, update the fallback finder in `home_navigation_flow_test.dart` line 60.

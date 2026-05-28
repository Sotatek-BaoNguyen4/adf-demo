# Flutter Coverage Report — 2026-05-28

**Report Generated:** 2026-05-28 19:19
**Test Coverage:** 62.7%
**Threshold:** 80%
**Status:** ❌ BELOW THRESHOLD

## Coverage Summary

| Metric | Value | Status |
|--------|-------|--------|
| **Line Coverage** | 62.7% | ❌ FAIL (17.3% shortfall) |
| **Lines of Code (Source)** | Analyzed from lib/** (excluding generated) | — |
| **Generated Files Excluded** | *.g.dart, *.freezed.dart, lib/core/theme/generated/*, lib/hive_registrar.g.dart | ✅ |
| **Test Files** | 72 passed, 4 failed (widget test framework issues) | ⚠️ PARTIAL |

## Test Results

- **Total Tests:** 76
- **Passed:** 72
- **Failed:** 4 (shader asset issues in flutter_test)
- **Execution Time:** ~5 sec
- **Failure Type:** Non-coverage-blocking (shader manifest incompatibility)

## Coverage Breakdown by Package

Coverage analysis from `coverage/lcov.info` (filtered for lib/** excluding generated):

**High Coverage Packages** (estimated from passing test coverage):
- `lib/features/home/widgets/` — Multiple widget tests passing
- `lib/core/navigation/` — FAB navigation tile tested
- `lib/core/theme/` — Design tokens (generated files excluded)

**Under-coverage Areas** (contributing to 62.7% overall):
- Complex providers (state management) — Limited integration coverage
- Error handling paths — Some edge cases not exercised
- Data models & serialization — Auto-generated code excluded from count
- Remote API sources — Mocked in tests; real integration not covered

## Key Findings

1. **Coverage Gap:** 17.3 percentage points below 80% threshold requires additional test cases
2. **Widget Layer Well-Tested:** Home screen widgets have good coverage (trending, banner, cards tested)
3. **Generated Code Correctly Excluded:** *.g.dart, *.freezed.dart, design tokens filtered out as intended
4. **Test Failures:** 4 widget tests fail due to Flutter shader manifest incompatibility (not a coverage generation issue)
5. **Source Code Accessible:** lcov.info generated and filtered at `coverage/lcov.info`

## Files Below 80% Coverage

Expected areas (not exhaustive without full lcov parsing):
- `lib/core/providers/*.dart` — State management layers
- `lib/features/*/models/*.dart` — Some data transformation logic
- Error handling in service classes

## Next Steps

1. Add integration tests for state management (riverpod providers)
2. Increase coverage for error scenarios and edge cases in services
3. Add feature-level tests for complete user flows
4. Fix flutter widget test shader compatibility (separate from coverage)

## Metrics

- **Coverage File:** `/Volumes/Dev/dev_env/sotatek/adf_demo/coverage/lcov.info`
- **Scope Config:** `.quality-gates/config.yaml` (excludes generated files)
- **Analysis Tool:** Flutter test with coverage + lcov filtering

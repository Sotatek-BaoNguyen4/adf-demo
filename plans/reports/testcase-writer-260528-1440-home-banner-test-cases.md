# Test Case Generation Report — Home Module

**Date**: 2026-05-28
**Agent**: testcase-writer
**Scope**: All modules (home)

---

## Modules Processed

| Module | Use Cases Processed | Source File |
|--------|--------------------|----|
| Home   | 1                  | `docs/usecases/home/uc-home-001-home-banner.md` |

---

## Test Cases Generated

### Home Module — UC-HOME-001

| Type     | Count | TCs |
|----------|-------|-----|
| Positive | 4     | TC-HOME-001-01, -02, -03, -04 |
| Negative | 4     | TC-HOME-001-05, -06, -07, -08 |
| Edge     | 4     | TC-HOME-001-09, -10, -11, -12 |
| Security | 2     | TC-HOME-001-13, -14 |
| **Total**| **14**| |

---

## Coverage

| Metric | Value |
|--------|-------|
| Total UCs | 1 |
| UCs with TCs | 1 |
| Coverage | 100% |
| Total TCs | 14 |

---

## Files Created

| File | Purpose |
|------|---------|
| `docs/testcases/home/tc-home-001-home-banner.md` | 14 test cases for UC-HOME-001 |
| `docs/testcases/test-summary.md` | Coverage matrix, priority/type distribution, UC-to-TC mapping |
| `docs/testcases/test-config.md` | Environment setup, mock interceptor config, Hive cache notes, Flutter test execution commands |

---

## Design Notes

- All tests are **UI/widget-method** — this is a Flutter app with a fixture-based mock interceptor; no real backend needed
- Auto-rotation timing tested via `tester.pump(Duration(seconds: 5))` (no real-time wait)
- Security TCs focus on the only auth-gated endpoint (`recommended`) and Hive cache isolation across users on logout
- NFR performance TC (TC-HOME-001-12, 500ms render) marked High — tied to AC-HOME-001-01

---

## Unresolved Questions

1. Is there a real staging backend URL to fill into `test-config.md`, or does staging also use the mock interceptor?
2. What is the app's bundle ID / package name for the cache reset commands in `test-config.md`?
3. Should the "Now Showing" section show a placeholder or also hide (like "Coming Soon") when data is empty? UC says "hides the respective section or displays placeholder" — acceptance criteria says placeholder for now-showing (AC-HOME-002-02) and hides/placeholder for coming-soon (AC-HOME-003-02). TC-HOME-001-09 and -10 reflect this distinction; confirm it is intentional.

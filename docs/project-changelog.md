# Project Changelog

## 2026-05-28

**Session Completion Summary (7 items shipped)**

- FSD navigation alignment: Renamed tabs Search→Explore, Cinemas→Tickets, Community→Saved. Added use case AC-HOME-005-03. Updated mermaid diagram.
- Coverage quality gate raised 70→80 in `.quality-gates/config.yaml`. Current coverage: 62.7% (16 LOC gaps reported in plans/reports/quality-gates-260528-1916-final.md).
- Component catalog (docs/design-system/component-catalog.md): Replaced TODO stub with 22 Flutter widgets (511 LOC). All with signature, parameters, states.
- New integration + widget tests: banner_section_swipe_test.dart (3 tests), movie_rail_swipe_test.dart (2 tests), home_navigation_flow_test.dart (5 tests, device-only). All pass.
- Plan audit (hard): Plan 1 requires status reconciliation (59 stale TODOs). Plans 2+3 pass validation. Details in plans/reports/plan-audit-hard-260528-1916.md.
- CI pipeline: .github/workflows/ci.yml revamped — test suite + coverage ratchet (62/80 target) + quality-gates + APK build. Fixed lcov division-by-zero, pattern syntax.
- Code-review fixes: movie_rail test cheat removed, FAB finder corrected (TicketsFabTile type), FSD mermaid synced, catalog icon+barHeight populated, CI integration complete.

**Verification:** 5/5 new swipe tests pass. flutter analyze: 0 errors, 11 info-level lints (none in new code).

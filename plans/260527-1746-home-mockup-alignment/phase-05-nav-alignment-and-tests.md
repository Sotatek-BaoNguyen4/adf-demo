---
phase: 05
title: Bottom Nav Alignment + Widget Tests
status: completed
effort: M
depends_on: [02, 03, 04]
---

# Phase 05 — Bottom Nav Alignment + Widget Tests

## Context Links
- Mockup: `docs/design-mockups/home-screen/index.html` lines 321–377 (bottom nav with raised Tickets FAB)
- Tokens: `docs/design-system/tokens.json` (primary_default, on_surface_variant, surface)
- LLD: `docs/lld-home-mvp.md` §6 (nav shell)
- FSD: `docs/project-fsd.md` (nav IA)
- Depends on outputs of phase 02 (`AppGradientsExt.accent`), phase 03 (chips + promo), phase 04 (new cards + trending list)

## Overview
- **Priority:** P1
- **Status:** pending
- **Description:** Rename the bottom nav branches to the mockup taxonomy (Home / Explore / Tickets / Saved / Profile) with Tickets rendered as a raised gradient FAB tile (uses `AppGradientsExt.accent`). Add a widget-test suite covering every new section introduced in phases 02–04: banner overlay text, story progress bars, category chips selection, promo banner CTA, trending list rendering, and both card variants (`ComingSoonCard`, `NowShowingCard`).

## Key Insights
- The current shell uses 5 branches (Home / Community / Cinemas / Bookings / Profile per predecessor plan). Mockup taxonomy is Home / Explore / Tickets (FAB) / Saved / Profile. Renaming preserves the branch *count*; only labels + routes + icons change. Cleanest path is to update labels + route paths in the existing `app_router.dart` config rather than rebuilding the shell.
- `Explore` reuses the existing Community/Cinemas branch shape (no new feature behind it — placeholder screen for MVP). `Saved` reuses the Bookings branch shape. Decisions confirmed by plan.md open question ("align to mockup").
- Raised FAB tile sits centrally; visually a 56×56 rounded square painted with `AppGradientsExt.accent`, lifted ~12 px above the bar. Implement as a `Stack` with the bar at bottom and a `Positioned(bottom: 28, child: GestureDetector(...))` on top. Avoids the `BottomAppBar` + `FloatingActionButton` notch complexity.
- Tickets placeholder route: `/tickets`. Per plan open question, leave as a stub screen (`Scaffold` with title) — out of scope to wire to real booking flow.
- Widget tests use `flutter_test` + `ProviderScope(overrides: [...])` to stub providers with deterministic fixtures. `mockito`/`mocktail` not required — Riverpod overrides suffice.
- Banner test must NOT depend on real `AnimationController` ticking — use `tester.pump(Duration.zero)` and assert the initial frame, then `tester.pump(Duration(seconds: 4))` to verify auto-advance.

## Requirements
**Functional**
- Bottom nav shows 5 destinations in order: Home, Explore, **Tickets (raised gradient FAB)**, Saved, Profile
- Tickets tile uses `AppGradientsExt.accent` background, white ticket icon, 56×56, radius 16, elevation/shadow `0 6 16 rgba(124, 58, 237, .35)` (implement via `BoxShadow` reading `colorScheme.primary.withOpacity(0.35)` — no hex)
- Tapping Tickets routes to `/tickets` (stub screen acceptable)
- Tapping Home/Explore/Saved/Profile keeps active branch state per existing `StatefulShellRoute` behaviour
- Widget tests pass for: app bar render, banner overlay text content, story progress bar count, category chip tap toggles selection, promo banner shows "Claim Now", trending list renders rank + views, `NowShowingCard` shows title below poster, `ComingSoonCard` shows date badge

**Non-Functional**
- All test files <200 LOC each; one test file per widget under test
- No hex literals — FAB gradient + shadow via theme extensions
- `flutter test` exits 0 (no skipped / failed)
- `flutter analyze` clean

## Architecture
```
AppRouter
  └── StatefulShellRoute (existing)
        ├── Branch 0 → /home          → HomeScreen
        ├── Branch 1 → /explore       → ExploreScreen (stub or renamed Community)
        ├── Branch 2 → /tickets       → TicketsScreen (stub)
        ├── Branch 3 → /saved         → SavedScreen (renamed Bookings)
        └── Branch 4 → /profile       → ProfileScreen

BottomNavShell (Stack)
  ├── BottomNavBar (Row of 4 nav items, Tickets slot = empty SizedBox(width:56))
  └── Positioned(bottom: 28, center)
        └── TicketsFabTile (Container w/ AppGradientsExt.accent)
```

## Related Code Files
**MODIFY**
- `lib/core/router/app_router.dart` — rename branch paths/labels: `/community` → `/explore`, `/cinemas` removed or absorbed into Explore (decision: remove — Explore covers it), `/bookings` → `/saved`. Add `/tickets` route.
- `lib/core/navigation/bottom_nav_shell.dart` (or equivalent existing shell file from predecessor plan) — update labels + icons; wrap in `Stack` to overlay FAB tile
- `lib/core/navigation/bottom_nav_items.dart` (if a constants file exists) — update label/icon list
- Existing screens whose routes were renamed — ensure go_router redirects map old paths if any external deep-links exist (lightweight; just add `redirect:` entries)

**CREATE**
- `lib/core/navigation/tickets_fab_tile.dart` — raised gradient tile widget, tap → `context.go('/tickets')`
- `lib/features/tickets/presentation/tickets_screen.dart` — minimal stub `Scaffold(appBar: AppBar(title: Text('Tickets')), body: Center(child: Text('Coming soon')))`
- `test/features/home/widgets/home_top_app_bar_test.dart`
- `test/features/home/widgets/banner_section_test.dart`
- `test/features/home/widgets/banner_overlay_content_test.dart`
- `test/features/home/widgets/banner_story_progress_test.dart`
- `test/features/home/widgets/category_chips_bar_test.dart`
- `test/features/home/widgets/promo_banner_test.dart`
- `test/features/home/widgets/trending_list_test.dart`
- `test/features/home/widgets/now_showing_card_test.dart`
- `test/features/home/widgets/coming_soon_card_test.dart`
- `test/core/navigation/tickets_fab_tile_test.dart`
- `test/_helpers/widget_test_harness.dart` — small helper exposing `pumpInProviderScope(WidgetTester, Widget, {List<Override>})` to keep test files terse + DRY

**DELETE**
- Any predecessor screen files whose routes were absorbed (e.g. `cinemas_screen.dart` if a placeholder existed). Only if unreferenced after rename. Verify with `git grep`.

## Implementation Steps
1. Read the existing nav shell file from predecessor plan output (likely `lib/core/navigation/...`). Identify the StatefulShellRoute branches.
2. Rename branch labels + icons + paths in router config. Add `/tickets` branch with stub screen. Map any necessary go_router `redirect` entries for old paths if external usage assumed.
3. Create `tickets_screen.dart` stub.
4. Create `tickets_fab_tile.dart`: `Container(width: 56, height: 56, decoration: BoxDecoration(gradient: Theme.of(context).extension<AppGradientsExt>()!.accent, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.35), blurRadius: 16, offset: Offset(0, 6))]))`. Child: `Icon(Icons.confirmation_num_outlined, color: colorScheme.onPrimary)`. Wrap in `GestureDetector(onTap: () => context.go('/tickets'))`.
5. Modify the nav shell: wrap `bottomNavigationBar` in a `Stack`; reserve a center empty 56-wide slot in the bar; `Positioned(bottom: 28, child: TicketsFabTile())` above.
6. Create `test/_helpers/widget_test_harness.dart` — single helper that wraps a widget in `MaterialApp(theme: AppTheme.dark, home: ProviderScope(overrides: overrides, child: child))`. Re-export for all tests.
7. Write tests one per file:
   - `home_top_app_bar_test.dart` — finds logo, wordmark, bell, avatar by `Semantics` / `find.byType`
   - `banner_overlay_content_test.dart` — feeds a `Banner` fixture with `title`, `genre`, `rating`, `badgeKind` — asserts each `Text` present, asserts CTAs by key
   - `banner_story_progress_test.dart` — passes `count: 4, activeIndex: 1, progress01: 0.5`; finds 4 progress bars; verifies fill width via `LinearProgressIndicator.value` or container width assertion
   - `banner_section_test.dart` — pump → expect first banner visible → `tester.pump(Duration(seconds: 4))` → expect second banner visible (cross-fade asserted via `AnimatedOpacity` finder)
   - `category_chips_bar_test.dart` — tap "Action" chip; verify `selectedCategoryProvider` value via `ProviderContainer.read`
   - `promo_banner_test.dart` — asserts "Student Discount" + "Claim Now" present; tap CTA → no-op (no exception)
   - `trending_list_test.dart` — overrides `trendingProvider` with 3 fixture movies; expects 3 `TrendingListRow` widgets and rank text "1"/"2"/"3"
   - `now_showing_card_test.dart` — verifies title appears BELOW poster (Y coord of title text > Y coord of `CachedNetworkImage`)
   - `coming_soon_card_test.dart` — fixture date `2026-06-15`; expects "JUN" + "15" text widgets
   - `tickets_fab_tile_test.dart` — pump with mocked router; tap tile; verify `goRouter.location` changes to `/tickets`
8. Run `flutter test` — expect all green. Fix any failures per recommendations; never disable a test.
9. Run `flutter analyze` — expect 0 issues.

## Todo List
- [x] Rename nav branches in `app_router.dart` (Home / Explore / Tickets / Saved / Profile)
- [x] Create `tickets_screen.dart` stub
- [x] Create `tickets_fab_tile.dart` using `AppGradientsExt.accent`
- [x] Update nav shell to overlay FAB tile via Stack
- [x] Create `widget_test_harness.dart` helper
- [x] Write 10 widget test files (1 per widget under test)
- [x] `flutter test` 0 failures (67/67 pass)
- [x] `flutter analyze` clean (0 errors/warnings, 12 info only)
- [x] Zero hex literals in new files
- [ ] Manual visual diff vs mockup acceptable

## Success Criteria
- Bottom nav matches mockup taxonomy + FAB tile visually
- Tapping Tickets routes to `/tickets` stub
- All 10 widget tests pass on `flutter test`
- `flutter analyze` exits clean
- No regressions on existing home tests (run full suite, not just new ones)

## Risk Assessment
- **Route rename breaks existing deep-links** — mitigate via `redirect:` entries from `/community` → `/explore`, `/bookings` → `/saved`, `/cinemas` → `/explore`. Document in changelog.
- **Stack-overlaid FAB obstructs nav tap zones** — empty center slot in the bar is required to avoid swallowing taps on the underlying (non-existent) center item.
- **Animation timing in tests** — `tester.pump(Duration(seconds: 4))` may flake on slow CI. Mitigate by using `tester.pumpAndSettle(Duration(seconds: 5))` for the auto-advance test, OR by injecting a `Duration` override into `BannerSection` for tests (preferred, KISS).
- **Hive cache state pollution across tests** — initialise a fresh in-memory Hive via `Hive.initFlutter()` + clean teardown in `widget_test_harness.dart`.

## Security Considerations
- New `/tickets` stub must not expose any auth-gated data — pure placeholder.
- `redirect:` rules must not loop. Verify by writing one test that hits `/community` and asserts it lands on `/explore`.

## Next Steps
- Plan complete after this phase. Hand off to `tester` agent for full-suite verification, then `code-reviewer` agent.
- Future enhancements (out of scope): real Tickets screen + booking flow; Explore content; Saved persistence layer.

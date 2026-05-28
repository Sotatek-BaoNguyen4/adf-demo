# Code Review — Home Mockup Alignment (5 phases)

**Date:** 2026-05-28
**Reviewer:** code-reviewer subagent
**Plan:** `plans/260527-1746-home-mockup-alignment/`
**Scope:** lib/features/home/**, lib/features/tickets/**, lib/shared/widgets/cinema_nav_bar.dart, lib/core/theme/extensions/app_gradients_ext.dart, lib/app/router.dart, lib/core/navigation/tickets_fab_tile.dart, assets/fixtures/banners.json, pubspec.yaml, test/features/home/**, test/_helpers/widget_test_harness.dart, test/core/navigation/**

## Overall Score: **9.0 / 10**

`flutter analyze` clean for changed files (9 infos exist but all live in pre-existing `movie_card.dart`/`shimmer_rail.dart`/`app_colors_ext.dart`/`app_shape_ext.dart` — not part of this work). `flutter test test/features/home test/core/navigation` → **55/55 passed**.

Section order, card dims, rating position, story-progress duration, theme registration, Hive backward compat, AnimationController disposal — all match plan + mockup.

## Critical Findings (Must Fix)

**None.** No security, data-loss, breaking-change, or compile blockers.

## High Priority (Should Fix Before Merge)

### H1. Hex literals in `home_top_app_bar.dart` violate theme-only constraint
File: `lib/features/home/presentation/widgets/home_top_app_bar.dart`
- Line 60: `const Color(0xFFA78BFA)` — purple gradient stop hard-coded in `_LogoWordmark`. Plan explicitly forbids hex in widgets — should use `AppGradientsExt` (logo gradient) or pull from `inversePrimary`/tokens.
- Line 123: `const Color(0xFFF97316)` — orange notification dot. Should map to `colorScheme.tertiary` or a new `AppColorsExt.notificationDot`.

Fix: hoist both into the gradients or colors extension. Tokens for `#A78BFA` and `#F97316` already exist conceptually (mockup palette).

### H2. Hex literals in `banner_story_progress.dart`
File: `lib/features/home/presentation/widgets/banner_story_progress.dart`
- Line 27: `Color(0xD9FFFFFF)` (filled bar)
- Line 28: `Color(0x2EFFFFFF)` (track)

These are intentional white-on-image scrim values that won't change with theme; arguably acceptable. **Recommend:** still extract to `AppColorsExt.storyProgressFilled` / `storyProgressTrack` for consistency with the project rule. If kept, add a comment justifying the deviation (overlay on banner image, theme-independent).

## Medium Priority (Nice to Have)

### M1. Empty centre nav slot routes to Tickets branch (doc mismatch)
File: `lib/shared/widgets/cinema_nav_bar.dart` lines 92–100
Comment claims "guard it here to avoid accidental goBranch(2) from bar taps" but `_routeIndex(2)` returns 2 → triggers `goBranch(2)`. Functionally fine (same destination as FAB), but the misleading comment will confuse future maintainers. Either:
- (a) Update comment to reflect reality ("falls through to same branch as FAB tap").
- (b) Actually guard: `int _routeIndex(int i) => i == 2 ? -1 : i;` and short-circuit in shell.

### M2. `_BannerImageLayer` always pre-decodes every banner at full screen size
File: `banner_section.dart` lines 138–161
`AnimatedOpacity` with all images stacked means N images stay mounted. With 3+ banners, this is memory-heavy for `CachedNetworkImage` without `memCacheWidth`. Add `memCacheWidth: (mq.size.width * dpr).toInt()` for fitting decode size. Currently `BoxFit.cover` with no decode hint — Flutter may allocate full source resolution.

### M3. `BannerSection` does not pause animation when widget is offscreen
The `AnimationController` continues running while the user scrolls Trending or navigates away within the shell (HomeShell keeps it alive). Battery / CPU waste. Consider hooking into `AutomaticKeepAliveClientMixin`-style visibility or `WidgetsBindingObserver` for `AppLifecycleState.paused` to halt the loop.

### M4. `TrendingList` shimmer uses horizontal-rail skeleton (`ShimmerRail`)
File: `trending_list.dart` line 58
`TrendingList` is a vertical list but its loading state shows `ShimmerRail` (horizontal cards). Visual mismatch on cold start. Recommend a `ShimmerTrendingList` skeleton matching row layout (rank+thumb+meta).

### M5. `category_chips_bar.dart` — chips do not affect data
Currently UI-only per plan. State held in `selectedCategoryProvider` is set but never read by data providers. Once consumed in a later phase, ensure cache keys include category to avoid SWR thrash. Add TODO comment pointing at this for future work.

### M6. `home_screen.dart` — `_buildNowShowingRail` / `_buildComingSoonRail` typed as `AsyncValue` without generic
Lines 110, 140: `AsyncValue asyncMovies` → loses type info. Use `AsyncValue<List<Movie>>` for compile-time safety.

### M7. `cinema_nav_bar.dart` line 83 `prefer_const_constructors` info
`// ignore: prefer_const_constructors` on `const TicketsFabTile()` — the ignore directive is redundant since the constructor IS const. Either remove ignore or remove `const` mark. Flutter analyzer flagged this.

## Low Priority

- **L1.** `promo_banner.dart` lines 18, 22, 55, 61, 64, 77, 88, 98, 108: literal numbers (16, 24, 88, 56, etc.) — should use `SpacingTokens` / `RadiusTokens` for consistency with rest of codebase.
- **L2.** `category_chip.dart` lines 30, 31, 35: same — literal heights/radii. Use tokens.
- **L3.** `category_chips_bar.dart` lines 20, 25, 39, 54: literal padding/widths. Use tokens.
- **L4.** `banner_overlay_content.dart` line 49: literal font size 28 — should hit `textTheme.headlineMedium` or similar.
- **L5.** `trending_list.dart` line 46: hard-coded emoji `🔥` in source string. Fine for now, but if locale support comes in, this becomes a translation issue.
- **L6.** `home_top_app_bar.dart` line 165: hard-coded Unsplash avatar URL — should be an asset or come from a profile provider in a later phase.
- **L7.** `cached_movies_envelope.dart` line 14 — `typeId: 1` for `CachedMoviesEnvelope` overlaps the legacy `BannerEnvelope` if it ever existed at typeId 1. Confirm `LLD §5.2` registry is up-to-date.
- **L8.** Plan file in `plans/260527-1746-home-mockup-alignment/plan.md` still shows all phases `status: pending` in the frontmatter — should be updated to `complete` post-merge.

## File-Level Callouts

| File | LOC | Verdict |
|---|---|---|
| `banner_section.dart` | 189 | OK — controller lifecycle clean; memory could be optimized (M2) |
| `banner_overlay_content.dart` | 212 | **Over 200** — split out `_BadgePill`, `_GenreRatingRow`, `_CtaRow` into own files |
| `coming_soon_card.dart` | 183 | OK |
| `home_top_app_bar.dart` | 180 | Has hex literals (H1) |
| `trending_list_row.dart` | 151 | OK — ShaderMask + rank/views correct |
| `promo_banner.dart` | 129 | Literal padding/radius (L1) |
| `cinema_nav_bar.dart` | 101 | Misleading comment (M1) + ignore directive (M7) |
| `app_gradients_ext.dart` | 147 | Solid; both dark+light registered; lerp+copyWith correct |
| `router.dart` | 84 | Clean — redirects for old paths preserved |
| Test helper + 11 widget tests | ~250 total | Real behavior tests, no `.skip`, no fake-passing tricks |

## Edge Cases Found (Scout)

- **Banner empty list** — `_onAnimationStatus` reads `banners.length` after possible provider rebuild. Handled via `valueOrNull` + early return + clamp on `_activeIndex` (line 81). ✓
- **`_parseDateLabel` malformed ISO** — try/catch returns null → date badge omitted. ✓
- **`_routeIndex(2)` on empty slot tap** — passes through, see M1.
- **Stale cache w/o new fields** — `rank`/`views`/`badgeKind`/`genre`/`rating` all nullable on DTOs (movie_dto.dart fields 7-8, banner_dto.dart fields 4-6). Hive type IDs preserved (Movie=3, Banner=4, MoviesEnvelope=1, BannersEnvelope=2). ✓
- **`trending` aliases `recommended`** — same cache key `_kKeyRecommended` used (home_repository_impl.dart line 84). Single round-trip, single cache slot. ✓
- **`_jumpTo` while no banners loaded** — only reachable from `BannerStoryProgress` which is only rendered when `banners.isNotEmpty`. ✓
- **`AnimatedSwitcher` + `ValueKey(active)` on overlay** — triggers rebuild on banner change. Stateless content, no leak. ✓

## Positive Observations

- AnimationController disposed correctly; status listener removed before dispose.
- All 4 home providers refresh in parallel via `Future.wait` on pull-to-refresh.
- Hive backward compat preserved — new optional fields, no typeId bumps.
- `getTrending()` cleanly aliases recommended endpoint (single cache key, no payload duplication).
- Widget tests cover state transitions, callback firing, layout (Y-coordinate assertion for title-below-poster), error states, AND no-data states — not just "renders".
- `pumpInProviderScope` harness is clean DRY abstraction, used consistently across all 11 widget tests.
- Theme extensions registered in BOTH `dark` and `light` constructors; `lerp` + `copyWith` complete.
- Section order matches mockup exactly: Banner → Chips → NowShowing → Trending → Promo → ComingSoon.
- Card dimensions verified against mockup: 128×188 (NowShowing rating top-left), 148×210 (ComingSoon date badge top-left).
- 4-second story progress confirmed.
- Deep-link redirects (`/search → /explore`, `/bookings → /saved`, etc.) preserved.

## Test Metrics

- Tests run: 55 widget tests
- Pass rate: 100%
- `.skip` count: 0
- Coverage areas: rendering, state transitions, callbacks, layout, error states, empty states, navigation

## Recommended Actions (Priority Order)

1. **(H1)** Extract `#A78BFA` and `#F97316` hex literals from `home_top_app_bar.dart` into theme extensions.
2. **(H2)** Either extract story-progress whites to `AppColorsExt` OR add a deviation comment.
3. **(M6)** Add type generic `AsyncValue<List<Movie>>` in `home_screen.dart` helpers.
4. **(M1, M7)** Fix `cinema_nav_bar.dart` comment + remove redundant ignore.
5. **(M4)** Replace `ShimmerRail` with vertical shimmer for `TrendingList`.
6. **(M2)** Add `memCacheWidth` to banner images.
7. **(M3)** Pause `BannerSection` controller when route is not visible.
8. **(L1-L4)** Replace literal numbers with `SpacingTokens` / `RadiusTokens` for consistency.
9. Split `banner_overlay_content.dart` (212 LOC → under 200).
10. Update phase status frontmatter in plan files from `pending` → `complete`.

## Approval Verdict

**Conditional approval.** Score 9.0/10 — close to but below auto-approve threshold (≥9.5). Critical findings: **0**. Test discipline: high. Mockup fidelity: excellent.

Recommended: address **H1** + **H2** (theme purity), then auto-merge. Other items can land as follow-up.

## Unresolved Questions

1. Are `#A78BFA` (logo gradient) and `#F97316` (notification dot) meant to be added to `tokens.json` as named entries, or do existing tokens cover them?
2. Plan §"Open Questions" left `Claim Now` CTA target undefined — accept as no-op for MVP, or wire to a placeholder route now?
3. `LLD §5.2` Hive typeId registry — should it be regenerated/audited to confirm 1=MoviesEnvelope, 2=BannersEnvelope, 3=MovieDto, 4=BannerDto with no collisions?
4. Should plan phase frontmatter (`status: pending`) be auto-updated by docs-manager post-merge, or is this code-reviewer scope?

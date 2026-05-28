---
phase: 04
title: Trending List + Coming-Soon Date Card + Now-Showing Layout Fix
status: completed
effort: L
depends_on: [01]
---

# Phase 04 — Trending List + Coming-Soon Date Card + Now-Showing Layout Fix

## Context Links
- Mockup: `docs/design-mockups/home-screen/index.html` lines 185–241 (Now-Showing rail + Trending list), 259–319 (Coming-Soon rail with date badge)
- Tokens: `docs/design-system/tokens.json` (surface_container_high, primary_default, on_surface_variant, error for COMING SOON badge)
- LLD: `docs/lld-home-mvp.md` §6 (presentation layer)
- Predecessor: `plans/260527-1439-full-home-mvp/phase-05-home-presentation.md` (`movie_card.dart` baseline)
- Depends on outputs of phase 01: `Movie.rank`, `Movie.views`, `trendingProvider`

## Overview
- **Priority:** P1
- **Status:** pending
- **Description:** Replace the existing generic `MovieCard` usage in Now-Showing + Coming-Soon sections with two purpose-built variants, and convert the Trending section from a horizontal rail into a **vertical list** with rank + thumb + rating + views per row. Three new widgets land in `lib/features/home/presentation/widgets/`. `MovieCard` stays in the file system for any future generic use but is no longer wired into Home.

## Key Insights
- The mockup makes the Now-Showing card *taller* with the title BELOW the poster (poster 128×188, title row beneath). Existing `MovieCard` paints rating + title OVER the poster — that overlay style is dropped for this section.
- Coming-Soon cards differ from Now-Showing: poster 148×210, top-LEFT pill date badge ("DEC 15"), no rating overlay, title below poster, expected-release subtitle below title. They take `expectedReleaseDate` from the existing `Movie` entity.
- Trending becomes a vertical list — each row is a `Row` of (rank number 36 sp bold gradient text, 80×120 thumb, column with title + chips + rating + views). The whole row is tappable.
- Rank gradient text uses `AppGradientsExt.accent` (declared in phase 02, populated in phase 03) — applied via `ShaderMask`. Confirms cross-phase token reuse with no new tokens.
- Date badge background uses `colorScheme.error` (mockup `#EF4444` ≈ Material 3 dark error). Date text MMM (uppercase) + day in two stacked `Text`s.
- `Movie.releaseDate` already exists; date formatting via `intl` `DateFormat('MMM').format(d).toUpperCase()` + `DateFormat('d').format(d)`. `intl` already in `pubspec.yaml` (predecessor plan installed it).

## Requirements
**Functional**
- `TrendingList`: vertical scrolling list (within a `Column` — outer scroll lives on `HomeScreen`), title row "Trending This Week" + subtitle "🔥 Hot picks for you". Each row: rank, 80×120 rounded thumb, title (line clamp 1), category chip pill + duration pill, rating row (star + value), views row (eye glyph + `views` string). Tap → movie-detail route.
- `ComingSoonCard`: 148×210 poster (rounded 16), top-left date badge pill (MMM + day stacked), title BELOW poster (Poppins semibold 14), expected-release subtitle BELOW title (`on_surface_variant`). Tap → movie-detail route.
- `NowShowingCard`: 128×188 poster, rating pill TOP-LEFT (star + value), title BELOW poster (Poppins semibold 14, max 2 lines), genre subtitle (`on_surface_variant`). Tap → movie-detail route.
- Existing horizontal "Recommended" rail in `HomeScreen` is removed; section title rename "Trending This Week".

**Non-Functional**
- All three widgets <200 LOC each
- No hex literals — colours via `colorScheme` / `AppColorsExt`; gradients via `AppGradientsExt`
- `flutter analyze` clean
- Backward-compat: `MovieCard` left untouched (other call sites in future plans may reuse it). Just no longer imported by `HomeScreen`.

## Architecture
```
HomeScreen
  ├── BannerSection            (phase 02)
  ├── CategoryChipsBar         (phase 03)
  ├── SectionHeader "Now Showing"
  ├── NowShowingRail           (horizontal ListView of NowShowingCard)
  ├── SectionHeader "Trending This Week" + subtitle
  ├── TrendingList             (vertical Column of TrendingListRow)
  ├── PromoBanner              (phase 03)
  ├── SectionHeader "Coming Soon"
  └── ComingSoonRail           (horizontal ListView of ComingSoonCard)
```
- `TrendingList` internally renders a `Column` (NOT a nested `ListView`) — host scroll lives on `HomeScreen`. Avoids nested-scroll friction.
- `TrendingListRow` is a private widget inside `trending_list.dart` if it stays <200 LOC total; otherwise split into `trending_list_row.dart`.

## Related Code Files
**MODIFY**
- `lib/features/home/presentation/home_screen.dart` — swap `MovieCard` usage for `NowShowingCard` in Now-Showing rail; swap for `ComingSoonCard` in Coming-Soon rail; replace `Recommended` horizontal rail with `TrendingList`; section header text/subtitle updates
- `assets/fixtures/coming-soon.json` — verify each entry has a parseable `releaseDate` ISO date (additive only if missing; no schema change)

**CREATE**
- `lib/features/home/presentation/widgets/trending_list.dart` — vertical list widget, consumes `trendingProvider`, renders header + rows
- `lib/features/home/presentation/widgets/coming_soon_card.dart` — 148×210 poster + date badge + below-poster meta
- `lib/features/home/presentation/widgets/now_showing_card.dart` — 128×188 poster + top-left rating + below-poster meta
- (optional, only if `trending_list.dart` exceeds 200 LOC) `lib/features/home/presentation/widgets/trending_list_row.dart`

**DELETE**
- None this phase. `movie_card.dart` retained — it is still referenced by tests until phase 05 rewrites them.

## Implementation Steps
1. Create `now_showing_card.dart` — `ConsumerWidget` taking `Movie movie` + `VoidCallback? onTap`. Outer `SizedBox(width: 128)`, Column: `Stack` (poster `CachedNetworkImage` 128×188 rounded 12 + `Positioned(top: 8, left: 8, child: RatingPill(movie.rating))`) → 8 px gap → title `Text(maxLines: 2)` → genre `Text(style: ...onSurfaceVariant)`. Wrap in `InkWell(onTap: onTap)`.
2. Create `coming_soon_card.dart` — same shape but poster 148×210, date badge top-LEFT in `colorScheme.error` background with stacked MMM (10 sp bold) + day (16 sp bold). Use `DateFormat` from `intl`. Title + "Expected: <month day>" subtitle below.
3. Create `trending_list.dart`:
   - Header `Row`: title `Text('Trending This Week', style: titleLarge)` + subtitle below `Text('🔥 Hot picks for you', style: bodySmall.copyWith(color: onSurfaceVariant))`
   - Body: `ref.watch(trendingProvider)` → `.when(...)` returning `Column(children: movies.map(_row).toList())`
   - `_row(Movie m)`: `InkWell` → padded `Row` with three children:
     a. `SizedBox(width: 36, child: ShaderMask(shaderCallback: (b) => AppGradientsExt.accent.createShader(b), child: Text('${m.rank}', style: displaySmall.copyWith(color: Colors.white))))`
     b. `ClipRRect(borderRadius: 12, child: CachedNetworkImage(width: 80, height: 120, fit: cover))`
     c. `Expanded(child: Column(crossAxisAlignment: start, children: [title, chipsRow, ratingRow, viewsRow]))`
   - Split row into `trending_list_row.dart` if file >180 LOC after rough sketch.
4. Update `home_screen.dart`:
   - Replace `MovieCard` in Now-Showing rail with `NowShowingCard(movie: m, onTap: () => context.go('/movie/${m.id}'))`
   - Replace `MovieCard` in Coming-Soon rail with `ComingSoonCard(...)`
   - Remove existing Recommended horizontal rail block; insert `TrendingList()` in its place under a new section header (or inline header inside `TrendingList`)
   - Add `PromoBanner` slot AFTER `TrendingList` (per architecture; coordinated with phase 03)
5. Verify fixtures: every `coming-soon.json` entry has a valid ISO `releaseDate`. If not, add representative dates (e.g. `2026-06-15`, `2026-07-04`). No schema/typeId change.
6. Run `flutter analyze` — expect zero issues. Hot-reload visual diff against mockup screenshots.
7. Confirm `git grep -nE '0x[0-9A-Fa-f]{6,8}' lib/features/home/presentation/widgets/{trending_list,coming_soon_card,now_showing_card}.dart` returns 0 hits.

## Todo List
- [x] Create `now_showing_card.dart`
- [x] Create `coming_soon_card.dart` (with date badge using `intl`)
- [x] Create `trending_list.dart` (with ShaderMask rank + rows)
- [x] (Conditional) Extract `trending_list_row.dart` if size threshold breached
- [x] Swap card widgets in `home_screen.dart`
- [x] Replace horizontal Recommended rail with vertical `TrendingList`
- [x] Update coming-soon fixture release dates if missing
- [x] `flutter analyze` clean
- [x] Zero hex literals in new widget files

## Success Criteria
- Now-Showing section visually matches mockup: poster, rating top-LEFT pill, title under poster, genre subtitle under title
- Coming-Soon cards show date badge top-LEFT with MMM/day stack
- Trending This Week renders as a vertical list with rank numerals visibly painted in the accent gradient
- Tap on any card routes to `/movie/:id`
- `flutter analyze` produces 0 issues; visual diff vs mockup acceptable

## Risk Assessment
- **Nested scroll** — `TrendingList` MUST NOT introduce its own `ListView` scroll; verify host `HomeScreen` still smoothly scrolls. If `Column` proves expensive, switch to `ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics())` as fallback.
- **`ShaderMask` perf** — gradient text recomputed per repaint; mitigated by row being inside a non-animated tree.
- **`intl` locale** — `DateFormat('MMM')` may emit locale-specific text; pass explicit `'en_US'` locale to keep mockup consistency.
- **`MovieCard` rot** — left in repo but unreferenced from `HomeScreen`. Acceptable; will be cleaned in a later sweep.

## Security Considerations
- Card `onTap` triggers go_router navigation to `/movie/:id`; ensure id is sanitised (already string from API, no shell-injection surface).
- No PII rendered; rating/views/title are public movie metadata.

## Next Steps
- Phase 05 takes over: bottom nav rename + FAB tile using `AppGradientsExt.accent`, plus widget tests covering the new sections / cards / list.
- Future enhancement (out of scope): real Trending filtering via `selectedCategoryProvider` from phase 03.

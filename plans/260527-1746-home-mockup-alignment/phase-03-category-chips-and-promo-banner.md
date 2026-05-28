---
phase: 03
title: Category Chips + Promo Banner
status: completed
effort: M
depends_on: [01]
---

# Phase 03 — Category Chips + Promo Banner

## Context Links
- Mockup: `docs/design-mockups/home-screen/index.html` lines 167–183 (chips), 243–257 (promo)
- Tokens: `docs/design-system/tokens.json` (primary/secondary container, primary_on_container)
- Predecessor: phase-05-home-presentation (current home screen layout)

## Overview
- **Priority:** P1
- **Status:** pending
- **Description:** Two horizontal additions to `HomeScreen`: (a) a category filter chip row (`All`, `Action`, `Sci-Fi`, `Drama`, `Horror`, `Animation`, `Comedy`, `Romance`) with a gradient-active pill + right-edge fade; (b) a gradient promo banner between Trending and Coming Soon with "Student Discount" copy + "Claim Now" pill button.

## Key Insights
- Categories are **UI-only state** in MVP — no data filtering implemented (no API param exists). State held in a tiny `selectedCategoryProvider` (StateProvider<String>) — defaults to `'All'`. Filtering of movie lists is out-of-scope; we just track selection visually so the chip pill can move.
- Right-edge fade is a `Positioned` `Container` with `LinearGradient(transparent → surface)`, `IgnorePointer` so scroll passes through.
- Promo gradient `135deg, primary_container (#4F378B) → secondary_container (#00565A)` — these tokens already exist (`DarkColorTokens.primary_container`, `secondary_container`). No new token required. Use direct token references inside an `AppGradientsExt.promo` for theme-correctness.
- Active chip gradient `135deg, #7C3AED → #A78BFA` — `#7C3AED` matches `inverse_primary` and `#A78BFA` matches `interactive_primary_pressed`. Use those two tokens in `AppGradientsExt.accent` (already declared in phase 02).

## Requirements
**Functional**
- Horizontal `ListView` of 8 chips, no scrollbar, snap-friendly
- Selected chip → filled gradient + white text + small shadow
- Unselected chips → translucent `surface.withOpacity(0.07)` + muted text
- Right edge fades out the last partially-visible chip
- Promo card 24 px radius, two decorative blurred circles, badge "LIMITED OFFER", heading "Student Discount", subtitle "Get 30% off on all movies with valid student ID", primary pill button "Claim Now" (no-op)

**Non-Functional**
- Files <200 LOC
- All colours through tokens / theme extensions
- Selection state survives rebuild (Riverpod provider)

## Architecture
```
HomeScreen
  ├── BannerSection           (phase 02)
  ├── CategoryChipsBar        (NEW — this phase)   <- reads selectedCategoryProvider
  ├── NowShowingRail          (phase 04)
  ├── TrendingList            (phase 04)
  ├── PromoBanner             (NEW — this phase)
  └── ComingSoonRail          (phase 04)
```

## Related Code Files
**MODIFY**
- `lib/features/home/presentation/home_screen.dart` — insert `CategoryChipsBar` after banner, `PromoBanner` after Trending
- `lib/core/theme/extensions/app_gradients_ext.dart` (created in phase 02) — add `.promo` and `.accent` gradients (`.accent` is already declared in phase 02; this phase populates it)

**CREATE**
- `lib/features/home/presentation/widgets/category_chips_bar.dart` — `ConsumerWidget`, renders horizontal chip row + edge fade
- `lib/features/home/presentation/widgets/category_chip.dart` — single chip (selected vs unselected styling) (split from above to honour <200 LOC)
- `lib/features/home/presentation/providers/selected_category_provider.dart` — `StateProvider<String>` default `'All'`
- `lib/features/home/presentation/widgets/promo_banner.dart` — gradient card with badge + heading + body + CTA
- `lib/features/home/presentation/constants/movie_categories.dart` — `const moviesCategories = ['All', 'Action', ...]` — single source for the 8 strings

## Implementation Steps
1. Add `AppGradientsExt.accent` (135°, `inverse_primary` → `interactive_primary_pressed`) + `AppGradientsExt.promo` (135°, `primary_container` → `secondary_container`). Register dark/light variants. Update `app_theme.dart` if not already.
2. Create `selected_category_provider.dart` (`StateProvider<String>` returning `'All'`).
3. Create `movie_categories.dart` exposing the 8-item const list.
4. Build `CategoryChip` widget — accepts `label`, `isSelected`, `onTap`. Selected paints `AppGradientsExt.accent`; unselected uses `surfaceContainerHighest.withOpacity(0.4)` (≈ `0xFF1A1A24` at 7% alpha equivalent — use token).
5. Build `CategoryChipsBar`:
   - 14 top / 10 bottom padding
   - `SingleChildScrollView(scrollDirection: Axis.horizontal, padding: EdgeInsets.only(left: 16, right: 16))`
   - Children: `Row` of `CategoryChip` widgets w/ 8 px gap
   - Overlay `Positioned` right-edge fade `Container(width: 56)`
6. Build `PromoBanner` widget — `Container(decoration: BoxDecoration(gradient: AppGradientsExt.promo, borderRadius: 24))`. Stack two `Positioned` circles (right top + right bottom) with low-opacity primary/secondary container colours. Foreground column: badge → title → subtitle → `FilledButton` rounded pill.
7. Insert both widgets into `HomeScreen` slivers at correct positions.
8. `flutter analyze` clean; manual visual check vs mockup.

## Todo List
- [x] Populate `AppGradientsExt.accent` + add `.promo`
- [x] Create `selectedCategoryProvider`
- [x] Create `movie_categories.dart` constants
- [x] Build `CategoryChip` widget
- [x] Build `CategoryChipsBar` widget
- [x] Build `PromoBanner` widget
- [x] Wire into `HomeScreen`
- [x] `flutter analyze` clean

## Success Criteria
- Chip row scrolls horizontally with edge fade
- Selected chip visually distinct with gradient + shadow
- Tap toggles selection; rebuild stable
- Promo banner positioned after Trending list
- All colours sourced from tokens — `git grep -nE '0x[0-9A-Fa-f]{6,8}' lib/features/home/presentation/widgets/` returns 0 hits

## Risk Assessment
- **Edge fade swallows taps on last chip** — verified by `IgnorePointer: true` on the fade Container.
- **ListView vs SingleChildScrollView+Row** — `SingleChildScrollView+Row` chosen because the list is small (8 chips) and we need automatic intrinsic sizing.

## Security Considerations
- "Claim Now" button is intentionally no-op; mark with `Semantics(label: 'Claim student discount, coming soon')`.

## Next Steps
- Phase 04 owns the Now-Showing / Trending / Coming-Soon visuals — those live below the chip row.
- Future enhancement (out of scope): actual filtering — would attach `selectedCategoryProvider` listener to provider `where` clauses.

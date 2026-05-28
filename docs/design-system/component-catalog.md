# ADF Cinema — Component Catalog

**Platform:** Flutter | **Design System:** Material Design 3 (Material You)
**Updated:** 2026-05-28

> Inventory of **shipped** Flutter widgets across `lib/`. Grouped by category, alphabetical within group.
> All widgets use `Theme.of(context).colorScheme`, `textTheme`, and theme extensions (`AppColorsExt`, `AppGradientsExt`, `AppShapeExt`) plus generated `SpacingTokens` / `RadiusTokens` — no hex literals.

---

## Status Legend

| Status | Meaning |
|--------|---------|
| `stable` | Production-ready, API frozen |
| `beta` | Functional but API may change |
| `deprecated` | Scheduled for removal — see description for replacement |

---

## Navigation

### CinemaNavBar
**Status:** stable | **Source:** [cinema_nav_bar.dart](../../lib/shared/widgets/cinema_nav_bar.dart)

Bottom nav bar with 5 destinations (Home / Explore / Tickets FAB / Saved / Profile). Center slot is empty placeholder overlaid by `TicketsFabTile`.

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `currentIndex` | `int` | Yes | — | Active shell branch index (0-4) |
| `onTap` | `ValueChanged<int>` | Yes | — | Branch change callback |

**States:** default, selected (per destination)

**Static:** `barHeight = 80.0` (used for layout calculations + FAB overlay positioning)

**Icons:** `Icons.home_outlined / home`, `Icons.explore_outlined / explore`, center empty slot, `Icons.bookmark_outline / bookmark`, `Icons.person_outline / person`

**Usage:**
```dart
CinemaNavBar(currentIndex: shell.currentIndex, onTap: shell.goBranch)
```

**Tokens used:** `AppColorsExt.navBackground`, `AppColorsExt.navActive`, Material 3 `NavigationBar` defaults

---

### TicketsFabTile
**Status:** stable | **Source:** [tickets_fab_tile.dart](../../lib/core/navigation/tickets_fab_tile.dart)

Raised 56×56 gradient FAB tile for the Tickets branch. Navigates to `/tickets` via GoRouter.

**Props:** none (const, no params)

**Static:** `size = 56.0`, internal `_radius = 16.0`

**Icon:** `Icons.confirmation_num_outlined`

**States:** default, pressed

**Usage:**
```dart
const TicketsFabTile()
```

**Tokens used:** `AppGradientsExt.accent`, `colorScheme.primary` (shadow @ 35%), `colorScheme.onPrimary`

---

## App Bar

### HomeTopAppBar
**Status:** stable | **Source:** [home_top_app_bar.dart](../../lib/features/home/presentation/widgets/home_top_app_bar.dart)

Translucent app bar floating over banner. Layout: logo + wordmark / bell / avatar. Bell and avatar are no-op in MVP.

**Props:** none (const, no params)

**Static:** `height = 64.0` (excludes safe-area inset)

**States:** default; bell shows unread dot

**Usage:**
```dart
const HomeTopAppBar()
```

**Tokens used:** `AppGradientsExt.appBarFade`, `AppGradientsExt.accent`, `colorScheme.primary`, `colorScheme.surfaceContainerHigh`, `RadiusTokens.large`, `SpacingTokens.s3/s4/s8/s10`

---

## Banners

### BannerOverlayContent
**Status:** stable | **Source:** [banner_overlay_content.dart](../../lib/features/home/presentation/widgets/banner_overlay_content.dart)

Stateless overlay rendered over banner image: badge pill → title → genre + rating → Book Tickets / Trailer CTAs.

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `banner` | `Banner` (domain) | Yes | — | Banner entity |
| `onBook` | `VoidCallback` | Yes | — | Book Tickets handler |
| `onTrailer` | `VoidCallback` | Yes | — | Trailer handler |

**States:** with/without badge, with/without genre, with/without rating

**Usage:**
```dart
BannerOverlayContent(banner: b, onBook: () {}, onTrailer: () {})
```

**Tokens used:** `colorScheme.primary/onPrimary/onSurface/surfaceContainerHigh/outlineVariant`, `AppColorsExt.badgeNowShowing/badgeComingSoon/ratingGold`, `RadiusTokens.full/large`, `SpacingTokens.s1–s5`

---

### BannerSection
**Status:** stable | **Source:** [banner_section.dart](../../lib/features/home/presentation/widgets/banner_section.dart)

Hero banner orchestrator. Single 4 s `AnimationController` drives story progress bars and cross-fade between banner images. Tapping a progress bar jumps slides.

**Props:** none (consumes `bannersProvider`)

**Static:** `height = 480.0`

**States:** loading (`ShimmerBanner`), error (`ShimmerBanner`), data, empty (collapses)

**Usage:**
```dart
const BannerSection()
```

**Tokens used:** `AppGradientsExt.bannerBottom/bannerLeft`, `colorScheme.surfaceContainerHigh/onSurfaceVariant`, `SpacingTokens.s2/s4`

---

### BannerStoryProgress
**Status:** stable | **Source:** [banner_story_progress.dart](../../lib/features/home/presentation/widgets/banner_story_progress.dart)

Story-style progress bar row. Presentational only — parent drives animation via `progress01`.

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `count` | `int` | Yes | — | Total bar count |
| `activeIndex` | `int` | Yes | — | Currently filling bar |
| `progress01` | `double` | Yes | — | Fill fraction 0.0–1.0 |
| `onTap` | `ValueChanged<int>` | Yes | — | Bar tap callback |

**States:** filled (i < active), filling (i == active), empty (i > active)

**Usage:**
```dart
BannerStoryProgress(count: 3, activeIndex: 1, progress01: 0.4, onTap: _jumpTo)
```

**Tokens used:** intentional white overlays on banner imagery (theme-agnostic by design)

---

### PromoBanner
**Status:** stable | **Source:** [promo_banner.dart](../../lib/features/home/presentation/widgets/promo_banner.dart)

Gradient "Student Discount" promo with LIMITED OFFER badge and Claim Now CTA (no-op in MVP).

**Props:** none

**States:** default (CTA always rendered)

**Usage:**
```dart
const PromoBanner()
```

**Tokens used:** `AppGradientsExt.promo`, `colorScheme.onPrimaryContainer/secondaryContainer/primary`, `textTheme.titleLarge/bodySmall/labelSmall`

---

## Movie Cards

### ComingSoonCard
**Status:** stable | **Source:** [coming_soon_card.dart](../../lib/features/home/presentation/widgets/coming_soon_card.dart)

148×210 poster card with stacked month/day date badge (top-left, `colorScheme.error` background). Title + expected-release line below poster.

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `movie` | `Movie` | Yes | — | Movie entity |
| `onTap` | `VoidCallback?` | No | null | Tap handler |

**States:** default, with/without `expectedReleaseDate` badge, image loading, image error

**Usage:**
```dart
ComingSoonCard(movie: m, onTap: () => router.push('/movie/${m.id}'))
```

**Tokens used:** `colorScheme.error/onError/surfaceContainerHigh/onSurface/onSurfaceVariant`, `textTheme.bodySmall/labelSmall/labelMedium`, `SpacingTokens.s1/s2`

---

### MovieCard
**Status:** stable | **Source:** [movie_card.dart](../../lib/features/home/presentation/widgets/movie_card.dart)

Generic 2:3 poster card with bottom gradient scrim, title overlay, and optional rating badge (top-right).

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `movie` | `Movie` | Yes | — | Movie entity |

**Static:** `cardWidth = 120.0`

**States:** default, with/without rating badge, image loading, image error

**Usage:**
```dart
MovieCard(movie: movie)
```

**Tokens used:** `AppShapeExt.medium`, `colorScheme.surface/surfaceContainerHigh/onSurface/onSurfaceVariant`, `textTheme.bodyMedium`, `SpacingTokens.s2/s16`

---

### NowShowingCard
**Status:** stable | **Source:** [now_showing_card.dart](../../lib/features/home/presentation/widgets/now_showing_card.dart)

128×188 poster card for the Now Showing rail. Rating pill top-LEFT (differs from `MovieCard`); title + genre below poster.

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `movie` | `Movie` | Yes | — | Movie entity |
| `onTap` | `VoidCallback?` | No | null | Tap handler |

**States:** default, with/without rating, with/without releaseDate

**Usage:**
```dart
NowShowingCard(movie: m, onTap: () => router.push('/movie/${m.id}'))
```

**Tokens used:** `colorScheme.surfaceContainerHigh/onSurface/onSurfaceVariant`, `textTheme.bodySmall/labelSmall`, `SpacingTokens.s2`

---

### TrendingListRow
**Status:** stable | **Source:** [trending_list_row.dart](../../lib/features/home/presentation/widgets/trending_list_row.dart)

Single row of the Trending list. Layout: gradient rank numeral (via `ShaderMask`) | 80×120 thumb | title + rating + views.

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `movie` | `Movie` | Yes | — | Movie entity (`rank`, `views` consumed) |
| `onTap` | `VoidCallback?` | No | null | Tap handler |

**States:** default, with/without rating, with/without views

**Usage:**
```dart
TrendingListRow(movie: m, onTap: () => router.push('/movie/${m.id}'))
```

**Tokens used:** `AppGradientsExt.accent`, `AppColorsExt.ratingGold`, `colorScheme.surfaceContainerHigh/onSurface/onSurfaceVariant`, `textTheme.displaySmall/bodyMedium/labelSmall`

---

## Rails & Lists

### MovieRail
**Status:** stable | **Source:** [movie_rail.dart](../../lib/features/home/presentation/widgets/movie_rail.dart)

Generic horizontal rail. Same widget serves Now Showing, Coming Soon, Recommended — only the provider differs. Composes `SectionHeader` + (`ShimmerRail` | `ErrorSectionView` | `EmptySectionView` | `ListView` of `MovieCard`).

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `title` | `String` | Yes | — | Section title |
| `asyncMovies` | `AsyncValue<List<Movie>>` | Yes | — | Riverpod async state |
| `onRetry` | `VoidCallback` | Yes | — | Retry handler (typically `ref.invalidate`) |
| `onSeeAll` | `VoidCallback?` | No | null | "See All" handler |

**States:** loading, error, empty, data

**Usage:**
```dart
MovieRail(title: 'Now Showing', asyncMovies: ref.watch(nowShowingProvider),
  onRetry: () => ref.invalidate(nowShowingProvider))
```

**Tokens used:** `SpacingTokens.s2/s3/s4`; downstream from `MovieCard` / state views

---

### TrendingList
**Status:** stable | **Source:** [trending_list.dart](../../lib/features/home/presentation/widgets/trending_list.dart)

Vertical Trending This Week list. Renders a `Column` (not nested `ListView`) so the host `CustomScrollView` owns scrolling.

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `onRetry` | `VoidCallback?` | No | null | Retry override (defaults to `ref.invalidate(trendingProvider)`) |
| `onMovieTap` | `void Function(String movieId)?` | No | null | Row tap callback |

**States:** loading, error, empty, data

**Usage:**
```dart
TrendingList(onMovieTap: (id) => router.push('/movie/$id'))
```

**Tokens used:** `colorScheme.onSurfaceVariant`, `textTheme.titleLarge/bodySmall`, `SpacingTokens.s1/s3/s4`

---

## Section Helpers

### CategoryChip
**Status:** stable | **Source:** [category_chip.dart](../../lib/features/home/presentation/widgets/category_chip.dart)

Single 34 px filter pill. Selected = gradient + white text + shadow; unselected = translucent surface.

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `label` | `String` | Yes | — | Chip label |
| `isSelected` | `bool` | Yes | — | Selection state |
| `onTap` | `VoidCallback` | Yes | — | Tap handler |

**States:** selected, unselected (animates over 200 ms)

**Usage:**
```dart
CategoryChip(label: 'Action', isSelected: sel == 'Action', onTap: () => set('Action'))
```

**Tokens used:** `AppGradientsExt.accent`, `colorScheme.surfaceContainerHighest/inversePrimary/onSurfaceVariant`, `textTheme.labelMedium`

---

### CategoryChipsBar
**Status:** stable | **Source:** [category_chips_bar.dart](../../lib/features/home/presentation/widgets/category_chips_bar.dart)

Horizontal scrollable row of `CategoryChip`s with right-edge fade. Selection held in `selectedCategoryProvider`. Fade uses `IgnorePointer` so touch scrolls pass through.

**Props:** none (consumes provider)

**States:** any one chip selected

**Usage:**
```dart
const CategoryChipsBar()
```

**Tokens used:** `colorScheme.surface` (fade), downstream from `CategoryChip`

---

### RatingBadge
**Status:** stable | **Source:** [rating_badge.dart](../../lib/features/home/presentation/widgets/rating_badge.dart)

Star icon + numeric score pill. Rendered with translucent surface background and gold star/text.

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `rating` | `double` | Yes | — | Score (rendered as 1-decimal) |

**States:** default (only renders when caller passes non-null rating)

**Usage:**
```dart
if (movie.rating != null) RatingBadge(rating: movie.rating!)
```

**Tokens used:** `AppColorsExt.ratingGold`, `colorScheme.surface` (@ 85%), `textTheme.labelSmall`, `SpacingTokens.s1/s3`

---

### SectionHeader
**Status:** stable | **Source:** [section_header.dart](../../lib/features/home/presentation/widgets/section_header.dart)

Section title row + optional trailing "See All" `TextButton`.

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `title` | `String` | Yes | — | Section title |
| `onSeeAll` | `VoidCallback?` | No | null | If non-null, renders See All button |

**States:** with/without See All

**Usage:**
```dart
SectionHeader(title: 'Now Showing', onSeeAll: () => router.push('/now-showing'))
```

**Tokens used:** `textTheme.titleLarge/labelLarge`, `colorScheme.primary`, `SpacingTokens.s4`

---

## Loading / Empty / Error States

### EmptySectionView
**Status:** stable | **Source:** [empty_section_view.dart](../../lib/features/home/presentation/widgets/empty_section_view.dart)

Movie icon + "No movies available" text. Shown when a rail returns empty (UC EF-2).

**Props:** none

**States:** single

**Usage:**
```dart
const EmptySectionView()
```

**Tokens used:** `colorScheme.onSurfaceVariant`, `textTheme.bodyMedium`, `SpacingTokens.s2/s4/s6`

---

### ErrorSectionView
**Status:** stable | **Source:** [error_section_view.dart](../../lib/features/home/presentation/widgets/error_section_view.dart)

Error icon + message + Retry button for a single rail section.

**Props:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `onRetry` | `VoidCallback` | Yes | — | Retry handler (maps to `ref.invalidate`) |
| `message` | `String?` | No | null | Defaults to "Failed to load — pull to refresh" |

**States:** with/without custom message

**Usage:**
```dart
ErrorSectionView(onRetry: () => ref.invalidate(p), message: 'Failed to load X')
```

**Tokens used:** `colorScheme.error/onSurfaceVariant`, `textTheme.bodyMedium`, `SpacingTokens.s2/s4`

---

### ShimmerBanner
**Status:** stable | **Source:** [shimmer_banner.dart](../../lib/features/home/presentation/widgets/shimmer_banner.dart)

Full-width 16:7 shimmer matching the banner carousel aspect ratio. Used as loading + error state for `BannerSection`.

**Props:** none

**Static:** `aspectRatio = 16 / 7`

**States:** continuously animating

**Usage:**
```dart
const ShimmerBanner()
```

**Tokens used:** `colorScheme.surfaceContainerHigh/surfaceContainerHighest`, `SpacingTokens.s4`

---

### ShimmerMovieCard
**Status:** stable | **Source:** [shimmer_movie_card.dart](../../lib/features/home/presentation/widgets/shimmer_movie_card.dart)

Shimmer skeleton sized to match `MovieCard` exactly (`MovieCard.cardWidth`, 2:3 ratio).

**Props:** none

**States:** continuously animating

**Usage:**
```dart
const ShimmerMovieCard()
```

**Tokens used:** `colorScheme.surfaceContainerHigh/surfaceContainerHighest`, `SpacingTokens.s3`

---

### ShimmerRail
**Status:** stable | **Source:** [shimmer_rail.dart](../../lib/features/home/presentation/widgets/shimmer_rail.dart)

Header text shimmer + 3 `ShimmerMovieCard`s in a non-scrollable row. Loading state for `MovieRail` / `TrendingList`.

**Props:** none

**States:** continuously animating

**Usage:**
```dart
const ShimmerRail()
```

**Tokens used:** `colorScheme.surfaceContainerHigh/surfaceContainerHighest`, `SpacingTokens.s1/s3/s4/s6/s20`

---

## Maintenance

- Update via direct edits when widgets ship/change — no auto-discovery script
- Group by category (Navigation, App Bar, Banners, Movie Cards, Rails & Lists, Section Helpers, Loading/Empty/Error)
- Sort alphabetically within group
- Keep each section under ~25 lines; record props from constructor exactly
- When deprecating, set `Status: deprecated` and name the replacement in the description

---

## Token Sources

- **Base tokens:** [tokens.json](./tokens.json)
- **Dark theme:** [themes/dark.json](./themes/dark.json)
- **Light theme:** [themes/light.json](./themes/light.json)
- **Principles:** [design-principles.md](./design-principles.md)

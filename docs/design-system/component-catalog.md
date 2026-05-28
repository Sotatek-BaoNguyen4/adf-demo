# ADF Cinema — Component Catalog

**Platform:** Flutter | **Design System:** Material Design 3 (Material You)
**Theme:** Dark Cinematic | **Updated:** 2026-05-27

> All Flutter widgets use `Theme.of(context).colorScheme` and `Theme.of(context).textTheme` — never hardcode hex colors in widgets.

---

## Status Legend

| Status | Meaning |
|--------|---------|
| `planned` | Defined, not yet built |
| `in-progress` | Currently being implemented |
| `stable` | Built, tested, ready to use |
| `deprecated` | Replaced — do not use |

---

## Navigation

| Component | M3 Equivalent | Description | Status | Path |
|-----------|--------------|-------------|--------|------|
| `CinemaNavBar` | `NavigationBar` | 5-destination M3 nav bar — active pill indicator, frosted glass bg | `planned` | `lib/widgets/navigation/cinema_nav_bar.dart` |
| `CinemaAppBar` | `AppBar` (M3) | M3 top app bar with cinematic title + action icons, tonal elevation on scroll | `planned` | `lib/widgets/navigation/cinema_app_bar.dart` |
| `CinemaSearchBar` | `SearchBar` | M3 search bar, full-width, `shape.full` radius | `planned` | `lib/widgets/navigation/cinema_search_bar.dart` |

---

## Movie Cards

| Component | M3 Equivalent | Description | Status | Path |
|-----------|--------------|-------------|--------|------|
| `MovieCard` | `Card` (Elevated) | 2:3 poster, `shape.medium` (12dp), cinematic gradient overlay, title + rating badge | `planned` | `lib/widgets/movie/movie_card.dart` |
| `MovieCardSkeleton` | — | Shimmer skeleton matching `MovieCard` exact dimensions | `planned` | `lib/widgets/movie/movie_card_skeleton.dart` |
| `FeaturedMovieBanner` | `Card` (Filled) | 16:9 hero banner, `shape.large` (16dp), primary-container bg | `planned` | `lib/widgets/movie/featured_movie_banner.dart` |
| `MovieListTile` | `ListTile` (M3) | Horizontal movie item — thumbnail + title + metadata, for search results | `planned` | `lib/widgets/movie/movie_list_tile.dart` |

---

## Carousel / Lists

| Component | M3 Equivalent | Description | Status | Path |
|-----------|--------------|-------------|--------|------|
| `BannerCarousel` | — | Full-width auto-scroll carousel, 4s interval, M3 dot indicators | `planned` | `lib/widgets/carousel/banner_carousel.dart` |
| `HorizontalMovieList` | — | Horizontal scroll list of `MovieCard` with `SectionHeader` | `planned` | `lib/widgets/carousel/horizontal_movie_list.dart` |
| `CarouselDotIndicator` | — | M3-styled dot indicator — active: 8dp violet pill, inactive: 4dp outline | `planned` | `lib/widgets/carousel/carousel_dot_indicator.dart` |

---

## Badges & Chips

| Component | M3 Equivalent | Description | Status | Path |
|-----------|--------------|-------------|--------|------|
| `GenreChip` | `FilterChip` (M3) | Genre filter chip — `shape.full`, selected uses `secondary-container` | `planned` | `lib/widgets/chips/genre_chip.dart` |
| `StatusBadge` | `Badge` (M3) | "Now Showing" / "Coming Soon" — `shape.full`, themed per status | `planned` | `lib/widgets/chips/status_badge.dart` |
| `RatingBadge` | — | Star icon + score — `#FBBF24` gold, `shape.extra-small`, top-right on card | `planned` | `lib/widgets/chips/rating_badge.dart` |
| `NewReleaseBadge` | `Badge` (M3) | "NEW" label — success green, `shape.full` | `planned` | `lib/widgets/chips/new_release_badge.dart` |

---

## Buttons

| Component | M3 Equivalent | Description | Status | Path |
|-----------|--------------|-------------|--------|------|
| `PrimaryButton` | `FilledButton` (M3) | `shape.full` pill, `primary` bg, `on-primary` text, disabled + loading states | `planned` | `lib/widgets/buttons/primary_button.dart` |
| `SecondaryButton` | `OutlinedButton` (M3) | `shape.full` pill, `outline` border, `primary` text | `planned` | `lib/widgets/buttons/secondary_button.dart` |
| `TonalButton` | `FilledTonalButton` (M3) | `secondary-container` bg — less prominent secondary actions | `planned` | `lib/widgets/buttons/tonal_button.dart` |
| `CinemaFab` | `FloatingActionButton` (M3) | Watch Now FAB — `shape.large`, `primary-container` bg, play icon | `planned` | `lib/widgets/buttons/cinema_fab.dart` |
| `IconActionButton` | `IconButton` (M3) | 48×48dp minimum tap target, `on-surface-variant` color | `planned` | `lib/widgets/buttons/icon_action_button.dart` |

---

## Loading States

| Component | M3 Equivalent | Description | Status | Path |
|-----------|--------------|-------------|--------|------|
| `ShimmerBox` | — | Base shimmer widget — `surface-container-high` base, `surface-container-highest` highlight | `planned` | `lib/widgets/loading/shimmer_box.dart` |
| `BannerSkeleton` | — | Full-width 16:9 banner skeleton | `planned` | `lib/widgets/loading/banner_skeleton.dart` |
| `SectionListSkeleton` | — | Section header + row of 3 `MovieCardSkeleton` | `planned` | `lib/widgets/loading/section_list_skeleton.dart` |
| `CinemaProgressIndicator` | `CircularProgressIndicator` (M3) | `primary` color, used for async operations | `planned` | `lib/widgets/loading/cinema_progress_indicator.dart` |

---

## Feedback & States

| Component | M3 Equivalent | Description | Status | Path |
|-----------|--------------|-------------|--------|------|
| `EmptyStateView` | — | Illustration + `bodyLarge` message + optional CTA | `planned` | `lib/widgets/states/empty_state_view.dart` |
| `ErrorStateView` | — | Error message + `OutlinedButton` retry | `planned` | `lib/widgets/states/error_state_view.dart` |
| `CinemaSnackbar` | `SnackBar` (M3) | M3 snackbar — `inverse-surface` bg, `inverse-on-surface` text, `shape.extra-small` | `planned` | `lib/widgets/states/cinema_snackbar.dart` |
| `CinemaDialog` | `AlertDialog` (M3) | M3 alert dialog — `shape.large`, `surface-container-highest` bg | `planned` | `lib/widgets/states/cinema_dialog.dart` |
| `CinemaBottomSheet` | `ModalBottomSheet` (M3) | `shape.extra-large` top corners, drag handle, `surface-container-low` bg | `planned` | `lib/widgets/states/cinema_bottom_sheet.dart` |

---

## Layout & Structure

| Component | M3 Equivalent | Description | Status | Path |
|-----------|--------------|-------------|--------|------|
| `SectionHeader` | — | Section label (titleLarge, Poppins 600) + optional "See All" `TextButton` | `planned` | `lib/widgets/layout/section_header.dart` |
| `ScreenWrapper` | `Scaffold` (M3) | Root scaffold — correct bg color, safe area, nav bar padding | `planned` | `lib/widgets/layout/screen_wrapper.dart` |
| `CinemaDivider` | `Divider` (M3) | `outline-variant` color, 1dp height | `planned` | `lib/widgets/layout/cinema_divider.dart` |

---

## Typography Widgets

| Component | M3 Equivalent | Description | Status | Path |
|-----------|--------------|-------------|--------|------|
| `DisplayText` | `Text(style: displayMedium)` | Righteous font — splash/marketing hero | `planned` | `lib/widgets/typography/display_text.dart` |
| `HeadlineText` | `Text(style: headlineMedium)` | Poppins 700 — screen headings | `planned` | `lib/widgets/typography/headline_text.dart` |
| `BodyText` | `Text(style: bodyMedium)` | Inter 400 — descriptions and metadata | `planned` | `lib/widgets/typography/body_text.dart` |
| `LabelText` | `Text(style: labelMedium)` | Inter 500 — badges, overlines, status | `planned` | `lib/widgets/typography/label_text.dart` |

---

## Flutter ThemeData Mapping

Map design tokens to Flutter `ThemeData` in `lib/core/theme/`:

```dart
// Color scheme roles → ColorScheme
colorScheme.primary         // color.primary.default
colorScheme.onPrimary       // color.primary.on
colorScheme.primaryContainer    // color.primary.container
colorScheme.onPrimaryContainer  // color.primary.on-container
colorScheme.surface         // color.surface.default
colorScheme.onSurface       // color.on-surface.default
colorScheme.surfaceContainerLow // color.surface.container-low
colorScheme.outline         // color.outline.default
colorScheme.outlineVariant  // color.outline.variant

// Typography → TextTheme (Poppins headings, Inter body)
textTheme.displayLarge      // fontSize.display-large + fontFamily.display
textTheme.headlineMedium    // fontSize.headline-medium + fontFamily.heading
textTheme.bodyMedium        // fontSize.body-medium + fontFamily.body
textTheme.labelMedium       // fontSize.label-medium + fontFamily.body

// Shape → ShapeTheme
cardTheme.shape             // RoundedRectangleBorder(radius: 12) — shape.medium
buttonTheme.shape           // StadiumBorder() — shape.full
```

---

## Token Sources

- **Base tokens:** `docs/design-system/tokens.json`
- **Dark theme (default):** `docs/design-system/themes/dark.json`
- **Light theme:** `docs/design-system/themes/light.json`
- **Principles & guidelines:** `docs/design-system/design-principles.md`

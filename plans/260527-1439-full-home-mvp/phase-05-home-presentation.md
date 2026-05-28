---
phase: 05
title: Home presentation
status: pending
priority: P0
effort: L
depends_on: [02, 04]
---

# Phase 05 — Home presentation

## Context Links
- HLD §4.2, §4.3, §5 (LOC budgets), §7.2 (states)
- FSD §2 Home Screen, §2 States
- Use case: UC-HOME-001
- Component catalog: `docs/design-system/component-catalog.md`
- Mockup: `docs/design-mockups/home-screen/index.html`

## Overview
Build the visible Home screen: banner carousel, 3 movie rails, all loading/empty/error states. Riverpod providers wrap `HomeRepository`. Pull-to-refresh. All styling from theme — zero hex in widgets.

## Key Insights
- 4 independent `AsyncNotifier` providers — parallel `build()` fires 4 repo calls concurrently (LLD §8).
- `BannerCarousel` 5s auto-rotate (BR-001), pauses on manual swipe for 5s then resumes (UC-HOME-001 AF-1).
- `MovieRail` is generic over endpoint — same widget for Now Showing / Coming Soon / Recommended; differs by title + provider.
- Each `AsyncValue.when` handles 3 states: loading (shimmer), data (list or empty), error (retry).
- Components match catalog at `lib/shared/widgets/` (catalog says `lib/widgets/` — defer to HLD `shared/widgets/` for cross-feature; feature-specific stays in `features/home/presentation/widgets/`).

## Requirements
**Functional**
- 4 Riverpod `AsyncNotifier` providers wired to `HomeRepository`.
- `HomeScreen` renders carousel + 3 rails in `CustomScrollView` (allows pull-to-refresh).
- `BannerCarousel`: PageView, auto-advance every 5s, dot indicators, pause-on-touch + resume after 5s idle.
- `MovieRail`: section header + horizontal `ListView.builder` of `MovieCard`.
- `MovieCard`: 2:3 poster (cached_network_image), gradient overlay, title, rating badge.
- Loading: `shimmer` package widgets matching each row layout.
- Empty: per-section "No movies available" placeholder (UC EF-2).
- Error: section-level error view with retry button → `ref.invalidate(provider)`.
- `RefreshIndicator` wraps the scroll view → invalidates all 4 providers in parallel.

**Non-functional**
- Every file <200 LOC.
- 60fps scroll on mid-tier Android (no jank from image decode — `cached_network_image` handles).
- All colors/typography/spacing read from `Theme.of(context)` + `Theme.of(context).extension<AppColorsExt>()`.

## Architecture
```
features/home/presentation/
├── home_screen.dart                  # CustomScrollView: carousel + 3 rails
├── providers/
│   ├── banners_provider.dart         # @riverpod AsyncNotifier<List<Banner>>
│   ├── now_showing_provider.dart
│   ├── coming_soon_provider.dart
│   └── recommended_provider.dart
└── widgets/
    ├── banner_carousel.dart          # PageView w/ auto-rotate
    ├── banner_dot_indicator.dart     # carousel dots
    ├── movie_rail.dart               # section header + horizontal list
    ├── movie_card.dart               # poster + overlay + badge
    ├── section_header.dart           # title + optional "See All"
    ├── rating_badge.dart             # star + score
    ├── shimmer_movie_card.dart       # skeleton matching MovieCard size
    ├── shimmer_banner.dart           # skeleton matching carousel size
    ├── shimmer_rail.dart             # header + 3x shimmer_movie_card
    ├── empty_section_view.dart
    └── error_section_view.dart       # message + retry button
```

## Related Code Files
**Create** all above. Add `home_repository_provider.dart` in `features/home/data/` (Riverpod provider exposing `HomeRepositoryImpl`).

**Modify**
- None outside `features/home/` (theme + core are stable post-phase 02/03/04).

## Implementation Steps
1. **Repository provider** — `final homeRepositoryProvider = Provider<HomeRepository>(...)`. Inject Dio + LocalCache providers.
2. **4 AsyncNotifier providers** — pattern:
   ```dart
   @riverpod
   class NowShowing extends _$NowShowing {
     @override
     Future<List<Movie>> build() => ref.read(homeRepositoryProvider).getNowShowing();
     Future<void> refresh() async { state = const AsyncLoading(); state = await AsyncValue.guard(build); }
   }
   ```
3. **`MovieCard`** — `Card` (Elevated, shape.medium), `AspectRatio(2/3)` poster via `CachedNetworkImage`, `Positioned` gradient overlay, title `bodyMedium`, rating `RatingBadge` top-right.
4. **`MovieRail`** — `SectionHeader` + `SizedBox(height: …)` containing `ListView.separated(scrollDirection: horizontal, ...)`. Empty/error/loading via `AsyncValue.when`.
5. **`BannerCarousel`** — `PageView.builder` + `Timer.periodic(5s)` advancing controller. On manual swipe (`onPageChanged`), cancel timer, restart after 5s. Dispose timer in `dispose()`.
6. **Shimmer skeletons** — `Shimmer.fromColors` wrapping placeholder `Container`s sized to match real widgets.
7. **`HomeScreen`** — `Scaffold(body: RefreshIndicator(onRefresh: ..., child: CustomScrollView(slivers: [SliverToBoxAdapter(BannerCarousel), 3x SliverToBoxAdapter(MovieRail)])))`.
8. **Pull-to-refresh** — in `onRefresh`:
   ```dart
   await Future.wait([
     ref.refresh(bannersProvider.future),
     ref.refresh(nowShowingProvider.future),
     ref.refresh(comingSoonProvider.future),
     ref.refresh(recommendedProvider.future),
   ]);
   ```
9. **Empty/error per-section** — `AsyncValue.when(loading: ShimmerRail, error: ErrorSectionView, data: list.isEmpty ? EmptySectionView : MovieRail)`.
10. Run `dart run build_runner build` (generates `_$NowShowing` etc.). `flutter analyze` clean.

## Todo List
- [ ] homeRepositoryProvider
- [ ] 4 AsyncNotifier providers (riverpod_generator)
- [ ] MovieCard + RatingBadge
- [ ] SectionHeader
- [ ] MovieRail (loading/empty/error states)
- [ ] BannerCarousel (auto-rotate + manual swipe + pause)
- [ ] BannerDotIndicator
- [ ] Shimmer skeletons (banner, movie card, rail)
- [ ] EmptySectionView + ErrorSectionView
- [ ] HomeScreen w/ CustomScrollView + RefreshIndicator
- [ ] No hex literals; all from Theme
- [ ] `flutter analyze` clean
- [ ] Manual smoke: run on simulator, verify all 3 states render

## Success Criteria
- HomeScreen renders carousel + 3 rails (data state)
- Banner auto-advances every 5s; pauses 5s on touch (UC AF-1)
- Pull-to-refresh triggers all 4 providers
- Loading shimmer visible during cold start
- Empty-state widget shown when fixture returns `[]` (test by editing fixture)
- Error widget shown when `?_mock_error=500` injected
- 60fps scroll (use `flutter run --profile`)
- All files <200 LOC

## Risk Assessment
| Risk | Mitigation |
|---|---|
| BannerCarousel timer leaks across rebuilds | `StatefulWidget` + dispose timer in `dispose()`; use `WidgetsBinding.instance.addPostFrameCallback` to start after first frame |
| `cached_network_image` flashes placeholder per scroll | Set `memCacheWidth`/`memCacheHeight` to actual rendered size |
| 4 providers fire simultaneously → main-isolate jitter | Dio + Hive are async I/O on isolate pool; no jank in practice; verified by LLD §8 |
| Theme extension lookup boilerplate | Single `context.appColors` extension method in `app_colors_ext.dart` |

## Security Considerations
- Image URLs from fixtures are HTTPS only.
- No user input on Home → no XSS/injection vectors.

## Next Steps
Unblocks phase 06 (router wraps HomeScreen in shell).

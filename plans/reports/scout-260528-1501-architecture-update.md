# Architecture Scout Report — ADF Cinema MVP (Flutter)

**Date**: 2026-05-28  
**Scope**: Flutter codebase architecture, layering, data flow, infrastructure, gaps  
**Total LOC (excluding generated)**: ~6,607 lines

---

## 1. Module Map

### lib/app/
- **router.dart** (85 LOC) — GoRouter with StatefulShellRoute.indexedStack; 5 branches + redirects for legacy paths.
- **app.dart** (23 LOC) — MaterialApp.router root; dark theme hard-coded (HLD §7.6).
- **shell/**
  - **home_shell.dart** (30 LOC) — Scaffold + CinemaNavBar layout; persistent bottom nav.
  - **placeholder_tab.dart** (24 LOC) — Generic "Coming soon" screen for Explore/Saved/Profile.

### lib/core/
Infrastructure and cross-cutting concerns.

#### **core/network/**
- **dio_client.dart** (57 LOC) — Dio factory; interceptor chain: LogInterceptor → MockInterceptor.
- **network_config.dart** (25 LOC) — NetworkConfig constants (baseUrl, timeouts, useMock dart-define).
- **mock_interceptor.dart** — Fixture-based request interception for offline dev/testing.
- **mock_fixture_loader.dart** — Asset JSON → Map parser.

#### **core/storage/**
- **hive_bootstrap.dart** (50 LOC) — Hive init; opens two boxes: movies_cache, banners_cache.
- **local_cache.dart** (80+ LOC) — Typed wrapper around Hive boxes; read/write for MovieDto & BannerDto envelopes.
- **cache_policy.dart** (36 LOC) — TTL constants (movies: 6h, banners: 1h) + isFresh/isStale helpers.
- **cache_envelope.dart** (31 LOC) — Generic {payload, savedAtEpochMs, schemaVersion} wrapper for SWR.

#### **core/theme/**
- **app_theme.dart** (90 LOC) — ThemeData factory for dark/light modes; Material 3.
- **scheme_source.dart** — ColorScheme + M3 semantic color setup.
- **text_theme_builder.dart** — TextTheme from generated tokens.
- **extensions/**
  - **app_colors_ext.dart** — ThemeExtension with computed nav/accent colors.
  - **app_gradients_ext.dart** — Gradient tokens (dark/light variants).
  - **app_shape_ext.dart** — Border radius constants.
- **generated/** (auto, excluded from report)
  - color_tokens.dart, spacing_tokens.dart, radius_tokens.dart, typography_tokens.dart, motion_tokens.dart
  - Generated from design tokens; no hardcoded colors/values in code.

#### **core/errors/**
- **failure.dart** (85 LOC) — Sealed Failure hierarchy:
  - NetworkFailure (statusCode)
  - TimeoutFailure
  - ParseFailure (path)
  - CacheReadFailure, CacheWriteFailure (boxName)
  - FixtureMissingFailure (assetPath)
  - UnknownFailure
  - Security: redacts cause in release builds.

#### **core/navigation/**
- **tickets_fab_tile.dart** (48 LOC) — Raised 56×56 gradient FAB at nav bar center; navigates to /tickets.

### lib/features/home/
Clean layered architecture per feature.

#### **home/domain/**
- **home_repository.dart** (25 LOC) — Abstract contract: getNowShowing, getComingSoon, getRecommended, getTrending, getBanners.
- **entities/**
  - **movie.dart** (37 LOC) — @freezed Movie entity with optional rating/releaseDate/expectedReleaseDate/matchPercentage/rank/views.
  - **banner.dart** (26 LOC) — @freezed Banner entity with optional genre/rating/badgeKind.

#### **home/data/**
- **home_repository_impl.dart** (189 LOC) — SWR orchestrator.
  - Implements HomeRepository; checks cache freshness → returns fresh or fetches → caches + returns.
  - On error: returns stale cache if available; else throws Failure.
  - Exception → Failure mapping (DioException, FormatException, CheckedFromJsonException).
  - Cache write failures logged but don't block return of fresh data.
- **home_repository_provider.dart** (47 LOC) — Riverpod provider wiring:
  - dioProvider (Dio instance from DioClient.build).
  - localCacheProvider (overridden in main.dart after bootstrapHive).
  - homeRemoteSourceProvider, homeLocalSourceProvider, homeRepositoryProvider.
- **sources/**
  - **home_remote_source.dart** (69 LOC) — Dio-based fetches:
    - GET /api/v1/home/banners → List<BannerDto>
    - GET /api/v1/movies/now-showing → List<MovieDto>
    - GET /api/v1/movies/coming-soon → List<MovieDto>
    - GET /api/v1/movies/recommended → List<MovieDto>
    - Handles Dio response body normalization (pre-decoded List or String → jsonDecode).
  - **home_local_source.dart** (33 LOC) — Thin Hive wrapper; read/write typed envelopes.
- **dto/**
  - **movie_dto.dart** (60 LOC) — @freezed, @HiveType(3); mirrors FSD §4 response fields; .toEntity() mapper.
  - **banner_dto.dart** (58 LOC) — @freezed, @HiveType(4); enum mapper for BadgeKind.
  - **cached_movies_envelope.dart** — CacheEnvelope<List<MovieDto>>; @HiveType(1).
  - **cached_banners_envelope.dart** — CacheEnvelope<List<BannerDto>>; @HiveType(2).

#### **home/presentation/**
- **home_screen.dart** (177 LOC) — ConsumerWidget; Stack with CustomScrollView + floating HomeTopAppBar.
  - Watches 4 async providers: bannersProvider, nowShowingProvider, comingSoonProvider, trendingProvider.
  - Renders 4 sections: Banner → Category Chips → Now Showing Rail → Trending List → Promo → Coming Soon Rail.
  - Pull-to-refresh: concurrent refresh() on all 4 providers.
  - Per-section AsyncValue.when() for loading/error/data.
- **constants/**
  - **movie_categories.dart** — Category enum + display labels.
- **providers/**
  - **banners_provider.dart** (26 LOC) — @riverpod class Banners; Future<List<Banner>> build() reads homeRepositoryProvider.getBanners().
  - **now_showing_provider.dart** (25 LOC) — @riverpod class NowShowing; refresh() method for force-refresh.
  - **coming_soon_provider.dart** (25 LOC) — Analog.
  - **trending_provider.dart** (25 LOC) — Analog; maps to getRecommended() endpoint.
  - **selected_category_provider.dart** — State notifier for category filter (UI-only in MVP).
- **widgets/** (20+ files, ~600 LOC total)
  - **banner_section.dart** — BannerCarousel wrapper.
  - **banner_story_progress.dart** — Auto-rotating progress indicator.
  - **category_chips_bar.dart** — Horizontal scroll filter UI.
  - **now_showing_card.dart** — Card variant with release date + overlay.
  - **coming_soon_card.dart** — Card variant with expectedReleaseDate.
  - **movie_card.dart** — Base poster + rating card.
  - **movie_rail.dart** — Horizontal scroll container.
  - **trending_list.dart** — Vertical grid; reads trendingProvider.
  - **shimmer_*.dart** — Skeleton loaders during AsyncLoading state.
  - **error_section_view.dart** — Retry button on AsyncError.
  - **empty_section_view.dart** — Placeholder when list is empty.
  - **section_header.dart** — "Now Showing" / "Coming Soon" title.
  - **rating_badge.dart** — Star icon + score.
  - **promo_banner.dart** — Ad-like widget between sections.
  - **home_top_app_bar.dart** — Translucent custom AppBar floated over banner.

### lib/features/tickets/
- **presentation/tickets_screen.dart** (18 LOC) — Placeholder screen; "Coming soon" stub satisfies nav shell phase requirement (phase 05).

### lib/shared/
- **widgets/**
  - **cinema_nav_bar.dart** (108 LOC) — 5-destination BottomNavigationBar with raised FAB tile overlay.
    - Slots: Home (0), Explore (1), [FAB] (2), Saved (3), Profile (4).
    - FAB overlay via Stack(clipBehavior: Clip.none); reserves empty SizedBox in nav position.
    - Maps nav index ↔ route index; FAB governs /tickets tap.
- **utils/** — (if present, not detailed in brief).

### lib/main.dart
- **main.dart** (23 LOC) — Entry point:
  1. WidgetsFlutterBinding.ensureInitialized().
  2. bootstrapHive() → boxes (movies, banners).
  3. LocalCache(boxes.movies, boxes.banners).
  4. ProviderScope(overrides: [localCacheProvider.overrideWithValue(…)]).

---

## 2. Architecture Layers — Trace: now_showing_provider

Complete data flow from UI → Provider → Repository → Sources → Cache/Network.

```
┌─────────────────────────────────────────────────────────┐
│ Presentation: HomeScreen (ConsumerWidget)              │
├─────────────────────────────────────────────────────────┤
│ ref.watch(nowShowingProvider) → AsyncValue<List<Movie>> │
│ .when(loading, error, data) renders NowShowingCard rail │
└─────────────────────────────────────────────────────────┘
           ↓ (Riverpod codegen)
┌─────────────────────────────────────────────────────────┐
│ Codegen Provider: now_showing_provider.g.dart          │
├─────────────────────────────────────────────────────────┤
│ @riverpod Future<List<Movie>> build() =>                │
│   ref.read(homeRepositoryProvider).getNowShowing()      │
│                                                         │
│ refresh() → AsyncLoading → guard(getNowShowing(       │
│   forceRefresh: true))                                 │
└─────────────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────────────┐
│ Domain: HomeRepository (abstract)                       │
├─────────────────────────────────────────────────────────┤
│ Future<List<Movie>> getNowShowing({forceRefresh})       │
└─────────────────────────────────────────────────────────┘
           ↓ (interface call)
┌─────────────────────────────────────────────────────────┐
│ Data: HomeRepositoryImpl (SWR orchestrator)             │
├─────────────────────────────────────────────────────────┤
│ 1. _readMovies('/api/v1/movies/now-showing')           │
│    → CachedMoviesEnvelope? (Hive read)                 │
│ 2. If fresh && !forceRefresh → return entities(DtoMaps)│
│ 3. Else: try await _remote.getNowShowing() →           │
│    4. On success: await _tryWriteMovies(key, dtos)     │
│       return dtos.map(toEntity()).toList()             │
│    5. On DioException:                                 │
│       - if cached exists: return cached entities       │
│       - else: throw Failure (mapped exception)         │
└─────────────────────────────────────────────────────────┘
        ↙ (cache read)      ↘ (cache write)
┌──────────────────┐    ┌──────────────────────┐
│ Local Source:    │    │ Remote Source:       │
│ HomeLocalSource  │    │ HomeRemoteSource     │
├──────────────────┤    ├──────────────────────┤
│ _cache.readMovies│    │ _dio.get(             │
│ → Hive movies box│    │  /api/v1/movies/…    │
│                  │    │ ) → response.data     │
│ CacheReadFailure │    │ _decodeMovies()      │
│ on HiveError     │    │ → List<MovieDto>     │
└──────────────────┘    │                      │
                        │ DioException on:     │
                        │ - timeout            │
                        │ - badResponse (4xx/5x)
                        │ - connection error   │
                        │ - other Dio errors   │
                        └──────────────────────┘
                              ↓
                        ┌──────────────────────┐
                        │ Core: Dio Client     │
                        ├──────────────────────┤
                        │ dioProvider:         │
                        │ Dio instance from    │
                        │ DioClient.build()    │
                        │                      │
                        │ Interceptors:        │
                        │ 1. LogInterceptor    │
                        │ 2. MockInterceptor   │
                        │    (fixture loader)  │
                        └──────────────────────┘
                              ↓
                        ┌──────────────────────┐
                        │ Network/Cache/DTO    │
                        ├──────────────────────┤
                        │ Real: HTTP request   │
                        │ Mock: fixture JSON → │
                        │ MovieDto._fromJson() │
                        │ → Codegen JSON type  │
                        │ unwrapping           │
                        └──────────────────────┘
```

**DTO → Entity Mapping:**
```dart
// In movie_dto.dart:
extension MovieDtoMapper on MovieDto {
  Movie toEntity() => Movie(
    id: id, title: title, posterUrl: posterUrl,
    rating: rating, releaseDate: releaseDate, …
  );
}
```

**Cache Envelope Structure:**
```dart
CachedMoviesEnvelope(
  payload: List<MovieDto>,
  savedAtEpochMs: int,
  schemaVersion: 1
)
```

---

## 3. Cross-Cutting Infrastructure

### Error Handling
- **failure.dart** — Single sealed class hierarchy.
- Mapping happens in HomeRepositoryImpl._mapException() only.
- DioException → {NetworkFailure, TimeoutFailure, ParseFailure}.
- FormatException, CheckedFromJsonException → ParseFailure.
- HiveError → {CacheReadFailure, CacheWriteFailure}.
- All failures propagate to UI via AsyncValue.error.

### Network Configuration
- **NetworkConfig** — dart-define controlled (useMock, baseUrl, timeouts).
- **DioClient** — Factory with interceptor chain:
  1. LogInterceptor (dev builds only; no sensitive data).
  2. MockInterceptor (terminal when mock=true).
- **MockInterceptor** — Fixture JSON loaded from assets matching request paths.
- **MockFixtureLoader** — Asset→Map parser; throws FixtureMissingFailure on missing.

### Caching Strategy (SWR — Stale-While-Revalidate)
- **CachePolicy** — TTL constants: moviesTtl=6h, bannersTtl=1h.
- **CacheEnvelope** — Wrapper with {payload, savedAtEpochMs, schemaVersion}.
- **LocalCache** — Hive wrapper for two typed boxes.
- **Schema versioning** — kSchemaVersion=1; mismatch treated as cache miss.
- **Clock skew** — Negative age treated as fresh (acceptable for MVP).

#### SWR Flow in HomeRepositoryImpl:
1. Read cache (absorb CacheReadFailure as miss).
2. If fresh && !forceRefresh → return entities immediately.
3. Fetch remote.
4. On success: try write cache (swallow CacheWriteFailure; fresh data wins).
5. On error: if stale cache → return stale entities (offline UX).
6. Else: throw Failure.

### Theming & Design Tokens
- **Generated tokens** (color_tokens.dart, spacing_tokens.dart, etc.) excluded from report.
- **app_theme.dart** — Builds ThemeData from SchemeSource (dark/light ColorScheme).
- **ThemeExtensions** — Colors, Gradients, Shapes (no hardcoded literals).
- **Material 3** — useMaterial3=true; semantic color scheme.
- **Dark theme hard-coded** — ThemeMode.dark for MVP (HLD §7.6).

---

## 4. Routing & Shell Structure

### StatefulShellRoute with IndexedStack

```
GoRouter (app/router.dart)
├─ initialLocation: /home
├─ redirects: {/search→/explore, /cinemas→/explore, /community→/explore, /bookings→/saved}
└─ StatefulShellRoute.indexedStack(
    builder: HomeShell(navigationShell)
    branches: [
      0 → /home    → HomeScreen
      1 → /explore → PlaceholderTab(Explore)
      2 → /tickets → TicketsScreen
      3 → /saved   → PlaceholderTab(Saved)
      4 → /profile → PlaceholderTab(Profile)
    ]
   )
```

### Shell Layout (HomeShell)

```
Scaffold(
  body: navigationShell ← StatefulNavigationShell (IndexedStack preserves state per branch),
  bottomNavigationBar: CinemaNavBar(
    currentIndex, onTap → goBranch(index)
  )
)
```

### CinemaNavBar Architecture

- **5 destinations** in Material 3 NavigationBar: Home, Explore, [empty slot], Saved, Profile.
- **FAB overlay** — Positioned FAB tile (56×56) above the nav bar at center.
  - Stack(clipBehavior: Clip.none) + bottomNavigationBar slot doesn't clip → FAB paints over body.
  - SizedBox reserved in bar position 2 prevents indicator when FAB tapped.
  - Tapping FAB: context.go('/tickets') → goBranch(2).
- **Colors** — All from AppColorsExt; no hex literals.
- **Gradient** — AppGradientsExt.accent for FAB.

---

## 5. DTO ↔ Entity Mapping Pattern

### Pattern: Extension Mapper
```dart
// In *_dto.dart:
@freezed @HiveType(id) class XyzDto { … }
extension XyzDtoMapper on XyzDto {
  XyzEntity toEntity() => XyzEntity(…);
}
```

### Why This Works
- 1:1 field passthrough when DTO shape == entity shape.
- Complex logic (e.g., BadgeKind enum parse) lives in mapper.
- Centralized; easy to retro-fit if entity grows beyond DTO.
- DTOs also serve as Hive data; envelopes keep them cached.

### Examples
- **MovieDto** → Movie (rating, releaseDate, etc. optional per endpoint).
- **BannerDto** → Banner (badgeKind parsed from String).

---

## 6. Riverpod Provider Wiring

### Codegen Providers (@riverpod)
```dart
@riverpod
class Banners extends _$Banners {
  @override
  Future<List<Banner>> build() =>
    ref.read(homeRepositoryProvider).getBanners();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(homeRepositoryProvider).getBanners(forceRefresh: true),
    );
  }
}
```

- **Generated file** — banners_provider.g.dart (codegen).
- **build()** — Async task fired on cold start; concurrent with other home providers (LLD §8).
- **refresh()** — Force-refresh method; manually set state → AsyncLoading → await guard → set result.
- **Pull-to-refresh** — HomeScreen._refreshAll() calls .future on all 4 providers in parallel.

### Provider Dependencies
```
dioProvider
  ↓
homeRemoteSourceProvider
  ↓
homeRepositoryProvider
  ↗               ↖
 /                 \
localCacheProvider   homeRemoteSourceProvider
  ↓
homeLocalSourceProvider
```

- localCacheProvider **throws UnimplementedError** by default.
- main.dart **overrides** it after bootstrapHive().
- This dependency graph ensures Hive boxes are initialized before HomeRepository accesses them.

---

## 7. Notable Recent Additions & Updates

### Phase 03-05 Increments
1. **Quality Gates Config** (.quality-gates/config.yaml) — New integration.
   - Secrets scan (gitleaks), SAST (semgrep), deps (trivy), coverage (70%), file size (200 LOC max).
   - Excludes all generated files (.g.dart, .freezed.dart, tokens).
   - Enabled gates: secrets, deps, sast, coverage, file-size.

2. **Tickets Feature** (lib/features/tickets/) — Placeholder screen; FAB navigation wired.
   - TicketsFabTile in core/navigation → positioned in CinemaNavBar center.
   - Navigation branch indexed at 2; routes to /tickets.

3. **Navigation Shell (HomeShell)** — Multi-branch StatefulShellRoute with persistent nav bar.
   - Replaces older single-screen paradigm.
   - Indexed stack preserves tab state when switching.

4. **CinemaNavBar** — Center-raised FAB overlay pattern.
   - Solves Material 3 nav bar limitation; no native center FAB slot.
   - Stack + clipBehavior solution is elegant and reusable.

5. **SWR in HomeRepositoryImpl** — Explicit stale-while-revalidate implementation.
   - Not async cached refresh; synchronous fallback to stale on network error.
   - Matches offline-first UX goal.

### Design System Integration
- Generated tokens (color, spacing, radius, typography, motion) wired into AppTheme.
- ThemeExtensions (colors, gradients, shapes) reference tokens; no hardcoded values.
- Supports future dark/light mode toggle (currently dark hard-coded).

---

## 8. Gaps & Discrepancies with Docs

### What's in Code but May Not Be Documented
1. **Provider Concurrency** — LLD §8 states home providers fire concurrently on cold start; code confirms (Riverpod semantics), but confirm docs reflect this clearly.
2. **Pull-to-Refresh Behavior** — HomeScreen._refreshAll() forces all 4 providers via ref.refresh(…future); ensure docs specify forced cache bypass.
3. **SWR Stale-on-Error Semantics** — HomeRepositoryImpl returns stale data when network fails + cache exists; not all error handling docs may highlight this graceful degradation.
4. **MockInterceptor Fixture Matching** — Docs should clarify how request paths map to asset fixture JSON (e.g., /api/v1/movies/now-showing → asset path).
5. **Cache Schema Versioning** — kSchemaVersion=1 with bump protocol exists; ensure migration strategy is documented.
6. **Exception → Failure Mapping** — Centralized in HomeRepositoryImpl._mapException(); verify docs don't suggest mapping can happen elsewhere.
7. **Hive Box Initialization** — main.dart override pattern for localCacheProvider is MVP-specific; document as bootstrapping requirement, not permanent API.

### What Docs Should Reflect
1. **Tickets Feature Placeholder** — TicketsScreen is MVP stub; docs should flag as phase 05 placeholder, not production-ready booking.
2. **FAB Tile Design Pattern** — CinemaNavBar's Stack overlay solution is custom; document as reusable pattern for future raised nav elements.
3. **DTO vs Entity Boundary** — Extension mappers blur DTO/entity line; clarify intent (preserve DTO for cache, map to entity for domain).
4. **Error Handling Security** — Failure.toString() redacts cause in release builds; ensure security docs capture this.

### Potential Inconsistencies
- **Theme Coverage** — Code supports light theme (AppTheme.light()) but hard-codes dark; ensure deployment docs note this.
- **Category Filter UI** — selected_category_provider exists but is UI-only; confirm requirements don't expect filtering to affect API calls.
- **Trending ≈ Recommended** — getTrending() aliases getRecommended() endpoint; document this equivalence so future changes don't duplicate.

---

## 9. File Size & Complexity Snapshot

| File | LOC | Role |
|------|-----|------|
| home_repository_impl.dart | 189 | SWR + exception mapping |
| home_screen.dart | 177 | Main UI + pull-to-refresh |
| app_theme.dart | 90 | Theme factory |
| failure.dart | 85 | Error hierarchy |
| dio_client.dart | 57 | Dio setup + interceptors |
| banner_dto.dart | 58 | DTO + mapper |
| movie_dto.dart | 60 | DTO + mapper |
| local_cache.dart | 80+ | Hive wrapper |
| cinema_nav_bar.dart | 108 | Nav bar + FAB overlay |
| router.dart | 85 | GoRouter config |

- **All files < 200 LOC** ✓ (quality gate: file_max_loc=200).
- **Presentation widgets** mostly 20–50 LOC (modular, single-responsibility).
- **Data layer** concentrated in 3 files (repository_impl, sources, dtos).

---

## Summary

**Architecture Quality**: Clean 3-layer (presentation → domain → data) per feature. Riverpod state management is modern and well-wired. SWR caching is thoughtfully implemented with offline UX as priority. Error handling is typed and secure.

**Infrastructure Maturity**: Network, storage, theming, navigation all in place. Quality gates configured. Design tokens generation integrated. Mock interceptor enables offline dev.

**Notable Patterns**:
- DTO↔Entity extension mappers (elegant, maintainable).
- Provider dependency injection via overrides (Riverpod idiomatic).
- SWR with stale-on-error (user-centric error recovery).
- StatefulShellRoute for persistent nav (modern go_router idiom).
- Stack-based FAB overlay (solves Material 3 design gap).

**Readiness**: MVP-complete. Phase 05 (navigation) complete. Phase 06 (caching) complete. Quality gates active. Ready for phase 07+ (features: search, auth, bookings).


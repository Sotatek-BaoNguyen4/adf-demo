# Codebase Summary — ADF Cinema MVP

**Overview**: Complete walkthrough of `lib/` directory structure, module responsibilities, and dependency graph.  
**Last Updated**: 2026-05-28

---

## 1. Directory Structure

```
lib/
├── main.dart                           # App entry point (12 LOC)
├── hive_registrar.g.dart              # Generated: Hive TypeAdapter registry
├── app/
│   ├── app.dart                       # MaterialApp.router + dark theme (20 LOC)
│   ├── router.dart                    # go_router with StatefulShellRoute (60 LOC)
│   └── shell/
│       ├── home_shell.dart            # Scaffold + CinemaNavBar layout (25 LOC)
│       └── placeholder_tab.dart       # Explore/Saved/Profile stubs (15 LOC)
├── core/
│   ├── errors/
│   │   └── failure.dart               # Sealed Failure hierarchy (70 LOC)
│   ├── navigation/
│   │   └── tickets_fab_tile.dart      # Raised center FAB widget (45 LOC)
│   ├── network/
│   │   ├── dio_client.dart            # Dio factory + interceptor wiring (35 LOC)
│   │   ├── mock_interceptor.dart      # Fixture-based request interception (55 LOC)
│   │   ├── mock_fixture_loader.dart   # Asset JSON → Map parser (40 LOC)
│   │   └── network_config.dart        # Base URL, timeouts, mock flag (25 LOC)
│   ├── storage/
│   │   ├── hive_bootstrap.dart        # Hive init + box registration (50 LOC)
│   │   ├── cache_envelope.dart        # {payload, savedAt, schemaVersion} (35 LOC)
│   │   ├── cache_policy.dart          # TTL + isFresh() logic (40 LOC)
│   │   └── local_cache.dart           # Typed read/write wrapper (60 LOC)
│   └── theme/
│       ├── app_theme.dart             # AppTheme.light() / .dark() factory (45 LOC)
│       ├── scheme_source.dart         # ColorScheme + M3 source setup (30 LOC)
│       ├── text_theme_builder.dart    # TextTheme from tokens (40 LOC)
│       ├── extensions/
│       │   ├── app_colors_ext.dart    # ThemeExtension: colors (35 LOC)
│       │   ├── app_gradients_ext.dart # ThemeExtension: gradients (30 LOC)
│       │   └── app_shape_ext.dart     # ThemeExtension: border radius (30 LOC)
│       └── generated/
│           ├── color_tokens.dart      # Generated from tokens.json (100+ LOC, auto)
│           ├── spacing_tokens.dart    # Generated from tokens.json (80+ LOC, auto)
│           ├── radius_tokens.dart     # Generated from tokens.json (60+ LOC, auto)
│           ├── typography_tokens.dart # Generated from tokens.json (50+ LOC, auto)
│           └── motion_tokens.dart     # Generated from tokens.json (40+ LOC, auto)
├── features/
│   ├── home/
│   │   ├── data/
│   │   │   ├── home_repository_impl.dart    # HomeRepository impl (55 LOC)
│   │   │   ├── home_repository_provider.dart # Riverpod provider factory (20 LOC)
│   │   │   ├── sources/
│   │   │   │   ├── home_remote_source.dart  # Dio-based remote fetch (40 LOC)
│   │   │   │   └── home_local_source.dart   # Hive-based local cache (45 LOC)
│   │   │   └── dto/
│   │   │       ├── banner_dto.dart          # @freezed + JSON (30 LOC)
│   │   │       ├── movie_dto.dart           # @freezed + JSON (35 LOC)
│   │   │       ├── cached_banners_envelope.dart # @freezed (20 LOC)
│   │   │       └── cached_movies_envelope.dart  # @freezed (20 LOC)
│   │   ├── domain/
│   │   │   ├── home_repository.dart         # Abstract repository (25 LOC)
│   │   │   └── entities/
│   │   │       ├── banner.dart              # @freezed entity (20 LOC)
│   │   │       └── movie.dart               # @freezed entity (30 LOC)
│   │   └── presentation/
│   │       ├── home_screen.dart             # Main screen (70 LOC)
│   │       ├── constants/
│   │       │   └── movie_categories.dart    # Category enum + display (15 LOC)
│   │       ├── providers/
│   │       │   ├── banners_provider.dart     # @riverpod async (30 LOC)
│   │       │   ├── now_showing_provider.dart # @riverpod async (30 LOC)
│   │       │   ├── coming_soon_provider.dart # @riverpod async (30 LOC)
│   │       │   ├── trending_provider.dart    # @riverpod async (30 LOC)
│   │       │   └── selected_category_provider.dart # @riverpod (10 LOC)
│   │       └── widgets/
│   │           ├── banner_section.dart           # Container (30 LOC)
│   │           ├── banner_carousel.dart          # PageView (45 LOC)
│   │           ├── banner_carousel_overlay.dart  # Gradient + text (35 LOC)
│   │           ├── story_progress_indicator.dart # Animated progress (40 LOC)
│   │           ├── category_chips_bar.dart       # Horizontal scroll (35 LOC)
│   │           ├── category_chip.dart            # Single chip (25 LOC)
│   │           ├── promo_banner.dart             # Ad-like widget (30 LOC)
│   │           ├── home_top_app_bar.dart         # Custom AppBar (30 LOC)
│   │           ├── movie_card.dart               # Base card (40 LOC)
│   │           ├── now_showing_card.dart         # Variant with overlay (35 LOC)
│   │           ├── coming_soon_card.dart         # Release date variant (35 LOC)
│   │           ├── movie_rail.dart               # Container + overflow (30 LOC)
│   │           ├── movie_rail_item.dart          # Poster + rating (25 LOC)
│   │           ├── trending_list.dart            # Grid container (25 LOC)
│   │           ├── trending_list_row.dart        # Row layout (20 LOC)
│   │           ├── trending_item.dart            # Card variant (30 LOC)
│   │           ├── section_header.dart           # Title + see-all (20 LOC)
│   │           ├── rating_badge.dart             # Star + score (20 LOC)
│   │           ├── empty_view.dart               # Placeholder (20 LOC)
│   │           ├── error_view.dart               # Error + retry (25 LOC)
│   │           └── movie_shimmer_loader.dart     # Shimmer skeleton (40 LOC)
│   └── tickets/
│       └── presentation/
│           └── tickets_screen.dart          # Placeholder (10 LOC)
└── shared/
    └── widgets/
        └── cinema_nav_bar.dart               # Bottom nav (5 tabs + FAB) (90 LOC)
```

---

## 2. Module Responsibilities

### `main.dart` — App Bootstrap
- Initializes Hive boxes via `bootstrapHive()`
- Wraps app in `ProviderScope` (Riverpod)
- Runs `AdfCinemaApp()`

### `app/` — Routing & Shell
| File | Responsibility |
|---|---|
| `app.dart` | MaterialApp.router config; applies dark theme globally |
| `router.dart` | go_router definition; StatefulShellRoute with 5 branches (Home/Explore/Tickets/Saved/Profile) |
| `shell/home_shell.dart` | Scaffold wrapping each branch; adds persistent CinemaNavBar |
| `shell/placeholder_tab.dart` | Generic placeholder screen (Explore, Saved, Profile reuse this) |

**Dependency**: Consumes `AppTheme.dark()` from `core/theme/`.

### `core/errors/` — Error Handling
| File | Responsibility |
|---|---|
| `failure.dart` | Sealed Failure hierarchy: `NetworkFailure`, `TimeoutFailure`, `ParseFailure`, `CacheReadFailure`, `CacheWriteFailure`, `FixtureMissingFailure`, `UnknownFailure` |

**Used by**: Network sources, local sources, and repository impl. Mapped at layer boundaries before throwing.

### `core/network/` — HTTP Client & Mocking
| File | Responsibility |
|---|---|
| `network_config.dart` | Constants: base URL, timeouts, mock flag (dart-define toggled) |
| `dio_client.dart` | Dio instance factory; wires MockInterceptor based on config |
| `mock_interceptor.dart` | Intercepts `/api/v1/*` → matches fixture path → returns mocked response + latency simulation |
| `mock_fixture_loader.dart` | Reads asset JSON (e.g., `assets/fixtures/banners.json`) and parses to Map |

**Dependency**: Uses `mock_fixture_loader` to load fixture JSONs.  
**Consumed by**: `home_remote_source.dart` via injected `DioClient`.

### `core/storage/` — Local Cache & Persistence
| File | Responsibility |
|---|---|
| `hive_bootstrap.dart` | Initializes Hive; registers TypeAdapters for DTOs; opens boxes (`banners`, `movies`) |
| `cache_envelope.dart` | @freezed class: `{payload, savedAt, schemaVersion}` — wraps cached data with metadata |
| `cache_policy.dart` | TTL logic: `isFresh(savedAt, ttlMinutes)` → bool; used in SWR decision |
| `local_cache.dart` | Typed read/write: `get<T>(key)`, `set<T>(key, value)` — wraps Hive box ops with error mapping |

**Dependency**: Requires Hive TypeAdapters (registered in bootstrap).  
**Consumed by**: `home_local_source.dart` via injected `LocalCache`.

### `core/theme/` — Design Tokens & Theming
| File | Responsibility |
|---|---|
| `app_theme.dart` | Factory: `AppTheme.dark()` → ThemeData with M3 + extensions |
| `scheme_source.dart` | ColorScheme setup; M3 dynamic color source (hardcoded for MVP) |
| `text_theme_builder.dart` | TextTheme from generated typography tokens |
| `extensions/*.dart` | ThemeExtension subclasses (colors, gradients, shapes) — mounted in `AppTheme` |
| `generated/*.dart` | Codegen output from `tool/gen_theme.dart` — reads `docs/design-system/tokens.json` + themes |

**Dependency**: Reads design system tokens at codegen time.  
**Consumed by**: `app.dart` + all widgets via `Theme.of(context)` + `context.appColors()`, etc.

### `features/home/data/` — Data Layer
| File | Responsibility |
|---|---|
| `home_repository_impl.dart` | Implements `HomeRepository`; orchestrates `HomeRemoteSource` + `HomeLocalSource`; implements SWR logic + error mapping |
| `home_repository_provider.dart` | Riverpod provider factory for `HomeRepository` |
| `sources/home_remote_source.dart` | Dio calls to `/api/v1/home/banners`, `/api/v1/movies/*`; throws `NetworkFailure` on error |
| `sources/home_local_source.dart` | Hive reads/writes via `LocalCache`; TTL checking; throws `CacheReadFailure`/`CacheWriteFailure` |
| `dto/banner_dto.dart` | @freezed; JSON serializable; mapper to `Banner` entity |
| `dto/movie_dto.dart` | @freezed; JSON serializable; mapper to `Movie` entity |
| `dto/cached_*_envelope.dart` | @freezed wrappers around `CacheEnvelope<T>` for Hive storage |

**Dependency**: Consumes `DioClient`, `LocalCache`, `Failure`.  
**Consumed by**: `home_repository_provider.dart` (exposes to presentation).

### `features/home/domain/` — Domain Layer
| File | Responsibility |
|---|---|
| `home_repository.dart` | Abstract interface: `Future<List<Banner>> getBanners()`, etc. — no impl details |
| `entities/banner.dart` | @freezed entity; business model independent of DTO |
| `entities/movie.dart` | @freezed entity; business model independent of DTO |

**Dependency**: None (pure domain).  
**Consumed by**: Presentation providers (via `HomeRepository`).

### `features/home/presentation/` — Presentation Layer
| File | Responsibility |
|---|---|
| `home_screen.dart` | Main screen; builds layout tree; orchestrates Riverpod providers; handles SliverAppBar + scroll |
| `constants/movie_categories.dart` | Category enum (`nowShowing`, `comingSoon`, `trending`); display strings |
| `providers/*.dart` | @riverpod providers: `bannersProvider`, `moviesProvider`, `selectedCategoryProvider` (state + filtering) |
| `widgets/*.dart` | 20+ focused widgets: banners, cards, rails, category chips, loading/error states, etc. |

**Dependency**: Consumes `HomeRepository`, design tokens.  
**Consumed by**: `home_screen.dart`.

### `features/tickets/presentation/` — Placeholder
| File | Responsibility |
|---|---|
| `tickets_screen.dart` | Stub screen; will be wired post-MVP |

### `shared/widgets/` — Reusable Widgets
| File | Responsibility |
|---|---|
| `cinema_nav_bar.dart` | Bottom navigation bar (5 tabs + raised center FAB for Tickets); stateless |

**Dependency**: Consumes design tokens, router context.  
**Consumed by**: `home_shell.dart`.

---

## 3. Dependency Graph

```
Presentation Layer
    ├─ home_screen.dart
    ├── providers/*.dart (banners, movies, category)
    └── widgets/*.dart (20+ components)
           ↓
Domain Layer
    ├─ home_repository.dart (abstract)
    └─ entities/{banner, movie}.dart
           ↓
Data Layer
    ├─ home_repository_impl.dart (orchestrates sources)
    ├─ sources/
    │  ├─ home_remote_source.dart (→ core/network)
    │  └─ home_local_source.dart (→ core/storage)
    └─ dto/*.dart (mappers)
           ↓
Core (Shared Infrastructure)
    ├─ core/errors/failure.dart ←─────┐
    ├─ core/network/                  ├─ Used by data+presentation
    │  ├─ dio_client.dart             │
    │  ├─ mock_interceptor.dart       │
    │  ├─ mock_fixture_loader.dart    │
    │  └─ network_config.dart         │
    ├─ core/storage/                  │
    │  ├─ hive_bootstrap.dart         │
    │  ├─ cache_envelope.dart         │
    │  ├─ cache_policy.dart           │
    │  └─ local_cache.dart            │
    ├─ core/theme/ ←────────────────────── Used by all widgets
    │  ├─ app_theme.dart
    │  ├─ extensions/*.dart
    │  └─ generated/*.dart
    ├─ core/navigation/
    │  └─ tickets_fab_tile.dart
    └─ shared/widgets/
       └─ cinema_nav_bar.dart
```

**Flow**: Presentation → Domain ← Data → Core.

---

## 4. State Management (Riverpod)

### Providers Structure

```dart
// Async providers — fetch data from repository
@riverpod
Future<List<Banner>> banners(BannersRef ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getBanners();
}

// Async providers — filtered lists
@riverpod
Future<List<Movie>> nowShowingMovies(NowShowingMoviesRef ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getMoviesNowShowing();
}

// State notifier provider — selection state
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  MovieCategory build() => MovieCategory.nowShowing;

  void select(MovieCategory category) => state = category;
}
```

### Lifecycle
- **build()** → runs once, subscribes to dependencies
- **.watch()** → reads another provider; rebuilds on change
- **.invalidate()** → force refresh (used by pull-to-refresh)
- **Disposal** → automatic when no listeners

**Error Handling**: Exceptions caught as `AsyncValue.error` in UI `.when()` blocks.

---

## 5. Generated Code

### Code Generation Commands

```bash
# Freezed (DTOs, entities, value equality)
dart run build_runner build --delete-conflicting-outputs

# Riverpod (providers with codegen)
# (runs as part of build_runner above)

# Hive (TypeAdapters for cached objects)
# (runs as part of build_runner above)

# Theme tokens (design system → Dart)
dart tool/gen_theme.dart
```

### Generated Outputs
- `*.freezed.dart` — Freezed value classes, equality, copyWith
- `*.g.dart` — Riverpod providers, Hive adapters, JSON serialization
- `lib/core/theme/generated/*.dart` — Token constants from design system

---

## 6. Testing Structure

```
test/
├── _helpers/
│   └── widget_test_harness.dart       # ProviderScope + MaterialApp wrapper
├── core/
│   └── navigation/
│       └── tickets_fab_tile_test.dart  # Tests FAB visibility + layout
├── features/
│   └── home/
│       ├── widgets/
│       │   ├── banner_carousel_test.dart
│       │   ├── banner_carousel_overlay_test.dart
│       │   ├── story_progress_indicator_test.dart
│       │   ├── category_chips_bar_test.dart
│       │   ├── coming_soon_card_test.dart
│       │   ├── home_top_app_bar_test.dart
│       │   ├── now_showing_card_test.dart
│       │   ├── promo_banner_test.dart
│       │   ├── trending_list_test.dart
│       │   └── trending_list_row_test.dart
│       └── (unit tests)
│           ├── home_remote_source_test.dart
│           └── home_repository_impl_test.dart
```

**Testing Strategy**:
- Widget tests use `WidgetTestHarness` (wraps with Riverpod + theme)
- Unit tests mock sources with `mocktail`
- Coverage target: >80% for home feature

---

## 7. Asset Organization

```
assets/
├── fixtures/
│   ├── banners.json       # [{id, imageUrl, title, targetUrl}, ...]
│   ├── now-showing.json   # [{id, title, posterUrl, rating, ...}, ...]
│   ├── coming-soon.json   # [{id, title, posterUrl, releaseDate, ...}, ...]
│   └── recommended.json   # [{id, title, posterUrl, rating, matchPercentage, ...}, ...]
└── fonts/
    ├── Poppins-*.ttf      # (pending drop-in, pubspec block commented)
    ├── Inter-*.ttf
    └── Righteous-*.ttf
```

**Fixture Format**: JSON objects matching DTOs in `features/home/data/dto/`.

---

## 8. Configuration & Constants

| File | Key Constants |
|---|---|
| `lib/core/network/network_config.dart` | `baseUrl`, `connectTimeout`, `receiveTimeout`, `USE_MOCK` |
| `lib/features/home/presentation/constants/movie_categories.dart` | `MovieCategory` enum + display labels |
| `docs/design-system/tokens.json` | All design tokens (colors, spacing, typography, motion) |

**Toggling Mock**: `fvm flutter run --dart-define=USE_MOCK=false` (defaults to true).

---

## 9. Key Architectural Patterns

### Stale-While-Revalidate (SWR)
```
1. Check local cache TTL
2a. If fresh → return immediately
2b. If stale → return + fetch in background
3. On network success → update cache, notify listeners
4. On error → use stale data, show snackbar
```

### Clean Architecture (Feature-Sliced)
```
Per feature:
  data/          (DTOs, sources, repository impl)
  domain/        (entities, repository interface)
  presentation/  (screen, providers, widgets)
Core shared:     (network, storage, errors, theme)
```

### Riverpod Codegen Providers
```
@riverpod async provider → compile-safe, no context, tested via ref
.watch() dependency graph → automatic rebuild on dependency change
.invalidate() → manual refresh trigger
```

### Token-Driven Theming
```
design-system/tokens.json
    ↓ (codegen: tool/gen_theme.dart)
lib/core/theme/generated/*_tokens.dart
    ↓ (used by)
app_theme.dart + extensions/*
    ↓ (applied)
Theme.of(context) + ThemeExtensions in all widgets
```

---

## 10. File Size Distribution

**All files ≤200 LOC** (enforced in code review).

| Category | Count | Avg LOC |
|---|---|---|
| Screens | 1 | 70 |
| Providers | 5 | 25 |
| Widgets | 20+ | 30 |
| Data Sources | 2 | 42 |
| Data Models (DTO/Entity) | 6 | 25 |
| Core Infrastructure | 11 | 40 |
| Shell/Routing | 3 | 35 |

**Total**: ~850 LOC (excluding generated + auto).

---

## 11. Quick Reference

### Import Paths
```dart
// Local models
import 'package:adf_demo/features/home/domain/entities/movie.dart';

// State management
import 'package:adf_demo/features/home/presentation/providers/banners_provider.dart';

// Core utilities
import 'package:adf_demo/core/errors/failure.dart';
import 'package:adf_demo/core/theme/app_theme.dart';

// Shared widgets
import 'package:adf_demo/shared/widgets/cinema_nav_bar.dart';
```

### Common Patterns
```dart
// Watch async provider
final AsyncValue<List<Movie>> movies = ref.watch(moviesProvider);

// Handle loading/error/data
movies.when(
  loading: () => SizedBox.expand(child: MovieShimmerLoader()),
  error: (err, st) => ErrorView(onRetry: () => ref.invalidate(moviesProvider)),
  data: (data) => MovieRail(movies: data),
);

// Update theme token
Theme.of(context).extension<AppColorsExt>()?.onPrimary
```

---

**End of Codebase Summary**

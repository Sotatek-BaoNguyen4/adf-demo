# Code Standards — ADF Cinema MVP

**Objective**: Establish consistent, maintainable code practices across the project.  
**Last Updated**: 2026-05-28

---

## 1. File Naming Conventions

### Dart Files
- **Format**: `kebab-case` with descriptive, self-documenting names
- **Goal**: LLM tools (Grep, Glob) can infer file purpose from name alone

| Category | Pattern | Example |
|---|---|---|
| **Screens** | `{feature}_screen.dart` | `home_screen.dart` |
| **Widgets** | `{widget_name}_widget.dart` or `{component_name}.dart` | `banner_carousel.dart`, `movie_card.dart` |
| **Providers** | `{state_name}_provider.dart` | `banners_provider.dart`, `selected_category_provider.dart` |
| **Models (Entity)** | `{entity_name}.dart` | `movie.dart`, `banner.dart` |
| **Data Transfer Objects** | `{model_name}_dto.dart` | `movie_dto.dart`, `banner_dto.dart` |
| **Repositories** | `{feature}_repository.dart` or `{feature}_repository_impl.dart` | `home_repository.dart`, `home_repository_impl.dart` |
| **Sources** | `{feature}_{source_type}_source.dart` | `home_remote_source.dart`, `home_local_source.dart` |
| **Services/Utilities** | `{service_name}.dart` | `dio_client.dart`, `hive_bootstrap.dart` |
| **Enums/Constants** | `{concept}_constants.dart` or `{enum_name}.dart` | `movie_categories.dart`, `failure.dart` |
| **Extensions** | `{type_name}_ext.dart` | `app_colors_ext.dart` |
| **Tests** | `{module}_test.dart` | `home_repository_impl_test.dart` |

### Directory Structure
- **Lowercase** with hyphens for multi-word dirs
- **Singular** feature names (not "features/homes/")
- **Functional grouping**: `data/`, `domain/`, `presentation/` per feature

```
lib/
├── features/home/          # singular
│   ├── data/               # DTO, sources, impl
│   ├── domain/             # entities, interfaces
│   └── presentation/       # screen, providers, widgets
├── core/                   # shared infrastructure
└── shared/                 # reusable widgets, helpers
```

---

## 2. File Size Management

### The <200 LOC Rule

**Rationale**: Optimal context window for code review, prevents cognitive overload, enforces modularity.

#### Enforcement
- **Code Review Gate**: Block merge if any new/modified Dart file exceeds 200 LOC
- **Tooling**: `wc -l` check pre-commit (optional, advisory)
- **Modularization**: Prefer splitting over increasing limit

#### Exceptions (Document if needed)
- Generated files (`*.freezed.dart`, `*.g.dart`) — excluded
- `lib/core/theme/generated/*_tokens.dart` — auto-generated, excluded
- Test fixtures/mocks — if unavoidable, comment with `// Line count: NNN (approved exception)`

#### When File Approaches Limit
```
Current: ~180 LOC + new feature = ~230 LOC
Action: Stop, split into focused files
  ├─ feature_v1.dart (single responsibility, ~100 LOC)
  ├─ feature_v2.dart (related concern, ~100 LOC)
  └─ _feature_shared.dart (common helpers, ~50 LOC, private module)
```

### Modularization Strategy

**By Responsibility**:
```dart
// ❌ Anti-pattern: widget_that_does_everything.dart (250 LOC)
class MovieCard extends StatelessWidget {
  // ... title, poster, rating, overlays, animations, error handling, ...
}

// ✅ Pattern: split by concern
├─ movie_card.dart (40 LOC — base layout)
├─ movie_card_overlay.dart (35 LOC — overlay/badge)
├─ movie_card_loading.dart (25 LOC — shimmer)
└─ movie_card_error.dart (20 LOC — error state)
```

**By Layer**:
```dart
// ❌ Anti-pattern: home_repository.dart (300 LOC)
// — Mixes interface, impl, sources

// ✅ Pattern: separation by layer
├─ domain/home_repository.dart (25 LOC — abstract)
├─ data/home_repository_impl.dart (60 LOC — impl)
├─ data/sources/home_remote_source.dart (45 LOC)
└─ data/sources/home_local_source.dart (45 LOC)
```

---

## 3. Layering & Architecture Rules

### Clean Architecture (Feature-Sliced)

```
Per Feature:
  ┌─ presentation/   (UI + state bindings)
  ├─ domain/         (business logic + interfaces)
  └─ data/           (concrete impl + sources)

Core (Shared):
  └─ {errors, network, storage, theme, navigation}
```

### Data Layer Rules

**Location & Structure**:
```
features/home/data/
├── dto/                          # Data Transfer Objects
│   ├── movie_dto.dart           # @freezed, JSON serializable
│   ├── banner_dto.dart          # includes mapper: toEntity()
│   └── cached_*_envelope.dart   # @freezed wrapper
├── sources/                      # Data sources
│   ├── home_remote_source.dart  # API calls (Dio)
│   └── home_local_source.dart   # Cache (Hive)
├── home_repository_impl.dart    # Repository implementation
└── home_repository_provider.dart # Riverpod provider factory
```

**DTO Rules**:
1. **@freezed + JSON**: Every DTO must be freezed with toJson/fromJson
   ```dart
   @freezed
   class MovieDto with _$MovieDto {
     factory MovieDto({
       required String id,
       required String title,
       required String posterUrl,
       @Default(0) double rating,
     }) = _MovieDto;

     factory MovieDto.fromJson(Map<String, dynamic> json) =>
         _$MovieDtoFromJson(json);

     // Mapper to entity
     Movie toEntity() => Movie(
       id: id,
       title: title,
       posterUrl: posterUrl,
       rating: rating,
     );
   }
   ```

2. **Mapper Location**: In DTO file, not separate mapper file
3. **Naming**: `Dto` suffix distinguishes from entities
4. **Cache Envelopes**: Wrap `CacheEnvelope<T>` for Hive storage
   ```dart
   @freezed
   class CachedMoviesEnvelope with _$CachedMoviesEnvelope {
     factory CachedMoviesEnvelope({
       required List<MovieDto> payload,
       required DateTime savedAt,
       @Default(1) int schemaVersion,
     }) = _CachedMoviesEnvelope;
   }
   ```

### Domain Layer Rules

**Location**:
```
features/home/domain/
├── home_repository.dart    # Abstract interface (no impl)
└── entities/
    ├── movie.dart          # @freezed entity
    └── banner.dart         # @freezed entity
```

**Repository Interface**:
```dart
// Abstract — no concrete logic
abstract class HomeRepository {
  Future<List<Banner>> getBanners();
  Future<List<Movie>> getMoviesNowShowing();
  Future<List<Movie>> getMoviesComingSoon();
  Future<List<Movie>> getRecommendedMovies();
}
```

**Entity Rules**:
1. **@freezed**: Value equality + copyWith
2. **No dependencies on DTOs or frameworks**
3. **Pure business model**: id, title, posterUrl, rating
4. **Separate from DTO**: Mapper in DTO file handles conversion

### Presentation Layer Rules

**Location**:
```
features/home/presentation/
├── home_screen.dart        # Main screen
├── providers/              # Riverpod providers
│   ├── banners_provider.dart
│   └── selected_category_provider.dart
├── widgets/                # Focused components
│   ├── banner_carousel.dart
│   └── movie_card.dart
└── constants/              # Enums, display strings
    └── movie_categories.dart
```

**Screen Structure**:
```dart
// ✅ home_screen.dart — 70 LOC max
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(bannersProvider);
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(...),  // Extracted to widget
        SliverToBoxAdapter(
          child: BannerSection(bannersAsync: bannersAsync),
        ),
        // More sections...
      ],
    );
  }
}
```

**Provider Structure**:
```dart
// ✅ @riverpod async provider
@riverpod
Future<List<Banner>> banners(BannersRef ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  try {
    return await repo.getBanners();
  } on Failure catch (e) {
    // Riverpod automatically wraps in AsyncValue.error
    rethrow;
  }
}

// ✅ @riverpod state provider
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  MovieCategory build() => MovieCategory.nowShowing;

  void select(MovieCategory category) => state = category;
}
```

**Widget Rules**:
1. **Stateless preferred**: Use ConsumerWidget, not StatefulWidget
2. **Single responsibility**: One visual concern per widget
3. **Extract early**: If nearing 200 LOC, split before merging
4. **Props via constructor**: No global state access (except via ref.watch)

```dart
// ✅ Focused widget
class MovieCard extends ConsumerWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorsExt>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(...),
    );
  }
}
```

---

## 4. Theming & Design Tokens

### No Hardcoded Colors/Sizes

**Rule**: All design values come from `Theme.of(context)` or `ThemeExtensions`.

#### ✅ Correct Patterns

```dart
// Color from theme
Color bg = Theme.of(context).colorScheme.surface;
Color primary = Theme.of(context).colorScheme.primary;

// ThemeExtension for custom tokens
Color accent = Theme.of(context).extension<AppColorsExt>()!.accentDark;
double spacing = Theme.of(context).extension<AppSpacingExt>()!.md;
double radius = Theme.of(context).extension<AppShapeExt>()!.radiusLg;

// Typography from tokens
TextStyle heading = Theme.of(context).extension<AppTypographyExt>()!.headingLarge;
```

#### ❌ Anti-patterns

```dart
// Hardcoded hex
Color bg = Color(0xFF1A1A1A);  // WRONG

// Magic numbers
padding: EdgeInsets.all(16),  // WRONG — should use token

// Inline theme values
RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))  // WRONG — use token
```

### Token-Driven Pipeline

```
docs/design-system/tokens.json
    ↓ (Codegen: dart tool/gen_theme.dart)
lib/core/theme/generated/{color,spacing,radius,typography,motion}_tokens.dart
    ↓ (Imported by)
lib/core/theme/{app_colors_ext,app_shape_ext, ...}.dart
    ↓ (Mounted in)
lib/core/theme/app_theme.dart → ThemeData(extensions: [...])
    ↓ (Used in)
All widgets: Theme.of(context).extension<AppColorsExt>()!.colorName
```

### Codegen Command

```bash
# Run when tokens.json or themes/*.json change
dart tool/gen_theme.dart

# Verify no breaking changes
flutter analyze
```

---

## 5. Error Handling

### Failure Taxonomy

**Sealed class hierarchy** — used across network + storage layers.

```dart
sealed class Failure implements Exception {
  final String message;
  final Object? cause;
  const Failure(this.message, [this.cause]);

  @override
  String toString() {
    final buf = StringBuffer('$runtimeType: $message');
    if (!kReleaseMode && cause != null) buf.write('\nCause: $cause');
    return buf.toString();
  }
}

// Network errors
final class NetworkFailure extends Failure {
  final int? statusCode;
  NetworkFailure(String message, [this.statusCode, Object? cause])
    : super(message, cause);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([Object? cause]) : super('Request timeout', cause);
}

// Parsing errors
final class ParseFailure extends Failure {
  final String? path;
  ParseFailure(String message, [this.path, Object? cause])
    : super(message, cause);
}

// Cache errors
final class CacheReadFailure extends Failure {
  final String boxName;
  CacheReadFailure(this.boxName, [Object? cause])
    : super('Cache read failed: $boxName', cause);
}

final class CacheWriteFailure extends Failure {
  final String boxName;
  CacheWriteFailure(this.boxName, [Object? cause])
    : super('Cache write failed: $boxName', cause);
}

// Fixture errors
final class FixtureMissingFailure extends Failure {
  final String assetPath;
  FixtureMissingFailure(this.assetPath, [Object? cause])
    : super('Fixture not found: $assetPath', cause);
}

// Catch-all
final class UnknownFailure extends Failure {
  const UnknownFailure(String message, [Object? cause]) : super(message, cause);
}
```

### Mapping Rules

| Exception Source | Failure Subclass | Example |
|---|---|---|
| `DioException.connectionTimeout` | `TimeoutFailure` | Dio can't connect within `connectTimeout` |
| `DioException.receiveTimeout` | `TimeoutFailure` | Dio waits >30s for response |
| `DioException` 4xx/5xx | `NetworkFailure(statusCode: …)` | API returned error |
| `FormatException` | `ParseFailure` | JSON decode failed |
| `TypeError` | `ParseFailure` | Type mismatch in JSON |
| Hive `HiveError` on read | `CacheReadFailure` | Box corrupted or adapter missing |
| Hive write error | `CacheWriteFailure` | Disk full or permission issue |
| Asset missing | `FixtureMissingFailure` | Fixture JSON not bundled |
| Anything else | `UnknownFailure` | Unclassified exception |

### Usage Pattern

```dart
// In remote_source.dart
Future<List<Movie>> getNowShowingMovies() async {
  try {
    final response = await dio.get('/api/v1/movies/now-showing');
    return (response.data as List)
        .map((json) => MovieDto.fromJson(json as Map<String, dynamic>))
        .map((dto) => dto.toEntity())
        .toList();
  } on DioException catch (e, st) {
    if (e.isConnectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      throw TimeoutFailure('Network timeout', e);
    }
    throw NetworkFailure(
      'Failed to fetch movies',
      e.response?.statusCode,
      e,
    );
  } on FormatException catch (e, st) {
    throw ParseFailure('Invalid response format', null, e);
  } catch (e, st) {
    throw UnknownFailure('Unexpected error: $e', e);
  }
}

// In repository_impl.dart
@override
Future<List<Movie>> getMoviesNowShowing() async {
  try {
    // SWR logic: check cache TTL first
    final cached = _localSource.getMoviesNowShowing();
    if (cached != null && _cachePolicy.isFresh(cached.savedAt, ttlMinutes: 30)) {
      return cached.payload.map((dto) => dto.toEntity()).toList();
    }
  } catch (e) {
    // Ignore cache errors, try network
  }

  // Fetch from network
  final fresh = await _remoteSource.getNowShowingMovies();
  
  // Update cache async
  _localSource.cacheMoviesNowShowing(fresh).ignore();
  
  return fresh;
}
```

### UI Error Handling

```dart
// In widget using Riverpod
movies.when(
  loading: () => MovieShimmerLoader(),
  error: (err, st) {
    if (err is TimeoutFailure) {
      return ErrorView(
        message: 'Network timeout. Check connection and try again.',
        onRetry: () => ref.invalidate(moviesProvider),
      );
    } else if (err is NetworkFailure) {
      return ErrorView(
        message: 'Failed to load movies.',
        onRetry: () => ref.invalidate(moviesProvider),
      );
    }
    return ErrorView(
      message: 'Unexpected error. Please try again.',
      onRetry: () => ref.invalidate(moviesProvider),
    );
  },
  data: (data) => MovieRail(movies: data),
);
```

---

## 6. Code Generation

### Commands

```bash
# Full build (Riverpod + Freezed + Hive + JSON)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (rebuild on file change)
dart run build_runner watch --delete-conflicting-outputs

# Clean generated files
dart run build_runner clean

# Theme tokens codegen
dart tool/gen_theme.dart
```

### Annotations

| Annotation | Use | File |
|---|---|---|
| `@freezed` | Data classes (DTO/entity) with equality + copyWith | `*.dart` (auto generates `*.freezed.dart`) |
| `@JsonSerializable()` | JSON serialization helpers | Freezed DTOs (auto with @freezed) |
| `@riverpod` | Provider (async or state) | `*_provider.dart` files |
| `@HiveType()` | Hive TypeAdapter (for cache objects) | `cache_envelope.dart`, `*_dto.dart` in cache |
| `@HiveField()` | Hive field annotation | Enum members in cached types |

### Generated File Convention

- **Freezed**: `{name}.freezed.dart` — in same dir, auto-imported via `part`
- **Riverpod**: `{provider}.g.dart` — in same dir, auto-imported via `part`
- **Hive**: `{box_type}.g.dart` in `.dart_tool/` — registered at bootstrap
- **Tokens**: `lib/core/theme/generated/{type}_tokens.dart` — manual location

---

## 7. Testing Conventions

### Widget Tests

**Helper**: Use `WidgetTestHarness` wrapper (wraps app in ProviderScope + MaterialApp).

```dart
// Test file: features/home/widgets/movie_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:adf_demo/features/home/domain/entities/movie.dart';
import 'package:adf_demo/features/home/presentation/widgets/movie_card.dart';
import 'test/_helpers/widget_test_harness.dart';

void main() {
  group('MovieCard', () {
    testWidgets('displays movie title and rating', (WidgetTester tester) async {
      final movie = Movie(
        id: '1',
        title: 'Inception',
        posterUrl: 'https://example.com/poster.jpg',
        rating: 8.8,
      );

      await tester.pumpWidget(
        WidgetTestHarness(
          home: MovieCard(
            movie: movie,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Inception'), findsOneWidget);
      expect(find.text('8.8'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      final movie = Movie(
        id: '1',
        title: 'Inception',
        posterUrl: 'https://example.com/poster.jpg',
        rating: 8.8,
      );

      await tester.pumpWidget(
        WidgetTestHarness(
          home: MovieCard(
            movie: movie,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(MovieCard));
      expect(tapped, isTrue);
    });
  });
}
```

### Unit Tests

**Mocking**: Use `mocktail` for repository/source mocking.

```dart
// Test file: features/home/data/home_repository_impl_test.dart
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adf_demo/features/home/data/home_repository_impl.dart';
import 'package:adf_demo/core/errors/failure.dart';

class MockHomeRemoteSource extends Mock implements HomeRemoteSource {}
class MockHomeLocalSource extends Mock implements HomeLocalSource {}

void main() {
  group('HomeRepositoryImpl', () {
    late MockHomeRemoteSource remoteSource;
    late MockHomeLocalSource localSource;
    late HomeRepositoryImpl repository;

    setUp(() {
      remoteSource = MockHomeRemoteSource();
      localSource = MockHomeLocalSource();
      repository = HomeRepositoryImpl(remoteSource, localSource);
    });

    test('returns cached banners if fresh', () async {
      final cached = [BannerDto(id: '1', title: 'Ad', imageUrl: 'url', targetUrl: 'target')];
      when(() => localSource.getBanners()).thenReturn(cached);
      when(() => localSource.isBannersCacheFresh()).thenReturn(true);

      final result = await repository.getBanners();

      expect(result, isNotEmpty);
      verify(() => remoteSource.getBanners()).called(0);  // No network call
    });

    test('fetches from network if cache stale', () async {
      final fresh = [BannerDto(id: '2', title: 'Ad2', imageUrl: 'url', targetUrl: 'target')];
      when(() => localSource.getBanners()).thenReturn(null);
      when(() => remoteSource.getBanners()).thenAnswer((_) async => fresh);
      when(() => localSource.cacheBanners(any())).thenAnswer((_) async {});

      final result = await repository.getBanners();

      expect(result, isNotEmpty);
      verify(() => remoteSource.getBanners()).called(1);
    });

    test('throws TimeoutFailure on network timeout', () async {
      when(() => localSource.getBanners()).thenReturn(null);
      when(() => remoteSource.getBanners())
          .thenThrow(TimeoutFailure());

      expect(
        () => repository.getBanners(),
        throwsA(isA<TimeoutFailure>()),
      );
    });
  });
}
```

### Coverage Target

- **Home feature**: >80% (screen, providers, widgets, data)
- **Core network**: >75% (Dio client, mock interceptor)
- **Core storage**: >75% (Hive bootstrap, LocalCache)
- **Overall**: >70%

**Run coverage**:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # View in browser
```

---

## 8. Linting & Analysis

### Pre-Commit Checks

```bash
# Analyze
fvm flutter analyze

# Format
fvm dart format lib/ test/ --line-length=100

# Tests (required before push)
fvm flutter test
```

### Zero-Issue Gate

- **Code review blocks**: Merge if `flutter analyze` shows any issues (severity: any)
- **False positives**: Document in `analysis_options.yaml` `exclude:` only if unavoidable
- **CI/CD enforcement**: GitHub Actions runs `flutter analyze` on PR

---

## 9. Git & Commits

### Conventional Commits

```
feat(feature): add home screen banner carousel
fix(core): timeout handling in Dio client
docs(readme): update deployment steps
refactor(home): split banner widget into focused components
test(home): add MovieCard widget tests
chore(deps): update Riverpod to 2.5.1
```

### Commit Best Practices

1. **Keep focused**: One feature or fix per commit
2. **No generated files**: Exclude `*.freezed.dart`, `*.g.dart`, theme tokens
3. **Test with commit**: `test/` changes accompany code changes
4. **Reference docs**: Link FSD or design if relevant

```bash
git add lib/features/home/presentation/widgets/movie_card.dart test/features/home/widgets/movie_card_test.dart
git commit -m "feat(home): add MovieCard widget with rating badge

- Displays movie title, poster, and star rating
- Supports onTap callback for navigation
- Uses theme tokens for colors and spacing
- Includes widget tests for rendering and tap handling"
```

---

## 10. Performance & Optimization

### Key Metrics

| Metric | Target | Notes |
|---|---|---|
| Cold start | <2s | First API fetch + render |
| Warm start | <500ms | Cached load + render |
| Jank frames | <5% | Maintain 60 fps |
| Memory (idle) | <100 MB | Hive + image cache |
| Build time | <30s | Incremental, cached |

### Optimization Practices

1. **Image Caching**: Use `CachedNetworkImage` with Hive backend
2. **List Virtualization**: `ListView` / `GridView` only render visible items
3. **Provider Caching**: Avoid redundant `.watch()` calls; use selectors
4. **Async Batching**: Group related fetches (banners + movies) in single provider
5. **Shimmer Skeletons**: Loading state matches final layout (no jank on load)

```dart
// ✅ Efficient list rendering
ListView.builder(
  itemCount: movies.length,
  itemBuilder: (ctx, i) => MovieCard(movie: movies[i]),
);

// ✅ Efficient provider watch (selector)
final selectedMovies = ref.watch(
  moviesProvider.select((async) => async.maybeWhen(
    data: (all) => all.where((m) => m.status == category).toList(),
    orElse: () => [],
  )),
);

// ❌ Inefficient (rebuilds on any movie change)
final allMovies = ref.watch(moviesProvider);  // then filter in build()
```

---

## 11. Documentation Standards

### Code Comments

**Rule**: Write code that is self-documenting. Comments explain *why*, not *what*.

```dart
// ✅ Good: explains the decision
// Delay 500ms before refetch to avoid rapid repeated clicks
Future.delayed(Duration(milliseconds: 500), () => ref.invalidate(moviesProvider));

// ❌ Bad: repeats the code
// Delay 500ms
Future.delayed(Duration(milliseconds: 500), () => ref.invalidate(moviesProvider));

// ✅ Good: explains non-obvious constraint
// TTL = 30min per design/project-fsd.md § Cache Policy
const cacheTtlMinutes = 30;

// ❌ Bad: magic number with no rationale
const cacheTtlMinutes = 30;  // 30 minutes
```

### Doc Comments

**Functions & Classes**:
```dart
/// Fetches movies currently in theaters with local caching.
///
/// Implements Stale-While-Revalidate (SWR):
/// - Returns cached data if fresh (<30min)
/// - Refetches in background if stale
/// - Throws [TimeoutFailure] if network timeout
/// - Throws [NetworkFailure] if API error
///
/// See: [docs/project-fsd.md] § API Contracts
Future<List<Movie>> getMoviesNowShowing();
```

---

## 12. Quick Reference

### Do's
- ✅ Use kebab-case for filenames
- ✅ Keep files <200 LOC
- ✅ Use theme tokens for all colors/sizes
- ✅ Map exceptions to Failure taxonomy
- ✅ Extract widgets early (don't wait for 200 LOC)
- ✅ Test presentation + data layers
- ✅ Document *why* in comments, not *what*
- ✅ Use Riverpod @riverpod, not raw providers
- ✅ Run `flutter analyze` before commit

### Don'ts
- ❌ Hardcode hex colors or magic numbers
- ❌ Access global state without ref.watch()
- ❌ Ignore test failures
- ❌ Mix layers (presentation logic in data layer)
- ❌ Create files >200 LOC (split instead)
- ❌ Use StatefulWidget when ConsumerWidget suffices
- ❌ Commit generated files (*.freezed.dart, *.g.dart)
- ❌ Create circular dependencies (domain → data → domain)
- ❌ Deploy with `flutter analyze` issues

---

## 13. Reference Documents

- **[docs/project-overview-pdr.md](project-overview-pdr.md)** — Requirements, success metrics
- **[docs/system-architecture.md](system-architecture.md)** — Architecture, Failure taxonomy
- **[docs/codebase-summary.md](codebase-summary.md)** — File-by-file walkthrough
- **[docs/deployment-guide.md](deployment-guide.md)** — Build & test commands
- **[docs/project-fsd.md](project-fsd.md)** — API contracts, data models
- **[docs/design-system/component-catalog.md](design-system/component-catalog.md)** — Widget patterns

---

**End of Code Standards**

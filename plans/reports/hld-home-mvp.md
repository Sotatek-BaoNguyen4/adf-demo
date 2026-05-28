---
type: brainstorm-technical
title: High-Level Design — Home Screen MVP (ADF Cinema)
date: 2026-05-27
status: agreed
scope: Home screen MVP (FR-HOME-001..005)
stack: Flutter 3.10+ / Dart / Riverpod 2 / go_router / Hive / Dio
---

# HLD — ADF Cinema Home MVP

## 1. Problem Statement

Build first slice of ADF Cinema mobile app: a movie-discovery Home screen.
Scope = **Home MVP only** (FR-HOME-001..005):

- Auto-rotating banner carousel (5s, BR-001)
- Three horizontal rails: Now Showing, Coming Soon, Recommended
- Bottom-nav shell with 5 tabs (only Home wired; others = placeholder)
- Local cache for movie lists (BR-002)
- Cached-data load < 500ms (NFR perf)
- All data sourced from **mocked IMDB JSON fixtures** behind real HTTP contract

Not in scope: Search, Cinemas, Community, Profile screens, Auth, Movie Details, real IMDB API integration.

---

## 2. Constraints & Drivers

| Driver | Implication |
|---|---|
| Mobile-only (Flutter) | iOS + Android from one codebase; pubspec already minimal |
| Demo / Gen-Z audience | M3 dark-cinematic theme already designed |
| Existing FSD + design system | HLD must honor API contracts (FSD §4) + DTCG tokens |
| YAGNI/KISS/DRY | No premature layers; defer Clean-Arch UseCases until repos get logic |
| Mock-now / real-later | HTTP layer must allow swapping fixture source → real IMDB by flipping a flag |
| File-size rule (<200 LOC) | Force modularization in features + theme codegen output |

---

## 3. Evaluated Approaches (Summary of Debate)

### 3.1 Architecture pattern

| Option | Verdict |
|---|---|
| **Feature-first + MVVM-lite** ✅ | Chosen. Folder by feature; ViewModel = Riverpod Notifier; thin Repository. Right-sized for 5 tabs. |
| Clean Architecture (strict) | Rejected — UseCase layer adds boilerplate for trivial fetch+cache flows. |
| Flat screens+services | Rejected — collapses by tab #3. |

### 3.2 State management

| Option | Verdict |
|---|---|
| **Riverpod 2.x** ✅ | Chosen. Compile-safe, no context, async-first, testable. |
| flutter_bloc | Viable; rejected for boilerplate cost on simple list flows. |
| Provider | Too weak for async list state w/ caching. |
| GetX | Rejected — magic strings, tight coupling, controversial. |

### 3.3 Data strategy

| Option | Verdict |
|---|---|
| **Dio + JSON fixtures via interceptor** ✅ | Chosen. Honors FSD §4 contracts; swap-ready for real backend. |
| In-memory mock repo | Rejected — throws away API contracts. |
| Real IMDB direct | Rejected — keys/TOS/rate-limits for a demo. |

### 3.4 Cache, navigation, theming

| Layer | Choice | Why |
|---|---|---|
| Local cache | **Hive CE** | KV with TypeAdapters, TTL via timestamp, fast cold reads. |
| Navigation | **go_router 14 (StatefulShellRoute)** | Purpose-built for bottom-nav with per-tab back stacks; deep-link ready. |
| Theming | **Codegen from tokens.json + ThemeExtension** | Single source of truth; compile-safe; survives token edits. |

---

## 4. High-Level Architecture

### 4.1 Layered view (per feature)

```
┌────────────────────────────────────────────────────────────┐
│  Presentation         (Widgets + Riverpod Notifiers/VM)    │
│  ─────────────────────────────────────────────────────     │
│  HomeScreen  BannerCarousel  MovieRail  MovieCard          │
│           ▲                                                 │
│           │ AsyncValue<List<Movie>>                         │
│           │                                                 │
│  Domain               (Pure Dart models + interfaces)      │
│  ─────────────────────────────────────────────────────     │
│  Movie  Banner  HomeRepository (abstract)                  │
│           ▲                                                 │
│           │                                                 │
│  Data                 (Repo impl + sources + DTOs)         │
│  ─────────────────────────────────────────────────────     │
│  HomeRepositoryImpl                                         │
│     ├─ RemoteSource (Dio + endpoints)                       │
│     │     └─ MockInterceptor → assets/fixtures/*.json       │
│     └─ LocalSource  (Hive boxes: movies, banners + TTL)     │
└────────────────────────────────────────────────────────────┘
```

### 4.2 Folder layout (target)

```
lib/
├── main.dart
├── app/
│   ├── app.dart                       # MaterialApp.router + ProviderScope
│   └── router.dart                    # go_router config (StatefulShellRoute)
├── core/
│   ├── theme/
│   │   ├── app_theme.dart             # ThemeData light + dark builders
│   │   ├── generated/                 # codegen from tokens.json
│   │   │   ├── color_tokens.dart
│   │   │   ├── spacing_tokens.dart
│   │   │   └── typography_tokens.dart
│   │   └── extensions/                # M3 ThemeExtension classes
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── mock_interceptor.dart      # serves assets/fixtures/*.json
│   ├── storage/
│   │   ├── hive_bootstrap.dart
│   │   └── cache_policy.dart          # TTL helper
│   └── errors/
│       └── failure.dart
├── features/
│   └── home/
│       ├── data/
│       │   ├── home_repository_impl.dart
│       │   ├── sources/
│       │   │   ├── home_remote_source.dart
│       │   │   └── home_local_source.dart
│       │   └── dto/
│       │       ├── movie_dto.dart
│       │       └── banner_dto.dart
│       ├── domain/
│       │   ├── entities/movie.dart
│       │   ├── entities/banner.dart
│       │   └── home_repository.dart
│       └── presentation/
│           ├── home_screen.dart
│           ├── providers/             # Riverpod (Async)Notifiers
│           │   ├── banners_provider.dart
│           │   ├── now_showing_provider.dart
│           │   ├── coming_soon_provider.dart
│           │   └── recommended_provider.dart
│           └── widgets/
│               ├── banner_carousel.dart
│               ├── movie_rail.dart
│               ├── movie_card.dart
│               └── shimmer_placeholder.dart
└── shared/
    ├── widgets/                       # cross-feature widgets
    └── utils/
assets/
└── fixtures/
    ├── banners.json
    ├── now-showing.json
    ├── coming-soon.json
    └── recommended.json
tool/
└── gen_theme.dart                     # tokens.json → Dart codegen
test/
├── unit/
└── widget/
```

### 4.3 Data flow — Home cold start

```
HomeScreen mount
  → ref.watch(nowShowingProvider)
       AsyncNotifier.build()
         → HomeRepository.getNowShowing()
              1. LocalSource.read('now-showing')
                   ├─ hit + fresh → return cached  (✅ < 500ms target)
                   └─ stale/miss  → continue
              2. RemoteSource.getNowShowing()
                   → Dio → MockInterceptor
                        → load assets/fixtures/now-showing.json
                        → simulate 200ms latency
                   → DTO.fromJson → Movie entities
              3. LocalSource.write('now-showing', payload, ts)
              4. return list
  → UI renders shimmer → list (per AsyncValue state)
```

### 4.4 Bottom-nav shell (go_router StatefulShellRoute)

```
ShellRoute
├─ tab: Home       → /home       → HomeScreen  (implemented)
├─ tab: Search     → /search     → PlaceholderScreen
├─ tab: Cinemas    → /cinemas    → PlaceholderScreen
├─ tab: Community  → /community  → PlaceholderScreen
└─ tab: Profile    → /profile    → PlaceholderScreen
```

Each tab gets its own `Navigator` stack → back button per tab works correctly.

---

## 5. Key Components

| Component | Responsibility | LOC budget |
|---|---|---|
| `dio_client.dart` | Base URL, interceptors chain | < 60 |
| `mock_interceptor.dart` | Match `/api/v1/...` path → load fixture → return Response | < 120 |
| `hive_bootstrap.dart` | Register adapters, open boxes at startup | < 80 |
| `cache_policy.dart` | TTL constants + `isFresh(timestamp, ttl)` | < 40 |
| `home_repository_impl.dart` | Orchestrate local + remote, write-through cache | < 150 |
| `home_remote_source.dart` | One Dio call per endpoint | < 100 |
| `home_local_source.dart` | Hive read/write with TTL wrapper | < 100 |
| `home_screen.dart` | CustomScrollView of carousel + 3 rails + bottom nav | < 180 |
| `banner_carousel.dart` | 5s auto-rotate (BR-001), swipe, indicators | < 150 |
| `movie_rail.dart` | Horizontal `ListView.builder` + section header | < 120 |
| Riverpod notifiers (x4) | `build()` → repo call; `refresh()` for pull-to-refresh | < 80 each |
| `gen_theme.dart` (tooling) | Parse tokens.json + themes/*.json → emit Dart | < 200 |

All files satisfy the **< 200 LOC** project rule by design.

---

## 6. Dependencies (proposed `pubspec.yaml`)

```yaml
dependencies:
  flutter: { sdk: flutter }
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5        # optional codegen
  go_router: ^14.6.0
  dio: ^5.7.0
  hive_ce: ^2.7.0
  hive_ce_flutter: ^2.0.0
  path_provider: ^2.1.5
  cached_network_image: ^3.4.1       # poster + banner image cache
  shimmer: ^3.0.0                    # loading state (FSD §2 Loading)
  freezed_annotation: ^2.4.4         # immutable DTOs/entities
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test: { sdk: flutter }
  flutter_lints: ^6.0.0
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  hive_ce_generator: ^1.7.0
  riverpod_generator: ^2.6.1
  mocktail: ^1.0.4
```

**Decision:** Codegen **enabled** (freezed + json_serializable + riverpod_generator). `build_runner watch` during dev. Hive variant = **Hive CE**.

---

## 7. Cross-Cutting Concerns

### 7.1 Error handling

- Single `Failure` sealed class in `core/errors/` (network / cache / parse / unknown)
- Repository catches Dio + Hive errors → returns `Result<T, Failure>` *or* throws typed
- Decision: **throw typed Failure**, let Riverpod's `AsyncValue.error` carry it → simpler UI

### 7.2 Loading / empty / error states (FSD §2)

Riverpod's `AsyncValue` already models all 4 (loading, data, error, refreshing) — UI uses `.when(...)`.
Shimmer for loading; empty-state widget when `data.isEmpty`; error widget w/ "pull to refresh".

### 7.3 Caching policy

- TTL per list: **6 hours** for movies, **1 hour** for banners (config in `cache_policy.dart`)
- Stale-while-revalidate: serve stale immediately + trigger background refresh → meets 500ms target
- Cache key = endpoint path; Hive box per kind

### 7.4 Theming

- Two `ThemeData` builders consume codegen tokens
- `MaterialApp.router(theme:, darkTheme:, themeMode:)`
- ThemeExtensions expose non-M3 tokens (custom spacing, radii, motion)

### 7.5 Image strategy

- All posters/banners via `cached_network_image` (memory + disk cache)
- Fixture URLs point at **remote IMDB-hosted images** (decision: realistic latency + exercises CDN cache path; internet required at first launch)

### 7.6 Theme mode

- **Dark theme hard-coded** for MVP (`themeMode: ThemeMode.dark`)
- Light theme builder still emitted from codegen but unused until Profile/Settings ships
- Aligns with design-system audience ("Dark Cinematic, Gen-Z")

### 7.7 Testing

- **Unit**: repository (mocked sources via mocktail), cache_policy, DTO parsing
- **Widget**: HomeScreen rendering for each `AsyncValue` state, BannerCarousel auto-rotate, pull-to-refresh triggers invalidate
- **Golden** (optional, stretch): one HomeScreen golden (dark theme)
- No integration tests in MVP scope

### 7.8 Mock auth handling

- `Recommended` endpoint requires auth per FSD §4 but auth feature is out of scope
- **Decision:** MockInterceptor **bypasses auth** in mock mode → returns recommended fixture unconditionally
- Real auth gate is wired when auth feature lands; no temporary auth stub code in MVP

---

## 8. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Riverpod + go_router learning curve | Med | Low | Patterns are stable in 2026; AsyncNotifier docs are mature |
| Hive CE adapter codegen friction | Low | Low | Keep DTOs simple; `build_runner watch` during dev |
| Mock interceptor diverges from real backend later | Med | Med | Same Dio interface; only swap interceptor → real base URL |
| `tokens.json` schema drift vs codegen | Low | Med | Run `dart tool/gen_theme.dart` in pre-commit hook |
| 500ms cold-start target | Low | Low | Stale-while-revalidate + Hive read is ~5-30ms typical |
| Bottom-nav state loss across tabs | Med | Low | StatefulShellRoute preserves each tab's Navigator stack |
| File-size creep > 200 LOC | Med | Low | Per-component LOC budgets in §5; enforce in code review |

---

## 9. Non-Goals (explicit YAGNI)

- ❌ Auth / login flow (mock interceptor bypasses the auth requirement on Recommended)
- ❌ Movie Details screen
- ❌ UseCase layer (only Repository → Notifier; reintroduce when logic warrants)
- ❌ Internationalization
- ❌ Analytics / telemetry SDKs
- ❌ Push notifications
- ❌ Real IMDB / RapidAPI integration
- ❌ Light-theme switching UI (light theme defined but unused until Profile ships)
- ❌ Offline-first / bundled image assets

---

## 10. Success Criteria

1. App launches → Home screen visible in < 2s cold start on mid-tier Android
2. Cached lists render in < 500ms on warm start (NFR met)
3. Banner auto-rotates every 5s (BR-001)
4. All three rails display fixture data via Dio + interceptor (FSD §4 contracts honored)
5. Bottom-nav switches tabs with independent back stacks
6. Light + dark themes produced 100% from `docs/design-system/tokens.json` (zero hand-coded colors in widgets)
7. `flutter analyze` clean; `flutter test` green
8. No file > 200 LOC in `lib/`

---

## 11. Next Steps & Dependencies

1. **Confirm dependency set** (esp. codegen yes/no, Hive CE vs original Hive)
2. **Run `/plan`** to break HLD into phases (proposed split):
   - Phase 1 — Project bootstrap (pubspec, folders, lints)
   - Phase 2 — Theme codegen + `core/theme/`
   - Phase 3 — Network + storage core (Dio, MockInterceptor, Hive bootstrap)
   - Phase 4 — Home domain + data (entities, DTOs, repo, sources, fixtures)
   - Phase 5 — Home presentation (providers, HomeScreen, carousel, rails)
   - Phase 6 — Router + bottom-nav shell
   - Phase 7 — Tests (unit + widget)
3. **Author fixtures** for 4 endpoints (banners, now-showing, coming-soon, recommended)
4. **Wire pre-commit** for `dart tool/gen_theme.dart` + `flutter analyze`

---

## 12. Resolved Decisions Log

| # | Question | Decision |
|---|---|---|
| 1 | Codegen vs hand-written DTOs | **Codegen** — freezed + json_serializable + riverpod_generator |
| 2 | Hive CE vs original Hive | **Hive CE** (hive_ce + hive_ce_flutter + hive_ce_generator) |
| 3 | Fixture poster images | **Remote IMDB-hosted URLs** (no bundled images) |
| 4 | Recommended endpoint auth in mock mode | **Bypass auth** in MockInterceptor; real gate added when auth feature lands |
| 5 | Pull-to-refresh on Home | **Included in MVP** (`RefreshIndicator` + `ref.invalidate(provider)`) |
| 6 | Theme mode for MVP | **Hard-coded dark** (`ThemeMode.dark`); light theme generated but unused |

All foundational decisions locked. Ready for `/plan`.

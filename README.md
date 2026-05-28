# ADF Cinema — Home Screen MVP

A Flutter-based movie discovery mobile app featuring an intelligent home screen with auto-rotating banners, movie categorization, and a robust bottom navigation shell. This is the **MVP** (Minimum Viable Product) focusing on the home screen experience with mocked IMDB data.

## Project Status

**Current Phase**: ✅ Complete (Home MVP v1.0)
- Home screen fully implemented and mockup-aligned
- Bottom navigation shell with 5 tabs (Home wired; others placeholder)
- Network layer (Dio + mock interceptor) and local cache (Hive) operational
- Design system tokens and theming pipeline integrated
- Test coverage across core, data, and presentation layers

## Tech Stack

- **Language**: Dart 3.10+ | **Framework**: Flutter 3.10+
- **State Management**: Riverpod 2.5 (codegen providers)
- **Navigation**: go_router 14 (StatefulShellRoute)
- **Network**: Dio 5 + mock interceptor (fixture-based)
- **Local Storage**: Hive CE 2.7 (KV store with TTL cache)
- **Serialization**: Freezed 2.5 (code generation)
- **Theming**: Material Design 3 (token-driven, codegen)
- **Testing**: Flutter test + mocktail 1.0

## Features

| Feature ID | Description | Status |
|---|---|---|
| **FR-HOME-001** | Display carousel banner of featured content | ✅ Done |
| **FR-HOME-002** | Fetch and display "Now Showing" movies | ✅ Done |
| **FR-HOME-003** | Fetch and display "Coming Soon" movies | ✅ Done |
| **FR-HOME-004** | Fetch and display "Recommended" movies | ✅ Done |
| **FR-HOME-005** | Bottom navigation (5 tabs) | ✅ Done |

## Quick Start

### Prerequisites
- Flutter 3.10+ (managed via [fvm](https://fvm.app/))
- Dart 3.10+
- iOS 12.0+ / Android API 21+

### Setup & Run

```bash
# Install FVM (if not already installed)
brew install fvm   # macOS
# or: choco install fvm   # Windows (Chocolatey)

# Sync Flutter version from .fvmrc
fvm install

# Get dependencies
fvm flutter pub get

# Generate code (Riverpod, Freezed, Hive adapters)
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Generate theme tokens
dart tool/gen_theme.dart

# Run on device/emulator
fvm flutter run -d <device-id>

# Run tests
fvm flutter test
```

### Build for Production

```bash
# Android
fvm flutter build apk --release

# iOS
fvm flutter build ios --release

# Web
fvm flutter build web --release
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── hive_registrar.g.dart             # Generated Hive adapter registry
├── app/
│   ├── app.dart                      # MaterialApp.router + dark theme
│   ├── router.dart                   # go_router StatefulShellRoute (5 tabs)
│   └── shell/
│       ├── home_shell.dart           # Scaffold + CinemaNavBar
│       └── placeholder_tab.dart      # Explore/Saved/Profile placeholders
├── core/                              # Shared infrastructure
│   ├── errors/failure.dart           # Sealed Failure hierarchy
│   ├── navigation/tickets_fab_tile.dart # Center FAB widget
│   ├── network/                      # Dio + mock interceptor
│   ├── storage/                      # Hive + cache policy
│   └── theme/                        # Theming + design tokens
├── features/
│   ├── home/                         # Home feature (data/domain/presentation)
│   │   ├── data/                    # DTOs, sources, repository impl
│   │   ├── domain/                  # Entities, repository interface
│   │   └── presentation/            # Screen, providers, widgets (20+ widgets)
│   └── tickets/
│       └── presentation/tickets_screen.dart # Placeholder
└── shared/
    └── widgets/cinema_nav_bar.dart   # Reusable bottom nav
```

## Documentation Index

| Document | Purpose |
|---|---|
| [**docs/project-overview-pdr.md**](docs/project-overview-pdr.md) | Product requirements, success metrics, constraints |
| [**docs/project-fsd.md**](docs/project-fsd.md) | Functional specification (FR-HOME-001..005, API contracts, data models) |
| [**docs/system-architecture.md**](docs/system-architecture.md) | Architecture diagrams, data flow, Failure taxonomy |
| [**docs/code-standards.md**](docs/code-standards.md) | File naming, <200 LOC rule, layering, codegen, testing |
| [**docs/codebase-summary.md**](docs/codebase-summary.md) | File-by-file walkthrough of lib/ structure |
| [**docs/deployment-guide.md**](docs/deployment-guide.md) | Build steps, platform targets, mock toggle, known caveats |
| [**docs/project-roadmap.md**](docs/project-roadmap.md) | Phase-by-phase progress, upcoming features |
| [**docs/design-system/**](docs/design-system/) | Design tokens, component catalog, themes |
| [**docs/usecases/**](docs/usecases/) | Per-module use case walkthroughs |

## Key Architectural Decisions

1. **Clean Architecture (Feature-Sliced)**: Each feature owns `data/`, `domain/`, `presentation/` layers. `core/` holds shared infrastructure (network, storage, errors, theme).

2. **Stale-While-Revalidate (SWR) Cache**: Hive stores `CacheEnvelope{payload, savedAt, schemaVersion}` with TTL. On stale read, async refresh in background.

3. **Mock-First Network**: `MockInterceptor` intercepts `/api/v1/*` and serves bundled JSON fixtures. Real backend swap via `--dart-define=USE_MOCK=false`.

4. **Token-Driven Theming**: `tool/gen_theme.dart` reads `docs/design-system/tokens.json` and generates compile-safe `lib/core/theme/generated/*_tokens.dart`. No hardcoded hex/sizes in widgets.

5. **File Size Cap**: All Dart files ≤200 LOC (enforced in code review). Large features split into multiple focused files.

## Contribution Rules

- **File Naming**: kebab-case, descriptive (e.g., `banner_carousel_section.dart`, not `widget.dart`)
- **Layering**: DTOs → `data/dto/`, Entities → `domain/entities/`, Mappers in DTOs
- **Theming**: Use `Theme.of(context)` + `ThemeExtensions` only; never hardcoded colors/sizes
- **Error Handling**: Map low-level exceptions to sealed `Failure` taxonomy before throwing
- **Testing**: Use `WidgetTestHarness` for widget tests; `mocktail` for mocks
- **Codegen**: Run `build_runner build --delete-conflicting-outputs` after modifying `@freezed` or `@riverpod` annotations
- **Linting**: `flutter analyze` must pass with 0 issues before phase complete

## Performance Targets

| Metric | Target |
|---|---|
| Cold start (first fetch from API) | <2s |
| Warm start (cached load) | <500ms |
| Banner auto-rotate interval | 5s |
| Code analysis | 0 issues |
| Test coverage (home feature) | >80% |

## Known Limitations (MVP)

- **Light theme**: Exists in design system but not user-toggleable (dark-only for MVP)
- **Font assets**: Pending `.ttf` drop-in; pubspec fonts block commented
- **Placeholders**: Explore, Saved, Profile tabs are static placeholders
- **No real auth**: Recommended endpoint is public mock (no token needed)
- **Mock-only data**: All fixtures are bundled JSON (no live IMDB integration)

## Next Steps (Post-MVP)

1. Drop font `.ttf` files, uncomment pubspec fonts block, rebuild
2. Implement light-theme toggle (UI + persistence)
3. Build Search feature (FR-SEARCH-001..003)
4. Build Cinemas feature (FR-CINEMAS-001..002)
5. Integrate real backend APIs (replace MockInterceptor)
6. Add authentication & profile (FR-AUTH-001..005)
7. Implement ticketing flow (FR-TICKETS-001..004)

## Support & Issues

For bugs or questions, refer to:
- **Architecture**: [docs/system-architecture.md](docs/system-architecture.md)
- **Building**: [docs/deployment-guide.md](docs/deployment-guide.md)
- **Code Review**: See [docs/code-standards.md](docs/code-standards.md)

---

**Version**: 0.1.0 | **Last Updated**: 2026-05-28 | **License**: Proprietary (Sotatek)

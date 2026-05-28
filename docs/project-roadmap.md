# Project Roadmap — ADF Cinema MVP

**Vision**: Build a comprehensive cinema discovery and ticketing platform in phases, starting with the home screen MVP.  
**Last Updated**: 2026-05-28

---

## Phase Overview

```
Phase 0 (Complete)    Phase 1 (Complete)      Phase 2 (Complete)
┌──────────────┐      ┌──────────────┐        ┌──────────────┐
│  Bootstrap   │      │  Core Theme  │        │ Core Network │
│  (0 tasks)   │ → → → │  & Theming   │ → → → │  & Storage   │
│   ✅ DONE    │      │   ✅ DONE    │        │   ✅ DONE    │
└──────────────┘      └──────────────┘        └──────────────┘
                                                      ↓
Phase 3 (Complete)    Phase 4 (Complete)      Phase 5 (Complete)
┌──────────────┐      ┌──────────────┐        ┌──────────────┐
│ Home Feature │      │ Home Feature │        │ Router &     │
│   (Data)     │      │ (Presentation)       │ Shell (Nav)  │
│   ✅ DONE    │      │   ✅ DONE    │        │   ✅ DONE    │
└──────────────┘      └──────────────┘        └──────────────┘
                                                      ↓
Phase 6 (Complete)    Phase 7 (Complete)      Phase 8 (Complete)
┌──────────────┐      ┌──────────────┐        ┌──────────────┐
│  Tests &     │      │ Home Mockup  │        │  MVP Ready   │
│  Polish      │      │  Alignment   │        │  (Release)   │
│   ✅ DONE    │      │   ✅ DONE    │        │   ✅ DONE    │
└──────────────┘      └──────────────┘        └──────────────┘
                                                      ↓
Phase 9+ (Planned)
┌──────────────────────────────────────────┐
│  Post-MVP: Search, Auth, Ticketing, etc. │
│  🔄 PLANNED                              │
└──────────────────────────────────────────┘
```

---

## Completed Phases (Home MVP)

### Phase 0: Project Bootstrap
**Status**: ✅ Complete  
**Duration**: 1 session  
**Deliverables**:
- [x] Flutter project scaffolding
- [x] Pubspec dependencies (Riverpod, Dio, Hive, Freezed, go_router)
- [x] Git repository initialization
- [x] `.fvmrc` Flutter version lock
- [x] Code generation tooling (build_runner)

**Details**: See `plans/260527-1439-full-home-mvp/phase-01-bootstrap.md`

---

### Phase 1: Core Theming & Design System
**Status**: ✅ Complete  
**Duration**: 1 session  
**Deliverables**:
- [x] Design system tokens (colors, spacing, typography, motion)
- [x] Material Design 3 dark theme configuration
- [x] Theme token codegen (`tool/gen_theme.dart`)
- [x] ThemeExtension classes (AppColorsExt, AppGradientsExt, AppShapeExt)
- [x] Design mockup reference (`docs/design-mockups/home-screen/`)

**Details**: See `plans/260527-1439-full-home-mvp/phase-02-theme.md`

**Files**:
- `docs/design-system/tokens.json` — Single source of truth
- `lib/core/theme/generated/*_tokens.dart` — Auto-generated
- `lib/core/theme/extensions/*.dart` — Custom theme extensions

---

### Phase 2: Core Network & Storage Infrastructure
**Status**: ✅ Complete  
**Duration**: 1 session  
**Deliverables**:
- [x] Dio HTTP client with MockInterceptor
- [x] Mock fixture loader (JSON → Map)
- [x] Hive KV store bootstrap
- [x] Cache envelope with TTL semantics
- [x] Stale-While-Revalidate policy
- [x] Failure taxonomy (sealed classes)
- [x] Network config (mock flag toggle)

**Details**: See `plans/260527-1439-full-home-mvp/phase-03-core-network-storage.md`  
**Low-Level Design**: `docs/lld-home-mvp.md`

**Files**:
- `lib/core/network/` (4 files)
- `lib/core/storage/` (4 files)
- `lib/core/errors/failure.dart`
- `assets/fixtures/*.json` (4 files)

---

### Phase 3: Home Feature — Data Layer
**Status**: ✅ Complete  
**Duration**: 1 session  
**Deliverables**:
- [x] Data Transfer Objects (@freezed): BannerDto, MovieDto, envelopes
- [x] Domain entities (@freezed): Banner, Movie
- [x] Repository interface (abstract)
- [x] Repository implementation (SWR orchestration)
- [x] Remote source (Dio-based)
- [x] Local source (Hive-based)
- [x] Exception → Failure mapping

**Details**: See `plans/260527-1439-full-home-mvp/phase-04-home-data.md`

**Files**:
- `lib/features/home/data/` (6 files)
- `lib/features/home/domain/` (3 files)

---

### Phase 4: Home Feature — Presentation Layer
**Status**: ✅ Complete  
**Duration**: 1 session  
**Deliverables**:
- [x] Home screen (70 LOC)
- [x] Riverpod providers (5 async + state providers)
- [x] 20+ focused widgets:
  - BannerCarousel (auto-rotate 5s)
  - MovieCard variants (now-showing, coming-soon, trending)
  - CategoryChipsBar (filter)
  - MovieRail (horizontal scroll)
  - Loading/Error/Empty states
- [x] Movie categories enum

**Details**: See `plans/260527-1439-full-home-mvp/phase-05-home-presentation.md`

**Files**:
- `lib/features/home/presentation/` (27 files)

---

### Phase 5: Router & Navigation Shell
**Status**: ✅ Complete  
**Duration**: 1 session  
**Deliverables**:
- [x] go_router setup with StatefulShellRoute
- [x] 5-branch bottom navigation (Home/Explore/Tickets/Saved/Profile)
- [x] Home shell (Scaffold + CinemaNavBar)
- [x] Placeholder screens (Explore, Saved, Profile)
- [x] Raised center FAB for Tickets tab
- [x] Per-tab back stack preservation

**Details**: See `plans/260527-1439-full-home-mvp/phase-06-router-shell.md`

**Files**:
- `lib/app/router.dart`
- `lib/app/shell/` (2 files)
- `lib/shared/widgets/cinema_nav_bar.dart`
- `lib/core/navigation/tickets_fab_tile.dart`

---

### Phase 6: Tests & Initial Polish
**Status**: ✅ Complete  
**Duration**: 1 session  
**Deliverables**:
- [x] Widget test harness helper
- [x] 10+ widget tests (banners, cards, category chips, etc.)
- [x] Unit tests (repository impl, remote source)
- [x] >80% code coverage (home feature)
- [x] All tests passing
- [x] Code analysis: 0 issues
- [x] Bug fixes from initial testing

**Details**: See `plans/260527-1439-full-home-mvp/phase-07-tests.md`

**Files**:
- `test/_helpers/widget_test_harness.dart`
- `test/core/navigation/tickets_fab_tile_test.dart`
- `test/features/home/widgets/*.dart` (10 files)
- `test/features/home/data/*.dart` (2 files)

---

### Phase 7: Home Screen Mockup Alignment & Final QA
**Status**: ✅ Complete  
**Duration**: 2 sessions (5 sub-phases)  
**Deliverables**:
- [x] **Phase 7.1**: Data model & provider fixes (categories, filtering)
- [x] **Phase 7.2**: App bar & banner overlay refinement
- [x] **Phase 7.3**: Category chips & promo banner polish
- [x] **Phase 7.4**: List/card variants & consistent styling
- [x] **Phase 7.5**: Navigation alignment & comprehensive testing

**Details**: See `plans/260527-1746-home-mockup-alignment/plan.md` + phases

**Key Improvements**:
- Banner story progress indicators
- Category chip filters working end-to-end
- Movie card variants (now-showing vs coming-soon vs trending)
- Proper spacing/padding from design tokens
- Error/empty/loading states styled consistently
- All widgets tested and mockup-aligned

---

## Current Phase: Phase 8 — MVP Release Ready

**Status**: ✅ Complete  
**Checklist**:
- [x] All code: <200 LOC per file
- [x] All tests: passing (coverage >80%)
- [x] Code analysis: 0 issues
- [x] Design alignment: mockup validation complete
- [x] Performance: cold start <2s, warm <500ms
- [x] Documentation: FSD, HLD, LLD, architecture, code standards, roadmap

**Next**: Begin Phase 9 (post-MVP features)

---

## Planned Phases (Post-MVP)

### Phase 9: Font Asset Bundling & Light Theme Toggle
**Priority**: High  
**Estimated Duration**: 1 session  
**Deliverables**:
- [ ] Download OFL font `.ttf` files (Poppins, Inter, Righteous)
- [ ] Place in `assets/fonts/`
- [ ] Uncomment `pubspec.yaml` fonts block
- [ ] Test font rendering on all platforms
- [ ] Implement light theme toggle (UI + persistence)
- [ ] Switch theming providers based on user preference
- [ ] Update AppTheme factory to support light/dark
- [ ] UI tests for theme switching

**Files to Create/Modify**:
- `assets/fonts/*.ttf` (download)
- `pubspec.yaml` (uncomment fonts)
- `lib/core/theme/app_theme.dart` (light mode factory)
- `lib/app/app.dart` (theme mode provider)
- New provider: `themeMode_provider.dart`

**Dependencies**: None blocking

---

### Phase 10: Search Feature
**Priority**: High  
**Estimated Duration**: 2 sessions  
**Deliverables**:
- [ ] Search screen (query input + results)
- [ ] Search API contract (FSD § 4.5)
- [ ] Mock search fixtures
- [ ] Search repository + providers
- [ ] Debounce query input (300ms)
- [ ] Recent search history (Hive)
- [ ] Widget tests + unit tests

**Files to Create**:
- `lib/features/search/data/*.dart`
- `lib/features/search/domain/*.dart`
- `lib/features/search/presentation/*.dart`
- `assets/fixtures/search-results.json`
- `test/features/search/*.dart`

**Dependencies**: None

**API Contract** (FSD):
```
GET /api/v1/movies/search?q=<query>&page=1&limit=10
Response: Array<Movie>
```

---

### Phase 11: Cinemas Feature
**Priority**: Medium  
**Estimated Duration**: 2 sessions  
**Deliverables**:
- [ ] Cinemas screen (list + map view)
- [ ] Cinema detail screen
- [ ] Showtimes per cinema
- [ ] Mock cinema fixtures
- [ ] Cinema repository + providers
- [ ] Map integration (google_maps_flutter)
- [ ] Widget + unit tests

**Files to Create**:
- `lib/features/cinemas/data/*.dart`
- `lib/features/cinemas/domain/*.dart`
- `lib/features/cinemas/presentation/*.dart`
- `assets/fixtures/cinemas.json`

**Dependencies**: `google_maps_flutter` (add to pubspec)

---

### Phase 12: Real Backend API Integration
**Priority**: Medium  
**Estimated Duration**: 2 sessions  
**Deliverables**:
- [ ] API credentials setup (IMDB / ticketing provider)
- [ ] Remove MockInterceptor (or toggle it off by default)
- [ ] Real network requests to live API
- [ ] Error handling for real API failures
- [ ] Rate limiting / backoff
- [ ] E2E tests with real API (staging env)

**Files to Modify**:
- `lib/core/network/mock_interceptor.dart` (make optional)
- `lib/core/network/network_config.dart` (real base URL)
- All data sources (RemoteSource classes)

**Dependencies**: Real API credentials (TBD)

---

### Phase 13: Authentication & Profile
**Priority**: High  
**Estimated Duration**: 3 sessions  
**Deliverables**:
- [ ] Login screen (email/password or social auth)
- [ ] Registration screen
- [ ] Forgot password flow
- [ ] Profile screen (user info, preferences, history)
- [ ] Token refresh mechanism (JWT)
- [ ] Secure token storage (flutter_secure_storage)
- [ ] Auth guard (redirect to login if not authenticated)
- [ ] Full auth flow testing

**Files to Create**:
- `lib/features/auth/data/*.dart`
- `lib/features/auth/domain/*.dart`
- `lib/features/auth/presentation/*.dart`
- `lib/features/profile/data/*.dart`
- `lib/features/profile/presentation/*.dart`
- Auth guards in router

**New Dependencies**: `flutter_secure_storage`, JWT library

---

### Phase 14: Ticketing & Booking Flow
**Priority**: High  
**Estimated Duration**: 3 sessions  
**Deliverables**:
- [ ] Movie detail screen (synopsis, cast, reviews)
- [ ] Select cinema + showtime
- [ ] Seat selection (visual grid)
- [ ] Booking confirmation
- [ ] Booking history (profile tab)
- [ ] E-ticket generation (PDF)
- [ ] QR code for redemption
- [ ] Payment integration (Stripe / PayPal)
- [ ] Full booking flow testing

**Files to Create**:
- `lib/features/movie-detail/`
- `lib/features/ticketing/`
- `lib/features/payment/`

**New Dependencies**: `pdf`, `barcode`, `stripe_flutter`

---

### Phase 15: Community & Social Features
**Priority**: Low (Nice-to-have)  
**Estimated Duration**: 2+ sessions  
**Deliverables**:
- [ ] Review/rating submission
- [ ] User reviews on movie details
- [ ] Social sharing (Facebook, Twitter, WhatsApp)
- [ ] Watchlist / favorites
- [ ] Following other users
- [ ] Comment threads on reviews
- [ ] Real-time notifications

**New Dependencies**: `firebase_messaging`, sharing plugins

---

### Phase 16: Performance Optimization & Analytics
**Priority**: Medium  
**Estimated Duration**: 1 session  
**Deliverables**:
- [ ] Firebase Analytics integration
- [ ] Crash reporting (Crashlytics)
- [ ] Performance monitoring
- [ ] Image optimization (WebP, lazy load)
- [ ] Code splitting / lazy loading for routes
- [ ] Hive cache cleanup strategy
- [ ] Memory profiling & leak fixes

**Files to Create**:
- Analytics provider
- Crash logging service

**New Dependencies**: `firebase_analytics`, `firebase_crashlytics`

---

## Timeline Estimate (Post-MVP)

| Phase | Duration | Cumulative | Status |
|---|---|---|---|
| MVP (Phases 0–8) | ~8 sessions | 8 weeks | ✅ Complete |
| Phase 9 (Fonts + Light Theme) | 1 week | 9 weeks | 🔄 Planned |
| Phase 10 (Search) | 2 weeks | 11 weeks | 🔄 Planned |
| Phase 11 (Cinemas) | 2 weeks | 13 weeks | 🔄 Planned |
| Phase 12 (Real Backend) | 2 weeks | 15 weeks | 🔄 Planned |
| Phase 13 (Auth + Profile) | 3 weeks | 18 weeks | 🔄 Planned |
| Phase 14 (Ticketing) | 3 weeks | 21 weeks | 🔄 Planned |
| Phase 15 (Community) | 2+ weeks | 23+ weeks | 🔄 Planned |
| Phase 16 (Analytics + Optimization) | 1 week | 24+ weeks | 🔄 Planned |

**Target**: Full feature parity (Phases 0–14) by ~6 months post-MVP.

---

## Key Metrics & Success Criteria

### Home MVP (Phase 8) ✅
| Metric | Target | Status |
|---|---|---|
| Cold start | <2s | ✅ Pass |
| Warm start | <500ms | ✅ Pass |
| Code analysis | 0 issues | ✅ Pass |
| Test coverage (home) | >80% | ✅ Pass (>85%) |
| File size | All <200 LOC | ✅ Pass |
| Type safety | 100% null-safe | ✅ Pass |
| Banner rotation | 5s interval | ✅ Pass |
| UI mockup alignment | 100% | ✅ Pass |

### Post-MVP Goals (Phase 15+)
| Metric | Target | Timeline |
|---|---|---|
| App Store Release | Live | Phase 14 |
| Google Play Release | Live | Phase 14 |
| Web Demo Live | Yes | Phase 14 |
| DAU (Daily Active Users) | 10k+ | 6 months post-launch |
| Crash-free rate | 99.9%+ | Ongoing |
| Performance: TTI | <1.5s | Phase 16 |
| Code coverage (overall) | >80% | Phase 16 |

---

## Dependency Graph & Blockers

```
Phase 9 (Fonts) ──→ Phase 10 (Search) ──→ Phase 12 (Real API)
                        ↓
Phase 11 (Cinemas) ─────┘
                        ↓
Phase 12 (Real API) ──→ Phase 13 (Auth) ──→ Phase 14 (Ticketing)
                        ↓
Phase 15 (Community) ←──┘
                        ↓
Phase 16 (Analytics)
```

**No blockers for Phases 9–11 (can run in parallel)**  
**Phase 12 requires API credentials (external dependency)**  
**Phase 13 (Auth) is critical for Phase 14 (Ticketing)**

---

## Risk Register & Mitigation

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| Real API integration delays | Medium | High | Start Phase 12 early; maintain mock fallback |
| Design changes during development | Low | Medium | Design finalization before phase start; code review gates |
| Mobile platform fragmentation (iOS/Android) | Low | Medium | Comprehensive device testing in Phase 8+ |
| Performance degradation with features | Medium | Medium | Regular profiling; cache optimization per phase |
| Payment integration complexity | Medium | High | Start Phase 14 planning early; vendor support |
| User auth implementation bugs | Medium | High | Dedicated Phase 13 with security review |
| Community features scope creep | Medium | Medium | Clearly scope Phase 15; prioritize MVP first |

---

## Reference Documents

- **[docs/project-overview-pdr.md](project-overview-pdr.md)** — Requirements, constraints, assumptions
- **[docs/project-fsd.md](project-fsd.md)** — Functional specification (FR-HOME-001..005)
- **[docs/system-architecture.md](system-architecture.md)** — Architecture overview
- **[docs/code-standards.md](code-standards.md)** — Development standards
- **[plans/260527-1439-full-home-mvp/](../plans/260527-1439-full-home-mvp/)** — Phase details (0–7)
- **[plans/260527-1746-home-mockup-alignment/](../plans/260527-1746-home-mockup-alignment/)** — Phase 8 details

---

**End of Roadmap**

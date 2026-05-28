# ADF Cinema — Project Overview & PDR

**Project Name**: ADF Cinema — Home Screen MVP  
**Type**: Mobile App (MVP)  
**Version**: 1.0  
**Status**: Complete  
**Last Updated**: 2026-05-28

---

## 1. Vision & Problem Statement

### Vision
Build a **mobile-first movie discovery platform** that empowers Gen-Z users to explore trending cinema, discover new releases, and seamlessly book tickets — starting with a beautifully designed home screen MVP.

### Problem Statement
- **User Pain**: Movie discovery apps are cluttered, slow, and unintuitive for younger audiences
- **Market Gap**: No unified cinema ticketing platform with both entertainment discovery and seamless booking
- **Opportunity**: Mobile-first design + intelligent recommendations + real-time availability = market differentiation

### Target Users
- **Primary**: Gen-Z (18–25) cinema enthusiasts, tech-savvy, Instagram/TikTok native
- **Secondary**: Families seeking convenient movie booking without navigating multiple platforms
- **Tertiary**: Casual moviegoers who want trending content recommendations

---

## 2. Project Scope

### In Scope (MVP Phase)
| Component | Details | Status |
|---|---|---|
| **Home Screen** | Banner carousel (5s auto-rotate), 3 movie rails (Now Showing/Coming Soon/Recommended) | ✅ Done |
| **Bottom Navigation** | 5-tab shell (Home/Explore/Tickets/Saved/Profile) with per-tab back stacks | ✅ Done |
| **Mock Data** | Bundled JSON fixtures for banners, movies; served via HTTP contracts | ✅ Done |
| **Design System** | Material Design 3 dark theme, token-driven colors/spacing/typography | ✅ Done |
| **Caching** | Hive KV store with TTL envelope (Stale-While-Revalidate) | ✅ Done |
| **Testing** | Widget + unit tests for home feature, core network/storage, core navigation | ✅ Done |
| **Documentation** | FSD, architecture, code standards, design system reference | ✅ Done |

### Out of Scope (Post-MVP)
- Search feature (FR-SEARCH-001..003)
- Cinemas feature (FR-CINEMAS-001..002)
- Real backend APIs (IMDB, Ticketing)
- User authentication (login, registration, profile persistence)
- Payment integration
- Community / Social features
- Movie details screen + deep linking
- Light theme toggle
- Font asset bundling

---

## 3. Success Metrics

### Performance
| Metric | Target | Rationale |
|---|---|---|
| **Cold Start** | <2s (first fetch from API) | User tolerance for initial load |
| **Warm Start** | <500ms (cached data) | Smooth re-open experience |
| **Banner Rotation** | 5s interval | Optimal engagement without distraction |
| **API Response** | <1s (mock fixture) | Perceived instant load |

### Quality
| Metric | Target | Rationale |
|---|---|---|
| **Code Analysis** | 0 issues (flutter analyze) | Production-grade code quality |
| **Test Coverage** | >80% (home feature) | Regression prevention |
| **File Size** | All files <200 LOC | Maintainability + context limits |
| **Type Safety** | 100% null-safe Dart | No runtime type errors |

### User Experience
| Metric | Target | Rationale |
|---|---|---|
| **TTI (Time to Interactive)** | <2s | Immediate user interaction capability |
| **Jank Frames** | <5% (60 fps baseline) | Smooth scrolling + animations |
| **Empty/Error States** | Clear messaging + retry | User confidence in app stability |

---

## 4. Constraints & Dependencies

### Technical Constraints
| Constraint | Impact |
|---|---|
| **Mock-First Network** | All data from bundled JSON; real API integration deferred post-MVP |
| **Hive Local Cache** | TTL-based stale-while-revalidate; no cloud sync in MVP |
| **Dark Theme Only** | Light theme exists but not user-toggleable (MVP scope) |
| **Token-Driven Theming** | No hardcoded hex/sizes; all values sourced from design tokens |
| **File Size Cap** | <200 LOC per file; forces modularization + focus |
| **No Real Auth** | Mock endpoints are public; Recommended endpoint has no token requirement |

### Dependencies
| Dependency | Version | Purpose |
|---|---|---|
| Flutter | 3.10+ | Cross-platform mobile framework |
| Dart | 3.10+ | Language runtime + type system |
| Riverpod | 2.5 | Async-first state management (codegen) |
| go_router | 14 | Deep-link ready navigation (StatefulShellRoute) |
| Dio | 5 | HTTP client with interceptor support |
| Hive CE | 2.7 | KV local storage with TypeAdapters |
| Freezed | 2.5 | Data class + union type codegen |
| build_runner | 2.4 | Code generation orchestration |

---

## 5. Assumptions

1. **Mock data is sufficient for MVP**: Bundled JSON fixtures accurately represent real API responses (validated by FSD §4 contracts)
2. **Hive CE is production-ready**: Open-source KV store with TTL adequately replaces commercial caching solutions
3. **Riverpod codegen is stable**: No breaking changes in 2.5.x; async provider refactor not needed pre-release
4. **M3 dark theme resonates**: Gen-Z audience prefers dark UI (validated by design research; light theme can follow)
5. **Mocked network is undetectable**: Users cannot distinguish fixture responses from real API (latency/headers masked)
6. **Single-language support (English)**: Localization (intl) scaffolded but inactive; assume English-only MVP
7. **Platform parity**: iOS + Android shipping simultaneously with feature parity (no platform-specific branching)

---

## 6. Risks & Mitigation

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| **File size bloat** | Medium | Context overload + merge conflicts | <200 LOC rule enforced in code review; modularize early |
| **Cache staleness** | Low | Users see outdated movie lists | TTL + refresh-on-error pattern in SWR logic |
| **Fixture mismatch** | Low | Real API integrations break | API contracts locked in FSD §4; fixture validation test |
| **Theme token conflicts** | Medium | Color/spacing drift from design | Codegen `tool/gen_theme.dart` single source of truth |
| **Riverpod provider leaks** | Low | Memory leak in async notifiers | Test harness validates disposal; code review checks `.watch()` lifecycle |
| **Network timeout** | Medium | User stuck on loading spinner | TimeoutFailure mapped; UI shows "Failed to load, pull to refresh" |
| **Hive corruption** | Low | App crashes on box read | CacheEnvelope versioning + try-catch in LocalCache |
| **Quality gates misconfiguration** | Low | Gate rules block valid commits; false positives | Update `.quality-gates/config.yaml` scope exclusions as needed |

---

## 7. High-Level Architecture

**Layered (per-feature) + Shared Core**

```
┌─────────────────────────────────────────┐
│  Presentation (Widgets + Riverpod)      │
│  ├─ Screen (home_screen.dart)           │
│  ├─ Providers (banners, movies, etc.)   │
│  └─ Widgets (20+ focused components)    │
├─────────────────────────────────────────┤
│  Domain (Entities + Repository IF)      │
│  ├─ Entities (Banner, Movie)            │
│  └─ Repository (abstract HomeRepository)│
├─────────────────────────────────────────┤
│  Data (DTOs + Sources + Impl)           │
│  ├─ DTOs (BannerDto, MovieDto, etc.)    │
│  ├─ Remote Source (Dio + mock)          │
│  ├─ Local Source (Hive + cache policy)  │
│  └─ Repository Impl (HomeRepositoryImpl) │
├─────────────────────────────────────────┤
│  Core (Shared Infrastructure)           │
│  ├─ Network (DioClient + MockInterceptor│
│  ├─ Storage (Hive + LocalCache)         │
│  ├─ Errors (Failure sealed class)       │
│  └─ Theme (Design tokens + Material 3)  │
└─────────────────────────────────────────┘
```

See [docs/system-architecture.md](system-architecture.md) for detailed diagrams and data flow.

---

## 8. Key Decisions

| Decision | Rationale | Alternative Rejected |
|---|---|---|
| **Riverpod** for state mgmt | Compile-safe, async-first, no context | flutter_bloc (boilerplate), GetX (magic) |
| **Hive CE** for cache | KV + TypeAdapters + TTL semantics | SQLite (overkill), SharedPreferences (no TTL) |
| **Mock Interceptor** | Real HTTP contract testing + swap-ready | In-memory repo (breaks API contracts) |
| **Token-driven theming** | Single source of truth (design system) | Hardcoded theme (unmaintainable drift) |
| **Feature-sliced clean arch** | Right-sized for 5-tab app; easy to scale | Flat screens + services (collapses by tab #3) |
| **Material Design 3** | Industry standard, M3 design system exists | Custom theming (maintenance burden) |
| **go_router + StatefulShellRoute** | Per-tab back stacks + deep links | BottomNavigationBar (breaks nav state) |

---

## 9. Deliverables

| Deliverable | Status | Location |
|---|---|---|
| Home screen implementation (UI + logic) | ✅ Done | `lib/features/home/` |
| Bottom nav shell (5 tabs, routing) | ✅ Done | `lib/app/router.dart`, `lib/app/shell/` |
| Core network (Dio + MockInterceptor) | ✅ Done | `lib/core/network/` |
| Core storage (Hive + cache policy) | ✅ Done | `lib/core/storage/` |
| Design system (tokens + theming) | ✅ Done | `docs/design-system/`, `lib/core/theme/` |
| Test suite (widget + unit) | ✅ Done | `test/` |
| **Functional Specification (FSD)** | ✅ Done | `docs/project-fsd.md` |
| **High-Level Design (HLD)** | ✅ Done | `plans/reports/hld-home-mvp.md` |
| **Low-Level Design (LLD)** | ✅ Done | `docs/lld-home-mvp.md` |
| **Code Standards** | ✅ Done | `docs/code-standards.md` |
| **System Architecture** | ✅ Done | `docs/system-architecture.md` |
| **Codebase Summary** | ✅ Done | `docs/codebase-summary.md` |
| **Deployment Guide** | ✅ Done | `docs/deployment-guide.md` |
| **Project Roadmap** | ✅ Done | `docs/project-roadmap.md` |
| **Quality Gates Infrastructure** | ✅ Done | `.quality-gates/config.yaml`, `.quality-gates/gitleaks.toml` |

---

## 10. Success Criteria (Acceptance)

### Functional
- [x] Home screen displays 4 sections (banner, Now Showing, Coming Soon, Recommended)
- [x] Banner carousel auto-rotates every 5s
- [x] All sections load data from mocked `/api/v1/*` endpoints
- [x] Bottom nav shows 5 tabs; Home is wired; others show placeholders
- [x] Tap on movie navigates (logged, not yet detailed screen)
- [x] Pull-to-refresh triggers network fetch

### Non-Functional
- [x] Code analysis: 0 issues (`flutter analyze`)
- [x] Tests: >80% coverage for home feature, all tests passing
- [x] Performance: cached load <500ms
- [x] File sizes: all Dart files <200 LOC
- [x] Type safety: no runtime type errors
- [x] Accessibility: semantic widgets, readable contrast (M3 dark theme validated)

### Documentation
- [x] FSD complete with API contracts and data models
- [x] Architecture documented with diagrams and flow charts
- [x] Code standards codified (naming, layering, testing, codegen)
- [x] Design system reference with tokens + components
- [x] Deployment guide (build, test, run)
- [x] Roadmap with phase breakdown

---

## 11. Timeline & Phases

| Phase | Duration | Deliverable | Status |
|---|---|---|---|
| **Phase 0: Bootstrap** | Complete | Project setup, pubspec, git, Flutter config | ✅ Done |
| **Phase 1: Core Themes** | Complete | Design tokens, Material 3 theming codegen | ✅ Done |
| **Phase 2: Core Network** | Complete | Dio client, MockInterceptor, fixtures | ✅ Done |
| **Phase 3: Core Storage** | Complete | Hive + LocalCache + TTL policy | ✅ Done |
| **Phase 4: Home Data** | Complete | DTOs, entities, repository (Impl + IF) | ✅ Done |
| **Phase 5: Home Presentation** | Complete | Screen, providers, 20+ widgets | ✅ Done |
| **Phase 6: Router & Shell** | Complete | go_router, StatefulShellRoute, nav bar | ✅ Done |
| **Phase 7: Tests & Polish** | Complete | Unit + widget tests, code review, fixes | ✅ Done |
| **Phase 8: Mockup Alignment** | Complete | UI polish per design mockup, final QA | ✅ Done |
| **Phase 9+: Post-MVP** | Pending | Search, Cinemas, Auth, Real APIs | 🔄 Planned |

---

## 12. Glossary

| Term | Definition |
|---|---|
| **SWR** | Stale-While-Revalidate — return cached data while fetching fresh in background |
| **TTL** | Time To Live — cache expiration duration |
| **DTO** | Data Transfer Object — serializable data structure for network/storage |
| **Entity** | Domain model — business logic representation (independent of storage/network) |
| **Repository** | Data abstraction layer — hides remote/local sources behind clean interface |
| **Provider** | Riverpod construct — declarative async state with lifecycle management |
| **Failure** | Sealed error class — typed exception hierarchy (NetworkFailure, TimeoutFailure, etc.) |
| **Token** | Design system primitive — named color, spacing, typography value (codegen source) |
| **Mock Interceptor** | Dio interceptor — intercepts `/api/v1/*` requests and returns fixture responses |
| **Hive** | KV store — local persistence layer with TypeAdapter support |

---

## 13. Reference Documents

- **[docs/project-fsd.md](project-fsd.md)** — Detailed FR-HOME-001..005 with API contracts, data models, screen descriptions
- **[docs/system-architecture.md](system-architecture.md)** — Architecture diagrams, layering, data flow, Failure taxonomy
- **[docs/code-standards.md](code-standards.md)** — File naming, <200 LOC rule, layering, codegen, testing practices
- **[docs/codebase-summary.md](codebase-summary.md)** — File-by-file walkthrough of lib/ structure and responsibilities
- **[docs/deployment-guide.md](deployment-guide.md)** — Prerequisites, build commands, platform targets, troubleshooting
- **[docs/project-roadmap.md](project-roadmap.md)** — Post-MVP phases, upcoming features, timeline
- **[plans/reports/hld-home-mvp.md](../plans/reports/hld-home-mvp.md)** — High-level design rationale (architecture choices, constraints evaluation)
- **[docs/lld-home-mvp.md](lld-home-mvp.md)** — Detailed network/storage design (DioClient, MockInterceptor, HiveBootstrap)
- **[docs/design-system/](design-system/)** — Design tokens (colors, spacing, typography, motion), component catalog

---

**End of Document**

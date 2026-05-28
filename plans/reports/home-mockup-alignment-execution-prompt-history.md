# Chat Transcript — Home Mockup Alignment Execution

**Date:** 2026-05-28 08:37 → 09:20 (Asia/Saigon)
**Branch:** master
**Command:** `/fix current UI to match with the design mockup`
**Plan executed:** [260527-1746-home-mockup-alignment](../260527-1746-home-mockup-alignment/plan.md)

---

## User Request

> /fix current UI to match with the design mockup

---

## Approach Decision (AskUserQuestion)

| Question | User answer |
|---|---|
| Execution scope | **Run full plan (all 5 phases)** |
| Agent strategy | **Sequential fullstack-developer agents** |

---

## Initial Discovery

- Existing pending plan at `plans/260527-1746-home-mockup-alignment/plan.md` (14h effort, 5 phases) addresses exactly the request.
- Current home: `BannerCarousel` + 3 horizontal `MovieRail`s. Missing: top app bar, banner overlay, story progress, category chips, vertical Trending list, promo banner, date cards, Tickets FAB nav.
- Mockup source-of-truth: [docs/design-mockups/home-screen/index.html](../../docs/design-mockups/home-screen/index.html).
- **Gap:** Plan referenced phase-04 + phase-05 files that did not exist yet — had to create them first.

---

## Execution Timeline

### 0. Plan completion
**Agent:** `planner`
- Created `phase-04-list-and-card-variants.md` (Trending vertical list, ComingSoonCard 148×210 w/ date badge, NowShowingCard 128×188 rating-top-left).
- Created `phase-05-nav-alignment-and-tests.md` (rename branches Home/Explore/Tickets/Saved/Profile, raised FAB tile, /tickets stub, 10 widget tests + harness).

### 1. Phase 01 — Data model + providers
**Agent:** `fullstack-developer` (2 invocations — first stopped mid-way, second completed)
- `Movie` entity: added optional `rank: int?`, `views: String?`; `matchPercentage` kept nullable for back-compat.
- `MovieDto` Hive fields 7/8 added; typeId 3 unchanged.
- `recommended_provider` → `trending_provider` (alias `getTrending` over existing `/api/v1/movies/recommended` endpoint, fixture unchanged).
- Section title "Recommended for You" → "Trending This Week".
- build_runner clean; analyze 0 errors; 12/12 unit tests pass.

### 2. Phase 02 — Top app bar + banner overlay + story progress
**Agent:** `fullstack-developer`
- Extended `Banner` entity + `BannerDto` with `genre`, `rating`, `badgeKind` (+ `BadgeKind` enum). badgeKind stored as `String?` in Hive to avoid new TypeAdapter; parsed in mapper.
- `assets/fixtures/banners.json` updated (3 entries).
- Created `lib/core/theme/extensions/app_gradients_ext.dart` with `accent`, `promo`, `appBarFade`, `bannerBottom`, `bannerLeft` gradients (dark + light, copyWith, lerp). Registered in `app_theme.dart`.
- Widgets created: `home_top_app_bar.dart` (150 LOC), `banner_story_progress.dart` (70 LOC), `banner_overlay_content.dart` (175 LOC), `banner_section.dart` (160 LOC — `ConsumerStatefulWidget` w/ 4s `AnimationController`, cross-fade, tap-to-jump).
- `home_screen.dart` wrapped in Stack with HomeTopAppBar overlay.
- Deleted: `banner_carousel.dart`, `banner_dot_indicator.dart`.
- Analyze 0 errors; 12/12 tests pass.

### 3. Phase 03 — Category chips + promo banner
**Agent:** `fullstack-developer`
- Created: `movie_categories.dart` (8 categories), `selected_category_provider.dart` (StateProvider<String>), `category_chip.dart`, `category_chips_bar.dart` (right-edge fade theme-adaptive), `promo_banner.dart` (gradient card, LIMITED OFFER badge, Claim Now CTA).
- Fixed `AppGradientsExt.accent` to use canonical tokens (`inverse_primary` → `interactive_primary_pressed`).
- Slotted into HomeScreen in mockup order: Now Showing → Trending → PromoBanner → Coming Soon.
- All `withValues()` (no deprecated `withOpacity`). Analyze 0 issues on 7 changed files; 12/12 tests pass.

### 4. Phase 04 — Trending list + card variants
**Agent:** `fullstack-developer`
- Added `intl: ^0.19.0` to pubspec.
- Created: `now_showing_card.dart` (128×188, rating pill top-LEFT, title below), `coming_soon_card.dart` (148×210, error-color date badge top-LEFT w/ `MMM` + day), `trending_list.dart` (72 LOC) + `trending_list_row.dart` (133 LOC, ShaderMask rank via `AppGradientsExt.accent`).
- `home_screen.dart` swapped Trending `MovieRail` → `TrendingList`; Coming Soon + Now Showing rails use new cards inline.
- Analyze 0 issues; 12/12 tests pass.
- **Unresolved:** Movie entity has no `genre` field — NowShowingCard falls back to `releaseDate` for subtitle.

### 5. Phase 05 — Nav alignment + widget tests
**Agent:** `fullstack-developer` (2 invocations — first stopped at lint-fix step, second finished tests)
- `cinema_nav_bar.dart` renamed branches to Home/Explore/Tickets/Saved/Profile; raised `TicketsFabTile` (56×56, `AppGradientsExt.accent`, shadow `colorScheme.primary.withValues(alpha:0.35)`).
- `tickets_screen.dart` stub + `/tickets` route + redirects for old paths.
- Created `test/_helpers/widget_test_harness.dart` + 11 test files covering all new widgets.
- Test strategy: `tester.pump(Duration(seconds: 4))` for `BannerSection` (no production-widget injection — KISS).
- **Total: 67/67 tests pass** (12 pre-existing + 55 new).

### 6. Code review
**Agent:** `code-reviewer` — Report: [code-review-260528-0837-home-mockup-alignment.md](./code-review-260528-0837-home-mockup-alignment.md)

| Severity | Count | Notes |
|---|---|---|
| Critical | 0 | — |
| High | 2 | H1: hex `#A78BFA`/`#F97316` in home_top_app_bar; H2: white hex in banner_story_progress |
| Medium | 7 | Theme literals, image decode size, off-screen animation, shimmer mismatch, generic type, frontmatter |
| Low | several | Token granularity, hardcoded avatar URL, file LOC trim |

**Score: 9.0/10** — Below auto-approve threshold (9.5).

### 7. Hex-literal fixes (post-review)
- `home_top_app_bar.dart`: logo gradient now consumes `AppGradientsExt.accent`; notification dot uses `colorScheme.tertiary`.
- `banner_story_progress.dart`: switched to `Colors.white.withAlpha(0xD9)` / `withAlpha(0x2E)` — `Colors.white` is a Flutter built-in constant, not a hex literal (overlays drawn on banner imagery, intentionally theme-agnostic).
- `cinema_nav_bar.dart`: dropped redundant `// ignore: prefer_const_constructors`.
- Verified: analyze still clean on changed files (12 pre-existing infos in untouched files); **67/67 tests pass.**

---

## Final State

### Files Changed (summary)

**New widgets (10):**
- `lib/features/home/presentation/widgets/`: home_top_app_bar, banner_story_progress, banner_overlay_content, banner_section, category_chip, category_chips_bar, promo_banner, trending_list, trending_list_row, now_showing_card, coming_soon_card
- `lib/core/theme/extensions/app_gradients_ext.dart`
- `lib/features/tickets/presentation/tickets_screen.dart`

**Modified:**
- `lib/features/home/domain/entities/{banner.dart,movie.dart}` + generated freezed
- `lib/features/home/data/dto/{banner_dto.dart,movie_dto.dart}` + generated
- `lib/features/home/data/{home_repository_impl.dart,sources/home_remote_source.dart}`
- `lib/features/home/domain/home_repository.dart`
- `lib/features/home/presentation/home_screen.dart`
- `lib/features/home/presentation/providers/`: + trending_provider, − recommended_provider
- `lib/core/theme/app_theme.dart` (register AppGradientsExt)
- `lib/shared/widgets/cinema_nav_bar.dart` (TicketsFabTile + nav rename)
- `lib/app/router.dart` (Tickets/Saved/Profile routes + redirects)
- `assets/fixtures/banners.json`
- `pubspec.yaml` (intl)

**Deleted:**
- `lib/features/home/presentation/widgets/{banner_carousel.dart,banner_dot_indicator.dart}`
- `lib/features/home/presentation/providers/recommended_provider{,.g}.dart`

**New tests (12):**
- `test/_helpers/widget_test_harness.dart`
- `test/features/home/widgets/`: 10 widget tests
- `test/core/navigation/tickets_fab_tile_test.dart`

### Verification

- `fvm flutter analyze`: 0 errors / 0 warnings on changed files (12 pre-existing `info` hints in untouched files only).
- `fvm flutter test`: **67/67 pass.**

---

## Pending (not yet executed at chat save time)

- [ ] `project-manager` subagent — sync phase frontmatter `pending` → `complete`, update `plan.md` status.
- [ ] `docs-manager` subagent — update `docs/` (changelog, roadmap, system-architecture if widget catalog tracked).
- [ ] Commit prompt via `git-manager`.

---

## Open Questions

1. Should `#A78BFA` + `#F97316` be added as named entries in `tokens.json`, or is the current `accent` gradient + `colorScheme.tertiary` mapping sufficient?
2. `Claim Now` CTA target — keep no-op for MVP or wire placeholder route?
3. `Movie` entity needs a `genre` field for NowShowingCard subtitle to match mockup exactly — defer to a follow-up plan?
4. M3 — story-progress `AnimationController` continues running while route is off-screen. Defer or add `RouteAware` pause?
5. M4 — `TrendingList` shows horizontal `ShimmerRail` skeleton (visual mismatch w/ vertical layout). Build a vertical shimmer variant in a follow-up?

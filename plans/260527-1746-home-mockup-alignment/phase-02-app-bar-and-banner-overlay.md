---
phase: 02
title: Top App Bar + Banner Overlay + Story Progress
status: completed
effort: L
depends_on: [01]
---

# Phase 02 — Top App Bar + Banner Overlay + Story Progress

## Context Links
- Mockup: `docs/design-mockups/home-screen/index.html` lines 85–165 (header + banner overlay + progress bars)
- Tokens: `docs/design-system/tokens.json`
- Predecessor: `plans/260527-1439-full-home-mvp/phase-05-home-presentation.md`

## Overview
- **Priority:** P1
- **Status:** pending
- **Description:** Replace plain SafeArea+scroll with a layered Scaffold: (a) translucent overlapping top app bar with logo + wordmark + notifications bell + profile avatar, (b) banner stack that draws title/genre/rating/badge + Book Tickets/Trailer CTAs over the image, (c) story-style progress bars driven by a 4 s timer (replaces dot indicator).

## Key Insights
- App bar uses gradient `linear-gradient(180deg, surface 0%, surface@dd 70%, transparent 100%)`. Implement via `BoxDecoration(gradient: LinearGradient(...))` reading `colorScheme.surface` — no hex.
- Banner becomes a `Stack` with absolute-positioned overlays. Image still uses `CachedNetworkImage`; gradients (bottom-up + left-fade) drawn via `Container(decoration: BoxDecoration(gradient: ...))`.
- Story progress requires a per-banner `AnimationController` (4 s linear). Cleaner than the existing 5 s `Timer.periodic`. Replace `BannerCarousel` internal timer logic.
- App bar overlays banner — easiest layout is a `Stack` at HomeScreen root rather than a real `AppBar`. The banner reserves the top ~480 dp; the app bar floats on top with `IgnorePointer` regions for the gradient and `pointerEvents:none` semantics.
- Banner overlay needs `title`, `genre`, `rating`, `badge` — `domain.Banner` only has `id`, `imageUrl`, `targetUrl`, `title`. **Either** extend `Banner` entity with `genre`, `rating`, `badgeKind` (NowShowing / ComingSoon), **or** keep the entity lean and derive overlay text from a join to the linked Movie. **Decision:** extend `Banner` — banner is presentation-shaped already (FSD §4 banners endpoint returns these as separate fields per LLD).
- New gradient values for header bg + CTA "Book Tickets" use existing tokens: `primary_default` (#D0BCFF) + `primary_on` (#381E72). No new token needed for the *banner overlay* itself — but the FAB gradient in phase 05 will need an `AppGradientsExt`.

## Requirements
**Functional**
- Top app bar: 32×32 gradient square w/ "A" glyph + "ADF Cinema" wordmark; notifications bell button (with orange dot indicator); circular profile avatar (40×40, primary border)
- Banner shows: badge pill (NOW SHOWING / COMING SOON colour-varied), title (Poppins 28 bold), genre + star rating row, Book Tickets primary CTA (full-width-ish) + Trailer secondary outlined button with play icon
- Story progress bars: one per banner, 2 px tall, gap 4 px; active fills 0→100 % over 4 s then auto-advances; completed bars stay 100 %; tapping a bar jumps to that banner and resets its fill

**Non-Functional**
- No layout jank during banner transitions (opacity crossfade only, no `PageView` swipe — match mockup)
- Animation controllers properly disposed
- Files <200 LOC

## Architecture
```
HomeScreen (Stack)
  ├── CustomScrollView           // content
  │     ├── BannerSection         // NEW — replaces BannerCarousel
  │     │     ├── BannerImageLayer  (cross-fade)
  │     │     ├── BannerOverlayContent  (badge/title/genre/rating/CTAs)
  │     │     └── BannerStoryProgress   (top-positioned progress bars)
  │     └── (rest of sections)
  └── HomeTopAppBar              // NEW — overlays at top with fade gradient
```
- Banner data extended: `Banner { genre: String?, rating: double?, badgeKind: BadgeKind? }`. `BadgeKind` is a new enum in `domain/entities/banner.dart`.

## Related Code Files
**MODIFY**
- `lib/features/home/presentation/home_screen.dart` — wrap body in `Stack`; insert `HomeTopAppBar`; replace `BannerCarousel` with `BannerSection`
- `lib/features/home/domain/entities/banner.dart` — add `genre`, `rating`, `badgeKind` (+ `BadgeKind` enum) — all optional for backward compat
- `lib/features/home/data/dto/banner_dto.dart` — add matching `@HiveField(4) genre`, `@HiveField(5) rating`, `@HiveField(6) badgeKind`
- `assets/fixtures/banners.json` — add `genre`, `rating`, `badgeKind` per entry

**CREATE**
- `lib/features/home/presentation/widgets/home-top-app-bar.dart` — Stack-friendly translucent app bar (logo, bell, avatar). Renamed: `home_top_app_bar.dart` (kebab-case via underscores is Dart convention)
- `lib/features/home/presentation/widgets/banner_section.dart` — replaces `BannerCarousel`; orchestrates layers
- `lib/features/home/presentation/widgets/banner_overlay_content.dart` — badge + title + genre + rating + CTA row (under 200 LOC)
- `lib/features/home/presentation/widgets/banner_story_progress.dart` — animated progress bars
- `lib/core/theme/extensions/app_gradients_ext.dart` — `accent` (primary→A78BFA) + `appBarFade` gradients (consumed in phase 03 + 05)

**DELETE (after migration)**
- `lib/features/home/presentation/widgets/banner_carousel.dart`
- `lib/features/home/presentation/widgets/banner_dot_indicator.dart`

## Implementation Steps
1. Define `BadgeKind { nowShowing, comingSoon }` in `banner.dart`. Add `genre`, `rating`, `badgeKind` (nullable) to `Banner` + `BannerDto` + mapper.
2. Update `banners.json` fixture with `genre`, `rating`, `badgeKind` strings.
3. Run build_runner; verify `banner.freezed.dart` and `banner_dto.*.dart` regenerate. Hive `typeId 4` preserved.
4. Create `AppGradientsExt` with two gradients (`accent` placeholder for phase 03/05 + `appBarFade`). Register in `app_theme.dart` `ThemeData.extensions`.
5. Create `home_top_app_bar.dart`: Row of (logo+wordmark, Spacer, bell IconButton, profile CircleAvatar). Background = `appBarFade` gradient.
6. Create `banner_story_progress.dart`: takes `count`, `activeIndex`, `progress01` (0–1), `onTap(i)`. Renders Row of `Expanded(child: Container(... LinearProgressIndicator-like))`. No animation logic inside — parent drives.
7. Create `banner_overlay_content.dart`: stateless widget consuming a `Banner` + onBook + onTrailer callbacks. Lays out badge → title → (genre + rating row) → CTA row.
8. Create `banner_section.dart` (`ConsumerStatefulWidget`): single `AnimationController` (4 s linear), on completion advances `activeIndex` modulo `banners.length`. Manual tap on progress bar resets controller. Uses `AnimatedOpacity` for cross-fade between images.
9. In `home_screen.dart`: wrap `Scaffold.body` in `Stack`; `Positioned.fill` with CustomScrollView; `Positioned(top:0,left:0,right:0, child: HomeTopAppBar())`.
10. Remove old `banner_carousel.dart` + `banner_dot_indicator.dart` after the import switch.
11. `flutter analyze` clean; widget smoke test loads HomeScreen.

## Todo List
- [x] Extend `Banner` entity + DTO with overlay fields
- [x] Update banners fixture
- [x] Regenerate freezed/hive code
- [x] Add `AppGradientsExt` + register in theme
- [x] Build `HomeTopAppBar` widget
- [x] Build `BannerStoryProgress` widget
- [x] Build `BannerOverlayContent` widget
- [x] Build `BannerSection` widget (AnimationController-driven)
- [x] Wire into `HomeScreen` (Stack layering)
- [x] Delete old `BannerCarousel` + `BannerDotIndicator`
- [x] `flutter analyze` clean

## Success Criteria
- App bar visible at top with fade gradient blending into banner
- Banner shows live overlay text + working Book Tickets / Trailer CTAs (CTAs may be no-op in this phase)
- 4 s progress bar fills + auto-advances; tap-to-jump works
- All 4 banners cycle without leak (verify with `flutter test` rebuild + dispose check)

## Risk Assessment
- **AnimationController leak on hot-reload** — guard with `if (!mounted) return` after async waits; dispose in `dispose()`.
- **Cross-fade flicker** — pre-cache next image via `precacheImage` after first frame.
- **Hive backward compat** — new fields are nullable; existing cached payloads still load.

## Security Considerations
- Notification bell + avatar buttons currently no-op; ensure `Semantics(label: ...)` set so screen readers don't pick up dead targets.

## Next Steps
- Phase 03 (chips + promo) and phase 04 (cards + list) can start immediately after phase 01; phase 02 file ownership does NOT overlap with theirs.
- Phase 05 reuses `AppGradientsExt.accent` for the Tickets FAB.

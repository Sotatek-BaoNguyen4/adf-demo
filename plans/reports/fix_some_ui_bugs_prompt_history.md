# Chat — UI fixes: AppBar / Nav Bar / Movie Images / Overflow

**Date:** 2026-05-28 09:26 → 09:42 (Asia/Saigon)
**Branch:** master
**Scope:** Three rounds of `/fix` against the cinema home screen.

---

## Round 1 — `/fix`

**User requests:**
1. The appbar is overlap with banner
2. Use correct IMDb movie image
3. Overflow error in `coming_soon_card`

### Findings & fixes

**1. AppBar overlap**
- Root cause: `HomeTopAppBar.height = 86.0` was a hardcoded constant, but actual rendered height = `safeAreaTop + content (64)`. On notched iOS the bar reached ~111 px while `BannerStoryProgress` was `Positioned(top: 86)` → progress bars hidden behind the bell/avatar row.
- Fix:
  - [home_top_app_bar.dart:17](../../lib/features/home/presentation/widgets/home_top_app_bar.dart#L17) — `height` redefined as content-only `64.0`.
  - [banner_section.dart:116](../../lib/features/home/presentation/widgets/banner_section.dart#L116) — progress bars now positioned at `MediaQuery.paddingOf(context).top + HomeTopAppBar.height + SpacingTokens.s2`.

**2. IMDb movie images**
- Replaced random `picsum.photos` URLs across all four fixtures with TMDB CDN URLs (TMDB mirrors IMDb's image library).
- Files: [banners.json](../../assets/fixtures/banners.json), [now-showing.json](../../assets/fixtures/now-showing.json), [coming-soon.json](../../assets/fixtures/coming-soon.json), [recommended.json](../../assets/fixtures/recommended.json).

**3. Overflow in coming_soon_card**
- Root cause: SizedBox height `_comingSoonCardHeight + 52 = 262`; content (poster 210 + spacer 8 + 2-line title ~40 + 1-line subtitle ~16) ≈ 274.
- Fix:
  - [coming_soon_card.dart:79–108](../../lib/features/home/presentation/widgets/coming_soon_card.dart#L79-L108) — wrapped title+subtitle in `Flexible`; reduced title `maxLines: 1`.
  - [home_screen.dart:151](../../lib/features/home/presentation/home_screen.dart#L151) — rail height bumped `+52` → `+64`.

`flutter analyze` → clean.

---

## Round 2 — `/fix`

**User requests:**
1. The ticket button in nav bar drops too low (should overflow to TOP, outside the nav bar)
2. The image still not used correctly for movies

### Findings & fixes

**1. Tickets FAB drops too low**
- Root cause in [cinema_nav_bar.dart](../../lib/shared/widgets/cinema_nav_bar.dart):
  - `NavigationBar` had no height constraint → rendered at M3 intrinsic ~80 px, taller than design token `barHeight = 72`.
  - FAB at `bottom: fabLift = 12` ended up at y=12–68 → fully *inside* the 80-px bar.
- First fix attempted:
  - Constrained `NavigationBar` height to `barHeight`.
  - Replaced `fabLift` → `fabOverhang = TicketsFabTile.size / 2` (28).
  - FAB positioned at `bottom: barHeight - fabSize/2 = 44` (straddles top edge).

**2. Movie images still wrong**
- Verified all 10 TMDB URLs via `curl`. 3 returned 404:
  - The Martian poster `/AjuvyfkKHHGSPGfeAhHJTLDtfu7.jpg`
  - Dune backdrop `/87jJjTGtKfvk1eMP02JeBNgQ8c5.jpg`
  - The Martian backdrop `/nrtbv6Cew7qC7k9GsYSf5uRR1cN.jpg`
- Pulled correct paths via `WebFetch` against `themoviedb.org`:
  - Martian poster → `/73WiP7qwfrBWEcFsarDSe6S692q.jpg` ✓
  - Dune backdrop → `/eZ239CUp1d6OryZEBPnO2n87gMG.jpg` ✓
  - Martian backdrop → `/lzMS0CI3FLQYC5EgJoWeIaEt0lm.jpg` ✓
- All 10 URLs now return 200.

`flutter analyze` → clean.

---

## Round 3 — `/fix`

**User feedback:** After Round 2, FAB raises correctly, but:
- Other button backgrounds at top being cut
- Black band above the buttons makes the nav bar look big and cuts the UI below

### Findings & fixes

Three problems caused by Round 2's first fix:
1. **Icons cut top** — constraining `NavigationBar` to `72` squashed its 80-px M3 intrinsic, clipping icon/label tops.
2. **Black band** — `SizedBox(height: 72 + 28 = 100)` reserved 100 px in the bottom slot; only bottom 72 px held the bar; top 28 px showed Scaffold black.
3. **UI cut below** — 100-px slot ate body space.

Fix in [cinema_nav_bar.dart](../../lib/shared/widgets/cinema_nav_bar.dart):
- `barHeight` → `80.0` (matches M3 default).
- Removed `height: barHeight` constraint from `NavigationBar`.
- `SizedBox` height = `barHeight` only (no overhang reserved → no black band, body regains space).
- Kept `Stack(clipBehavior: Clip.none)`; FAB at `bottom: barHeight - fabSize/2 = 52` paints its top half OUTSIDE the SizedBox bounds → floats over body. Scaffold's bottom slot does not clip descendants.
- Reverted the brief `extendBody: true` change in [home_shell.dart](../../lib/app/shell/home_shell.dart) — not needed, would have hidden bottom content.

`flutter analyze` → clean.

---

## Files modified

| File | Rounds |
|------|--------|
| `lib/features/home/presentation/widgets/home_top_app_bar.dart` | R1 |
| `lib/features/home/presentation/widgets/banner_section.dart` | R1 |
| `lib/features/home/presentation/widgets/coming_soon_card.dart` | R1 |
| `lib/features/home/presentation/home_screen.dart` | R1 |
| `lib/shared/widgets/cinema_nav_bar.dart` | R2, R3 |
| `assets/fixtures/banners.json` | R1, R2 |
| `assets/fixtures/now-showing.json` | R1, R2 |
| `assets/fixtures/coming-soon.json` | R1 |
| `assets/fixtures/recommended.json` | R1 |

## Unresolved questions

- Movie titles are fictional sequels (Dune Part Three, Interstellar 2, …) mapped to real movie posters. If exact title/poster alignment matters, either rename the titles or source different posters.
- No visual regression on R3 has been confirmed on-device — relies on the assumption that Scaffold's `bottomNavigationBar` slot does not clip descendants (true in stock Material, but worth a runtime check).

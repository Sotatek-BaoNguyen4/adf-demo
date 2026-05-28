---
title: "Home Screen Mockup Alignment"
description: "Close visual + feature gaps between MVP Home screen and the design mockup (top bar, banner overlay, story progress, category chips, trending list, promo, date cards, nav)."
status: pending
priority: P1
effort: 14h
branch: master
tags: [flutter, home, ui, theme, design-alignment]
created: 2026-05-27
---

# Plan — Home Mockup Alignment

Brings the Flutter Home screen in line with the design source-of-truth: `docs/design-mockups/home-screen/index.html`. The predecessor plan [260527-1439-full-home-mvp](../260527-1439-full-home-mvp/plan.md) (phase-05) delivered the structural MVP — this plan layers the missing visual + behavioural details on top without rewriting the data layer.

## Source of Truth
- Mockup: [index.html](../../docs/design-mockups/home-screen/index.html)
- Tokens: [tokens.json](../../docs/design-system/tokens.json)
- Predecessor plan: [260527-1439-full-home-mvp/plan.md](../260527-1439-full-home-mvp/plan.md) (phase-05)
- LLD: [lld-home-mvp.md](../../docs/lld-home-mvp.md)
- FSD: [project-fsd.md](../../docs/project-fsd.md)

## Gap Recap (verified against current code)
1. No top app bar with logo/wordmark + notification bell + profile avatar (fade gradient bg)
2. Banner has no text overlay (badge / title / genre / rating / Book Tickets + Trailer CTAs)
3. Banner uses dot indicator instead of 4-second story-style progress bars
4. No category filter chips (All/Action/Sci-Fi/Drama/Horror/Animation/Comedy/Romance)
5. "Trending This Week" must be a **vertical list** with rank + thumb + rating + views (currently a horizontal "Recommended" rail with `matchPercentage`)
6. Missing promo banner ("Student Discount" with gradient + Claim Now CTA)
7. Coming-Soon card is 120×180 generic; mockup is 148×210 with date badge overlay
8. Now-Showing card has rating top-right + title overlaid; mockup puts rating top-LEFT and title BELOW poster (128×188)
9. Bottom nav labels mismatch mockup (Home/Explore/Tickets-FAB/Saved/Profile)

## Phases

| # | Phase | Status | Effort | Depends on |
|---|---|---|---|---|
| 01 | [Data model + provider extensions](./phase-01-data-model-and-providers.md) — `rank`/`views` on Movie, rename `recommended`→`trending`, fixtures, optional `releaseDate` carry-through | pending | M | — |
| 02 | [Top app bar + banner overlay + story progress](./phase-02-app-bar-and-banner-overlay.md) — new home shell layout, banner overlay widget, story progress bars | pending | L | 01 |
| 03 | [Category chips + promo banner](./phase-03-category-chips-and-promo-banner.md) — `CategoryChipsBar` widget + `PromoBanner` widget, slot into HomeScreen | pending | M | 01 |
| 04 | [Trending list + coming-soon date card + now-showing layout fix](./phase-04-list-and-card-variants.md) — `TrendingList`, `ComingSoonCard`, `NowShowingCard` (replaces generic `MovieCard` for these two sections) | pending | L | 01 |
| 05 | [Bottom-nav alignment + tests](./phase-05-nav-alignment-and-tests.md) — rename branches to Home/Explore/Tickets/Saved/Profile, raised FAB tile for Tickets, widget tests covering new sections | pending | M | 02, 03, 04 |

## Critical Path
01 → (02 + 03 + 04 in parallel; 02 owns banner files, 03 owns chips/promo, 04 owns card+list) → 05. Phase 02–04 are safe to parallelise because file ownership is disjoint per the lists in each phase file.

## Key Constraints
- **Theme only** — no hex literals in widgets. Any new color (e.g. gradient stops `#7C3AED→#A78BFA` / `#7C3AED→#06B6D4`) goes via `AppColorsExt` or a new `AppGradientsExt`. New token IDs are listed per-phase.
- **<200 LOC per file**, kebab-case.
- **No new endpoints** — repackage existing `recommended.json` as `trending.json` (extra fields: `rank`, `views`); reuse `now-showing` and `coming-soon` paths as-is.
- **Backwards compat** — keep `matchPercentage` nullable on `Movie` so older cache envelopes still deserialize.

## Risks
- Hive cache schema drift (new optional fields on `MovieDto`): mitigated by keeping new fields *optional* — no `typeId` bump needed.
- Gradient + ThemeExtension boilerplate: introduce `AppGradientsExt` once in phase 02, reuse in phase 03 + 04.
- Bottom-nav rename may break deep-link routes (`/community`, `/cinemas`): phase 05 handles redirects.

## Open Questions
- Confirm: should phase 05 actually align nav to mockup (Home/Explore/Tickets/Saved/Profile) or keep the current 5-branch shell? Plan assumes **align**.
- "Tickets" raised FAB target: mockup links to `movie-detail.html` — keep as placeholder route `/tickets` for now?
- Promo "Claim Now" CTA target: undefined in mockup — left as no-op for MVP.

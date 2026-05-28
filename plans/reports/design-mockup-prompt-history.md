# Session: Home Screen Mockup Design
**Date:** 2026-05-27 | **Branch:** master | **Project:** ADF Cinema

---

## Summary

Iterative design session creating and refining a mobile home screen mockup for the ADF Cinema app — Material Design 3, dark cinematic theme, youth-focused (Gen-Z 16–28).

---

## What Was Built

**File:** `docs/design-mockups/home-screen/index.html`
**Stack:** HTML + Alpine.js + Tailwind CSS (token-derived config)
**Design system:** `docs/design-system/tokens.json` — M3 dark cinematic, Electric Violet primary, Cyan accent

### Pages scaffolded
| File | Description |
|------|-------------|
| `index.html` | Home screen (fully implemented) |
| `movie-detail.html` | Movie detail (scaffolded) |
| `search.html` | Search/explore (scaffolded) |
| `profile.html` | User profile (scaffolded) |

---

## Home Screen Sections

1. **Status bar** — decorative iOS-style time + icons
2. **Top app bar** — fixed, gradient-fade, logo + notification bell + avatar
3. **Hero banner carousel** — 3 slides with crossfade, badge, title, genre/rating, Book + Trailer CTAs
4. **Story-style progress bars** — JS-driven fill (2px bars at top of banner)
5. **Category chips** — horizontal scroll, pill shape, gradient active state
6. **Now Showing** — horizontal card scroll with rating chip overlay
7. **Trending This Week** — ranked list rows with poster thumb
8. **Promo banner** — Student Discount gradient card
9. **Coming Soon** — horizontal card scroll with date badge
10. **Bottom navigation bar** — 5 tabs, center FAB-style Tickets button

---

## Iterations & Fixes

### Iteration 1 — Initial build
- Full home screen created with all sections
- Vertical pill carousel indicators on the right side
- Category chips with horizontal padding on outer wrapper

### Iteration 2 — Fix chip clipping + indicator position
- **Chip fix:** Moved horizontal padding inside the scroll container (`padding:0 16px`) so outer wrapper no longer clips chips
- **Indicator fix:** Removed vertical side pills; replaced with horizontal dots embedded in banner content between genre line and CTA buttons

### Iteration 3 — Modernize both components
- **Indicators → Story-style bars:** Thin 2px lines at top of banner (like Instagram Stories). Used CSS `progressFill` keyframe animation on active bar. *(Issue: animation didn't restart on Alpine DOM reuse)*
- **Chips → M3 Filter Chips:** 8px-radius rectangular chips, transparent inactive, `#4F378B` filled active, leading checkmark SVG, right-edge scroll fade gradient added

### Iteration 4 — Fix progress bar (animation restart) + chip scrollability
- **Progress bar root cause:** Alpine.js reuses DOM nodes in `x-for`, so CSS animation class never restarts when `activeBanner` changes
- **Fix:** Replaced CSS animation with JS-driven `progress` counter — `startProgress()` method resets `progress=0` and runs a 100ms interval (+2.5 per tick → 100 in 4s), then advances the slide. Clicking a bar also calls `startProgress()`
- **Chip root cause:** `overflow:hidden` on parent was clipping horizontal scroll
- **Fix:** Removed `overflow:hidden`; redesigned chips as full pills (`border-radius:9999px`), no border, gradient active (`#7C3AED→#A78BFA` + glow shadow), ghost inactive (`rgba(255,255,255,0.07)`). Added 44px trailing spacer + 56px right-edge fade with `pointer-events:none`

---

## Key Design Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Carousel indicator | Story-style bars at banner top | Modern (Instagram Stories / Snapchat pattern), shows temporal progress |
| Category chip shape | Full pill (9999px) | More playful/youthful vs rectangular M3 chips |
| Chip active state | Gradient fill + glow | Energetic, matches Gen-Z aesthetic, high contrast |
| Progress mechanism | JS interval (not CSS animation) | Alpine DOM reuse breaks CSS animation restart |
| Chip scroll | `overflow-x:auto`, no parent clip | Ensures chips never get cut; trailing spacer clears fade overlay |
| Bottom nav FAB | Center elevated Tickets button | M3 pattern for primary action, cinema context |

---

## Design Tokens Used

```
Primary:    #D0BCFF  (M3 primary)
Container:  #4F378B  (primary container)
Brand:      #7C3AED  (Electric Violet seed)
Secondary:  #67E8F9  (Cyan)
Tertiary:   #FDB97D  (Warm Orange)
Surface:    #0A0A0F / #13131A / #1A1A24
Text:       #E6E1E5 / #CAC4D0 / #938F99
Fonts:      Righteous (display), Poppins (heading), Inter (body)
```

---

## Files Changed

```
docs/design-mockups/home-screen/
├── index.html          — fully implemented home screen
├── mockup.json         — flow manifest (4 pages)
├── tailwind.config.js  — generated from design tokens
├── input.css           — @tailwind directives
└── output.css          — built CSS
```

---

## Unresolved / Next Steps

- [ ] Build remaining 3 pages: `movie-detail.html`, `search.html`, `profile.html`
- [ ] Build CSS: `bash .claude/skills/design-mockup-create/scripts/build-mockup-css.sh docs/design-mockups/home-screen/`
- [ ] Touch-test on real mobile device (390px viewport)
- [ ] Verify story bar progress animation timing feels right vs the 4s auto-advance

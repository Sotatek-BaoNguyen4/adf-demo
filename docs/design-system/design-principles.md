# ADF Cinema — Design Principles

**Style:** Dark Cinematic + Material Design 3 (Material You)
**Audience:** Youth / Gen-Z (16–28) | **Platform:** Flutter Mobile
**Spec:** https://m3.material.io

---

## 1. Core Philosophy

### Feel Like a Cinema, Not a Form
Every screen should evoke the excitement of movies — deep blacks, vivid violet tonal palette, dramatic M3 typography. UI should feel immersive, not administrative.

### Material You, Cinematic Soul
We adopt M3's color roles, shape scale, elevation system, and motion tokens — then layer our cinematic identity (violet palette, Poppins headings, glow effects) on top. M3 provides structure; cinema provides soul.

### Youth-First, Accessible Always
Optimized for Gen-Z habits (quick scans, tap gestures, short sessions) while respecting WCAG AA contrast and M3's 48dp touch target standard.

---

## 2. Color System (M3 Color Roles)

Material Design 3 uses **tonal color roles**, not flat hex values. Every UI element references a role, not a hardcoded color — enabling dynamic theming.

### Core Roles (Dark Scheme — Default)

| Role | Dark Value | Usage |
|------|-----------|-------|
| `primary` | `#D0BCFF` | Buttons, FABs, active nav indicator |
| `on-primary` | `#381E72` | Text/icons on primary color |
| `primary-container` | `#4F378B` | Chips, selected state backgrounds |
| `on-primary-container` | `#EADDFF` | Text on primary container |
| `secondary` | `#67E8F9` | Cyan — Coming Soon badge, secondary actions |
| `tertiary` | `#FDB97D` | Orange warmth — ratings, genre labels |
| `surface` | `#0A0A0F` | App background |
| `surface-container-low` | `#13131A` | Card backgrounds |
| `surface-container` | `#1A1A24` | Elevated cards |
| `on-surface` | `#E6E1E5` | Primary body text |
| `on-surface-variant` | `#CAC4D0` | Secondary text, icons |
| `outline` | `#938F99` | Input borders, dividers |
| `outline-variant` | `#49454F` | Subtle card edges |

### Tonal Elevation (M3 Dark Theme)
In dark theme, M3 uses **primary color overlay** on surfaces to indicate elevation — no heavy drop shadows.

| Level | dp | Overlay | Usage |
|-------|----|---------|-------|
| 0 | 0dp | 0% | Surface base |
| 1 | 1dp | 5% | Resting cards |
| 2 | 3dp | 8% | FAB, menus |
| 3 | 6dp | 11% | Navigation drawer, modal sheets |
| 4 | 8dp | 12% | Navigation bar |
| 5 | 12dp | 14% | Scrolled top app bar |

### Cinematic Extras (on top of M3)
- **Glow primary:** `box-shadow: 0 0 20px #D0BCFF40` — focused interactive elements
- **Cinematic gradient overlay:** `linear-gradient(180deg, transparent, #0A0A0F)` — on all movie poster images
- **Rating gold:** `#FBBF24` — star ratings exclusively

### Do's & Don'ts
- **Do** use M3 color roles (`primary`, `on-surface`, etc.) — never hardcode hex in widgets
- **Do** apply `primary-container` for selected/active chip backgrounds
- **Don't** use more than 3 color roles on one component
- **Don't** place `on-surface-variant` text on `surface-container-highest` — check contrast

---

## 3. Typography (M3 Type Scale)

M3 defines 5 levels × 3 sizes = 15 type styles. Map them to cinema UI patterns:

| M3 Style | Size | Weight | Flutter TextStyle | Usage |
|----------|------|--------|-------------------|-------|
| Display Large | 57px | 400 | `displayLarge` | Splash screen hero |
| Display Medium | 45px | 400 | `displayMedium` | Marketing banner text |
| Display Small | 36px | 400 | `displaySmall` | Section hero title |
| Headline Large | 32px | 700 | `headlineLarge` | Movie detail title |
| Headline Medium | 28px | 700 | `headlineMedium` | Screen titles |
| Headline Small | 24px | 600 | `headlineSmall` | Section headings |
| Title Large | 22px | 600 | `titleLarge` | Card titles, app bar |
| Title Medium | 16px | 500 | `titleMedium` | List item titles |
| Title Small | 14px | 500 | `titleSmall` | Chip labels |
| Body Large | 16px | 400 | `bodyLarge` | Primary body text |
| Body Medium | 14px | 400 | `bodyMedium` | Descriptions, metadata |
| Body Small | 12px | 400 | `bodySmall` | Captions, timestamps |
| Label Large | 14px | 500 | `labelLarge` | Button text |
| Label Medium | 12px | 500 | `labelMedium` | Badge text |
| Label Small | 11px | 500 | `labelSmall` | Overlines, status chips |

### Font Stack
- **Heading/Display:** Poppins (700–800) → Roboto fallback
- **Body/Labels:** Inter (400–500) → Roboto fallback
- **Marketing splash:** Righteous

### Rules
- Maximum 3 type styles visible at once per screen
- Movie card titles: `titleMedium` (Poppins 600) over image with cinematic overlay
- Section labels: `titleLarge` (Poppins 600), primary color

---

## 4. Shape System (M3 Shape Scale)

M3 uses rounded corners as a primary design signal. Shape communicates hierarchy and brand personality.

| Token | Value | M3 Name | Component Usage |
|-------|-------|---------|-----------------|
| `shape.extra-small` | 4dp | Extra Small | Tooltips, menus, text fields |
| `shape.small` | 8dp | Small | Buttons, icon buttons, FAB small |
| `shape.medium` | 12dp | Medium | Cards, date picker, alert dialogs |
| `shape.large` | 16dp | Large | Navigation drawer, bottom sheets (top) |
| `shape.extra-large` | 28dp | Extra Large | FAB, extended FAB, bottom sheets top edge |
| `shape.full` | 9999dp | Full | Badges, switches, search bar, sliders, chips |

### Rules
- **Never** mix shape categories on similar components (all cards same radius)
- Movie cards: `shape.medium` (12dp) — approachable, not sharp
- Buttons: `shape.full` (pill) — M3 filled button standard
- Bottom nav: `shape.extra-large` on top corners only

---

## 5. Spacing & Layout

### 8dp Grid (M3 Standard)
All spacing is multiples of **8dp** (primary) or **4dp** (fine-grained). Never use odd values like 7px or 13px.

| Use | Value |
|-----|-------|
| Screen horizontal padding | 16dp |
| Section vertical gap | 32dp |
| Card internal padding | 16dp |
| List item spacing | 8dp |
| Bottom nav height | 80dp (64dp bar + 16dp safe area) |
| Top app bar height | 64dp |

### Touch Targets (M3 48dp minimum)
M3 requires **48×48dp** minimum touch targets (upgraded from WCAG's 44px).

- All icon buttons: 48×48dp tappable area minimum
- Movie cards: full-card tap zone
- Bottom nav items: full-height tap zone

---

## 6. Motion (M3 Motion System)

M3 defines easing curves as **Emphasized**, **Standard**, **Decelerate**, **Accelerate**.

### Easing Curves
| Curve | Value | Use |
|-------|-------|-----|
| Emphasized | `cubic-bezier(0.2, 0, 0, 1.0)` | Hero transitions, FAB morph, page enter (500ms) |
| Standard | `cubic-bezier(0.2, 0, 0, 1.0)` | Most UI transitions (300ms) |
| Decelerate | `cubic-bezier(0, 0, 0, 1)` | Elements entering screen |
| Accelerate | `cubic-bezier(0.3, 0, 1, 1)` | Elements leaving screen |

### Duration Tokens (M3 Short → Long)
| Token | Duration | Usage |
|-------|----------|-------|
| `short-3` | 150ms | Ripple, icon swap, micro-interactions |
| `medium-1` | 250ms | FAB, card hover reveal |
| `medium-2` | 300ms | Dialogs, bottom sheets |
| `long-1` | 450ms | Page transitions (emphasized easing) |
| `long-2` | 500ms | Complex container transforms |
| `extra-long-4` | 1500ms | Skeleton shimmer loop |

### Accessibility
- Always check `prefers-reduced-motion` — disable all motion except instant fades
- Ripple effects are allowed under reduced motion (they're feedback, not decoration)

---

## 7. M3 Component Guidelines

### Filled Button (Primary CTA)
- Shape: `full` pill — M3 standard
- Color: `primary` background, `on-primary` text
- Elevation: Level 0 (no shadow) — M3 filled buttons are flat
- State layers: hover 8% overlay, pressed 12% overlay, focus 12% overlay

### Cards (M3 Elevated Card)
- Shape: `medium` (12dp)
- Elevation: Level 1 (1dp + 5% tonal overlay in dark)
- No border — elevation communicates separation

### Navigation Bar (M3 Bottom Nav)
- M3 NavigationBar — max 5 destinations
- Active indicator: pill shape behind icon (`primary-container` bg, `on-primary-container` icon)
- Label: always visible (M3 default)
- Height: 80dp

### Chips (Filter/Genre Chips)
- Shape: `full` (pill)
- Selected: `secondary-container` bg + `on-secondary-container` text
- Unselected: `surface-container-high` bg + `on-surface-variant` text

### FAB (Watch Now)
- Shape: `large` (16dp) or `extra-large` (28dp) for large FAB
- Color: `primary-container` bg, `on-primary-container` icon
- Elevation: Level 3 (6dp)

---

## 8. Anti-Patterns

| Avoid | Reason |
|-------|--------|
| Hardcoded hex in Flutter widgets | Breaks dynamic theming — use `Theme.of(context).colorScheme.primary` |
| Shadow-only elevation | M3 dark theme uses tonal overlay — shadows alone feel flat |
| Touch targets under 48dp | M3 standard (upgraded from 44px) |
| Linear easing | Feels mechanical — use M3 emphasized/standard curves |
| Emoji as UI icons | Inconsistent rendering — use Material Symbols or Lucide |
| More than 3 shape variants on one screen | Creates visual chaos |
| `surface-container-highest` text below 4.5:1 contrast | WCAG AA violation |
| Auto-play video with sound | Violates user expectation + drains battery |

# ADF Cinema — Component Catalog

**Platform:** Flutter | **Design System:** Material Design 3 (Material You)
**Updated:** 2026-05-28

> Inventory of **shipped** Flutter widgets in `lib/widgets/`. Planned components live in [plans/component-roadmap.md](../../plans/component-roadmap.md).
> All widgets use `Theme.of(context).colorScheme` and `Theme.of(context).textTheme` — never hardcode hex colors.

---

## Status Legend

| Status | Meaning |
|--------|---------|
| `stable` | Production-ready, API frozen |
| `beta` | Functional but API may change |
| `deprecated` | Scheduled for removal — see description for replacement |

---

## Components

| Component | Description | Status | Source |
|-----------|-------------|--------|--------|
| _No components shipped yet — see [component-roadmap.md](../../plans/component-roadmap.md)_ | | | |

---

## Maintenance

- Populate via `/design-system discover` after widgets ship under `lib/widgets/`
- Sort alphabetically by component name
- Keep descriptions ≤60 characters, no trailing period
- Don't document props/variants here — that's the widget's own docs
- When deprecating, include replacement in description (e.g. `Deprecated — use NewWidget instead`)

---

## Token Sources

- **Base tokens:** [tokens.json](./tokens.json)
- **Dark theme:** [themes/dark.json](./themes/dark.json)
- **Light theme:** [themes/light.json](./themes/light.json)
- **Principles:** [design-principles.md](./design-principles.md)

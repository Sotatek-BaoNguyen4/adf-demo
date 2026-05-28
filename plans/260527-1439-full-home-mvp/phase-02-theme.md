---
phase: 02
title: Theme codegen + core/theme
status: pending
priority: P0
effort: M
depends_on: [01]
---

# Phase 02 — Theme codegen + core/theme

## Context Links
- HLD §4.2, §7.4, §7.6 (theming, dark-only MVP)
- Design system: `docs/design-system/tokens.json`, `themes/dark.json`, `themes/light.json`
- Catalog: `docs/design-system/component-catalog.md` (ThemeData mapping at §"Flutter ThemeData Mapping")

## Overview
Build a tooling script that compiles `tokens.json` + theme overlays into Dart constants + `ThemeData` + custom `ThemeExtension`s. Zero hand-coded hex in widgets.

## Key Insights
- Token JSON is DTCG-shaped (`$value`, `$type`). Parse generically; emit typed Dart.
- Two outputs: **base tokens** (spacing, radius, typography, motion) and **per-theme color schemes** (dark + light).
- Light theme **emitted but unused** in MVP (`themeMode: ThemeMode.dark` hard-coded in router phase).
- ThemeExtensions cover non-M3 tokens (custom shape radii, motion curves, rating-gold).

## Requirements
**Functional**
- `dart tool/gen_theme.dart` reads tokens.json + themes/*.json, writes Dart files to `lib/core/theme/generated/`.
- `AppTheme.dark()` / `AppTheme.light()` return ready-to-use `ThemeData`.
- Custom `AppColorsExt` (rating-gold, badge-success) registered as `ThemeExtension`.
- Re-running codegen is idempotent.

**Non-functional**
- Generated files <200 LOC each (split per concern).
- `flutter analyze` clean on generated output.

## Architecture
```
tokens.json + dark.json/light.json
       │ (read at build time)
       ▼
  tool/gen_theme.dart  ──► lib/core/theme/generated/
                           ├── color_tokens.dart       # raw color refs by alias
                           ├── spacing_tokens.dart
                           ├── typography_tokens.dart
                           ├── radius_tokens.dart
                           └── motion_tokens.dart
                          lib/core/theme/
                           ├── app_theme.dart          # ThemeData builders (dark+light)
                           └── extensions/
                               ├── app_colors_ext.dart # rating-gold, success
                               └── app_shape_ext.dart  # extra-small..full radii
```

## Related Code Files
**Create**
- `tool/gen_theme.dart` (<200 LOC) — parser + emitter
- `lib/core/theme/app_theme.dart` (<120 LOC)
- `lib/core/theme/generated/color_tokens.dart` (gen)
- `lib/core/theme/generated/spacing_tokens.dart` (gen)
- `lib/core/theme/generated/typography_tokens.dart` (gen)
- `lib/core/theme/generated/radius_tokens.dart` (gen)
- `lib/core/theme/generated/motion_tokens.dart` (gen)
- `lib/core/theme/extensions/app_colors_ext.dart` (<60 LOC)
- `lib/core/theme/extensions/app_shape_ext.dart` (<60 LOC)

## Implementation Steps
1. Inspect `docs/design-system/tokens.json` and `themes/{dark,light}.json` to confirm DTCG shape.
2. Write `tool/gen_theme.dart`:
   - Use `dart:io` + `dart:convert` only (no external deps).
   - Resolve `{alias}` references (DTCG `{color.primary.default}` → hex).
   - Emit `color_tokens.dart` with `static const Color primaryDefault = Color(0xFF...);`
   - Emit spacing/typography/radius/motion as `const` maps or constants.
3. Write `app_theme.dart`:
   ```dart
   class AppTheme {
     static ThemeData dark() => _build(_DarkColors());
     static ThemeData light() => _build(_LightColors());
     static ThemeData _build(_SchemeSrc s) { /* ColorScheme + TextTheme + shape + ext */ }
   }
   ```
   - ColorScheme.fromSeed disabled — use explicit colors from tokens.
   - TextTheme: Poppins (display+heading), Inter (body+label), Righteous (display-large only). Use `google_fonts`? **No** — HLD doesn't list it; bundle local fonts via `pubspec.yaml.fonts:` (add as part of this phase).
   - Register `AppColorsExt` + `AppShapeExt` via `ThemeData.extensions`.
4. Add fonts to `pubspec.yaml` under `flutter.fonts:` — Poppins, Inter, Righteous (from `assets/fonts/`). Note: download .ttf files; commit to `assets/fonts/`.
5. Add codegen invocation note to README: `dart tool/gen_theme.dart` before `flutter run`.

## Todo List
- [ ] Inspect token JSON shape
- [ ] Write `tool/gen_theme.dart` parser
- [ ] Emit 5 generated token files
- [ ] Implement `AppTheme.dark/light`
- [ ] Define `AppColorsExt`, `AppShapeExt`
- [ ] Add fonts to pubspec + assets/fonts/
- [ ] Verify idempotency (run gen twice → no diff)
- [ ] `flutter analyze` clean

## Success Criteria
- `dart tool/gen_theme.dart` exits 0
- Generated files all <200 LOC
- `AppTheme.dark()` returns ThemeData without runtime errors
- All colors in generated files trace back to tokens.json
- No widget in MVP uses hex literals (enforce in code review)

## Risk Assessment
| Risk | Mitigation |
|---|---|
| DTCG alias resolution misses circular refs | First pass: collect aliases; second pass: resolve; error on unresolved |
| Font files not licensed for redistribution | Use Google Fonts SIL OFL versions (Poppins, Inter, Righteous all OFL); commit license |
| Codegen drift vs tokens.json | Pre-commit hook: `dart tool/gen_theme.dart && git diff --exit-code lib/core/theme/generated/` |

## Security Considerations
None.

## Next Steps
Unblocks phase 05 (presentation needs theme).

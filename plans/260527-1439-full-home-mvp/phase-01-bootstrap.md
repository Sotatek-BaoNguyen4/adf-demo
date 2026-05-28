---
phase: 01
title: Project bootstrap
status: completed
priority: P0
effort: S
depends_on: []
---

# Phase 01 — Project bootstrap

## Context Links
- HLD §4.2 (folder layout), §6 (deps)
- Project rule: `<200 LOC`, kebab-case

## Overview
Stand up the Flutter project skeleton: dependencies, folder structure, lints, build_runner. No business logic yet.

## Key Insights
- `pubspec.yaml` currently barebones; needs full dep set from HLD §6.
- `lib/` only has `main.dart` (default counter). Replace with minimal `runApp(MaterialApp(home: SizedBox()))` for now — real wiring lands in phase 06.
- `analysis_options.yaml` already present — extend with strict lints.

## Requirements
**Functional**
- Folder skeleton mirrors HLD §4.2 exactly.
- `pubspec.yaml` lists every dep + dev_dep from HLD §6 with pinned versions.
- `assets/fixtures/` directory created and registered under `flutter.assets`.
- `build_runner` runs clean (no warnings) on empty codebase.

**Non-functional**
- `flutter pub get` succeeds.
- `flutter analyze` clean.

## Architecture
N/A — scaffolding only.

## Related Code Files
**Create**
- `lib/app/` (empty dir + `.gitkeep`)
- `lib/core/{theme,network,storage,errors}/.gitkeep`
- `lib/features/home/{data,domain,presentation}/.gitkeep`
- `lib/shared/{widgets,utils}/.gitkeep`
- `assets/fixtures/.gitkeep`
- `tool/.gitkeep`
- `test/{unit,widget}/.gitkeep`

**Modify**
- `pubspec.yaml` — full deps + asset registration
- `analysis_options.yaml` — strict lints (prefer_const_constructors, avoid_print, require_trailing_commas, etc.)
- `lib/main.dart` — minimal stub: `void main() => runApp(const SizedBox());`

## Implementation Steps
1. Update `pubspec.yaml`:
   - Add dependencies block per HLD §6.
   - Add `flutter.assets: - assets/fixtures/`.
   - Bump `environment.sdk` to `^3.10.7` (already set).
2. Update `analysis_options.yaml`:
   ```yaml
   include: package:flutter_lints/flutter.yaml
   linter:
     rules:
       prefer_const_constructors: true
       prefer_const_literals_to_create_immutables: true
       avoid_print: true
       require_trailing_commas: true
       sort_pub_dependencies: true
   ```
3. Create directory skeleton (commit with `.gitkeep`).
4. Strip `main.dart` to placeholder app (real wiring in phase 06).
5. Run `flutter pub get`.
6. Run `dart run build_runner build --delete-conflicting-outputs` (no-op, but verifies setup).
7. Run `flutter analyze` → must be clean.

## Todo List
- [x] pubspec.yaml deps + assets
- [x] analysis_options.yaml lints
- [x] Folder skeleton + .gitkeep
- [x] main.dart stub
- [x] `flutter pub get` clean
- [x] `build_runner build` clean
- [x] `flutter analyze` clean

## Success Criteria
- `flutter pub get` exits 0
- `flutter analyze` reports 0 issues
- All directories from HLD §4.2 exist
- `dart run build_runner build` no errors

## Risk Assessment
| Risk | Mitigation |
|---|---|
| Pinned version conflict | Use HLD §6 versions verbatim; if conflict, pin to next compat patch |
| iOS Podfile not regenerated after deps added | Run `cd ios && pod install` after `pub get` |

## Security Considerations
None at this phase.

## Next Steps
Unblocks phase 02 (theme) and phase 03 (core network+storage) in parallel.

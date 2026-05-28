# Chat — Fix Safe Area & Broken Image Links

- Date: 2026-05-27 17:30 (Asia/Saigon)
- Branch: master
- Command: `/test and fix the safe area, error image link`

---

## User

> /test and fix the safe area, error image link

---

## Assistant — Investigation

Project is Flutter (cinema demo). Scoped to home feature.

Searched for relevant code:

- `lib/features/home/presentation/home_screen.dart` — Scaffold body had no `SafeArea` → banner sliding under status bar/notch.
- `lib/features/home/presentation/widgets/banner_carousel.dart` + `widgets/movie_card.dart` — both use `CachedNetworkImage` with proper `errorWidget`, so error handling already correct.
- `assets/fixtures/{banners,now-showing,coming-soon,recommended}.json` — every poster/banner URL pointed to fabricated `m.media-amazon.com/images/M/MV5B...` paths. None resolve → all images falling back to the `broken_image_outlined` placeholder.

Root cause of "error image link" was the fixture data itself, not the widget code.

---

## Fixes Applied

### 1. Safe area — `lib/features/home/presentation/home_screen.dart`

Wrapped body in `SafeArea(bottom: false, ...)`. Top-only because `HomeShell` `Scaffold` already handles the bottom inset via `bottomNavigationBar`.

```dart
return Scaffold(
  body: SafeArea(
    bottom: false,
    child: RefreshIndicator(
      onRefresh: () => _refreshAll(ref),
      child: CustomScrollView(
        slivers: [ ... ],
      ),
    ),
  ),
);
```

### 2. Broken image URLs — `assets/fixtures/*.json`

Replaced all 4 fixtures' fabricated Amazon URLs with deterministic `picsum.photos/seed/<id>/W/H`:

| File | Dimensions | Seed |
|------|------------|------|
| `banners.json` | 1200×675 (16:9) | `dune3`, `martian2`, `interstellar2` |
| `now-showing.json` | 400×600 (2:3 poster) | `m1`–`m4` |
| `coming-soon.json` | 400×600 | `m5`–`m7` |
| `recommended.json` | 400×600 | `m1`, `m3`, `m4` |

Seeded by id → same image every load → image cache hits work as expected.

---

## Validation

```
fvm flutter analyze lib/features/home/presentation/home_screen.dart
  → No issues found! (ran in 2.7s)

fvm flutter test
  → 12/12 passed (00:00 +12)
```

---

## Files Touched

- `lib/features/home/presentation/home_screen.dart`
- `assets/fixtures/banners.json`
- `assets/fixtures/now-showing.json`
- `assets/fixtures/coming-soon.json`
- `assets/fixtures/recommended.json`

## Unresolved Questions

- None.

# Code Review — Home Feature

**Date**: 2026-05-27
**Scope**: `lib/features/home/**`, `test/**`
**Spec**: `docs/lld-home-mvp.md`, `docs/project-fsd.md`, `docs/usecases/home/uc-home-001-home-banner.md`
**Total LOC reviewed (hand-written)**: ~1,105 across 25 files
**File-size rule (<200 LOC)**: ALL files comply (largest = `home_repository_impl.dart` @ 146)

Overall: implementation is faithful to the LLD on shape, layering, and Failure mapping. Several real correctness and spec-deviation bugs exist, plus one critical test gap.

---

## Critical

### C1 — `_mock_error=parse` fallout: malformed JSON is returned as `String`, never reaches DTO parser
**File**: `lib/core/network/mock_interceptor.dart:129-137` + `lib/features/home/data/sources/home_remote_source.dart:18-46`

The mock resolves with `data: '{not json'` and `statusCode: 200`. But `Dio.get<List<dynamic>>(...)` was called with an explicit type parameter. When the body is a `String`, Dio will not auto-decode JSON (the receiver type does not match), and `res.data as List` in `home_remote_source.dart:19` throws a **plain `TypeError`** — not a `FormatException`.

`HomeRepositoryImpl._mapException` (line 141) only checks `e is FormatException`; a `TypeError` falls through to `UnknownFailure`, not `ParseFailure` as the LLD §4.6 table requires.

```dart
// home_remote_source.dart:19
return (res.data as List)               // ← TypeError when data is String
    .map((j) => BannerDto.fromJson(j as Map<String, dynamic>))
    .toList();
```

**Why it matters**: LLD §4.6 promises `?_mock_error=parse → ParseFailure`. Today it becomes `UnknownFailure`, breaking the contract and the §9 unit test (`malformed body → ParseFailure`) when written.

**Fix**: In `mock_interceptor.dart` `_handleErrorInjection` case `'parse'`, return a malformed `List`-shaped body that survives the cast but fails JSON-shape validation, e.g. `data: [{'not': 'a movie'}]` — OR keep the string but parse on the repo side using `jsonDecode` so it throws `FormatException`. Cleaner: in remote source, do `final raw = res.data; if (raw is String) jsonDecode(raw);` to convert string-body cases to `FormatException` before the `as List` cast.

---

### C2 — `switch` cases in `_handleErrorInjection` fall through silently
**File**: `lib/core/network/mock_interceptor.dart:107-141`

```dart
switch (code) {
  case '500':
    handler.reject(...);     // no break, no return
  case 'timeout':
    handler.reject(...);
  case 'parse':
    handler.resolve(...);
  default:
    handler.next(options);
}
```

Dart 3 `switch` statements do **not** auto-fall-through at runtime (each case body executes only its own case), so this compiles — but it also means the function **returns without calling `return`** after rejecting. That's fine here BUT after `handler.reject` the function then continues and **`return`s normally with no further side effects**. However the original LLD/intent reads as a sequential decision tree. The bigger risk: when refactored, every reviewer will assume C-style fall-through and add `break`. Make intent explicit.

**Also**: the `'500'` path constructs a `DioException(type: badResponse)` with a `response.statusCode = 500`, but `error:` is not set. `DioException.toString()` will print `null` for error; unit test asserting cause should be aware.

**Fix**: Convert to `switch (code) { '500' => handler.reject(...), 'timeout' => ..., 'parse' => ..., _ => handler.next(options) }` expression OR add explicit `return;` after each `handler.*` call. The function is `void` returning so an early-return guard is cheap.

---

### C3 — Stale cache served on success of `_local.writeMovies` failure causes data loss + silent failure
**File**: `lib/features/home/data/home_repository_impl.dart:91-104`

```dart
try {
  final dtos = await fetch();
  await _local.writeMovies(key, dtos);         // ← may throw CacheWriteFailure
  return dtos.map((d) => d.toEntity()).toList();
} on Failure {
  rethrow;                                      // ← re-throws CacheWriteFailure to UI
} ...
```

If the network call succeeds but the cache write fails (disk full, corrupt box), the `CacheWriteFailure` is **rethrown** by `on Failure { rethrow; }` — so the user sees an error even though we have fresh data in memory. LLD §6 SWR algorithm says "fetch → cache → return"; a cache write failure should be logged-and-swallowed, not surface as `AsyncError` to the UI.

**Fix**: Wrap the `writeMovies`/`writeBanners` call in its own try/catch and swallow `CacheWriteFailure` (optionally log), then return the fresh entities. Same bug in `getBanners` lines 47-49.

---

### C4 — Test coverage: 0% (only `.gitkeep` in `test/`)
**Files**: `test/unit/.gitkeep`, `test/widget/.gitkeep`

Zero tests for the entire feature. LLD §9 demands 85% on `core/`; FSD requires `< 500ms` perf NFR. Both unverifiable.

**Minimum viable test list** (matches LLD §9 + UC):

| Tier | File | Cases |
|---|---|---|
| Repo | `home_repository_impl_test.dart` | (a) fresh cache hit → no remote call, (b) cache miss → remote + write, (c) stale + remote fail → stale fallback, (d) no cache + remote fail → throws Failure, (e) `forceRefresh: true` skips cache, (f) write failure does NOT surface (C3) |
| Mapper | `dto_mapper_test.dart` | `MovieDto.toEntity()` field-for-field; null rating; null releaseDate |
| Remote | `home_remote_source_test.dart` | each endpoint hits correct path; List<dynamic> decode |
| Widget | `home_screen_widget_test.dart` | loading shimmer renders; 3 rails + carousel render with mock providers; error state shows Retry button (`MOCK_DETERMINISTIC=true`) |
| Widget | `banner_carousel_test.dart` | empty list → SizedBox.shrink; auto-advance fires; manual swipe cancels + restarts timer (use `fake_async`) |
| Widget | `movie_rail_test.dart` | empty list → `EmptySectionView`; non-empty → N `MovieCard`s; error → `ErrorSectionView` |

Without these, regressions on C1/C3/I1/I2/I4 will all ship silently.

---

## Important

### I1 — `BannerCarousel` has no error UI (silently shows shimmer forever on failure)
**File**: `lib/features/home/presentation/widgets/banner_carousel.dart:82-84`

```dart
return async.when(
  loading: () => const ShimmerBanner(),
  error: (_, __) => const ShimmerBanner(),    // ← masks the failure
  data: ...
);
```

UC-HOME-001 EF-1 explicitly: "System displays a network error message or 'Failed to load content'". Returning `ShimmerBanner` on error means the user sees an infinite shimmer with no retry. Violates the use case.

**Fix**: On error, render `ErrorSectionView` (reuse the existing widget) with a retry that calls `ref.invalidate(bannersProvider)`. Or at minimum hide the carousel slot (`SizedBox.shrink()`) and let pull-to-refresh recover it.

---

### I2 — `bannersProvider` autorefresh timer keeps animating against stale data after retry race
**File**: `lib/features/home/presentation/widgets/banner_carousel.dart:57-67`

```dart
void _advance() {
  if (!_controller.hasClients) return;
  final banners = ref.read(bannersProvider).valueOrNull;
  ...
  final next = ((_currentPage + 1) % banners.length).toInt();
  _controller.animateToPage(next, ...);
}
```

When the user pulls-to-refresh, `bannersProvider` goes to `AsyncLoading`. During loading, `valueOrNull` returns the **previous** value (Riverpod retains last data) — fine. BUT if the list length **changes** between refreshes (5 → 3 banners), `_currentPage` may exceed new length until next `onPageChanged`. The `% banners.length` saves the `animateToPage` arg, but the *displayed* page (before timer fires) is still based on old `_currentPage` against the new `itemCount: banners.length` PageView, which Flutter clamps — may show an unexpected page jump.

**Fix**: After `onPageChanged`, clamp `_currentPage` to `banners.length - 1` defensively, OR reset `_currentPage = 0` whenever banner length changes via a `ref.listen(bannersProvider, ...)` in `initState`/`build`.

Also `_currentPage` is never reset on `bannersProvider` refresh, so length shrink → out-of-range index until next swipe.

---

### I3 — Carousel timer leaks via `Future.delayed` capture after dispose
**File**: `lib/features/home/presentation/widgets/banner_carousel.dart:72-76`

```dart
void _onPageChanged(int index) {
  setState(() => _currentPage = index);
  _cancelTimer();
  Future.delayed(_autoAdvance, () {
    if (mounted) _startTimer();           // ← `mounted` guard OK
  });
}
```

`mounted` check protects `_startTimer`, BUT if the widget is rebuilt many times during interaction, multiple pending `Future.delayed` instances accumulate. Each will check `mounted` and call `_startTimer()` → which calls `_cancelTimer()` first. Net effect is functional, but inefficient and racy: if two delayed callbacks fire in the same microtask, the second one wins, then the first one (already executed) is GC'd.

**Fix**: Use a single nullable `Timer? _restartTimer` (`Timer(_autoAdvance, _startTimer)`) and `_restartTimer?.cancel()` in `_cancelTimer()` and `dispose()`. Cleaner state, no zombie futures.

---

### I4 — Accessibility: zero `Semantics` on banner / movie card / dot indicator
**Files**: `banner_carousel.dart`, `movie_card.dart`, `banner_dot_indicator.dart`, `rating_badge.dart`

- `BannerCarousel _BannerPage` (line 114) renders a `CachedNetworkImage` of `banner.imageUrl` with **no semantic label**. Screen readers announce nothing — banner has a `title` field that's wasted.
- `MovieCard` (line 12) is tappable per design (FSD §2 "Movie card taps") but is NOT wrapped in `InkWell` / `GestureDetector` — also no `Semantics(label: movie.title)`.
- `BannerDotIndicator` has no announcement of "page X of N".
- `RatingBadge`: rating is shown visually only; no semantic.

**Why it matters**: project README/docs aren't shown but WCAG / a11y is universally required for app store submissions. Easy to fix and the cost of retrofitting later is high.

**Fix**: Wrap each image with `Semantics(label: banner.title, image: true, child: ...)`. Wrap `MovieCard` body with `Semantics(label: '${movie.title}${rating != null ? ', rated ${rating}' : ''}', button: true, child: ...)`. For dots: `Semantics(label: 'Banner ${currentIndex+1} of $count')`.

---

### I5 — `MovieCard` is not tappable — FSD §2 says it should be
**File**: `lib/features/home/presentation/widgets/movie_card.dart:25-99`

The card is a passive `SizedBox`/`Card`/`Stack`. FSD §2 Interactive Elements list includes "Movie card taps" and Screen Flow has `Tap Movie → Movie Details Screen`. No `onTap` plumbed.

**Fix**: Add `final VoidCallback? onTap;` to `MovieCard`, wrap in `InkWell(onTap: onTap, child: ...)`. Same for `BannerCarousel._BannerPage` — `banner.targetUrl` exists for a reason (deep-link) and is currently unused. Banner tap should navigate via `targetUrl`.

---

### I6 — `home_screen.dart` ignores `bannersProvider` ref.watch but its widget still consumes it
**File**: `lib/features/home/presentation/home_screen.dart:20-23`

`HomeScreen.build` only `ref.watch`s the 3 movie providers, not `bannersProvider`. `BannerCarousel` (a `ConsumerStatefulWidget`) does its own `ref.watch`. This is fine — but `_refreshAll` (line 64) calls `ref.refresh(bannersProvider.future)`, which works regardless.

The bug: `nowShowing`, `comingSoon`, `recommended` are bound to local vars but `bannersProvider` is not, so on a refresh the carousel reads via its own consumer. Not a defect per se, but the comment at line 14-15 ("Each section reads its own AsyncNotifier") is misleading because the movie rails *don't* — they go through `HomeScreen`. Inconsistent pattern.

**Fix (cosmetic)**: either make all four sections self-consuming (move `nowShowing` etc into `MovieRail` as a `ConsumerWidget`-wrapper) for symmetry with carousel, OR drop the `Banners` self-consume and lift it to `HomeScreen` like the others. Pick one. KISS: probably lift to `HomeScreen`.

---

### I7 — `ref.refresh(bannersProvider.future)` will throw inside `Future.wait` if any one fails
**File**: `lib/features/home/presentation/home_screen.dart:64-69`

```dart
await Future.wait([
  ref.refresh(bannersProvider.future),
  ref.refresh(nowShowingProvider.future),
  ...
]);
```

`Future.wait` rejects on **first** error — if banners 500's, the other 3 outcomes are discarded as errors-via-Future.wait-cancellation semantics (technically they still complete, but exceptions thrown by the wait propagate to RefreshIndicator). The `RefreshIndicator.onRefresh` Future will then complete with error, and Flutter prints a `Future error not caught` warning. The actual rail providers each updated their own AsyncValue correctly, so the UI is still OK — but the console will be noisy.

**Fix**: Use `Future.wait(..., eagerError: false)` and wrap each `ref.refresh().future` in a `.catchError((_) {})` since each provider already stores its own error state via Riverpod.

---

### I8 — `ListView.separated` builds movie items with no `key`
**File**: `lib/features/home/presentation/widgets/movie_rail.dart:58-67`

```dart
itemBuilder: (_, index) => MovieCard(movie: movies[index]),
```

No `ValueKey(movie.id)`. If the list reorders (rare here but possible after recommendations refresh), Flutter element-tree reuses widgets by position — risk: wrong poster shown for a frame, wrong rating badge animates from one card to another.

**Fix**: `MovieCard(key: ValueKey(movies[index].id), movie: movies[index])`. Same in `BannerCarousel` `PageView.builder` (line 96): `_BannerPage(key: ValueKey(banners[index].id), banner: banners[index])`.

---

### I9 — DTO `fromJson` will throw on missing required field; no fixture-shape validation
**File**: `lib/features/home/data/dto/movie_dto.dart` (generated `_$MovieDtoFromJson`)

`id`, `title`, `posterUrl` are `required` in `MovieDto`. Real backend or future fixture mistakes (typo, missing field) → `_$MovieDtoFromJson` throws `CheckedFromJsonException` (not a `FormatException`) → falls through to `UnknownFailure` (same bug class as C1).

**Fix**: In `_mapException`, also catch `CheckedFromJsonException` (from `json_annotation`) and map to `ParseFailure`. Or wrap fromJson with try/catch in remote source. Add a unit test that feeds a missing-id JSON.

---

## Nits

### N1 — `import '../../core/errors/failure.dart'` path is wrong (double-relative)
**File**: `lib/core/storage/local_cache.dart:8`

```dart
import '../../core/errors/failure.dart';
```

This file is **already** in `lib/core/storage/`; the path resolves to `lib/core/errors/failure.dart` only because `../..` goes up to `lib/`. Correct relative is `../errors/failure.dart`. Compiles either way, but reads confusingly. (Strictly speaking `lib/core/storage/local_cache.dart` is outside the home-feature review scope but it's the only file the home repo imports beyond `cache_policy`.)

---

### N2 — `_kKeyBanners` etc are private top-level consts in `home_repository_impl.dart` — duplicate of `mock_interceptor.dart` `_kFixtureMap` keys
**File**: `lib/features/home/data/home_repository_impl.dart:16-19` and `lib/core/network/mock_interceptor.dart:9-14`

Same path strings in two places. If FSD §4 path changes, both must update. Low risk, but DRY violation.

**Fix**: Hoist to `lib/core/network/api_paths.dart` and import in both. Tiny file, big consistency win.

---

### N3 — `movie_card.dart:39` — `memCacheWidth: cardWidth.toInt() * 2`
Hardcoded 2× for DPR. Acceptable, but `MediaQuery.devicePixelRatioOf(context)` is more correct. Not blocking.

---

### N4 — `banner_carousel.dart:73` — `Future.delayed(_autoAdvance, ...)` uses `_autoAdvance` (5s) as the "idle" period
LLD §UC AF-1 says "restarts the auto-rotation timer after 5 seconds of inactivity" — matches. But the auto-advance is **also** 5s. So after a manual swipe, the user effectively sees the new banner for 10s (5s idle + 5s advance) instead of 5s. Probably wrong intent; "5s of inactivity" usually means "wait 5s then resume the normal cadence", which this code does. Minor UX ambiguity.

---

### N5 — `dioProvider` is a plain `Provider`, not `autoDispose`
**File**: `lib/features/home/data/home_repository_provider.dart:13`

A `Dio` instance is moderately expensive. Keeping it cached for the app lifetime is correct — but the same `Dio` is held even if the user navigates away from Home permanently. Acceptable for MVP, just flag for later.

---

### N6 — `coming_soon_provider.dart` etc are identical except for the method name
**Files**: `now_showing_provider.dart`, `coming_soon_provider.dart`, `recommended_provider.dart`

Three nearly-identical 24-line providers. Riverpod codegen requires this duplication (each `@riverpod class` becomes a distinct provider). Not a real DRY violation under riverpod_generator — leave as-is. Flagging only because a future maintainer might over-engineer a "shared base".

---

### N7 — `mock_interceptor.dart:46-50` — unknown path forwards via `handler.next(options)`
LLD §4.3 says "forward `RequestInterceptorHandler.next` (lets Dio's default adapter 404 in dev)". In mock-only mode there is NO real backend, so an unknown path will actually attempt to hit `https://api.adf-cinema.local` (a fake host) and time out after 5s. The dev will think it's a network issue when it's actually a missing fixture map.

**Fix**: When `useMock=true`, reject with `FixtureMissingFailure` (after wrapping in DioException of type `unknown` or `badResponse 404`) so the dev sees a clear error within ~10ms, not 5s. The LLD wording is ambiguous — clarify with author.

---

### N8 — `RatingBadge` always uses gold for both icon and text
**File**: `lib/features/home/presentation/widgets/rating_badge.dart:32-38`

The numeric text uses `gold` (`ratingGold`) — combined with a `0.85` alpha surface background this could fail contrast on some themes. Worth a quick contrast check with `WCAGContrastRatio`. Low priority.

---

### N9 — `home_local_source.dart` is a pure pass-through (4 one-line methods)
The seam is for testability, but `LocalCache` is already mockable. Extra layer adds zero behaviour. YAGNI flag — acceptable if you write tests against `HomeLocalSource` to avoid mocking Hive directly. Otherwise delete.

---

## Spec Compliance Matrix

| LLD §  | Requirement | Status |
|---|---|---|
| §6 | `HomeRepository` interface | ✅ matches verbatim |
| §6 | SWR algorithm | ⚠ correct on read; **broken on cache-write-failure** (C3) |
| §3 | Failure mapping | ⚠ `FormatException` only — missing `CheckedFromJsonException`, `TypeError` (C1, I9) |
| §4.6 | `?_mock_error=parse → ParseFailure` | ❌ becomes `UnknownFailure` (C1) |
| §5.4 | Schema mismatch → silent delete | ✅ implemented in `LocalCache` |
| §5.6 | Cache key = endpoint path | ✅ |
| §6 stale-fallback | Serve stale on network failure | ✅ correct |
| FSD §6 BR-001 | Auto-rotate 5s | ✅ |
| FSD §6 BR-002 | Cache local | ✅ |
| FSD §2 / UC EF-1 | Error message + Retry button | ⚠ rails yes; **banner no** (I1) |
| FSD §2 / UC EF-2 | Empty placeholder | ✅ rails; banner returns `SizedBox.shrink` (acceptable) |
| FSD §2 Interactive | Movie card taps | ❌ not wired (I5) |
| FSD §2 Interactive | Banner taps | ❌ `targetUrl` unused (I5) |
| File <200 LOC | All files | ✅ max 146 |

---

## Positive Observations

- Clean layer separation; data/domain/presentation boundaries respected; no domain → data leakage.
- `Failure` mapping centralised in repo, exactly per LLD §3.
- `kReleaseMode`-aware `Failure.toString()` redaction is a nice security touch.
- DTO + entity split with `toEntity()` extension is idiomatic and DRY.
- Shimmer placeholders match real widget dimensions (`ShimmerMovieCard` ↔ `MovieCard`, `ShimmerBanner.aspectRatio`).
- All widgets are `const`-correct where possible; theme tokens used throughout (no hex literals spotted).
- `BannerCarousel` correctly disposes both timer and controller.
- Schema-version envelope honoured with silent-delete on mismatch.

---

## Recommended Actions (priority order)

1. **Fix C1** (parse-injection → ParseFailure) — straightforward, breaks the error-injection contract.
2. **Fix C3** (cache-write failure surfaces as UI error) — silent regression hiding under happy path.
3. **Write the test suite in C4** — without it none of the above fixes are verifiable. Start with `home_repository_impl_test.dart` (highest ROI).
4. **Fix I1** (banner error state) — UC violation, user-visible.
5. **Fix I5** (movie/banner tap handlers) — wires FSD §3 navigation.
6. **Fix I4** (semantics) — required for accessibility audits.
7. C2, I2, I3, I7-9, then nits.

---

## Unresolved Questions

1. LLD §4.3 says unknown paths `handler.next(options)` — but in mock-only mode this hits a fake host. Should unknown paths reject as `FixtureMissingFailure` instead? (See N7.) Author intent unclear.
2. Banner tap target: should it navigate via `Navigator` using `banner.targetUrl` scheme (`adf://movie/m1`), or open a WebView for non-`adf://` schemes? FSD §3 says "Banner Details/WebView" — ambiguous.
3. Should `recommended` endpoint enforce 401 handling? FSD §4 marks it `Auth: Required` but LLD §4.3 says "bypass" in mock mode. Currently no auth wiring at all — flagged for backlog or explicit decision.
4. `bannersProvider` does its own consume inside `BannerCarousel`; `MovieRail` is dumb and receives `AsyncValue` from `HomeScreen`. Pick one pattern (see I6).
5. `MovieDto.matchPercentage` is `int` but `recommended` fixture uses what? Worth verifying that fixture matches DTO shape (link to N9 / test gap).

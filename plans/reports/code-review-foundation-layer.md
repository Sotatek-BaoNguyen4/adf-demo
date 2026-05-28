# Code Review — Foundation Layer (Fresh Project)

**Date:** 2026-05-27
**Reviewer:** code-reviewer
**Scope:** `lib/main.dart`, `lib/app/**`, `lib/core/**`, `lib/shared/**`, `lib/hive_registrar.g.dart`, `pubspec.yaml`, `analysis_options.yaml`
**Excluded:** `lib/features/**`
**Files reviewed:** 26 (1,672 LOC total; all individual files ≤ 200 LOC ✓)

---

## Critical

### C1. `mock_interceptor.dart:107-141` — Switch statement falls through; all error-injection paths invoke multiple terminal handler methods

```dart
switch (code) {
  case '500':
    handler.reject(DioException(...), true);   // no break/return
  case 'timeout':
    handler.reject(DioException(...), true);   // no break/return
  case 'parse':
    handler.resolve(Response(...));            // no break/return
  default:
    handler.next(options);
}
```

Dart 3 disallows non-empty case bodies without `break`/`return`/`throw`/`continue`. This is either:
1. A static error (`case_block_not_terminated`) that prevents compilation, or
2. If linter is lenient on this rule in this SDK + analysis profile, it falls through executing every subsequent branch — meaning a `?_mock_error=500` request triggers `reject(...)`, then `reject(...)` again for timeout, then `resolve(...)`, then `next(options)`. Dio prohibits calling more than one terminal method per request — this throws or silently corrupts the response.

**Fix:** add `return;` after each terminal call:
```dart
case '500':
  handler.reject(DioException(...), true);
  return;
case 'timeout':
  ...
  return;
```
Or switch to a switch-**expression** that yields `void` (less idiomatic here). Equally important: **no unit test exercises this method**, otherwise it would have failed immediately. LLD §10.1 line 520 mandates `_mock_error=500/timeout/parse` test coverage — currently fictional.

**Why it matters:** error-injection is the *only* way the app exercises non-happy paths in MVP. Broken here means error UI (Phase 06+) ships untested or never runs.

---

### C2. `hive_bootstrap.dart:74` — Corrupt-box fallback opens an in-memory box that will silently throw on subsequent writes

```dart
return await Hive.openBox<T>(name, bytes: Uint8List(0));
```

`Hive.openBox(..., bytes: ...)` in hive_ce opens a **read-only** in-memory box backed by the supplied bytes buffer; calling `.put()`/`.delete()` raises `HiveError` ("Cannot write to a box opened with bytes"). The LLD §5.5 intent ("data loss acceptable") implies a writable memory box — this implementation gives a writable-once buffer that fails on the first write, so every subsequent cache write throws `CacheWriteFailure`. Cache becomes permanently broken until process restart.

Hive CE does not currently expose a true "memory-only mutable box" primitive. Two acceptable fixes:
- **(KISS)** Catch the retry-failure, log loudly, and **rethrow** — let the app surface the cache as unavailable rather than fake-succeed.
- **(Better)** Wrap `LocalCache` writes/reads in an `if (_box.isOpen && !_box.isEmpty || writableMemoryBoxOk)` guard with a `_degradedMode` flag; in degraded mode, no-op writes and return null on reads.

Current code is worse than throwing because the failure surface migrates from bootstrap (recoverable) to deep inside every cache call site.

---

### C3. `main.dart:15-18` & `home_repository_provider.dart:23` — Box type mismatch will throw a `CastError` at first read/write

```dart
// main.dart
final localCache = LocalCache(
  Hive.box<dynamic>('movies_cache'),    // Box<dynamic>
  Hive.box<dynamic>('banners_cache'),
);
```

`Hive.box<dynamic>(...)` only succeeds if the box was *opened* as `Box<dynamic>`. `hive_bootstrap.dart:51-53` opens it with `_openBoxSafe<dynamic>(_kMoviesBox)` — so type alignment holds. However `LocalCache` then does:

```dart
final env = raw as CachedMoviesEnvelope;
```

`raw` is `dynamic` (the box value type). If Hive returns the **wrong adapter's** decoded value (e.g. cross-box read with a typeId collision), `as CachedMoviesEnvelope` throws `_TypeError` at runtime, not `HiveError`, so the `on HiveError catch` clause **does not catch it**. The exception escapes `readMovies`, propagates as an uncaught async error, breaks the repository, and is not converted to `Failure`.

**Fix:** broaden catch:
```dart
} on HiveError catch (e) {
  throw CacheReadFailure(...);
} catch (e) {
  // Corrupted entry of wrong type — treat as cache miss and evict.
  await _moviesBox.delete(key);
  return null;
}
```

Same issue applies to `readBanners` (line 81-98).

---

### C4. `local_cache.dart:24` & `main.dart:15` — Provider/box wiring contract is fragile and untyped

`localCacheProvider` defaults to throwing if not overridden (good), but `main.dart` constructs `LocalCache` by **directly** calling `Hive.box<dynamic>(name)` — a global lookup that bypasses `bootstrapHive`'s return value. If a future refactor changes the box name in `hive_bootstrap.dart` (`_kMoviesBox`) without changing `main.dart`, `Hive.box(...)` throws `HiveError: box not found` *after* runApp, post-frame, in an opaque place.

The constants `_kMoviesBox` and `_kBannersBox` are private to bootstrap — `main.dart` re-hardcodes the strings. **DRY violation with high blast radius.**

**Fix:** have `bootstrapHive()` return the opened boxes (or a record), and pass them into `main`'s `LocalCache` constructor. Example:
```dart
final (movies, banners) = await bootstrapHive();
final localCache = LocalCache(movies, banners);
```
Or expose box names as `const` in a shared location.

---

## Important

### I1. `dio_client.dart:21` — `bool mock = NetworkConfig.useMock` default is not `const`-evaluable in some Dart versions but works here; however the parameter is misleading

Static method defaults must be const; `NetworkConfig.useMock` is `const`-derived from `bool.fromEnvironment`, so this compiles. Fine. But the **real** problem is that `MockInterceptor()` is also the only acceptable error path — there's no way for callers to inject a custom interceptor (e.g. test doubles wanting deterministic data). Provider in Phase 06+ will need to wrap or replace. Either:
- Accept `MockInterceptor? mockInterceptor` and default-construct only when null and `mock == true`.
- Or document that tests should pass `mock: false` and wire fixtures separately.

### I2. `mock_interceptor.dart:33-35` — `Random()` per-instance is fine, but error-injection sequence is fully untested

`_kDeterministic` controls latency randomness only; error-injection itself is deterministic. OK as-is, but combined with C1 means **zero test coverage** on error paths. Mention here for traceability — flag this when Phase 03 tests land.

### I3. `mock_interceptor.dart:98` — Latency calculation `nextInt(maxMs - minMs + 1)` will throw if max < min

`minMs = 120`, `maxMs = 320` — fine for current constants. Defensive: assert `maxMs >= minMs` in `NetworkConfig`, or clamp. If anyone tweaks `mockMaxLatency` below `mockMinLatency`, this throws `RangeError` deep inside the request lifecycle and gets swallowed as a Dio error.

### I4. `failure.dart:19-26` — `toString` exposes `cause` in debug but not release — good, BUT `cause` may include sensitive tokens (auth headers, query params) when `cause` is a `DioException`

`DioException.toString()` prints the full request URL with query string. When error-injection params like `_mock_error=parse` are in the URL, they leak into logs. In MVP this is harmless; once auth tokens or PII reach query strings, this `cause: $cause` in debug mode logs them to `print` (via `log()`) and crash reporters. **Add a TODO comment** at line 22 noting this assumption holds only for the MVP fixture surface.

### I5. `hive_bootstrap.dart:6-10` — Foundation layer imports `features/home/data/dto/*` — layering violation

```dart
import '../../features/home/data/dto/banner_dto.dart';
import '../../features/home/data/dto/cached_banners_envelope.dart';
import '../../features/home/data/dto/cached_movies_envelope.dart';
import '../../features/home/data/dto/movie_dto.dart';
```

`core/storage/` is a foundation primitive but knows about a feature's DTOs to register their adapters at startup. Same issue in `local_cache.dart:3-6`. Two structural problems:

1. Adding a new feature now requires editing `core/storage/hive_bootstrap.dart` — features depend on core (correct) AND core depends on features (incorrect inversion).
2. `hive_registrar.g.dart` already centralises adapter registration via the `HiveRegistrar` extension — **but `bootstrapHive` does not use it**. Hand-rolled `if (!isAdapterRegistered(N)) registerAdapter(...)` duplicates the generated extension. DRY violation.

**Fix:** use the generated extension:
```dart
import '../../hive_registrar.g.dart';
...
Hive.registerAdapters();   // generated extension; idempotent? — verify
```
If `registerAdapters()` is not idempotent (re-registering throws), wrap in try/catch or check `isAdapterRegistered` on a single canonical typeId before calling. Either way, the feature import list belongs at the call site of the generated registrar, not in `core/`.

Also: `LocalCache.readMovies`/`readBanners` return `CachedMoviesEnvelope`/`CachedBannersEnvelope` (feature DTOs) — the **API of a core class** uses feature types. Sealing this requires either moving the envelopes to core (and parameterising payload externally) or moving the cache into the feature layer. Acknowledge as architectural debt; do not block MVP.

### I6. `mock_fixture_loader.dart:17, 30-32` — In-memory cache is unbounded and never invalidated

`_cache` grows with each unique asset path, never evicts. For 4 fixtures this is ~10 KB total — fine for MVP. **But:** the loader is an injectable singleton shared across the entire `MockInterceptor` instance, which is global. If fixtures grow (regional variants, per-cinema lists), this leaks. Add a TODO and document max-entries assumption. KISS does not mean unbounded.

Also: `_cache[assetPath] = decoded` on line 56 stores the **decoded JSON object** — if any caller mutates the returned `Map`/`List`, the cache is polluted for the next reader. Either return a deep-clone, freeze with `UnmodifiableMapView`, or document the no-mutation contract. Given DTOs go through `fromJson` and don't mutate, current state is safe — but document the invariant.

### I7. `cache_envelope.dart` — Generic `CacheEnvelope<T>` exists but is never instantiated; only `CachedMoviesEnvelope`/`CachedBannersEnvelope` (feature concretes) are used

This is the LLD's intended pattern (§5.2 — Hive CE adapters require concrete types), but the generic class in core is then **dead code**: never constructed, never extended (concretes don't extend it — they're separate `@HiveType` classes). Either:
- Make concretes extend `CacheEnvelope<List<MovieDto>>` (probably blocks codegen).
- Or delete `core/storage/cache_envelope.dart` and move the doc comment into a `core/storage/README.md` explaining the typeId reservation table.

YAGNI: a class that exists only as documentation is misleading. Confirm via grep — no `new CacheEnvelope(`, no `extends CacheEnvelope` anywhere.

### I8. `cache_policy.dart:8` — `kSchemaVersion` is top-level, declared inside `core/storage/cache_policy.dart`

Importers (`local_cache.dart`) access it directly through that path. Conceptually it belongs on `CacheEnvelope` (e.g. `CacheEnvelope.currentSchemaVersion`) or in a dedicated `schema_version.dart`. Coupling schema version to "policy" (TTL) is incidental. Minor — flag for refactor when next entity lands.

### I9. `app_theme.dart:75-81` — `cardTheme` is the only widget theme set; partial M3 surface

The other widget themes (AppBarTheme, NavigationBarTheme, ChipTheme, TextButtonTheme, FilledButtonTheme, etc.) are absent. Material 3 defaults are mostly correct, but **NavigationBar** in particular relies on `ColorScheme.surface` for background — yet `cinema_nav_bar.dart:26` overrides this with `appColors.navBackground`. Inconsistent: card uses theme defaults, nav uses extension. Pick one pattern.

### I10. `app/router.dart:18` — Top-level `final GoRouter appRouter = GoRouter(...)` initialises at library load

This is a global mutable singleton initialised eagerly. Problems:
1. Cannot be reset in tests (no provider, no factory).
2. Listening providers (auth state, deep-link state) cannot inject into the router config.
3. Hot-restart edge cases sometimes leave stale routes.

For MVP scope (no auth-gated routes), the eager singleton is acceptable. **Add a TODO** at line 18 noting Phase 06+ will need a Riverpod provider for the router when auth lands. Currently `appRouter` is `final` so cannot be replaced.

### I11. `dio_client.dart:48-50` — `MockInterceptor()` is constructed without an injected `MockFixtureLoader`

```dart
if (mock) {
  dio.interceptors.add(MockInterceptor());
}
```

This means the fixture-loader cache is **separate** per Dio instance, and not shareable with tests. Tests can't inject a `TestAssetBundle` through `DioClient.build`. Either:
- Take an optional `MockInterceptor? interceptor` parameter.
- Or inject `MockFixtureLoader?` and forward.

Phase 03 unit tests for `mock_interceptor.dart` (LLD §10.1 line 520) will need this hook.

---

## Nits

### N1. `analysis_options.yaml` — Missing strict lints commonly used in cinema-grade Flutter codebases

Current rules are minimal. Consider adding:
- `unawaited_futures: true` (catches missing `await`/`unawaited()`, relevant for `box.delete()` calls)
- `always_use_package_imports: false` (consistent — currently mixed package + relative)
- `prefer_final_locals` / `prefer_final_in_for_each`
- `omit_local_variable_types: false` (LLD code style implicitly uses types)

Not blocking; recommend adding before Phase 03.

### N2. `pubspec.yaml:7` — `sdk: ^3.10.7` pins to Dart 3.10 which is unreleased as of this review's knowledge

If this resolves at install time, fine; if CI uses Flutter stable channel (Dart 3.5/3.6 at most as of mid-2025), this fails. Verify CI Flutter version aligns. Loosen to `>=3.5.0 <4.0.0` if uncertain.

### N3. `color_tokens.dart`, all `*_tokens.dart` — `// ignore_for_file: constant_identifier_names` plus `snake_case` constants

Idiomatic Dart is `lowerCamelCase` for constants. The generator chose snake_case (probably to mirror design-token JSON keys). Acceptable for **generated** files but propagates outward: `RadiusTokens.extra_small`, `FontFamilyTokens.body` are called all over `text_theme_builder.dart`, `app_shape_ext.dart` — these are hand-written and now must match the generated style. Pollutes hand-written code style.

Fix in the generator (`tool/gen_theme.dart` per file header) to emit `extraSmall` / `displayLarge`. Not blocking; preserve snake_case for token IDs in the source JSON.

### N4. `scheme_source.dart:40-106` — Two near-identical 33-line classes; copy-paste

`DarkScheme` and `LightScheme` differ only by `DarkColorTokens.` vs `LightColorTokens.`. Could be deduplicated via a single `class _TokenBackedScheme implements SchemeSource { final _Tokens t; ... }` if the tokens classes shared an interface — but they don't (they're `abstract final class` with static fields, not instances). For MVP, leave it; flag if a third theme variant (e.g. AMOLED) lands.

### N5. `home_shell.dart:19-25` — `CinemaNavBar` invokes `goBranch` with a non-trivial heuristic

`initialLocation: i == navigationShell.currentIndex` re-pops to the root on re-tap of the active tab. This is correct UX behaviour, but undocumented for the next reader. Comment is present (line 23) — keep.

### N6. `placeholder_tab.dart:14` — `'$name — Coming soon'` is a hardcoded English string

For MVP, fine. Note for i18n phase: there's no `intl`/`flutter_localizations` setup yet — call out so a follow-up adds `MaterialApp.localizationsDelegates` before any user-facing copy ships.

### N7. `failure.dart:33` — `NetworkFailure` constructor body uses old-style positional super pass

```dart
const NetworkFailure(String message, {this.statusCode, Object? cause})
    : super(message, cause);
```

Dart 2.17+ supports super-initialisers: `: super(message, cause)` can become `: super(cause)` if `message` is `super.message`. Cosmetic; not worth changing without a project-wide pass.

### N8. `mock_interceptor.dart:46-49` — Unknown path falls through to real adapter, **even when mock mode is on**

```dart
if (fixturePath == null) {
  handler.next(options);
  return;
}
```

LLD §4.3 line 150 says "Unknown path → forward `RequestInterceptorHandler.next` (lets Dio's default adapter 404 in dev)" — but in mock mode with `baseUrl = https://api.adf-cinema.local`, the default adapter will hit a non-resolvable host. The test then times out (5s `connectTimeout`) instead of failing fast. Minor; LLD-aligned. Document.

### N9. `cinema_nav_bar.dart:27` — `withValues(alpha: 0.2)` is Flutter 3.27+ API

If CI uses Flutter < 3.27, this fails compilation. `withOpacity(0.2)` is the older equivalent (deprecated in 3.27 but still works). Verify Flutter channel.

### N10. `hive_registrar.g.dart` — generated file imports look correct; no hand-edits visible

Sanity-checked: file is autogenerated, header says "Do not modify", contents are 27 lines of pure registration. **However:** `hive_bootstrap.dart` doesn't use it (see I5). This generated file is currently **dead code in the runtime path**. If you keep `hive_bootstrap.dart`'s manual registration, delete the generator output to avoid confusion. If you switch to the generated registrar, simplify `bootstrapHive`. Don't keep both.

### N11. `pubspec.yaml:38-41` — `assets/fonts/` listed but fonts block commented out

Listing the directory under `assets` (without `fonts:`) means asset-loader treats `.ttf` files as raw bytes (loadable but not registered as font families). Once fonts land in Phase 02, uncomment the `fonts:` block — don't rely on the bare `assets/fonts/` line. Currently the directory is empty so this is moot.

### N12. `main.dart` — No `runZonedGuarded` / `FlutterError.onError` wiring

Async errors in `bootstrapHive`, in providers, in widgets — all log via Flutter's default which goes to stderr. For an MVP that's fine, but `ProviderObserver` + a crash-reporter hook (or even just `FlutterError.onError = (details) => log(details.toString())`) is one line of insurance. Note for Phase 06+.

### N13. `cache_envelope.dart:14, 17` — Doc comments use Unicode `→` and `—` followed by space-glitch (visible in viewer as `…` artefacts)

Cosmetic; rendering artefact only. Compare line 14 with line 17 — different em-dash characters. Run Prettier or just normalise to ASCII `--` if it bugs anyone.

---

## Positive Observations (kept brief, per instructions)

- All foundation files ≤ 200 LOC — project rule honoured.
- `kReleaseMode` redaction in `failure.dart:19-26` — correct security posture.
- `MockInterceptor` strips query string before path-match (line 43) — prevents `_mock_error` from breaking routing.
- `_openBoxSafe` corrupt-recovery pattern is the right architectural shape (concern: implementation — see C2).
- Provider override pattern (`localCacheProvider.overrideWithValue`) — clean DI boundary.
- `analysis_options.yaml` includes `require_trailing_commas` — formatter-friendly diffs.
- Pubspec is alphabetically sorted (`sort_pub_dependencies: true` enforces).
- Theme extension registration (`extensions: [ext, AppShapeExt.instance]` in `app_theme.dart:82`) — correct M3 pattern.

---

## Unresolved Questions

1. **C1 severity:** does the current Dart SDK (`^3.10.7` in pubspec) treat the switch-without-break as a compile error, an analyzer warning, or silent fallthrough? Worth a `flutter analyze` run before claiming this blocks.
2. **C2 fix shape:** is silent in-memory fallback (LLD §5.5 intent) acceptable to the product team, or should bootstrap surface a non-fatal user message ("local cache temporarily unavailable")?
3. **I5 layering:** is the `core → features` import an explicit design choice (lightweight, no abstract registry) or unintentional? Generated `hive_registrar.g.dart` exists but is unused — what's the intended adapter-registration path going forward?
4. **I7 cache_envelope.dart:** keep as documentation-only stub, or delete? Generic class with no instantiations smells like YAGNI.
5. **N2 SDK version:** is `^3.10.7` correct, or a typo for `^3.5.0`? Verify against CI.
6. **N9 Flutter version:** does the team's pinned Flutter channel include `Color.withValues` (3.27+)?

---

## Recommended Actions (Prioritised)

1. **Fix C1** (compile/runtime correctness) — add `return;` after each `handler.*` call in `_handleErrorInjection`. Add unit test covering all three error codes.
2. **Fix C2** — replace memory-box fallback with explicit degraded mode or rethrow.
3. **Fix C3** — broaden catch in `LocalCache.readMovies`/`readBanners` to handle `TypeError` from corrupted entries.
4. **Fix C4** — have `bootstrapHive()` return the opened boxes; pass into `LocalCache`.
5. **Resolve I5** — decide on `hive_registrar.g.dart` vs manual registration; delete the unused one.
6. **Address I7** — delete or actualise `CacheEnvelope<T>`.
7. **Run `flutter analyze` + `dart format --set-exit-if-changed`** before Phase 03 to validate C1, N1, N2, N9 in one pass.

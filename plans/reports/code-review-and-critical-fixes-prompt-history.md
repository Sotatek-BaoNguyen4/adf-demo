# Chat Log — Code Review & Critical Fixes Session

**Date:** 2026-05-27 16:15–16:34 (Asia/Saigon)
**Branch:** master (no commits yet — fresh Flutter project)
**User:** anna@cratius.holdings
**Operator:** Claude Code (Opus 4.7, 1M ctx)

---

## Session Flow

### 1. `/code-review` — scope selection

**User chose:** *Review recent changes/PR*.

State of repo at start: 77 untracked files (52 hand-written Dart, ~4500 LOC), no commits. No diff baseline.

Follow-up question presented: how to scope without a diff. **User chose:** *Review all untracked files as the change*.

### 2. Parallel review dispatch

Two `code-reviewer` agents spawned in background, both reading `docs/lld-home-mvp.md` for spec context:

| Agent | Scope | Result |
|-------|-------|--------|
| Foundation reviewer | `lib/main.dart`, `lib/app/**`, `lib/core/**`, `lib/shared/**`, `pubspec.yaml` | 4 Critical, 11 Important, 13 Nits — [foundation-layer report](code-review-260527-1615-foundation-layer.md) |
| Home-feature reviewer | `lib/features/home/**`, `test/**` | 4 Critical, 9 Important, 9 Nits — [home-feature report](code-review-260527-1615-home-feature.md) |

### 3. Critical findings synthesis

Cross-cutting Critical (both reviewers independently flagged `mock_interceptor.dart`):

| # | Issue | File |
|---|-------|------|
| C-MOCK-1 | switch cases lacked explicit terminators (intent unclear, risk on edit) | `mock_interceptor.dart:107-141` |
| C-MOCK-2 | `?_mock_error=parse` returns String body → `as List` throws `TypeError` not `FormatException` → mapped to `UnknownFailure` instead of `ParseFailure` (violates LLD §4.6) | `mock_interceptor.dart:129` + `home_remote_source.dart:19` |

Foundation Criticals:
- **C2** `Hive.openBox(name, bytes: Uint8List(0))` is read-only — degraded fallback permanently broken
- **C3** `as CachedXEnvelope` throws `_TypeError`, not caught by `on HiveError`
- **C4** Box names duplicated between `main.dart` and `hive_bootstrap.dart` (DRY)

Home Criticals:
- **C3** `CacheWriteFailure` surfaced as UI error despite fresh network data in hand (violates LLD §6 SWR)
- **C4** Zero tests (`test/` contained only `.gitkeep`)

### 4. `/fix above problem` — mode selection

**User chose:** *Autonomous (Recommended)* — fix all 8 Criticals end-to-end.

### 5. Fixes applied

| # | File | Change |
|---|------|--------|
| 1 | [lib/core/network/mock_interceptor.dart](../../lib/core/network/mock_interceptor.dart) | Explicit `return;` after every terminal `handler.*` call |
| 2 | [lib/features/home/data/sources/home_remote_source.dart](../../lib/features/home/data/sources/home_remote_source.dart) | `_decodeList` normalizes Dio body: String → `jsonDecode` → FormatException on malformed; non-List throws FormatException |
| 3 | [lib/core/storage/local_cache.dart](../../lib/core/storage/local_cache.dart) | Replaced `as CachedXEnvelope` with `if (raw is! CachedXEnvelope) { evict; return null; }`; fixed double-relative import |
| 4 | [lib/core/storage/hive_bootstrap.dart](../../lib/core/storage/hive_bootstrap.dart) | Returns `HiveBoxes` record `(movies, banners)`; removed `Uint8List(0)` read-only fallback; rethrows on persistent corruption |
| 5 | [lib/main.dart](../../lib/main.dart) | Consumes returned record; deletes duplicated box-name strings |
| 6 | [lib/features/home/data/home_repository_impl.dart](../../lib/features/home/data/home_repository_impl.dart) | `_tryWriteMovies`/`_tryWriteBanners` helpers swallow `CacheWriteFailure` and log; added `CheckedFromJsonException → ParseFailure` mapping |
| 7 | [test/unit/home_repository_impl_test.dart](../../test/unit/home_repository_impl_test.dart) (new) | 9 tests: SWR happy/miss/forceRefresh/stale-fallback/no-cache-error/write-swallow x2/FormatException/CheckedFromJsonException |
| 8 | [test/unit/home_remote_source_test.dart](../../test/unit/home_remote_source_test.dart) (new) | 3 tests: malformed String body, non-list body, valid list — verifies LLD §4.6 chain |

### 6. Verification

- **`flutter analyze`** — 14 pre-existing info issues; **none in changed code**, no warnings/errors.
- **`flutter test`** — **12/12 pass**.
- **Code-reviewer verification** ([critical-fix-verification report](code-review-260527-1615-critical-fix-verification.md)): 8/8 Criticals correctly addressed; 5 minor new defects (D1–D5), all low-severity; no regressions.

---

## Decisions Log

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | Parallel reviewers over single reviewer | Clear scope boundaries (core/app/shared vs features/home); ~50 Dart files benefit from 2 focused contexts vs 1 stretched |
| D2 | Treat untracked tree as the diff | No commits exist; user chose "review all as change" rather than scoping to a folder |
| D3 | Fix `parse` injection in remote source, not interceptor | Cleaner — also handles real backend cases where body comes back as String/bytes; doesn't require mock-specific knowledge in repo layer |
| D4 | Rethrow on persistent Hive corruption (not in-memory fallback) | Per reviewer KISS option: surfacing failure beats faking success then breaking every later `.put()` |
| D5 | `HiveBoxes` record returned from `bootstrapHive()` | Single source of truth for box-name constants; `main.dart` no longer references private bootstrap internals |
| D6 | Swallow `CacheWriteFailure` only in repo, not in `LocalCache` | Lower layer should surface the failure; repository decides policy ("fresh data wins") |
| D7 | Skip direct `MockInterceptor` unit test in this fix pass | Indirect coverage via `_decodeList` smoke tests + repo tests; direct interceptor tests flagged as carry-forward |

---

## Unresolved (Carry-Forward)

From the verification report (low severity, do not block):
1. Should `CheckedFromJsonException` be re-thrown as `FormatException` inside `HomeRemoteSource` to keep `json_annotation` out of the repository layer?
2. `bootstrapHive` partial-open resource leak (D3 in verification report) — fix now or defer?
3. LLD §5.5 originally specified a memory-only fallback; with rethrow-on-corruption, is hard-crash acceptable or do we need a `degradedCacheMode` flag?
4. Is indirect `MockInterceptor` coverage via `_decodeList` sufficient, or does LLD §10.1 line 520 require direct interceptor tests?

Important findings (I1–I9) from both review reports remain — banner error state, accessibility/`Semantics`, movie-card tappability, banner `targetUrl` navigation, `hive_registrar.g.dart` vs hand-rolled adapter registration choice, `core → features` layering inversion, dead `CacheEnvelope<T>` generic. Separate pass.

---

## Artifacts

- [code-review-260527-1615-foundation-layer.md](code-review-260527-1615-foundation-layer.md)
- [code-review-260527-1615-home-feature.md](code-review-260527-1615-home-feature.md)
- [code-review-260527-1615-critical-fix-verification.md](code-review-260527-1615-critical-fix-verification.md)

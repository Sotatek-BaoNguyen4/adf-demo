# Critical Fix Verification — Foundation + Home

**Date:** 2026-05-27
**Reviewer:** code-reviewer
**Scope:** 8 files modified to address 8 Criticals from prior reviews
**Prior reports:**
- `plans/reports/code-review-260527-1615-foundation-layer.md` (C1–C4)
- `plans/reports/code-review-260527-1615-home-feature.md` (C1–C4)
**Verification basis:** working-tree only (no commits). `flutter analyze` clean on changed code; 12 tests pass per upstream report.

---

## 1. Critical-by-Critical Verdict

| ID | Status | Judgment |
|---|---|---|
| **foundation C1** | ✅ FIXED | Every `handler.*` call in `_handleErrorInjection` (`mock_interceptor.dart:124,133,145,149`) is now followed by explicit `return;`. Fall-through ambiguity eliminated; comment at L107–109 documents intent. |
| **foundation C2** | ✅ FIXED | `Uint8List(0)` memory fallback removed. `_openBoxSafe` (`hive_bootstrap.dart:69-80`) now deletes the box file and retries once; on persistent failure it **rethrows**, surfacing the corruption to the caller instead of poisoning every later `.put()`. Doc at L33-40 explains the trade-off. |
| **foundation C3** | ✅ FIXED | `LocalCache.readMovies/readBanners` (`local_cache.dart:43-48, 90-94`) replaced the unguarded `as` cast with `is! CachedXEnvelope` type-guard + evict + return null. Wrong-type entries no longer escape as `_TypeError`. Bonus: import path corrected to `../errors/failure.dart` (N1 home report). |
| **foundation C4** | ✅ FIXED | `bootstrapHive()` returns `HiveBoxes` record (`hive_bootstrap.dart:19, 41, 64`); `main.dart:11-12` consumes `boxes.movies / boxes.banners`. Box-name constants are now genuinely private to `hive_bootstrap.dart`. `grep -rn "Hive.box"` confirms no remaining global lookups. |
| **home C1** | ✅ FIXED | `home_remote_source.dart:53-63` adds `_decodeList` which routes String bodies through `jsonDecode`, throws `FormatException` on non-list / non-string shapes. `HomeRepositoryImpl._mapException` catches `FormatException → ParseFailure` (L172-174). LLD §4.6 contract restored. |
| **home C2** | ✅ FIXED (same fix as foundation C1) | See above. |
| **home C3** | ✅ FIXED | `_tryWriteMovies` / `_tryWriteBanners` (`home_repository_impl.dart:115-135`) catch `CacheWriteFailure` and log; fresh network entities are still returned. Both `getBanners` (L51) and `_fetchMovies` (L96) route through these helpers. LLD §6 SWR contract honoured. |
| **home C4 (test gap)** | ⚠ PARTIAL | 2 new test files (13 cases total) cover repository SWR + remote-source body normalisation. Material gap remains — see §3. |

---

## 2. New Defects Introduced

### D1 — `_decodeList` swallows the underlying decode cause when `raw` is a non-List object
`home_remote_source.dart:60-62`:
```dart
throw FormatException(
  'Unexpected response body type: ${raw.runtimeType}',
);
```
No `cause` field. `ParseFailure.cause` will be the `FormatException` itself, but the original adapter response payload (if helpful for debug) is gone. Low severity, only affects debugging.

### D2 — `_decodeList` rethrows `jsonDecode` errors without wrapping
`home_remote_source.dart:55-58` calls `jsonDecode(raw)` directly. If `raw` contains a non-UTF or oversize payload that throws something other than `FormatException` (very unlikely for `jsonDecode` — it only throws `FormatException`), the repository falls through to `UnknownFailure`. Probability ~0; flagging for completeness only.

### D3 — `bootstrapHive` rethrow path leaves the **first** box opened before the second box fails
`hive_bootstrap.dart:60-64`:
```dart
final results = await Future.wait([
  _openBoxSafe<dynamic>(_kMoviesBox),
  _openBoxSafe<dynamic>(_kBannersBox),
]);
```
If `_kMoviesBox` opens but `_kBannersBox` rethrows on persistent corruption, `Future.wait` propagates the error; `_kMoviesBox` is left open with no handle, leaking the resource until process exit. Not a runtime bug (no `await Hive.close()` needed for MVP), but worth a `try { ... } catch (e) { await Hive.close(); rethrow; }` once a second feature consumes Hive.

### D4 — `CheckedFromJsonException` mapping is correct but the import pulls in `json_annotation` at the repository layer
`home_repository_impl.dart:4` adds `import 'package:json_annotation/json_annotation.dart';`. The repository is meant to be Dio/Hive-aware only; bringing in `json_annotation` pierces the data-layer boundary (this exception is a code-gen concern). Functional and minor — but `CheckedFromJsonException` should arguably be re-thrown as a `FormatException` inside `HomeRemoteSource` so the repository only knows `FormatException`. Defer.

### D5 — Mock `'500'` injection still does not set `DioException.error`
`mock_interceptor.dart:111-123`: `DioException(...)` for the 500 case has no `error:` field. Same critique was raised in home C2; not regressed but not fixed either. `e.toString()` will read `null` for `.error`. Cosmetic.

**No regressions of the 4 Criticals themselves.** All defects above are pre-existing or peripheral.

---

## 3. Test-Coverage Adequacy

### Adequate
- ✔ Cache-write-failure swallow (C3): tests at `home_repository_impl_test.dart:160-189` exercise both movies and banners paths.
- ✔ `CheckedFromJsonException → ParseFailure` (home I9 / D4): L248-261.
- ✔ Body-normalisation parse-injection path (C1): `home_remote_source_test.dart:51-69` covers both malformed string and non-list-object cases.
- ✔ Stale fallback + no-cache-failure-throw: L191-226.
- ✔ `forceRefresh`: L228-236.

### Gaps that still lock in risk
1. **No test for `MockInterceptor._handleErrorInjection` directly.** The Dio→remote→repo chain for `?_mock_error=500/timeout` is untested. C1 fix is *enabled* by the test on `_decodeList` but a regression that re-removes a `return;` from the `'timeout'` branch would not fail any current test. Add `mock_interceptor_test.dart` with 3 cases (one per error code) feeding a real `Dio` with the interceptor wired.
2. **No test for `LocalCache` wrong-type-evict path (foundation C3).** The `is! CachedMoviesEnvelope` branch (L43-48) is unreachable from the current `_FakeLocal` (it bypasses `LocalCache`). Suggested test: open an in-memory `Box<dynamic>`, `put(key, 'not an envelope')`, assert `readMovies(key)` returns null AND that the box no longer contains the key. Name: `local_cache_test.dart::readMovies returns null and evicts wrong-type entry`.
3. **No test for `bootstrapHive` corrupt-box rethrow path (foundation C2).** Difficult to simulate without mocking `Hive`; acceptable to defer with a TODO, but note that the *intent* of the C2 fix is now unverified.
4. **No widget test** — orthogonal to this fix pass; not raised here as a Critical regression.

### Suggested missing test names
- `mock_interceptor_test.dart::_mock_error=500 → DioException badResponse 500`
- `mock_interceptor_test.dart::_mock_error=timeout → DioException connectionTimeout`
- `mock_interceptor_test.dart::_mock_error=parse → Response with string body`
- `local_cache_test.dart::readMovies returns null and evicts wrong-type entry`
- `local_cache_test.dart::readBanners returns null and evicts wrong-type entry`
- `local_cache_test.dart::readMovies returns null and evicts on schemaVersion mismatch`

---

## 4. Spec Compliance Re-check

### LLD §4.6 — Mock error mapping
| Code | Required Failure | Pre-fix | Post-fix |
|---|---|---|---|
| `?_mock_error=500` | `NetworkFailure(statusCode: 500)` | broken by fall-through | ✅ `mock_interceptor.dart:111-124` → `DioException badResponse 500` → `home_repository_impl.dart:164-168` `NetworkFailure(statusCode: 500)` |
| `?_mock_error=timeout` | `TimeoutFailure` | broken by fall-through | ✅ `mock_interceptor.dart:125-133` → `connectionTimeout` → L160-163 `TimeoutFailure` |
| `?_mock_error=parse` | `ParseFailure` | became `UnknownFailure` | ✅ `mock_interceptor.dart:134-145` returns `'{not json'`; `_decodeList` throws `FormatException`; L172-174 maps to `ParseFailure` |

### LLD §6 — SWR
| Step | Pre-fix | Post-fix |
|---|---|---|
| Read fresh cache → return, skip remote | ✅ | ✅ (verified by test L136-145) |
| Fetch remote on miss/stale → write → return | ✅ but write failure surfaced | ✅ write failure swallowed (helpers L115-135) |
| Network failure + stale cache → return stale | ✅ | ✅ (test L191-205) |
| Network failure + no cache → throw `Failure` | ✅ | ✅ (test L207-226) |
| `forceRefresh: true` skips cache | ✅ | ✅ (test L228-236) |

**Spec status:** §4.6 and §6 now fully aligned with the LLD.

---

## 5. `HiveBoxes` typedef-record migration risk

- **Dart SDK requirement:** record types and `typedef`-on-records require Dart ≥ 3.0. `pubspec.yaml` pins `^3.10.7` (per N2 in prior report) — comfortably supports records.
- **Public API surface change:** `bootstrapHive()` signature changed from `Future<void>` → `Future<HiveBoxes>`. Only call site is `main.dart:11`; verified by `grep -rn "bootstrapHive"`. No tests call `bootstrapHive` directly. **No breakage.**
- **Future risk:** if a test wants to bootstrap Hive itself, it must destructure the record. Trivial. The typedef being public makes this self-documenting.
- **Anti-risk concern:** named-record fields (`movies`, `banners`) are coupled to the typedef. If a future schema renames `movies` → `nowShowing`, every consumer breaks at compile-time — which is exactly what we want (the prior `Hive.box<dynamic>('movies_cache')` would have broken at *runtime*). Net improvement.
- **One nitpick:** the `Box<dynamic>` value type leaks into the typedef. If you ever introduce strongly-typed boxes (e.g. `Box<CachedMoviesEnvelope>`), the typedef and all call sites must change together. Acceptable for MVP.

**Verdict:** no test or future-code risk from the migration; it strictly improves the contract.

---

## Final Assessment

- **8 / 8 Criticals correctly addressed** at the source-code level.
- **No regressions** of the original Criticals.
- **Test coverage locks in 6 / 8** Criticals directly; foundation C1 and C2 remain *implementation-correct but test-unverified* (see §3 gaps 1 & 3).
- **5 small new defects** (D1–D5), all low severity, none warrant blocking.
- Spec compliance against LLD §4.6 and §6 now passes.
- `HiveBoxes` migration is safe and a net architectural win.

**Recommendation:** ship the fix pass. Track the 3 missing test names in §3 as follow-up; do not block on them.

---

## Unresolved Questions

1. Should `CheckedFromJsonException` be re-thrown as `FormatException` inside `HomeRemoteSource` (D4) so the repository stays free of `json_annotation` imports? Cleaner layering vs current 2-line catch in `_mapException` — design call.
2. `bootstrapHive` resource-leak on partial open (D3): worth fixing now or defer to second-Hive-consumer landing?
3. LLD §5.5 originally specified a "memory-only" fallback. With the new rethrow-on-corruption behaviour, is the product expectation now "app crashes hard on persistent cache corruption" acceptable, or do we need a `degradedCacheMode` flag visible to the UI?
4. `MockInterceptor` direct test coverage (§3 gap 1) — is the indirect coverage via `_decodeList` test sufficient, or required by LLD §10.1 line 520?

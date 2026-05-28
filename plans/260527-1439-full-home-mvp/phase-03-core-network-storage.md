---
phase: 03
title: core/network + core/storage
status: pending
priority: P0
effort: M
depends_on: [01]
---

# Phase 03 — core/network + core/storage

## Context Links
- **LLD primary** (single source of truth): [lld-home-mvp.md](../../docs/lld-home-mvp.md) §3..§5
- HLD §4.1 layered view, §7.1 errors, §7.3 caching

## Overview
Implement the two foundational subsystems exactly per LLD: Dio + MockInterceptor + fixture loader; Hive bootstrap + CacheEnvelope + CachePolicy + LocalCache. Plus shared `Failure` taxonomy.

## Key Insights
- **LLD locks every contract** — implement to spec, do not reinterpret.
- Hive CE TypeAdapters are codegen'd; reserved typeId table at LLD §5.2 is binding.
- `MockInterceptor` is **terminal** when `useMock=true` — never hits real adapter.
- `CacheEnvelope<T>` requires concrete-T adapter generation (LLD §5.2). DTOs come in phase 04, but adapter registration site is wired here with TODOs.

## Requirements
**Functional**
- Files exactly per LLD §2 module layout.
- `Failure` sealed hierarchy per LLD §3.
- `MockInterceptor` matches paths per LLD §4.3 table; supports `_mock_error` query param.
- `MockFixtureLoader` caches in-memory after first read (LLD §4.4).
- `CachePolicy` constants: movies 6h, banners 1h (LLD §5.3).
- `LocalCache` API per LLD §5.4 signatures.
- `HiveBootstrap` recovers from corrupt box (delete + retry + in-memory fallback, LLD §5.5).

**Non-functional**
- All files <200 LOC per LLD budgets (§4, §5).
- 85%+ unit coverage (LLD §9) — tests authored in phase 07.

## Architecture
See LLD §2 module tree. No deviation.

## Related Code Files
**Create** (paths per LLD §2)
- `lib/core/errors/failure.dart`
- `lib/core/network/network_config.dart`
- `lib/core/network/dio_client.dart`
- `lib/core/network/mock_interceptor.dart`
- `lib/core/network/mock_fixture_loader.dart`
- `lib/core/storage/cache_envelope.dart` + `cache_envelope.g.dart` (gen)
- `lib/core/storage/cache_policy.dart`
- `lib/core/storage/local_cache.dart`
- `lib/core/storage/hive_bootstrap.dart`

## Implementation Steps
1. **`failure.dart`** — sealed class + 7 subclasses (LLD §3). `toString()` redacts `cause` in release.
2. **`network_config.dart`** — constants per LLD §4.1. Use `bool.fromEnvironment('USE_MOCK', defaultValue: true)`.
3. **`dio_client.dart`** — `DioClient.build({bool mock})` factory; wire BaseOptions + interceptor chain per LLD §4.2.
4. **`mock_fixture_loader.dart`** — class per LLD §4.4. Inject `AssetBundle` for testability. Cache JSON-decoded result.
5. **`mock_interceptor.dart`** — implement endpoint→fixture map (LLD §4.3), latency simulation, `_mock_error` handling, deterministic seed when `MOCK_DETERMINISTIC=true`.
6. **`cache_envelope.dart`** — `CacheEnvelope<T>` w/ Hive annotations (typeId 0 generic stub). Real concrete adapters wired in phase 04 once DTOs exist; for now leave `// TODO(phase-04): register concrete adapters` in `hive_bootstrap.dart`.
7. **`cache_policy.dart`** — pure functions per LLD §5.3. `kSchemaVersion = 1`.
8. **`local_cache.dart`** — typed wrapper per LLD §5.4. **Stub methods returning `null`/no-op until DTO adapters land** (phase 04 fills in `readMovies/writeMovies/...`). Alternative: parameterize via generics now and avoid TODOs — preferred. Implementation:
   ```dart
   class LocalCache {
     final Box<dynamic> _moviesBox;
     final Box<dynamic> _bannersBox;
     LocalCache(this._moviesBox, this._bannersBox);
     // Concrete typed wrappers added in phase 04 (avoids cyclic DTO dep).
     Box<dynamic> get moviesBox => _moviesBox;
     Box<dynamic> get bannersBox => _bannersBox;
     Future<void> evict(String box, String key) async { /* ... */ }
     Future<void> clearAll() async { /* ... */ }
   }
   ```
9. **`hive_bootstrap.dart`** — `bootstrapHive()` per LLD §5.5. Adapter registration list is populated in phase 04; leave clear extension point.
10. Run `flutter analyze` → clean. Build runner not needed yet (no @HiveType on concrete types here).

## Todo List
- [ ] `failure.dart` — sealed taxonomy
- [ ] `network_config.dart`
- [ ] `dio_client.dart` w/ interceptor chain
- [ ] `mock_fixture_loader.dart` w/ in-memory cache
- [ ] `mock_interceptor.dart` w/ endpoint map + error injection
- [ ] `cache_envelope.dart` (generic shell)
- [ ] `cache_policy.dart` w/ TTL constants + isFresh
- [ ] `local_cache.dart` (box-holder API; typed wrappers in phase 04)
- [ ] `hive_bootstrap.dart` w/ corrupt-recovery
- [ ] `flutter analyze` clean

## Success Criteria
- Every file <200 LOC (matches LLD budgets)
- `DioClient.build()` returns Dio instance without throwing
- `bootstrapHive()` opens both boxes idempotently
- Error injection (`?_mock_error=500`) returns DioException
- `flutter analyze` 0 issues

## Risk Assessment
| Risk | Mitigation |
|---|---|
| Hive concrete-T adapter codegen blocks this phase | Keep `LocalCache` generic-shell here; specialize in phase 04 |
| Path-matching regex bugs in interceptor | Use exact string match on stripped path (LLD §4.3) — no regex |
| Latency randomness flakes manual testing | `MOCK_DETERMINISTIC` build flag (LLD §4.3) |

## Security Considerations
- `Failure.toString()` must redact `cause` in release (LLD §3) — verify `kReleaseMode` branch.
- `_mock_error` only honored when `useMock=true` (LLD §11 risk row) — guarded by interceptor not being wired in real mode.

## Next Steps
Unblocks phase 04 (home data layer consumes Dio + LocalCache + Failure).

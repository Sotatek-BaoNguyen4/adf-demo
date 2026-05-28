---
type: prompt-history
title: Chat Transcript — Detailed Design for Home MVP
date: 2026-05-27
session: brainstorm-technical
output: docs/lld-home-mvp.md
parent: plans/reports/hld-home-mvp.md
---

# Chat Transcript — LLD Home MVP Session

## Session Context

- **Skill invoked**: `/brainstorm-technical`
- **Arguments**: `create detail design`
- **CWD**: `/Volumes/Dev/dev_env/sotatek/adf_demo`
- **DateTime**: 2026-05-27 14:10 (Asia/Saigon)
- **Branch**: master

---

## User Prompt 1

```
/brainstorm-technical create detail design
```

---

## Assistant — Scout Phase

Discovered project state:
- Flutter project `adf_demo`
- HLD already agreed: `plans/reports/hld-home-mvp.md`
- FSD present: `docs/project-fsd.md` (Home screen, FR-HOME-001..005)
- Design system in `docs/design-system/`
- Home mockup in `docs/design-mockups/home-screen/`
- Use case `UC-HOME-001` covering banner + 3 rails
- `lib/` only has stock `main.dart` — no code yet

Read full HLD to understand prior decisions (Riverpod 2, go_router, Hive CE, Dio + MockInterceptor, feature-first MVVM-lite, codegen enabled, dark theme hard-coded, stale-while-revalidate caching).

---

## Assistant — Discovery Phase Questions

Posed 4 questions via `AskUserQuestion`:

### Q1: Design depth
**Options:**
- Contracts + key flows (Recommended) — ~600-900 lines, class/method signatures, JSON schemas, sequence diagrams, error/state semantics, test matrix. No full Dart bodies.
- Full pseudocode/skeletons — ~1200-1800 lines, includes file-level Dart skeletons.
- Minimal — interfaces only — ~300-400 lines, abstract interfaces + DTO shapes only.

**User chose:** Contracts + key flows (Recommended)

### Q2: Scope (multi-select)
**Options:**
- core/network (Dio + MockInterceptor)
- core/storage (Hive + cache policy)
- core/theme (tokens codegen)
- features/home (repo + sources + providers + widgets)

**User chose:** core/network + core/storage only

### Q3: Sequence diagrams
**Options:**
- Yes — cold start, warm cache, refresh, error (Recommended)
- Only cold-start flow
- No diagrams, prose only

**User chose:** Yes — 4 diagrams

### Q4: Output location
**Options:**
- `plans/reports/lld-home-mvp.md` (Recommended)
- `docs/lld-home-mvp.md`

**User chose:** `docs/lld-home-mvp.md`

---

## Assistant — Verification

Read additional context for accuracy:
- `docs/usecases/home/uc-home-001-home-banner.md` — confirmed concurrent fetch flow, alt-flow for carousel auto-rotation, exception flows for network failure + empty data.

---

## Assistant — LLD Authoring

Wrote `docs/lld-home-mvp.md` (~510 lines). Structure:

1. **Scope & Non-Goals** — in-scope: core/network, core/storage, Failure taxonomy, 4 sequence diagrams, HomeRepository contract. Out: widgets, providers, navigation, theming.
2. **Module Layout** — explicit file tree with LOC budgets.
3. **Failure Taxonomy** — sealed class hierarchy + mapping table from low-level exceptions to typed Failures.
4. **core/network detailed contracts**:
   - `NetworkConfig` — base URL, timeouts, mock flag via `--dart-define`
   - `DioClient.build()` factory + interceptor chain order
   - `MockInterceptor` — endpoint→fixture map, latency simulation, error injection via `?_mock_error=…`, pagination ignored in MVP, determinism toggle for tests
   - `MockFixtureLoader` — bundle reads + in-memory cache
   - Fixture JSON schemas per FSD §4
5. **core/storage detailed contracts**:
   - Two-box schema: `movies_cache`, `banners_cache`
   - `CacheEnvelope<T>` with `savedAtEpochMs` + `schemaVersion`
   - Hive typeId registry (reserved 0-15)
   - `CachePolicy.isFresh/isStale/isCompatible` pure functions
   - `LocalCache` typed wrapper API
   - `HiveBootstrap` with corrupt-box recovery → in-memory fallback
   - Cache key convention = endpoint path
6. **HomeRepository boundary contract** — SWR algorithm with serve-stale-on-error fallback.
7. **Sequence diagrams (Mermaid)**:
   - Cold start (cache miss → network → write)
   - Warm start (cache hit, fresh, < 500ms NFR)
   - Pull-to-refresh (forceRefresh=true)
   - Error path (500 with stale-fallback + alt branch for no-cache)
8. **Concurrency & threading** — Hive box locks, Dio parallel calls, 4 parallel rail loads.
9. **Testing matrix** — per-file unit tests, mocktail + in-memory Hive, 85% coverage target on core/.
10. **Performance budget** — Hive open <60ms, cache read <15ms, warm Home <200ms, cold Home <500ms.
11. **Risks** — typeId collisions, fixture/FSD drift, corrupt Hive, clock skew, schema bump forgetfulness, latency flakes.
12. **Open Questions** — pagination slicing in mock, cache stats debug screen, stale badge UX.
13. **Definition of Done** — 8 checkboxes.
14. **10 Locked Decisions** — two boxes, endpoint-path key, CacheEnvelope shape, terminal MockInterceptor, fixture loader cache, error injection mechanism, stale-fallback policy, corrupt-box recovery, schemaVersion registry, shared Failure vocabulary.

---

## Assistant — Finalize Phase Question

### Q5: Next step
**Options:**
- Yes — run /plan with HLD + LLD context (Recommended)
- No — end session

**User chose:** No — end session

---

## Outcome

- ✅ LLD authored at [docs/lld-home-mvp.md](../../docs/lld-home-mvp.md)
- ✅ Scope narrowed to foundational core/* modules per user discipline
- ✅ 4 Mermaid sequence diagrams locked
- ✅ 10 LLD-scope decisions locked
- ⏸ `/plan` deferred — to be invoked manually later

---

## User Prompt 2

```
save this chat as markdown
```

Assistant wrote this transcript to `plans/reports/lld-home-mvp-prompt-history.md`.

---

## Unresolved Questions

None at LLD scope. Three open questions documented in §12 of the LLD itself (pagination slicing, debug stats screen, stale-badge UX) — none are blocking; flagged for backlog.

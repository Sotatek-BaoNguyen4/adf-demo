# Phase 01 — Add HLD Error Sequence Diagrams

## Context Links

- Target: [docs/system-architecture.md § 5](../../docs/system-architecture.md) lines 282–392
- Style reference: [docs/lld-home-mvp.md § 7.4](../../docs/lld-home-mvp.md) lines 473–500
- Mermaid syntax: `/mermaidjs-v11` skill

## Overview

**Priority:** Medium (docs gap, blocks no implementation)
**Status:** ✅ Complete
**Effort:** ~30 min

Insert 4 mermaid `sequenceDiagram` blocks into HLD § 5, placed **after** the "Exception Mapping Table" subsection and **before** the "UI Error Handling Pattern" subsection. New subsection heading: `### Error Propagation Sequence Diagrams`.

## Key Insights

- LLD § 7.4 already covers the **stale-fallback** error flow at the detail level. HLD diagrams must stay **architectural** — fewer participants, no method-level detail, no `_mock_error` query params.
- HLD § 3 uses ASCII diagrams; LLD § 7 uses mermaid. New diagrams use **mermaid** because: (1) renders in docs preview, (2) matches LLD's modern style, (3) `### Sequence Diagram` in HLD § 3 already uses textual flow — these complement, not replace.
- 4 diagrams cover the 4 distinct error origins: **Network**, **Timeout**, **Parse**, **Cache** — matching the sealed class groupings in HLD § 5.

## Requirements

**Functional**
- One mermaid `sequenceDiagram` per error category (4 total)
- Each diagram named with subsection heading `#### 5.X` matching numbering
- Each diagram uses `autonumber` (consistent with LLD § 7.4)
- Participants stay at HLD abstraction: UI, Provider, Repository, Network, Cache (no `MockInterceptor`, no `DioClient` internals)
- Each diagram ends at UI layer showing `AsyncError(<FailureClass>)` or `AsyncData` (for stale-fallback case)

**Non-Functional**
- Mermaid v11 valid syntax
- No code changes
- No changes to existing HLD subsections (additive only)

## Architecture

Each diagram follows the pattern:

```
UI → Provider → Repository → [Network|Cache] → (failure) → Repository (maps) → Provider → UI
```

**Layers (HLD-level participants):**
- `UI` — HomeScreen / widget
- `P` — Riverpod provider (`AsyncValue`)
- `R` — HomeRepository
- `N` — Network (Dio + remote source, collapsed)
- `C` — LocalCache (Hive)

## Related Code Files

**Modify**
- `docs/system-architecture.md` — insert new subsection between mapping table and UI handling pattern (around line 353)

**Create** — none
**Delete** — none

## Implementation Steps

### 1. Locate insertion point

In `docs/system-architecture.md`, find line 353 (`### UI Error Handling Pattern`). Insert new subsection **before** this line, **after** the mapping table ends (line 351, the row for `UnknownFailure`).

### 2. Insert new subsection

Add the following block (preserves blank lines around it):

```markdown
### Error Propagation Sequence Diagrams

The diagrams below show how errors flow from their origin (network/cache/parse) through the repository (where mapping to `Failure` happens) up to the UI (which receives `AsyncValue.error`). Layer-internal details (Dio interceptors, Hive box mechanics, fixture loading) live in [LLD § 7.4](./lld-home-mvp.md).

#### 5.1 Network 5xx / 4xx → `NetworkFailure`

\`\`\`mermaid
sequenceDiagram
    autonumber
    participant UI as HomeScreen
    participant P as Provider (AsyncValue)
    participant R as HomeRepository
    participant N as Network (Dio)
    participant C as LocalCache (Hive)

    UI->>P: ref.watch(moviesProvider)
    P->>R: getMovies()
    R->>C: read(key)
    C-->>R: null OR stale envelope
    R->>N: GET /api/v1/movies/*
    N-->>R: DioException(statusCode: 5xx)
    R->>R: map → NetworkFailure(statusCode)
    alt stale envelope exists
        Note over R: serve-stale-on-error
        R-->>P: stale payload
        P-->>UI: AsyncData(movies) + "outdated" badge
    else no cache
        R-->>P: throw NetworkFailure
        P-->>UI: AsyncError(NetworkFailure)
        UI->>UI: render ErrorView("Failed to load — Retry")
    end
\`\`\`

#### 5.2 Request Timeout → `TimeoutFailure`

\`\`\`mermaid
sequenceDiagram
    autonumber
    participant UI as HomeScreen
    participant P as Provider (AsyncValue)
    participant R as HomeRepository
    participant N as Network (Dio)
    participant C as LocalCache (Hive)

    UI->>P: ref.watch(moviesProvider)
    P->>R: getMovies()
    R->>C: read(key)
    C-->>R: null (cache miss)
    R->>N: GET /api/v1/movies/*
    Note over N: connectTimeout / receiveTimeout exceeded
    N-->>R: DioException(type: timeout)
    R->>R: map → TimeoutFailure
    R-->>P: throw TimeoutFailure
    P-->>UI: AsyncError(TimeoutFailure)
    UI->>UI: render ErrorView(icon: cloud_off, "Network timeout")
\`\`\`

#### 5.3 Malformed JSON → `ParseFailure`

\`\`\`mermaid
sequenceDiagram
    autonumber
    participant UI as HomeScreen
    participant P as Provider (AsyncValue)
    participant R as HomeRepository
    participant N as Network (Dio)

    UI->>P: ref.watch(moviesProvider)
    P->>R: getMovies()
    R->>N: GET /api/v1/movies/*
    N-->>R: 200 OK with malformed body
    R->>R: jsonDecode / DTO.fromJson
    Note over R: FormatException or TypeError thrown
    R->>R: map → ParseFailure(path)
    R-->>P: throw ParseFailure
    P-->>UI: AsyncError(ParseFailure)
    UI->>UI: render ErrorView("Unexpected error — Retry")
\`\`\`

#### 5.4 Cache Read/Write Error → `CacheReadFailure` / `CacheWriteFailure`

\`\`\`mermaid
sequenceDiagram
    autonumber
    participant UI as HomeScreen
    participant P as Provider (AsyncValue)
    participant R as HomeRepository
    participant C as LocalCache (Hive)
    participant N as Network (Dio)

    UI->>P: ref.watch(moviesProvider)
    P->>R: getMovies()
    R->>C: read(key)
    C-->>R: HiveError (corrupt box / IO)
    R->>R: map → CacheReadFailure (swallowed — fall through)
    Note over R: cache errors never block reads — proceed to network
    R->>N: GET /api/v1/movies/*
    N-->>R: 200 OK
    R->>C: write(envelope)
    C-->>R: HiveError
    R->>R: map → CacheWriteFailure (logged, not thrown)
    Note over R: write errors are non-fatal — fresh data still returned
    R-->>P: fresh payload
    P-->>UI: AsyncData(movies)
\`\`\`
```

> **Note for implementation:** In the actual file, replace `\`\`\`` with three real backticks (the escapes above are only for embedding in this plan).

### 3. Verify

- Run `grep -c "sequenceDiagram" docs/system-architecture.md` → expect 4 (was 0)
- Visually scan that section 5 still reads top-to-bottom: hierarchy → mapping table → **new sequences** → UI handling
- Open in markdown-novel-viewer or VSCode preview to confirm mermaid renders

## Todo List

- [x] Read current HLD § 5 to confirm insertion point line numbers (may have shifted)
- [x] Insert subsection header + intro paragraph
- [x] Insert 4 mermaid sequence diagrams (5.1–5.4)
- [x] Verify with grep + render check
- [x] No commit (user decides when to commit)

## Success Criteria

- HLD § 5 contains exactly 4 mermaid `sequenceDiagram` blocks (5.1–5.4)
- Each block lints as valid mermaid v11
- Existing § 5 content (hierarchy, mapping table, UI pattern) unchanged
- Cross-link to LLD § 7.4 present in intro paragraph
- No code file modified

## Risk Assessment

| Risk | Mitigation |
|---|---|
| Line numbers shifted before edit | Re-grep for `### UI Error Handling Pattern` to relocate insertion point |
| Mermaid syntax error breaks rendering | Validate via `/mermaidjs-v11` skill before committing |
| Sequence diagrams duplicate LLD § 7.4 detail | Keep participants at HLD layer (no `MockInterceptor`, no method signatures) |

## Security Considerations

None — docs-only change.

## Next Steps

After merge: consider similar treatment for HLD § 7 (Routing) and § 10 (Riverpod) — both currently lack sequence diagrams for edge cases. Out of scope here.

## Open Questions

- Should diagrams 5.1 and 5.4 also show the **provider invalidation** triggered by retry button? (Currently omitted — keeps focus on error propagation, not recovery.) Suggest: no, that belongs in a "Recovery & Retry" subsection if one is ever added.

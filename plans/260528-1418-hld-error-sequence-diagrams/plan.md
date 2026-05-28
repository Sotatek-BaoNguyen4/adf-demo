# Plan: HLD — Add Missing Sequence Diagrams for Error Lines

**Created:** 2026-05-28
**Status:** ✅ Complete
**Scope:** Docs-only (no code changes)
**Target file:** `docs/system-architecture.md` § 5 (Failure Taxonomy & Error Mapping)
**Completed:** 2026-05-28

## Problem

HLD § 5 describes error taxonomy via:
- Sealed class hierarchy (Dart code block)
- Exception mapping table
- UI error handling code

But has **no sequence diagrams** showing how errors propagate across layers. By contrast LLD § 7.4 has one mermaid `sequenceDiagram` for "network 500 with stale cache fallback". HLD needs equivalents at the architectural level to make error flow legible without diving into the LLD.

## Goal

Add 4 sequence diagrams to HLD § 5 — one per error category in the taxonomy — using mermaid (consistent with LLD § 7). Each diagram shows: trigger → exception source → mapping point → Failure class → UI surface.

## Phases

| # | Phase | File | Status |
|---|---|---|---|
| 01 | Add HLD error sequence diagrams | [phase-01-add-hld-error-sequences.md](phase-01-add-hld-error-sequences.md) | ✅ Complete |

## Key Dependencies

- Existing HLD § 5 (lines 282–392 in `docs/system-architecture.md`)
- LLD § 7.4 (mermaid style reference)
- HLD § 3 (SWR ASCII flow — for cross-reference)

## Success Criteria

- 4 mermaid sequence diagrams added to HLD § 5
- Each diagram cross-references the Failure class in the mapping table
- Markdown renders cleanly (mermaid v11 syntax)
- No code changes; no LLD changes

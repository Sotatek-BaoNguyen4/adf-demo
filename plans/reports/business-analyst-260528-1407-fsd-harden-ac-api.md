# FSD Hardening Report — Acceptance Criteria + API Contracts

**Date**: 2026-05-28
**Scope**: ADF Demo (mobile) — Home module
**FSD Version**: 1.0 → 1.1

## Summary

Closed the two lowest-scoring gaps in `docs/project-fsd.md`:
1. No acceptance criteria existed.
2. API contracts were inline TS-ish pseudo-schemas without status codes, examples, pagination, headers, or caching.

## Acceptance Criteria Added

New `## 2. Acceptance Criteria` section (placed after Feature Specs, later sections renumbered 3..8). Total: **14 ACs** across FR-HOME-001..005.

| FR | AC count | Coverage |
|----|----------|----------|
| FR-HOME-001 (banner) | 4 | success render <500ms, 5s auto-rotate, swipe halts rotation, 500 fallback |
| FR-HOME-002 (now-showing) | 3 | paginated success, empty list, cached fallback when offline |
| FR-HOME-003 (coming-soon) | 2 | success with locale-formatted dates, empty list |
| FR-HOME-004 (recommended) | 3 | authenticated 200 sorted by matchPercentage, 401 hides section, empty hides section |
| FR-HOME-005 (bottom nav) | 2 | tab switch updates active state, deep link preserves active tab |

All ACs link to `UC-HOME-001`; AC summary block added to the use case file with backlink to FSD §2.

## API Contracts Tightened

Rewrote `## 5. API Contracts` (was §4). For all 4 endpoints now specified:

- Method, Path, Auth (Public vs Bearer JWT)
- Required headers (`Accept`, `Accept-Language`, `Authorization` where applicable)
- Query param tables (`page` ≥1, `limit` 1..50 default 10)
- Request body (`None`)
- `200 OK` JSON example + field table (type, nullable, description)
- Shared pagination envelope `{ data, meta: { page, limit, total, hasNext } }`
- Shared error envelope `{ error: { code, message, requestId } }`
- Error status enumeration: 400, 401 (recommended only), 429, 500; 304 for banners (ETag)
- Caching: `Cache-Control` per endpoint; public lists 5min, recommended 2min private
- Rate limit hints: 60/min/IP public, 120/min/user authenticated

Endpoints tightened:
1. `GET /api/v1/home/banners`
2. `GET /api/v1/movies/now-showing`
3. `GET /api/v1/movies/coming-soon`
4. `GET /api/v1/movies/recommended`

## Files Touched

- `/Volumes/Dev/dev_env/sotatek/adf_demo/docs/project-fsd.md` — version bump 1.0→1.1, date 2026-05-28, new §2 ACs, rewritten §5 API contracts, sections renumbered.
- `/Volumes/Dev/dev_env/sotatek/adf_demo/docs/usecases/home/uc-home-001-home-banner.md` — Acceptance Criteria section added with 14 AC IDs linking back to FSD §2; date bumped.

No new files created.

## Unresolved Questions

- Auth flow for FR-HOME-004 not documented in FSD (no Auth module yet). AC-HOME-004-02 assumes a JWT acquired elsewhere; should a future `Auth` module own token issuance/refresh contracts?
- BR-002 says "cached locally" but TTL is unspecified. FSD now proposes `max-age=300` (5 min) for public lists and `max-age=120` (2 min) for recommended — confirm with product.
- Banner `targetUrl` may be either a deep link or external URL. Should there be a `type` discriminator (`deep_link` vs `external`) to drive in-app routing vs WebView?
- Rate-limit numbers (60/min/IP, 120/min/user) are placeholders; needs infra/SRE confirmation.
- `meta.total` requires the backend to compute exact counts — acceptable for mocked IMDB data but may need to drop to cursor-based pagination at scale.

---
phase: 01
title: Data Model + Provider Extensions
status: completed
effort: M
depends_on: []
---

# Phase 01 — Data Model + Provider Extensions

## Context Links
- Mockup: `docs/design-mockups/home-screen/index.html` (lines 53–57 — trending shape with `rank`, `views`; lines 266–270 — coming-soon `date`)
- LLD: `docs/lld-home-mvp.md` §5 (cache envelopes + Hive typeIds)
- FSD: `docs/project-fsd.md` §4 (endpoint payload shapes)
- Predecessor phase: `plans/260527-1439-full-home-mvp/phase-04-home-data.md`

## Overview
- **Priority:** P1 (blocker for phases 02–04)
- **Status:** pending
- **Description:** Extend `Movie` entity + `MovieDto` with two optional fields (`rank`, `views`) so the same entity covers the new Trending shape. Rename the `recommended` provider to `trending` (preserves `matchPercentage` field as nullable for backward compat). Update fixtures.

## Key Insights
- Hive `typeId` for `MovieDto` is **3** — must NOT change. New fields appended at `@HiveField(7)` and `@HiveField(8)` are safe because old cached records simply deserialize them as `null`.
- Mockup `views` is a presentation string ("2.4M"). Keep as `String?` to skip number-formatting logic in MVP.
- `releaseDate` already exists on `Movie` for now-showing — no change needed. Coming-Soon date badge reads `expectedReleaseDate`.
- Renaming endpoint key (`/api/v1/movies/recommended` → `/api/v1/movies/trending`) would break Hive cache key continuity AND break the mock interceptor. Keep the network path the same and only rename the **provider** + **section title**.

## Requirements
**Functional**
- `Movie.rank: int?` — 1-based weekly trending rank
- `Movie.views: String?` — formatted display string ("2.4M")
- `trendingProvider` exposes `Future<List<Movie>>` with `rank` populated
- Existing widgets continue to compile (matchPercentage stays nullable)

**Non-Functional**
- No Hive cache wipe required (additive optional fields)
- `flutter analyze` clean
- `dart run build_runner build --delete-conflicting-outputs` succeeds

## Architecture
```
Movie (+ rank, views)            <-- entity (domain)
   ^
   |
MovieDto (+ @HiveField(7), (8))  <-- DTO (data)
   ^
   |
trending.json (renamed fixture, + rank, views)
   ^
   |
HomeRemoteSource.getTrending()   <-- alias method (still hits /recommended path)
   ^
   |
trendingProvider (renamed from recommendedProvider)
```

## Related Code Files
**MODIFY**
- `lib/features/home/domain/entities/movie.dart` — add `rank`, `views`
- `lib/features/home/data/dto/movie_dto.dart` — add `@HiveField(7) rank`, `@HiveField(8) views` + mapper
- `lib/features/home/data/sources/home_remote_source.dart` — add `getTrending()` (alias to `/api/v1/movies/recommended` path; OR keep `getRecommended` and rename in provider only)
- `lib/features/home/data/home_repository_impl.dart` — add `getTrending` repository method (alias)
- `lib/features/home/domain/home_repository.dart` — add `getTrending` abstract method
- `lib/features/home/presentation/home_screen.dart` — swap import + watch call
- `assets/fixtures/recommended.json` → augment with `rank` + `views` for top 3 entries (no rename — endpoint path unchanged)

**CREATE**
- `lib/features/home/presentation/providers/trending_provider.dart` — `@riverpod class Trending` (parallel to existing `recommended_provider.dart`; thin delegation)

**DELETE**
- `lib/features/home/presentation/providers/recommended_provider.dart` (after migration; keep `.g.dart` regeneration step)
- `lib/features/home/presentation/providers/recommended_provider.g.dart`

## Implementation Steps
1. Add `rank` + `views` fields to `Movie` freezed class.
2. Add `@HiveField(7) int? rank` + `@HiveField(8) String? views` to `MovieDto`. Update `toEntity()` extension.
3. Run `dart run build_runner build --delete-conflicting-outputs`. Confirm `movie.freezed.dart`, `movie_dto.freezed.dart`, `movie_dto.g.dart` regenerate cleanly.
4. Add `getTrending({bool forceRefresh = false})` to `HomeRepository` interface returning `Future<List<Movie>>`.
5. In `HomeRepositoryImpl`, route `getTrending` to existing `_fetchMovies(_kKeyRecommended, _remote.getRecommended, ...)` — same cache key, same endpoint.
6. Create `trending_provider.dart` mirroring `recommended_provider.dart` shape but calling `getTrending()`.
7. Update `assets/fixtures/recommended.json`: add `"rank": 1..3` and `"views": "2.4M"|"1.9M"|"1.5M"` to all entries.
8. In `home_screen.dart`, replace `recommendedProvider` import + `ref.watch` with `trendingProvider`.
9. Delete `recommended_provider.dart` + its generated `.g.dart` once unreferenced.
10. Run `flutter analyze` → 0 issues; run existing tests → still green.

## Todo List
- [x] Add `rank`, `views` to `Movie` entity
- [x] Add `@HiveField(7)`, `@HiveField(8)` to `MovieDto`
- [x] Regenerate freezed/json/hive code
- [x] Add `getTrending` to repository interface + impl
- [x] Create `trending_provider.dart`
- [x] Update `recommended.json` fixture with rank + views
- [x] Swap provider usage in `home_screen.dart`
- [x] Delete `recommended_provider.dart` + `.g.dart`
- [x] `flutter analyze` clean
- [x] Existing tests still pass

## Success Criteria
- `Movie` has nullable `rank` + `views`
- `trendingProvider` resolves with rank-ordered list from fixture
- No Hive migration needed (verify by clearing cache then warm-loading is identical to cold)
- All existing unit + widget tests pass with no modification

## Risk Assessment
- **Hive field collision** — `@HiveField(7)`/`(8)` must not already exist (only 0–6 used) → CONFIRMED safe.
- **Provider rename breaking imports** — fix by searching `recommendedProvider` codebase-wide before delete.

## Security Considerations
- None — additive metadata fields, no auth surface change.

## Next Steps
- Unblocks phase 02 (banner overlay reads rating/title from existing `Banner`), phase 03 (chips have no data dep), phase 04 (Trending list reads `rank` + `views`).

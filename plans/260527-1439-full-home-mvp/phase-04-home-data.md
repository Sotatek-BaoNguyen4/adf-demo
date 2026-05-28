---
phase: 04
title: Home data + domain
status: pending
priority: P0
effort: M
depends_on: [03]
---

# Phase 04 — Home data + domain

## Context Links
- HLD §4.2 (folder), §4.3 (data flow), §7.3 (SWR)
- LLD §6 `HomeRepository` contract, §4.5 fixture schemas
- FSD §4 API contracts, §5 data models

## Overview
Implement domain entities, DTOs, fixture JSON, remote+local sources, and `HomeRepositoryImpl` with stale-while-revalidate semantics per LLD §6.

## Key Insights
- DTO ↔ Entity boundary: DTOs match FSD §4 fields byte-for-byte; Entities are presentation-shaped.
- Freezed handles immutability + copyWith + ==; json_serializable handles fromJson/toJson.
- `HomeRepositoryImpl` is the **only** code that catches DioException + HiveError → maps to `Failure`.
- Concrete Hive adapter generation happens here once DTOs exist — wire into `hive_bootstrap.dart`.

## Requirements
**Functional**
- `Movie` and `Banner` entities (pure Dart, freezed).
- `MovieDto` + `BannerDto` (freezed + json_serializable + Hive @HiveType per LLD §5.2 typeIds 3, 4).
- 4 fixture JSON files in `assets/fixtures/` matching LLD §4.5 schemas.
- `HomeRemoteSource` — 4 GET methods using Dio, return parsed DTO lists.
- Typed `LocalCache` methods filled in (`readMovies`/`writeMovies`/`readBanners`/`writeBanners`).
- `CacheEnvelope` concrete adapters generated (typeIds 1, 2).
- `HomeRepositoryImpl` implements SWR algorithm (LLD §6) for all 4 endpoints.
- `hive_bootstrap.dart` registers all 4 adapters.

**Non-functional**
- All files <200 LOC.
- Fixture JSON validated against DTO via unit test (phase 07).

## Architecture
```
features/home/
├── domain/
│   ├── entities/movie.dart           # freezed
│   ├── entities/banner.dart          # freezed
│   └── home_repository.dart          # abstract (LLD §6 interface)
└── data/
    ├── dto/
    │   ├── movie_dto.dart            # freezed + json + HiveType(3)
    │   └── banner_dto.dart           # freezed + json + HiveType(4)
    ├── sources/
    │   ├── home_remote_source.dart   # Dio calls
    │   └── home_local_source.dart    # wraps LocalCache typed methods
    └── home_repository_impl.dart     # SWR orchestration
```

## Related Code Files
**Create**
- `lib/features/home/domain/entities/movie.dart` (<80 LOC)
- `lib/features/home/domain/entities/banner.dart` (<60 LOC)
- `lib/features/home/domain/home_repository.dart` (<40 LOC, abstract)
- `lib/features/home/data/dto/movie_dto.dart` (<100 LOC) + `.g.dart` + `.freezed.dart`
- `lib/features/home/data/dto/banner_dto.dart` (<80 LOC) + gen
- `lib/features/home/data/sources/home_remote_source.dart` (<100 LOC, LLD §5 budget)
- `lib/features/home/data/sources/home_local_source.dart` (<100 LOC)
- `lib/features/home/data/home_repository_impl.dart` (<150 LOC)
- `assets/fixtures/banners.json`
- `assets/fixtures/now-showing.json`
- `assets/fixtures/coming-soon.json`
- `assets/fixtures/recommended.json`

**Modify**
- `lib/core/storage/local_cache.dart` — add typed `readMovies/writeMovies/readBanners/writeBanners` now that DTOs exist
- `lib/core/storage/hive_bootstrap.dart` — register 4 adapters per LLD §5.2

## Implementation Steps
1. **Entities** — `Movie {id, title, posterUrl, rating?, releaseDate?, expectedReleaseDate?, matchPercentage?}` covers all 3 movie endpoints. `Banner {id, imageUrl, targetUrl, title}`. Freezed unions not needed; nullable fields suffice (FSD §5).
2. **DTOs** — mirror FSD §4 response fields exactly. `MovieDto.toEntity()` mapper. `@HiveType(typeId: 3)` for MovieDto, `(4)` for BannerDto.
3. **Fixture JSON** — author 4 files per LLD §4.5. Use real IMDB poster URLs (HLD decision #3). Aim for 8-10 items per list.
4. **`HomeRemoteSource`** — one method per endpoint:
   ```dart
   Future<List<MovieDto>> getNowShowing() async {
     final res = await _dio.get('/api/v1/movies/now-showing');
     return (res.data as List).map((j) => MovieDto.fromJson(j)).toList();
   }
   ```
5. **`HomeLocalSource`** — thin wrapper:
   ```dart
   Future<CacheEnvelope<List<MovieDto>>?> readMovies(String key) => _cache.readMovies(key);
   Future<void> writeMovies(String key, List<MovieDto> dtos) => _cache.writeMovies(key, dtos);
   ```
6. **`LocalCache` typed methods** — implement read/write with concrete `CacheEnvelope<List<MovieDto>>` / `<List<BannerDto>>`. Wrap HiveError → `CacheReadFailure` / `CacheWriteFailure`.
7. **Generate adapters** — `dart run build_runner build --delete-conflicting-outputs`. Verify typeIds match LLD §5.2.
8. **Register in `hive_bootstrap.dart`** — 4 adapters per LLD §5.5 code block.
9. **`HomeRepositoryImpl`** — implement SWR per LLD §6 pseudocode for all 4 endpoints. Map DioException + HiveError → `Failure`. Stale-fallback on network error when cache exists.
10. Run `flutter analyze` + `dart run build_runner build` → clean.

## Todo List
- [ ] Entities: Movie, Banner
- [ ] DTOs: MovieDto, BannerDto (freezed+json+Hive)
- [ ] 4 fixture JSON files (LLD §4.5 schemas)
- [ ] HomeRemoteSource (4 methods)
- [ ] LocalCache typed methods (movies + banners read/write)
- [ ] HomeLocalSource
- [ ] Generate Hive adapters (typeIds 1,2,3,4)
- [ ] Wire adapters in hive_bootstrap.dart
- [ ] HomeRepositoryImpl w/ SWR + stale-fallback (4 methods)
- [ ] Error mapping: Dio + Hive → Failure
- [ ] `flutter analyze` clean

## Success Criteria
- `HomeRepositoryImpl.getNowShowing()` returns `List<Movie>` end-to-end (fixture → DTO → entity)
- Cache miss → Dio → write → return
- Cache hit + fresh → return without Dio call
- Network error + stale cache → returns stale payload
- All files <200 LOC
- `dart run build_runner build` clean

## Risk Assessment
| Risk | Mitigation |
|---|---|
| Freezed + Hive annotation conflict | Use `@freezed` + `@HiveType` on same class — verified pattern; ensure `mixin _$Foo` line present |
| Fixture URLs 404 at runtime | Use stable IMDB-hosted URLs (HLD §7.5); fallback handled by `cached_network_image` placeholder |
| typeId collision with phase 03 stub | typeId 0 is generic `CacheEnvelope` shell only; concrete adapters get 1, 2 — kept distinct per LLD §5.2 |

## Security Considerations
- DTOs do not log full payload in release (no `print` in mappers).
- Cache keys are endpoint paths only — no PII.

## Next Steps
Unblocks phase 05 (UI consumes `HomeRepository`).

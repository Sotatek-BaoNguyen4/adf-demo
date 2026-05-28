// Unit tests for HomeLocalSource (thin wrapper around LocalCache).
// Coverage:
//   - readMovies → delegates to cache
//   - writeMovies → delegates to cache
//   - readBanners → delegates to cache
//   - writeBanners → delegates to cache
//   - Returns/throws match cache behavior exactly

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'package:adf_demo/core/errors/failure.dart';
import 'package:adf_demo/core/storage/cache_policy.dart';
import 'package:adf_demo/core/storage/local_cache.dart';
import 'package:adf_demo/features/home/data/dto/banner_dto.dart';
import 'package:adf_demo/features/home/data/dto/cached_banners_envelope.dart';
import 'package:adf_demo/features/home/data/dto/cached_movies_envelope.dart';
import 'package:adf_demo/features/home/data/dto/movie_dto.dart';
import 'package:adf_demo/features/home/data/sources/home_local_source.dart';

// ─── Fakes ──────────────────────────────────────────────────────────────────

class _FakeLocalCache implements LocalCache {
  CachedMoviesEnvelope? cachedMovies;
  CachedBannersEnvelope? cachedBanners;
  bool throwOnMoviesRead = false;
  bool throwOnMoviesWrite = false;
  bool throwOnBannersRead = false;
  bool throwOnBannersWrite = false;

  int readMoviesCalls = 0;
  int writeMoviesCalls = 0;
  int readBannersCalls = 0;
  int writeBannersCalls = 0;

  @override
  Future<CachedMoviesEnvelope?> readMovies(String key) async {
    readMoviesCalls++;
    if (throwOnMoviesRead) {
      throw const CacheReadFailure(
        'test failure',
        boxName: 'movies_cache',
      );
    }
    return cachedMovies;
  }

  @override
  Future<void> writeMovies(String key, List<MovieDto> dtos) async {
    writeMoviesCalls++;
    if (throwOnMoviesWrite) {
      throw const CacheWriteFailure(
        'test failure',
        boxName: 'movies_cache',
      );
    }
    cachedMovies = CachedMoviesEnvelope(
      payload: dtos,
      savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      schemaVersion: kSchemaVersion,
    );
  }

  @override
  Future<CachedBannersEnvelope?> readBanners(String key) async {
    readBannersCalls++;
    if (throwOnBannersRead) {
      throw const CacheReadFailure(
        'test failure',
        boxName: 'banners_cache',
      );
    }
    return cachedBanners;
  }

  @override
  Future<void> writeBanners(String key, List<BannerDto> dtos) async {
    writeBannersCalls++;
    if (throwOnBannersWrite) {
      throw const CacheWriteFailure(
        'test failure',
        boxName: 'banners_cache',
      );
    }
    cachedBanners = CachedBannersEnvelope(
      payload: dtos,
      savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      schemaVersion: kSchemaVersion,
    );
  }

  @override
  Future<void> clearAll() async {
    cachedMovies = null;
    cachedBanners = null;
  }

  @override
  Future<void> evict(String boxName, String key) async {
    // No-op for this fake
  }

  @override
  Box<dynamic> get bannersBox =>
      throw UnimplementedError('not used in tests');

  @override
  Box<dynamic> get moviesBox =>
      throw UnimplementedError('not used in tests');
}

// ─── Fixtures ───────────────────────────────────────────────────────────────

const _movieDto = MovieDto(id: 'm1', title: 'Test Movie', posterUrl: 'p.jpg');
const _bannerDto = BannerDto(
  id: 'b1',
  imageUrl: 'i.jpg',
  title: 'Test Banner',
  targetUrl: 'adf://test',
);

CachedMoviesEnvelope _moviesEnv() => CachedMoviesEnvelope(
      payload: const [_movieDto],
      savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      schemaVersion: kSchemaVersion,
    );

CachedBannersEnvelope _bannersEnv() => CachedBannersEnvelope(
      payload: const [_bannerDto],
      savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      schemaVersion: kSchemaVersion,
    );

void main() {
  group('HomeLocalSource', () {
    late _FakeLocalCache fakeCache;
    late HomeLocalSource source;

    setUp(() {
      fakeCache = _FakeLocalCache();
      source = HomeLocalSource(fakeCache as dynamic);
    });

    group('Movies', () {
      test('readMovies delegates to cache', () async {
        fakeCache.cachedMovies = _moviesEnv();

        final result = await source.readMovies('now_showing');

        expect(result, isNotNull);
        expect(result!.payload, hasLength(1));
        expect(fakeCache.readMoviesCalls, 1);
      });

      test('readMovies returns null from cache miss', () async {
        final result = await source.readMovies('missing_key');

        expect(result, isNull);
        expect(fakeCache.readMoviesCalls, 1);
      });

      test('readMovies propagates cache read failure', () async {
        fakeCache.throwOnMoviesRead = true;

        expect(
          () => source.readMovies('key'),
          throwsA(isA<CacheReadFailure>()),
        );
      });

      test('writeMovies delegates to cache', () async {
        await source.writeMovies('now_showing', const [_movieDto]);

        expect(fakeCache.writeMoviesCalls, 1);
        expect(fakeCache.cachedMovies, isNotNull);
        expect(fakeCache.cachedMovies!.payload, hasLength(1));
      });

      test('writeMovies propagates cache write failure', () async {
        fakeCache.throwOnMoviesWrite = true;

        expect(
          () => source.writeMovies('key', const [_movieDto]),
          throwsA(isA<CacheWriteFailure>()),
        );
      });

      test('writeMovies with empty list', () async {
        await source.writeMovies('empty_key', []);

        expect(fakeCache.writeMoviesCalls, 1);
        expect(fakeCache.cachedMovies!.payload, isEmpty);
      });
    });

    group('Banners', () {
      test('readBanners delegates to cache', () async {
        fakeCache.cachedBanners = _bannersEnv();

        final result = await source.readBanners('banners');

        expect(result, isNotNull);
        expect(result!.payload, hasLength(1));
        expect(fakeCache.readBannersCalls, 1);
      });

      test('readBanners returns null from cache miss', () async {
        final result = await source.readBanners('missing_key');

        expect(result, isNull);
        expect(fakeCache.readBannersCalls, 1);
      });

      test('readBanners propagates cache read failure', () async {
        fakeCache.throwOnBannersRead = true;

        expect(
          () => source.readBanners('key'),
          throwsA(isA<CacheReadFailure>()),
        );
      });

      test('writeBanners delegates to cache', () async {
        await source.writeBanners('banners', const [_bannerDto]);

        expect(fakeCache.writeBannersCalls, 1);
        expect(fakeCache.cachedBanners, isNotNull);
        expect(fakeCache.cachedBanners!.payload, hasLength(1));
      });

      test('writeBanners propagates cache write failure', () async {
        fakeCache.throwOnBannersWrite = true;

        expect(
          () => source.writeBanners('key', const [_bannerDto]),
          throwsA(isA<CacheWriteFailure>()),
        );
      });

      test('writeBanners with empty list', () async {
        await source.writeBanners('empty_key', []);

        expect(fakeCache.writeBannersCalls, 1);
        expect(fakeCache.cachedBanners!.payload, isEmpty);
      });
    });

  });
}

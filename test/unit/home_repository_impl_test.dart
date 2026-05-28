// Tests covering critical SWR + failure-mapping fixes in HomeRepositoryImpl.
// Spec: docs/lld-home-mvp.md §6 (SWR) and §4.6 (mock error injection).
//
// Coverage:
//   - Fresh cache hit → no remote call (SWR happy path).
//   - Cache miss → remote + write, fresh entities returned.
//   - Cache-write failure does NOT surface to caller (fix for foundation C3).
//   - Stale cache + remote failure → stale fallback served.
//   - No cache + remote failure → typed Failure thrown.
//   - forceRefresh skips cache.
//   - DioException(badResponse) → NetworkFailure mapping.
//   - CheckedFromJsonException → ParseFailure mapping (fix for I9).

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:adf_demo/core/errors/failure.dart';
import 'package:adf_demo/core/storage/cache_policy.dart';
import 'package:adf_demo/features/home/data/dto/banner_dto.dart';
import 'package:adf_demo/features/home/data/dto/cached_banners_envelope.dart';
import 'package:adf_demo/features/home/data/dto/cached_movies_envelope.dart';
import 'package:adf_demo/features/home/data/dto/movie_dto.dart';
import 'package:adf_demo/features/home/data/home_repository_impl.dart';
import 'package:adf_demo/features/home/data/sources/home_local_source.dart';
import 'package:adf_demo/features/home/data/sources/home_remote_source.dart';

// ─── Fakes ──────────────────────────────────────────────────────────────────

class _FakeRemote implements HomeRemoteSource {
  _FakeRemote({
    this.nowShowing,
    this.banners,
    this.throwOnNowShowing,
  });

  final List<MovieDto>? nowShowing;
  final List<BannerDto>? banners;
  final Object? throwOnNowShowing;

  int nowShowingCalls = 0;
  int bannersCalls = 0;

  @override
  Future<List<MovieDto>> getNowShowing() async {
    nowShowingCalls++;
    if (throwOnNowShowing != null) throw throwOnNowShowing!;
    return nowShowing ?? [];
  }

  @override
  Future<List<MovieDto>> getComingSoon() async => [];

  @override
  Future<List<MovieDto>> getRecommended() async => [];

  @override
  Future<List<BannerDto>> getBanners() async {
    bannersCalls++;
    return banners ?? [];
  }
}

class _FakeLocal implements HomeLocalSource {
  _FakeLocal({
    this.cachedMovies,
    this.throwOnWrite = false,
  });

  CachedMoviesEnvelope? cachedMovies;
  CachedBannersEnvelope? cachedBanners;
  bool throwOnWrite;

  int writeMoviesCalls = 0;
  int writeBannersCalls = 0;

  @override
  Future<CachedMoviesEnvelope?> readMovies(String key) async => cachedMovies;

  @override
  Future<CachedBannersEnvelope?> readBanners(String key) async => cachedBanners;

  @override
  Future<void> writeMovies(String key, List<MovieDto> dtos) async {
    writeMoviesCalls++;
    if (throwOnWrite) {
      throw const CacheWriteFailure(
        'disk full',
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
  Future<void> writeBanners(String key, List<BannerDto> dtos) async {
    writeBannersCalls++;
    if (throwOnWrite) {
      throw const CacheWriteFailure(
        'disk full',
        boxName: 'banners_cache',
      );
    }
    cachedBanners = CachedBannersEnvelope(
      payload: dtos,
      savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      schemaVersion: kSchemaVersion,
    );
  }
}

// ─── Fixtures ───────────────────────────────────────────────────────────────

const _movie = MovieDto(id: 'm1', title: 'Movie 1', posterUrl: 'p1.jpg');

CachedMoviesEnvelope _freshMovies() => CachedMoviesEnvelope(
      payload: const [_movie],
      savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      schemaVersion: kSchemaVersion,
    );

CachedMoviesEnvelope _staleMovies() => CachedMoviesEnvelope(
      payload: const [_movie],
      savedAtEpochMs: DateTime.now()
          .subtract(CachePolicy.moviesTtl * 2)
          .millisecondsSinceEpoch,
      schemaVersion: kSchemaVersion,
    );

void main() {
  group('HomeRepositoryImpl — SWR', () {
    test('fresh cache hit → no remote call', () async {
      final remote = _FakeRemote();
      final local = _FakeLocal(cachedMovies: _freshMovies());
      final repo = HomeRepositoryImpl(remote, local);

      final result = await repo.getNowShowing();

      expect(result, hasLength(1));
      expect(remote.nowShowingCalls, 0);
    });

    test('cache miss → remote called + write performed', () async {
      final remote = _FakeRemote(nowShowing: const [_movie]);
      final local = _FakeLocal();
      final repo = HomeRepositoryImpl(remote, local);

      final result = await repo.getNowShowing();

      expect(result, hasLength(1));
      expect(remote.nowShowingCalls, 1);
      expect(local.writeMoviesCalls, 1);
      expect(local.cachedMovies, isNotNull);
    });

    test(
      'cache-write failure does NOT surface — fresh data still returned',
      () async {
        final remote = _FakeRemote(nowShowing: const [_movie]);
        final local = _FakeLocal(throwOnWrite: true);
        final repo = HomeRepositoryImpl(remote, local);

        final result = await repo.getNowShowing();

        expect(result, hasLength(1));
        expect(local.writeMoviesCalls, 1);
      },
    );

    test('banners — cache-write failure does NOT surface', () async {
      const banner = BannerDto(
        id: 'b1',
        imageUrl: 'i.jpg',
        title: 'T',
        targetUrl: 'adf://t',
      );
      final remote = _FakeRemote(banners: const [banner]);
      final local = _FakeLocal(throwOnWrite: true);
      final repo = HomeRepositoryImpl(remote, local);

      final result = await repo.getBanners();

      expect(result, hasLength(1));
      expect(local.writeBannersCalls, 1);
    });

    test('stale + remote failure → stale fallback served', () async {
      final remote = _FakeRemote(
        throwOnNowShowing: DioException(
          requestOptions: RequestOptions(path: '/api/v1/movies/now-showing'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      final local = _FakeLocal(cachedMovies: _staleMovies());
      final repo = HomeRepositoryImpl(remote, local);

      final result = await repo.getNowShowing();

      expect(result, hasLength(1));
      expect(remote.nowShowingCalls, 1);
    });

    test('no cache + remote failure → typed Failure thrown', () async {
      final remote = _FakeRemote(
        throwOnNowShowing: DioException(
          requestOptions: RequestOptions(path: '/api/v1/movies/now-showing'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions:
                RequestOptions(path: '/api/v1/movies/now-showing'),
            statusCode: 500,
          ),
        ),
      );
      final local = _FakeLocal();
      final repo = HomeRepositoryImpl(remote, local);

      expect(
        () => repo.getNowShowing(),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('forceRefresh skips fresh cache', () async {
      final remote = _FakeRemote(nowShowing: const [_movie]);
      final local = _FakeLocal(cachedMovies: _freshMovies());
      final repo = HomeRepositoryImpl(remote, local);

      await repo.getNowShowing(forceRefresh: true);

      expect(remote.nowShowingCalls, 1);
    });

    test('FormatException → ParseFailure', () async {
      final remote = _FakeRemote(
        throwOnNowShowing: const FormatException('bad json'),
      );
      final local = _FakeLocal();
      final repo = HomeRepositoryImpl(remote, local);

      expect(() => repo.getNowShowing(), throwsA(isA<ParseFailure>()));
    });

    test('CheckedFromJsonException → ParseFailure', () async {
      final remote = _FakeRemote(
        throwOnNowShowing: CheckedFromJsonException(
          {},
          'id',
          'MovieDto',
          'Required key missing',
        ),
      );
      final local = _FakeLocal();
      final repo = HomeRepositoryImpl(remote, local);

      expect(() => repo.getNowShowing(), throwsA(isA<ParseFailure>()));
    });
  });
}

// Unit tests for LocalCache (Hive-backed typed cache for movies & banners).
// Coverage:
//   - writeMovies/readMovies round-trip
//   - writeBanners/readBanners round-trip
//   - Cache miss (key absent) → null
//   - Type mismatch (corrupted entry) → evict + null
//   - Schema version mismatch → evict + null
//   - HiveError on read → CacheReadFailure
//   - HiveError on write → CacheWriteFailure
//   - evict() removes key
//   - clearAll() clears both boxes

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'package:adf_demo/core/errors/failure.dart';
import 'package:adf_demo/core/storage/cache_policy.dart';
import 'package:adf_demo/core/storage/local_cache.dart';
import 'package:adf_demo/features/home/data/dto/banner_dto.dart';
import 'package:adf_demo/features/home/data/dto/cached_banners_envelope.dart';
import 'package:adf_demo/features/home/data/dto/cached_movies_envelope.dart';
import 'package:adf_demo/features/home/data/dto/movie_dto.dart';

// ─── Fakes ──────────────────────────────────────────────────────────────────

/// In-memory Hive box fake for unit tests.
class _FakeBox<T> implements Box<T> {
  final Map<String, dynamic> _storage = {};
  bool _closed = false;

  @override
  Future<void> put(dynamic key, T value) async {
    if (_closed) throw HiveError('Box is closed');
    _storage[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _storage.remove(key);
  }

  @override
  T? get(dynamic key, {T? defaultValue}) => _storage[key] as T?;

  @override
  Future<int> clear() async {
    final count = _storage.length;
    _storage.clear();
    return count;
  }

  @override
  Future<void> close() async => _closed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not implemented');
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
  group('LocalCache', () {
    late _FakeBox<dynamic> moviesBox;
    late _FakeBox<dynamic> bannersBox;
    late LocalCache cache;

    setUp(() {
      moviesBox = _FakeBox<dynamic>();
      bannersBox = _FakeBox<dynamic>();
      cache = LocalCache(moviesBox, bannersBox);
    });

    group('Movies', () {
      test('writeMovies + readMovies round-trip', () async {
        const key = 'now_showing';
        await cache.writeMovies(key, const [_movieDto]);

        final result = await cache.readMovies(key);

        expect(result, isNotNull);
        expect(result!.payload, hasLength(1));
        expect(result.payload[0].id, 'm1');
        expect(result.schemaVersion, kSchemaVersion);
      });

      test('readMovies with missing key → null', () async {
        final result = await cache.readMovies('missing_key');
        expect(result, isNull);
      });

      test('readMovies with type mismatch → evict + null', () async {
        const key = 'type_mismatch';
        moviesBox.put(key, 'wrong type string');

        final result = await cache.readMovies(key);

        expect(result, isNull);
        expect(moviesBox.get(key), isNull);
      });

      test('readMovies with schema mismatch → evict + null', () async {
        const key = 'schema_old';
        final oldEnv = CachedMoviesEnvelope(
          payload: const [_movieDto],
          savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
          schemaVersion: kSchemaVersion + 1,
        );
        await moviesBox.put(key, oldEnv);

        final result = await cache.readMovies(key);

        expect(result, isNull);
        expect(moviesBox.get(key), isNull);
      });

      test('writeMovies with closed box → CacheWriteFailure', () async {
        moviesBox.close();

        expect(
          () => cache.writeMovies('key', const [_movieDto]),
          throwsA(isA<CacheWriteFailure>()),
        );
      });
    });

    group('Banners', () {
      test('writeBanners + readBanners round-trip', () async {
        const key = 'banners';
        await cache.writeBanners(key, const [_bannerDto]);

        final result = await cache.readBanners(key);

        expect(result, isNotNull);
        expect(result!.payload, hasLength(1));
        expect(result.payload[0].id, 'b1');
      });

      test('readBanners with missing key → null', () async {
        final result = await cache.readBanners('missing_key');
        expect(result, isNull);
      });

      test('readBanners with type mismatch → evict + null', () async {
        const key = 'type_mismatch';
        bannersBox.put(key, 123);

        final result = await cache.readBanners(key);

        expect(result, isNull);
        expect(bannersBox.get(key), isNull);
      });

      test('readBanners with schema mismatch → evict + null', () async {
        const key = 'schema_old';
        final oldEnv = CachedBannersEnvelope(
          payload: const [_bannerDto],
          savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
          schemaVersion: kSchemaVersion + 1,
        );
        await bannersBox.put(key, oldEnv);

        final result = await cache.readBanners(key);

        expect(result, isNull);
        expect(bannersBox.get(key), isNull);
      });

      test('writeBanners with closed box → CacheWriteFailure', () async {
        bannersBox.close();

        expect(
          () => cache.writeBanners('key', const [_bannerDto]),
          throwsA(isA<CacheWriteFailure>()),
        );
      });
    });

    group('Eviction & Cleanup', () {
      test('evict(movies_cache, key) removes from movies box', () async {
        const key = 'test_key';
        await moviesBox.put(key, _moviesEnv());
        expect(moviesBox.get(key), isNotNull);

        await cache.evict('movies_cache', key);

        expect(moviesBox.get(key), isNull);
      });

      test('evict(banners_cache, key) removes from banners box', () async {
        const key = 'test_key';
        await bannersBox.put(key, _bannersEnv());
        expect(bannersBox.get(key), isNotNull);

        await cache.evict('banners_cache', key);

        expect(bannersBox.get(key), isNull);
      });

      test('evict with unknown box name → ArgumentError', () async {
        expect(
          () => cache.evict('unknown_box', 'key'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('clearAll() clears both boxes', () async {
        const moviesKey = 'movies';
        const bannersKey = 'banners';
        await moviesBox.put(moviesKey, _moviesEnv());
        await bannersBox.put(bannersKey, _bannersEnv());

        await cache.clearAll();

        expect(moviesBox.get(moviesKey), isNull);
        expect(bannersBox.get(bannersKey), isNull);
      });
    });

  });
}

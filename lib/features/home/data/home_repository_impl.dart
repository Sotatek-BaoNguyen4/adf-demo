import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../core/errors/failure.dart';
import '../../../core/storage/cache_policy.dart';
import '../domain/entities/banner.dart';
import '../domain/entities/movie.dart';
import '../domain/home_repository.dart';
import 'dto/banner_dto.dart';
import 'dto/cached_banners_envelope.dart';
import 'dto/cached_movies_envelope.dart';
import 'dto/movie_dto.dart';
import 'sources/home_local_source.dart';
import 'sources/home_remote_source.dart';

/// Cache keys align with endpoint paths (LLD §5.6 / decision L2).
const _kKeyBanners = '/api/v1/home/banners';
const _kKeyNowShowing = '/api/v1/movies/now-showing';
const _kKeyComingSoon = '/api/v1/movies/coming-soon';
const _kKeyRecommended = '/api/v1/movies/recommended';

/// Implements [HomeRepository] with stale-while-revalidate semantics (LLD §6).
///
/// SWR algorithm for every method:
///   1. If !forceRefresh: read cache → if fresh → return entities, done.
///   2. Fetch remote → on success: write cache + return entities.
///   3. On any error: if stale cache exists → return stale entities (offline
///      UX); else rethrow as typed [Failure].
///
/// This is the ONLY place that catches [DioException] and maps to [Failure].
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteSource _remote;
  final HomeLocalSource _local;

  const HomeRepositoryImpl(this._remote, this._local);

  // ── Banners ────────────────────────────────────────────────────────────────

  @override
  Future<List<Banner>> getBanners({bool forceRefresh = false}) async {
    final cached = await _readBanners(_kKeyBanners);
    if (!forceRefresh &&
        cached != null &&
        cached.age < CachePolicy.bannersTtl) {
      return cached.payload.map((d) => d.toEntity()).toList();
    }
    try {
      final dtos = await _remote.getBanners();
      await _tryWriteBanners(_kKeyBanners, dtos);
      return dtos.map((d) => d.toEntity()).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      final failure = _mapException(e, _kKeyBanners);
      if (cached != null) {
        return cached.payload.map((d) => d.toEntity()).toList();
      }
      throw failure;
    }
  }

  // ── Movie endpoints ────────────────────────────────────────────────────────

  @override
  Future<List<Movie>> getNowShowing({bool forceRefresh = false}) =>
      _fetchMovies(_kKeyNowShowing, _remote.getNowShowing,
          forceRefresh: forceRefresh);

  @override
  Future<List<Movie>> getComingSoon({bool forceRefresh = false}) =>
      _fetchMovies(_kKeyComingSoon, _remote.getComingSoon,
          forceRefresh: forceRefresh);

  @override
  Future<List<Movie>> getRecommended({bool forceRefresh = false}) =>
      _fetchMovies(_kKeyRecommended, _remote.getRecommended,
          forceRefresh: forceRefresh);

  /// Aliases [getRecommended] — same endpoint + cache key, different provider name.
  @override
  Future<List<Movie>> getTrending({bool forceRefresh = false}) =>
      _fetchMovies(_kKeyRecommended, _remote.getRecommended,
          forceRefresh: forceRefresh);

  // ── SWR helper shared by all movie endpoints ───────────────────────────────

  Future<List<Movie>> _fetchMovies(
    String key,
    Future<List<MovieDto>> Function() fetch, {
    required bool forceRefresh,
  }) async {
    final cached = await _readMovies(key);
    if (!forceRefresh &&
        cached != null &&
        cached.age < CachePolicy.moviesTtl) {
      return cached.payload.map((d) => d.toEntity()).toList();
    }
    try {
      final dtos = await fetch();
      await _tryWriteMovies(key, dtos);
      return dtos.map((d) => d.toEntity()).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      final failure = _mapException(e, key);
      if (cached != null) {
        return cached.payload.map((d) => d.toEntity()).toList();
      }
      throw failure;
    }
  }

  // ── Cache write helpers — swallow CacheWriteFailure (fresh data wins) ─────
  //
  // LLD §6 SWR: when the network succeeds we MUST return the fresh entities.
  // A disk-write failure (full disk, corrupt box) is a degraded-cache concern,
  // not a user-facing data concern — log and continue.

  Future<void> _tryWriteMovies(String key, List<MovieDto> dtos) async {
    try {
      await _local.writeMovies(key, dtos);
    } on CacheWriteFailure catch (e) {
      log(
        'Cache write failed for "$key" — fresh data still returned. cause: $e',
        name: 'HomeRepository',
      );
    }
  }

  Future<void> _tryWriteBanners(String key, List<BannerDto> dtos) async {
    try {
      await _local.writeBanners(key, dtos);
    } on CacheWriteFailure catch (e) {
      log(
        'Cache write failed for "$key" — fresh data still returned. cause: $e',
        name: 'HomeRepository',
      );
    }
  }

  // ── Cache read helpers — absorb CacheReadFailure as miss ──────────────────

  Future<CachedMoviesEnvelope?> _readMovies(String key) async {
    try {
      return await _local.readMovies(key);
    } on CacheReadFailure {
      return null;
    }
  }

  Future<CachedBannersEnvelope?> _readBanners(String key) async {
    try {
      return await _local.readBanners(key);
    } on CacheReadFailure {
      return null;
    }
  }

  // ── Exception → Failure mapping (only place this conversion happens) ───────

  Failure _mapException(Object e, String path) {
    if (e is DioException) {
      return switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          TimeoutFailure('Request timed out: $path', e),
        DioExceptionType.badResponse => NetworkFailure(
            'HTTP ${e.response?.statusCode}: $path',
            statusCode: e.response?.statusCode,
            cause: e,
          ),
        _ => NetworkFailure('Network error: $path', cause: e),
      };
    }
    if (e is FormatException) {
      return ParseFailure('JSON parse error at $path', path: path, cause: e);
    }
    if (e is CheckedFromJsonException) {
      // Missing/typo'd required field from generated *_fromJson — also a
      // parse-shape failure from the caller's point of view (LLD §4.6).
      return ParseFailure('JSON shape error at $path', path: path, cause: e);
    }
    return UnknownFailure('Unexpected error at $path', e);
  }
}

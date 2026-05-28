import 'package:hive_ce/hive.dart';

import '../../features/home/data/dto/banner_dto.dart';
import '../../features/home/data/dto/cached_banners_envelope.dart';
import '../../features/home/data/dto/cached_movies_envelope.dart';
import '../../features/home/data/dto/movie_dto.dart';
import '../errors/failure.dart';
import 'cache_policy.dart';

/// Typed wrapper around the two Hive cache boxes.
///
/// This is the only public storage API — raw boxes are private.
/// Boxes are injected so tests can swap in in-memory boxes.
///
/// Read semantics (LLD §5.4):
///   1. box.get(key) → null → return null (cache miss).
///   2. schemaVersion mismatch → silent delete + return null.
///   3. Else return envelope (caller checks freshness via [CachePolicy]).
///
/// Write semantics:
///   1. Build envelope with now() + kSchemaVersion.
///   2. box.put(key, envelope).
///   3. HiveError → throw [CacheWriteFailure].
class LocalCache {
  final Box<dynamic> _moviesBox;
  final Box<dynamic> _bannersBox;

  LocalCache(this._moviesBox, this._bannersBox);

  // ── Raw box accessors (internal use / tests) ─────────────────────────────

  Box<dynamic> get moviesBox => _moviesBox;
  Box<dynamic> get bannersBox => _bannersBox;

  // ── Movies ────────────────────────────────────────────────────────────────

  /// Returns the cached movies envelope for [key], or null on miss/mismatch.
  /// Throws [CacheReadFailure] on HiveError.
  Future<CachedMoviesEnvelope?> readMovies(String key) async {
    try {
      final raw = _moviesBox.get(key);
      if (raw == null) return null;
      if (raw is! CachedMoviesEnvelope) {
        // Corrupted entry of wrong type (e.g. adapter typeId collision after
        // schema rename). Evict and treat as cache miss.
        await _moviesBox.delete(key);
        return null;
      }
      if (raw.schemaVersion != kSchemaVersion) {
        await _moviesBox.delete(key);
        return null;
      }
      return raw;
    } on HiveError catch (e) {
      throw CacheReadFailure(
        'Failed to read movies cache for key "$key"',
        boxName: 'movies_cache',
        cause: e,
      );
    }
  }

  /// Writes [dtos] into the movies cache under [key].
  /// Throws [CacheWriteFailure] on HiveError.
  Future<void> writeMovies(String key, List<MovieDto> dtos) async {
    try {
      final env = CachedMoviesEnvelope(
        payload: dtos,
        savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        schemaVersion: kSchemaVersion,
      );
      await _moviesBox.put(key, env);
    } on HiveError catch (e) {
      throw CacheWriteFailure(
        'Failed to write movies cache for key "$key"',
        boxName: 'movies_cache',
        cause: e,
      );
    }
  }

  // ── Banners ───────────────────────────────────────────────────────────────

  /// Returns the cached banners envelope for [key], or null on miss/mismatch.
  /// Throws [CacheReadFailure] on HiveError.
  Future<CachedBannersEnvelope?> readBanners(String key) async {
    try {
      final raw = _bannersBox.get(key);
      if (raw == null) return null;
      if (raw is! CachedBannersEnvelope) {
        // Corrupted entry of wrong type — evict and treat as cache miss.
        await _bannersBox.delete(key);
        return null;
      }
      if (raw.schemaVersion != kSchemaVersion) {
        await _bannersBox.delete(key);
        return null;
      }
      return raw;
    } on HiveError catch (e) {
      throw CacheReadFailure(
        'Failed to read banners cache for key "$key"',
        boxName: 'banners_cache',
        cause: e,
      );
    }
  }

  /// Writes [dtos] into the banners cache under [key].
  /// Throws [CacheWriteFailure] on HiveError.
  Future<void> writeBanners(String key, List<BannerDto> dtos) async {
    try {
      final env = CachedBannersEnvelope(
        payload: dtos,
        savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        schemaVersion: kSchemaVersion,
      );
      await _bannersBox.put(key, env);
    } on HiveError catch (e) {
      throw CacheWriteFailure(
        'Failed to write banners cache for key "$key"',
        boxName: 'banners_cache',
        cause: e,
      );
    }
  }

  // ── Eviction helpers ──────────────────────────────────────────────────────

  /// Removes [key] from the named box. No-op if key absent.
  Future<void> evict(String boxName, String key) async {
    final box = _boxByName(boxName);
    await box.delete(key);
  }

  /// Clears all entries from both boxes. Dev/debug use only.
  Future<void> clearAll() async {
    await Future.wait([_moviesBox.clear(), _bannersBox.clear()]);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Box<dynamic> _boxByName(String name) => switch (name) {
        'movies_cache' => _moviesBox,
        'banners_cache' => _bannersBox,
        _ => throw ArgumentError('Unknown box name: $name'),
      };
}

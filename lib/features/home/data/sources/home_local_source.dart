import '../../../../core/storage/local_cache.dart';
import '../dto/banner_dto.dart';
import '../dto/cached_banners_envelope.dart';
import '../dto/cached_movies_envelope.dart';
import '../dto/movie_dto.dart';

/// Thin wrapper around [LocalCache] typed methods for home-screen data.
///
/// Exists to give [HomeRepositoryImpl] a focused, mockable seam for the
/// local persistence layer. No business logic here — all policy lives in
/// [HomeRepositoryImpl] and [CachePolicy].
class HomeLocalSource {
  final LocalCache _cache;

  const HomeLocalSource(this._cache);

  // ── Movies ────────────────────────────────────────────────────────────────

  Future<CachedMoviesEnvelope?> readMovies(String key) =>
      _cache.readMovies(key);

  Future<void> writeMovies(String key, List<MovieDto> dtos) =>
      _cache.writeMovies(key, dtos);

  // ── Banners ───────────────────────────────────────────────────────────────

  Future<CachedBannersEnvelope?> readBanners(String key) =>
      _cache.readBanners(key);

  Future<void> writeBanners(String key, List<BannerDto> dtos) =>
      _cache.writeBanners(key, dtos);
}

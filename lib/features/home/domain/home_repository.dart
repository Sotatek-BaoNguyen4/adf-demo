import 'entities/banner.dart';
import 'entities/movie.dart';

/// Abstract contract for the home-screen data layer.
///
/// Implementation lives in `features/home/data/home_repository_impl.dart`.
/// All methods throw a [Failure] subclass on error (never raw exceptions).
/// SWR semantics: fresh cache → return immediately; stale/miss → fetch + cache.
abstract class HomeRepository {
  /// Now-showing movies. Cached 6 h (LLD §5.3).
  Future<List<Movie>> getNowShowing({bool forceRefresh = false});

  /// Coming-soon movies. Cached 6 h.
  Future<List<Movie>> getComingSoon({bool forceRefresh = false});

  /// Personalised recommendations. Cached 6 h.
  Future<List<Movie>> getRecommended({bool forceRefresh = false});

  /// Trending movies this week (aliases /recommended endpoint). Cached 6 h.
  Future<List<Movie>> getTrending({bool forceRefresh = false});

  /// Featured banner carousel. Cached 1 h (LLD §5.3).
  Future<List<Banner>> getBanners({bool forceRefresh = false});
}

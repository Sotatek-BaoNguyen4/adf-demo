import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/home_repository_provider.dart';
import '../../domain/entities/movie.dart';

part 'trending_provider.g.dart';

/// Async provider for "Trending This Week" movies.
///
/// Delegates to [HomeRepository.getTrending] which aliases the
/// /api/v1/movies/recommended endpoint — same cache key, same network path.
/// Fires concurrently with other home providers on cold start (LLD §8).
@riverpod
class Trending extends _$Trending {
  @override
  Future<List<Movie>> build() =>
      ref.read(homeRepositoryProvider).getTrending();

  /// Force-refresh from network, bypassing cache.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(homeRepositoryProvider).getTrending(forceRefresh: true),
    );
  }
}

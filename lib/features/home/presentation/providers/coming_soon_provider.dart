import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/home_repository_provider.dart';
import '../../domain/entities/movie.dart';

part 'coming_soon_provider.g.dart';

/// Async provider for "Coming Soon" movies.
///
/// Fires concurrently with other home providers on cold start (LLD §8).
@riverpod
class ComingSoon extends _$ComingSoon {
  @override
  Future<List<Movie>> build() =>
      ref.read(homeRepositoryProvider).getComingSoon();

  /// Force-refresh from network, bypassing cache.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(homeRepositoryProvider).getComingSoon(forceRefresh: true),
    );
  }
}

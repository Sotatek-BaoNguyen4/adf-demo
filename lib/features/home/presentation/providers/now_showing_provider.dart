import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/home_repository_provider.dart';
import '../../domain/entities/movie.dart';

part 'now_showing_provider.g.dart';

/// Async provider for "Now Showing" movies.
///
/// Fires concurrently with other home providers on cold start (LLD §8).
@riverpod
class NowShowing extends _$NowShowing {
  @override
  Future<List<Movie>> build() =>
      ref.read(homeRepositoryProvider).getNowShowing();

  /// Force-refresh from network, bypassing cache.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(homeRepositoryProvider).getNowShowing(forceRefresh: true),
    );
  }
}

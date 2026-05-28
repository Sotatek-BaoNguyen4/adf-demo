import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/home_repository_provider.dart';
import '../../domain/entities/banner.dart';

part 'banners_provider.g.dart';

/// Async provider for featured banner carousel data.
///
/// Reads [homeRepositoryProvider] on build — Riverpod fires this concurrently
/// with the other 3 home providers (LLD §8).
@riverpod
class Banners extends _$Banners {
  @override
  Future<List<Banner>> build() =>
      ref.read(homeRepositoryProvider).getBanners();

  /// Force-refresh banners from network, bypassing cache.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(homeRepositoryProvider).getBanners(forceRefresh: true),
    );
  }
}

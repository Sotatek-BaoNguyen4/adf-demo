// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trending_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trendingHash() => r'7034e7e520c0d7e2d6deafafc50d1ea2d5fc5d53';

/// Async provider for "Trending This Week" movies.
///
/// Delegates to [HomeRepository.getTrending] which aliases the
/// /api/v1/movies/recommended endpoint — same cache key, same network path.
/// Fires concurrently with other home providers on cold start (LLD §8).
///
/// Copied from [Trending].
@ProviderFor(Trending)
final trendingProvider =
    AutoDisposeAsyncNotifierProvider<Trending, List<Movie>>.internal(
      Trending.new,
      name: r'trendingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trendingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Trending = AutoDisposeAsyncNotifier<List<Movie>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'now_showing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nowShowingHash() => r'b3e46c7b791962eb68d4584670e68d1ff5ae7363';

/// Async provider for "Now Showing" movies.
///
/// Fires concurrently with other home providers on cold start (LLD §8).
///
/// Copied from [NowShowing].
@ProviderFor(NowShowing)
final nowShowingProvider =
    AutoDisposeAsyncNotifierProvider<NowShowing, List<Movie>>.internal(
      NowShowing.new,
      name: r'nowShowingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nowShowingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NowShowing = AutoDisposeAsyncNotifier<List<Movie>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coming_soon_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$comingSoonHash() => r'9179ba831be43b5b6b9ce19e7e09615b318c103a';

/// Async provider for "Coming Soon" movies.
///
/// Fires concurrently with other home providers on cold start (LLD §8).
///
/// Copied from [ComingSoon].
@ProviderFor(ComingSoon)
final comingSoonProvider =
    AutoDisposeAsyncNotifierProvider<ComingSoon, List<Movie>>.internal(
      ComingSoon.new,
      name: r'comingSoonProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$comingSoonHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ComingSoon = AutoDisposeAsyncNotifier<List<Movie>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

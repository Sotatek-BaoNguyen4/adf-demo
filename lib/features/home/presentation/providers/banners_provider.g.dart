// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banners_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bannersHash() => r'dad9eaa515b7757b05363d130f367d2320905177';

/// Async provider for featured banner carousel data.
///
/// Reads [homeRepositoryProvider] on build — Riverpod fires this concurrently
/// with the other 3 home providers (LLD §8).
///
/// Copied from [Banners].
@ProviderFor(Banners)
final bannersProvider =
    AutoDisposeAsyncNotifierProvider<Banners, List<Banner>>.internal(
      Banners.new,
      name: r'bannersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bannersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Banners = AutoDisposeAsyncNotifier<List<Banner>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

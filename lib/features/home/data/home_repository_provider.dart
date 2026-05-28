import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_config.dart';
import '../../../core/storage/local_cache.dart';
import '../domain/home_repository.dart';
import 'home_repository_impl.dart';
import 'sources/home_local_source.dart';
import 'sources/home_remote_source.dart';

/// Riverpod provider for [Dio]. Builds a new instance from [DioClient].
final dioProvider = Provider<Dio>(
  (ref) => DioClient.build(mock: NetworkConfig.useMock),
);

/// Riverpod provider for [LocalCache].
///
/// Intentionally throws [UnimplementedError] — Phase 06 bootstraps Hive and
/// satisfies this provider via:
///   `overrides: [localCacheProvider.overrideWithValue(cache)]`
/// after `bootstrapHive()` returns the opened boxes.
final localCacheProvider = Provider<LocalCache>(
  (ref) => throw UnimplementedError(
    'localCacheProvider must be overridden after bootstrapHive(). '
    'Phase 06 supplies: localCacheProvider.overrideWithValue(cache)',
  ),
);

/// Provider for [HomeRemoteSource] — depends on [dioProvider].
final homeRemoteSourceProvider = Provider<HomeRemoteSource>(
  (ref) => HomeRemoteSource(ref.watch(dioProvider)),
);

/// Provider for [HomeLocalSource] — depends on [localCacheProvider].
final homeLocalSourceProvider = Provider<HomeLocalSource>(
  (ref) => HomeLocalSource(ref.watch(localCacheProvider)),
);

/// Provider for [HomeRepository] — wires remote + local sources.
final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(
    ref.watch(homeRemoteSourceProvider),
    ref.watch(homeLocalSourceProvider),
  ),
);

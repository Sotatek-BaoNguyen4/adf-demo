import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'mock_interceptor.dart';
import 'network_config.dart';

/// Factory for creating configured [Dio] instances.
///
/// Not a singleton — Riverpod provider owns the instance lifetime.
///
/// Interceptor chain order (request → response):
///   1. [LogInterceptor]   — dev builds only; no headers/body in release.
///   2. [MockInterceptor]  — terminal when [mock] == true; bypassed otherwise.
///   3. (future) AuthInterceptor — placeholder; not wired in MVP.
class DioClient {
  const DioClient._();

  /// Builds and returns a fully configured [Dio] instance.
  ///
  /// [mock] defaults to [NetworkConfig.useMock] (build-time dart-define).
  static Dio build({bool mock = NetworkConfig.useMock}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: NetworkConfig.baseUrl,
        connectTimeout: NetworkConfig.connect,
        receiveTimeout: NetworkConfig.receive,
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'X-Client': 'adf-cinema/mvp',
        },
      ),
    );

    // 1. Logging — dev only; never log headers/body in release.
    if (!kReleaseMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
        ),
      );
    }

    // 2. Mock — terminal interceptor; real adapter never reached when active.
    if (mock) {
      dio.interceptors.add(MockInterceptor());
    }

    // 3. TODO(phase-future): wire AuthInterceptor here.

    return dio;
  }
}

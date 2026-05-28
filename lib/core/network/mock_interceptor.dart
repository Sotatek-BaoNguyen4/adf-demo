import 'dart:math';

import 'package:dio/dio.dart';

import 'mock_fixture_loader.dart';
import 'network_config.dart';

/// Endpoint → fixture asset mapping (LLD §4.3).
const Map<String, String> _kFixtureMap = {
  '/api/v1/home/banners': 'assets/fixtures/banners.json',
  '/api/v1/movies/now-showing': 'assets/fixtures/now-showing.json',
  '/api/v1/movies/coming-soon': 'assets/fixtures/coming-soon.json',
  '/api/v1/movies/recommended': 'assets/fixtures/recommended.json',
};

/// When true, [Random] is seeded with 0 for reproducible widget tests.
///
/// Enable via: flutter test --dart-define=MOCK_DETERMINISTIC=true
const bool _kDeterministic =
    bool.fromEnvironment('MOCK_DETERMINISTIC', defaultValue: false);

/// Terminal interceptor that resolves all requests from local fixture files.
///
/// The real Dio adapter is never reached when this interceptor is active.
/// Wired only when [NetworkConfig.useMock] is true (see [DioClient.build]).
///
/// Supports error injection via `?_mock_error=<500|timeout|parse>` for
/// testing error paths without code changes.
class MockInterceptor extends Interceptor {
  final MockFixtureLoader _loader;
  final Random _random;

  MockInterceptor({MockFixtureLoader? loader})
      : _loader = loader ?? MockFixtureLoader(),
        _random = _kDeterministic ? Random(0) : Random();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Strip query string for exact path matching (LLD §4.3).
    final path = options.path.split('?').first;
    final fixturePath = _kFixtureMap[path];

    if (fixturePath == null) {
      // Unknown path — forward to next (Dio default adapter will 404 in dev).
      handler.next(options);
      return;
    }

    // Simulate network latency before responding.
    await _simulateLatency();

    // Handle error injection query param (only honoured in mock mode).
    final mockError = options.queryParameters['_mock_error'];
    if (mockError != null) {
      _handleErrorInjection(mockError, options, handler);
      return;
    }

    // Load fixture and resolve.
    final dynamic data;
    try {
      data = await _loader.load(fixturePath);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 404,
            statusMessage: 'Fixture not found: $fixturePath',
          ),
          error: e,
        ),
        true,
      );
      return;
    }

    handler.resolve(
      Response(
        requestOptions: options,
        data: data,
        statusCode: 200,
        headers: Headers.fromMap({
          'content-type': ['application/json'],
        }),
      ),
    );
  }

  Future<void> _simulateLatency() async {
    final minMs = NetworkConfig.mockMinLatency.inMilliseconds;
    final maxMs = NetworkConfig.mockMaxLatency.inMilliseconds;
    final ms = minMs + _random.nextInt(maxMs - minMs + 1);
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  void _handleErrorInjection(
    String code,
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Explicit returns after every terminal handler.* call — Dio prohibits
    // calling more than one terminal method per request, and explicit returns
    // make the early-exit contract obvious to future maintainers.
    switch (code) {
      case '500':
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 500,
              statusMessage: 'Internal Server Error (injected)',
            ),
          ),
          true,
        );
        return;
      case 'timeout':
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          ),
          true,
        );
        return;
      case 'parse':
        // Resolve with a malformed JSON *string* body. The remote source
        // detects string payloads and routes them through jsonDecode so the
        // resulting FormatException maps cleanly to ParseFailure (LLD §4.6).
        handler.resolve(
          Response(
            requestOptions: options,
            data: '{not json',
            statusCode: 200,
          ),
        );
        return;
      default:
        // Unknown injection code — treat as normal success.
        handler.next(options);
        return;
    }
  }
}

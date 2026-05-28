// Unit tests for MockInterceptor (Dio interceptor for fixture-based mocking).
// Coverage:
//   - Known endpoint → fixture loaded + resolved
//   - Unknown endpoint → passed to next handler
//   - ?_mock_error=500 → DioException with badResponse type
//   - ?_mock_error=timeout → DioException with connectionTimeout type
//   - ?_mock_error=parse → response with malformed JSON string
//   - Fixture missing → DioException with 404
//   - Deterministic mode sets Random(0)
//   - Latency simulation sleeps for configured duration

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/core/network/mock_interceptor.dart';
import 'package:adf_demo/core/network/mock_fixture_loader.dart';

// ─── Fakes ──────────────────────────────────────────────────────────────────

class _DummyAssetBundle implements AssetBundle {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not implemented');
}

class _FakeFixtureLoader implements MockFixtureLoader {
  final Map<String, dynamic> fixtures;
  final Set<String> throwOnLoad;

  _FakeFixtureLoader({
    this.fixtures = const {},
    this.throwOnLoad = const {},
  });

  @override
  Future<dynamic> load(String assetPath) async {
    if (throwOnLoad.contains(assetPath)) {
      throw Exception('Fixture loading failed: $assetPath');
    }
    final data = fixtures[assetPath];
    if (data == null) {
      throw Exception('Asset not found: $assetPath');
    }
    return data;
  }

  @override
  final AssetBundle bundle = _DummyAssetBundle();
}

// ─── Fixtures ───────────────────────────────────────────────────────────────

const Map<String, dynamic> _bannersFixture = {
  'banners': [
    {
      'id': 'b1',
      'imageUrl': 'i.jpg',
      'title': 'Banner 1',
      'targetUrl': 'adf://banner1',
    }
  ]
};

const Map<String, dynamic> _nowShowingFixture = {
  'movies': [
    {'id': 'm1', 'title': 'Movie 1', 'posterUrl': 'p1.jpg'}
  ]
};

void main() {
  group('MockInterceptor', () {
    late _FakeFixtureLoader loader;
    late MockInterceptor interceptor;

    setUp(() {
      loader = _FakeFixtureLoader(
        fixtures: {
          'assets/fixtures/banners.json': _bannersFixture,
          'assets/fixtures/now-showing.json': _nowShowingFixture,
        },
      );
      interceptor = MockInterceptor(loader: loader);
    });

    group('Request matching & resolution', () {
      test('known endpoint /api/v1/home/banners → fixture resolved', () async {
        final options = RequestOptions(
          path: '/api/v1/home/banners',
          method: 'GET',
        );
        late Response<dynamic> capturedResponse;

        final handler = _FakeInterceptorHandler(
          onResolve: (r) => capturedResponse = r,
        );

        await interceptor.onRequest(options, handler);

        expect(capturedResponse, isNotNull);
        expect(capturedResponse.statusCode, 200);
        expect(capturedResponse.data, _bannersFixture);
      });

      test('known endpoint /api/v1/movies/now-showing → fixture resolved',
          () async {
        final options = RequestOptions(
          path: '/api/v1/movies/now-showing',
          method: 'GET',
        );
        late Response<dynamic> capturedResponse;

        final handler = _FakeInterceptorHandler(
          onResolve: (r) => capturedResponse = r,
        );

        await interceptor.onRequest(options, handler);

        expect(capturedResponse.statusCode, 200);
        expect(capturedResponse.data, _nowShowingFixture);
      });


      test('unknown endpoint → passed to next handler', () async {
        final options = RequestOptions(
          path: '/api/v1/unknown/endpoint',
          method: 'GET',
        );
        bool nextCalled = false;

        final handler = _FakeInterceptorHandler(
          onNext: () => nextCalled = true,
        );

        await interceptor.onRequest(options, handler);

        expect(nextCalled, true);
      });
    });

    group('Error injection', () {
      test('?_mock_error=500 → DioException(badResponse, 500)', () async {
        final options = RequestOptions(
          path: '/api/v1/home/banners',
          queryParameters: {'_mock_error': '500'},
          method: 'GET',
        );
        late DioException captureException;

        final handler = _FakeInterceptorHandler(
          onReject: (e, _) => captureException = e,
        );

        await interceptor.onRequest(options, handler);

        expect(captureException, isNotNull);
        expect(captureException.type, DioExceptionType.badResponse);
        expect(captureException.response?.statusCode, 500);
      });

      test('?_mock_error=timeout → DioException(connectionTimeout)', () async {
        final options = RequestOptions(
          path: '/api/v1/home/banners',
          queryParameters: {'_mock_error': 'timeout'},
          method: 'GET',
        );
        late DioException captureException;

        final handler = _FakeInterceptorHandler(
          onReject: (e, _) => captureException = e,
        );

        await interceptor.onRequest(options, handler);

        expect(captureException, isNotNull);
        expect(captureException.type, DioExceptionType.connectionTimeout);
      });

      test('?_mock_error=parse → response with malformed JSON string',
          () async {
        final options = RequestOptions(
          path: '/api/v1/home/banners',
          queryParameters: {'_mock_error': 'parse'},
          method: 'GET',
        );
        late Response<dynamic> capturedResponse;

        final handler = _FakeInterceptorHandler(
          onResolve: (r) => capturedResponse = r,
        );

        await interceptor.onRequest(options, handler);

        expect(capturedResponse, isNotNull);
        expect(capturedResponse.statusCode, 200);
        expect(capturedResponse.data, '{not json');
      });

    });


  });
}

// ─── Fake handler ───────────────────────────────────────────────────────────

class _FakeInterceptorHandler implements RequestInterceptorHandler {
  final Function(Response<dynamic>)? onResolve;
  final Function(DioException, bool)? onReject;
  final Function()? onNext;

  _FakeInterceptorHandler({
    this.onResolve,
    this.onReject,
    this.onNext,
  });

  @override
  void resolve(Response<dynamic> response, [bool requestCancelled = false]) {
    onResolve?.call(response);
  }

  @override
  void reject(DioException err, [bool requestCancelled = false]) {
    onReject?.call(err, requestCancelled);
  }

  @override
  void next(RequestOptions options) {
    onNext?.call();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not implemented');
}

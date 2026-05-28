// Verifies home_remote_source.dart routes string response bodies through
// jsonDecode so `?_mock_error=parse` (LLD §4.6) surfaces as FormatException,
// which the repository then maps to ParseFailure.
//
// We swap Dio's HttpClientAdapter for a deterministic fake — no real network,
// no MockInterceptor, just verifying body-shape handling in isolation.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/data/sources/home_remote_source.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromBytes(
      utf8.encode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(String body) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
  // Strip Dio's auto-JSON-decode so the remote source sees the raw String.
  dio.options.responseType = ResponseType.plain;
  dio.httpClientAdapter = _FakeAdapter(body);
  return dio;
}

void main() {
  group('HomeRemoteSource — response body normalization', () {
    test('malformed JSON string body → FormatException', () async {
      final dio = _dioWith('{not json');
      final source = HomeRemoteSource(dio);

      expect(
        () => source.getBanners(),
        throwsA(isA<FormatException>()),
      );
    });

    test('non-list JSON body (object) → FormatException', () async {
      final dio = _dioWith('{"unexpected": "object"}');
      final source = HomeRemoteSource(dio);

      expect(
        () => source.getNowShowing(),
        throwsA(isA<FormatException>()),
      );
    });

    test('valid JSON list body → parses successfully', () async {
      final dio = _dioWith(
        '[{"id":"m1","title":"T","posterUrl":"p.jpg"}]',
      );
      final source = HomeRemoteSource(dio);

      final result = await source.getNowShowing();

      expect(result, hasLength(1));
      expect(result.first.id, 'm1');
    });
  });
}

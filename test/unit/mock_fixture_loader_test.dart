// Unit tests for MockFixtureLoader (loads JSON fixtures from assets).
// Coverage:
//   - load(existing fixture) → decoded Map
//   - load(missing fixture) → FixtureMissingFailure
//   - load(malformed JSON) → ParseFailure
//   - Caching: second load returns from cache (no asset read)

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/core/errors/failure.dart';
import 'package:adf_demo/core/network/mock_fixture_loader.dart';

// ─── Fakes ──────────────────────────────────────────────────────────────────

class _FakeAssetBundle implements AssetBundle {
  final Map<String, String> assets;
  int loadStringCallCount = 0;

  _FakeAssetBundle({this.assets = const {}});

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    loadStringCallCount++;
    final asset = assets[key];
    if (asset == null) {
      throw Exception('Asset not found: $key');
    }
    return asset;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not implemented');
}

// ─── Fixtures ───────────────────────────────────────────────────────────────

const _validJsonString = '{"banners":[{"id":"b1"}]}';
const _malformedJson = '{not valid json}';

void main() {
  group('MockFixtureLoader', () {
    late _FakeAssetBundle bundle;
    late MockFixtureLoader loader;

    setUp(() {
      bundle = _FakeAssetBundle(assets: {
        'assets/fixtures/banners.json': _validJsonString,
      });
      loader = MockFixtureLoader(bundle: bundle);
    });

    group('Loading fixtures', () {
      test('load(existing fixture) → returns decoded JSON Map', () async {
        final result = await loader.load('assets/fixtures/banners.json');

        expect(result, isA<Map>());
        expect(result['banners'], isList);
        expect((result['banners'] as List).first['id'], 'b1');
      });

      test('load(missing fixture) → throws FixtureMissingFailure', () async {
        expect(
          () => loader.load('assets/fixtures/missing.json'),
          throwsA(isA<FixtureMissingFailure>()),
        );
      });

      test('load(malformed JSON) → throws ParseFailure', () async {
        bundle = _FakeAssetBundle(assets: {
          'assets/fixtures/bad.json': _malformedJson,
        });
        loader = MockFixtureLoader(bundle: bundle);

        expect(
          () => loader.load('assets/fixtures/bad.json'),
          throwsA(isA<ParseFailure>()),
        );
      });
    });

    group('Caching', () {
      test('second load returns from cache (no asset read)', () async {
        expect(bundle.loadStringCallCount, 0);

        await loader.load('assets/fixtures/banners.json');
        expect(bundle.loadStringCallCount, 1);

        await loader.load('assets/fixtures/banners.json');
        expect(bundle.loadStringCallCount, 1); // Not incremented
      });

      test('different paths cached independently', () async {
        bundle = _FakeAssetBundle(assets: {
          'assets/fixtures/banners.json': _validJsonString,
          'assets/fixtures/now-showing.json':
              '{"movies":[{"id":"m1","title":"Movie 1"}]}',
        });
        loader = MockFixtureLoader(bundle: bundle);

        await loader.load('assets/fixtures/banners.json');
        expect(bundle.loadStringCallCount, 1);

        await loader.load('assets/fixtures/now-showing.json');
        expect(bundle.loadStringCallCount, 2);

        // Both cached now — no more reads
        await loader.load('assets/fixtures/banners.json');
        await loader.load('assets/fixtures/now-showing.json');
        expect(bundle.loadStringCallCount, 2);
      });

      test('cached data returned identically', () async {
        final first = await loader.load('assets/fixtures/banners.json');
        final second = await loader.load('assets/fixtures/banners.json');

        expect(identical(first, second), true);
      });
    });


    group('Error handling', () {
      test('FixtureMissingFailure includes assetPath', () async {
        try {
          await loader.load('assets/fixtures/missing.json');
          fail('should have thrown');
        } on FixtureMissingFailure catch (e) {
          expect(e.message, contains('missing.json'));
        }
      });

      test('ParseFailure includes path', () async {
        bundle = _FakeAssetBundle(assets: {
          'assets/fixtures/bad.json': _malformedJson,
        });
        loader = MockFixtureLoader(bundle: bundle);

        try {
          await loader.load('assets/fixtures/bad.json');
          fail('should have thrown');
        } on ParseFailure catch (e) {
          expect(e.message, contains('bad.json'));
        }
      });
    });
  });
}

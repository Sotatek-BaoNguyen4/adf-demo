// Unit tests for Failure sealed hierarchy.
// Covers all 8 subclass constructors + toString behavior in debug/release modes.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/core/errors/failure.dart';

void main() {
  group('Failure hierarchy', () {
    test('NetworkFailure stores message and statusCode', () {
      const failure = NetworkFailure('HTTP 500', statusCode: 500);
      expect(failure.message, 'HTTP 500');
      expect(failure.statusCode, 500);
    });

    test('NetworkFailure.toString includes type and message', () {
      const failure = NetworkFailure('Server error', statusCode: 503);
      final str = failure.toString();
      expect(str, contains('NetworkFailure'));
      expect(str, contains('Server error'));
    });

    test('NetworkFailure with cause shows cause in debug mode', () {
      if (!kReleaseMode) {
        const failure =
            NetworkFailure('error', statusCode: 400, cause: 'bad request');
        final str = failure.toString();
        expect(str, contains('cause'));
      }
    });

    test('TimeoutFailure stores message', () {
      const failure = TimeoutFailure('Connection timed out');
      expect(failure.message, 'Connection timed out');
    });

    test('TimeoutFailure.toString includes type', () {
      const failure = TimeoutFailure('Timeout');
      expect(failure.toString(), contains('TimeoutFailure'));
    });

    test('TimeoutFailure with cause preserves it', () {
      final err = Exception('underlying');
      final failure = TimeoutFailure('Timeout', err);
      expect(failure.cause, err);
    });

    test('ParseFailure stores message and path', () {
      const failure = ParseFailure('Invalid JSON', path: 'fixtures/movies.json');
      expect(failure.message, 'Invalid JSON');
      expect(failure.path, 'fixtures/movies.json');
    });

    test('ParseFailure.toString includes type', () {
      const failure = ParseFailure('Bad format', path: 'data.json');
      expect(failure.toString(), contains('ParseFailure'));
    });

    test('CacheReadFailure stores message and boxName', () {
      const failure = CacheReadFailure('Corrupted box',
          boxName: 'movies_cache');
      expect(failure.message, 'Corrupted box');
      expect(failure.boxName, 'movies_cache');
    });

    test('CacheReadFailure.toString includes type', () {
      const failure =
          CacheReadFailure('Read error', boxName: 'banners_cache');
      expect(failure.toString(), contains('CacheReadFailure'));
    });

    test('CacheWriteFailure stores message and boxName', () {
      const failure = CacheWriteFailure('Disk full', boxName: 'movies_cache');
      expect(failure.message, 'Disk full');
      expect(failure.boxName, 'movies_cache');
    });

    test('CacheWriteFailure.toString includes type', () {
      const failure = CacheWriteFailure('Write error', boxName: 'temp');
      expect(failure.toString(), contains('CacheWriteFailure'));
    });

    test('FixtureMissingFailure stores message and assetPath', () {
      const failure = FixtureMissingFailure('Not found',
          assetPath: 'assets/fixtures/movies.json');
      expect(failure.message, 'Not found');
      expect(failure.assetPath, 'assets/fixtures/movies.json');
    });

    test('FixtureMissingFailure.toString includes type', () {
      const failure =
          FixtureMissingFailure('Missing', assetPath: 'banners.json');
      expect(failure.toString(), contains('FixtureMissingFailure'));
    });

    test('UnknownFailure stores message', () {
      const failure = UnknownFailure('Unexpected error');
      expect(failure.message, 'Unexpected error');
    });

    test('UnknownFailure.toString includes type', () {
      const failure = UnknownFailure('Unknown');
      expect(failure.toString(), contains('UnknownFailure'));
    });

    test('UnknownFailure with cause preserves it', () {
      final err = Error();
      final failure = UnknownFailure('Error', err);
      expect(failure.cause, err);
    });

    test('All Failure subclasses implement Exception', () {
      const failures = [
        NetworkFailure('net'),
        TimeoutFailure('timeout'),
        ParseFailure('parse'),
        CacheReadFailure('read', boxName: 'box'),
        CacheWriteFailure('write', boxName: 'box'),
        FixtureMissingFailure('missing', assetPath: 'path'),
        UnknownFailure('unknown'),
      ];
      for (final f in failures) {
        expect(f, isA<Exception>());
      }
    });
  });
}

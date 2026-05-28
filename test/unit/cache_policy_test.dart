// Unit tests for CachePolicy TTL logic.
// Covers isFresh, isStale, isCompatible, and schema version checks.

import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/core/storage/cache_envelope.dart';
import 'package:adf_demo/core/storage/cache_policy.dart';

void main() {
  group('CachePolicy', () {
    test('isFresh returns true when age < ttl', () {
      final now = DateTime.now();
      final freshEnv = CacheEnvelope(
        payload: 'data',
        savedAtEpochMs: now.millisecondsSinceEpoch,
        schemaVersion: kSchemaVersion,
      );

      expect(
        CachePolicy.isFresh(freshEnv, const Duration(hours: 1)),
        true,
      );
    });

    test('isFresh returns false when age >= ttl', () {
      final now = DateTime.now();
      final staleEnv = CacheEnvelope(
        payload: 'data',
        savedAtEpochMs: now
            .subtract(const Duration(hours: 2))
            .millisecondsSinceEpoch,
        schemaVersion: kSchemaVersion,
      );

      expect(
        CachePolicy.isFresh(staleEnv, const Duration(hours: 1)),
        false,
      );
    });

    test('isFresh handles clock skew (negative age treated as fresh)', () {
      final now = DateTime.now();
      final futureEnv = CacheEnvelope(
        payload: 'data',
        savedAtEpochMs:
            now.add(const Duration(hours: 1)).millisecondsSinceEpoch,
        schemaVersion: kSchemaVersion,
      );

      // Negative age (clock skew) is < any positive TTL, so fresh
      expect(
        CachePolicy.isFresh(futureEnv, const Duration(hours: 6)),
        true,
      );
    });

    test('isStale is inverse of isFresh', () {
      final now = DateTime.now();
      final freshEnv = CacheEnvelope(
        payload: 'data',
        savedAtEpochMs: now.millisecondsSinceEpoch,
        schemaVersion: kSchemaVersion,
      );

      expect(
        CachePolicy.isStale(freshEnv, const Duration(hours: 1)),
        false,
      );
    });

    test('isStale with Duration.zero forces always-stale', () {
      final now = DateTime.now();
      final env = CacheEnvelope(
        payload: 'data',
        savedAtEpochMs: now.millisecondsSinceEpoch,
        schemaVersion: kSchemaVersion,
      );

      expect(
        CachePolicy.isStale(env, Duration.zero),
        true,
      );
    });

    test('isCompatible returns true when schema matches kSchemaVersion', () {
      final env = CacheEnvelope(
        payload: 'data',
        savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        schemaVersion: kSchemaVersion,
      );

      expect(CachePolicy.isCompatible(env), true);
    });

    test('isCompatible returns false when schema mismatches', () {
      final env = CacheEnvelope(
        payload: 'data',
        savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        schemaVersion: kSchemaVersion + 1,
      );

      expect(CachePolicy.isCompatible(env), false);
    });

    test('moviesTtl constant is 6 hours', () {
      expect(CachePolicy.moviesTtl, const Duration(hours: 6));
    });

    test('bannersTtl constant is 1 hour', () {
      expect(CachePolicy.bannersTtl, const Duration(hours: 1));
    });

    test('isFresh works with movie TTL boundary', () {
      final now = DateTime.now();
      final almostStaleEnv = CacheEnvelope(
        payload: 'movies',
        savedAtEpochMs:
            now.subtract(const Duration(hours: 5, minutes: 59)).millisecondsSinceEpoch,
        schemaVersion: kSchemaVersion,
      );

      // 5:59 < 6 hours, so fresh
      expect(
        CachePolicy.isFresh(almostStaleEnv, CachePolicy.moviesTtl),
        true,
      );
    });

    test('isStale works with banner TTL boundary', () {
      final now = DateTime.now();
      final justStaleEnv = CacheEnvelope(
        payload: 'banners',
        savedAtEpochMs:
            now.subtract(const Duration(hours: 1, minutes: 1)).millisecondsSinceEpoch,
        schemaVersion: kSchemaVersion,
      );

      // 1:01 > 1 hour, so stale
      expect(
        CachePolicy.isStale(justStaleEnv, CachePolicy.bannersTtl),
        true,
      );
    });

    test('kSchemaVersion is 1', () {
      expect(kSchemaVersion, 1);
    });
  });
}

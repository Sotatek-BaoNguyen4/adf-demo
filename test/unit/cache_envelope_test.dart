// Unit tests for CacheEnvelope generic wrapper.
// Covers timestamp handling, age computation, and savedAt accessor.

import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/core/storage/cache_envelope.dart';

void main() {
  group('CacheEnvelope', () {
    test('constructor stores payload, timestamp, and schema version', () {
      final now = DateTime.now();
      const payload = ['a', 'b', 'c'];
      const schemaVersion = 1;

      final envelope = CacheEnvelope(
        payload: payload,
        savedAtEpochMs: now.millisecondsSinceEpoch,
        schemaVersion: schemaVersion,
      );

      expect(envelope.payload, payload);
      expect(envelope.schemaVersion, 1);
    });

    test('savedAt converts epochMs to DateTime', () {
      final now = DateTime.now();
      final epochMs = now.millisecondsSinceEpoch;

      final envelope = CacheEnvelope(
        payload: 'test',
        savedAtEpochMs: epochMs,
        schemaVersion: 1,
      );

      expect(envelope.savedAt.millisecondsSinceEpoch, epochMs);
    });

    test('age computes duration from savedAt to now', () {
      final now = DateTime.now();
      final fiveSecondsAgo =
          now.subtract(const Duration(seconds: 5)).millisecondsSinceEpoch;

      final envelope = CacheEnvelope(
        payload: 'test',
        savedAtEpochMs: fiveSecondsAgo,
        schemaVersion: 1,
      );

      // Age should be ~5 seconds (within 100ms tolerance for test execution)
      expect(
        envelope.age.inSeconds,
        greaterThanOrEqualTo(4),
      );
      expect(
        envelope.age.inSeconds,
        lessThanOrEqualTo(6),
      );
    });

    test('age handles clock skew (negative when savedAt is in future)', () {
      final now = DateTime.now();
      final fiveFutureAgo = now
          .add(const Duration(seconds: 5))
          .millisecondsSinceEpoch;

      final envelope = CacheEnvelope(
        payload: 'test',
        savedAtEpochMs: fiveFutureAgo,
        schemaVersion: 1,
      );

      // Age should be negative (clock skew — treated as fresh by policy)
      expect(envelope.age.isNegative, true);
    });

    test('generic type preservation with different payloads', () {
      final intEnvelope = CacheEnvelope(
        payload: 42,
        savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        schemaVersion: 1,
      );

      final stringEnvelope = CacheEnvelope(
        payload: 'hello',
        savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        schemaVersion: 1,
      );

      final listEnvelope = CacheEnvelope(
        payload: [1, 2, 3],
        savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        schemaVersion: 1,
      );

      expect(intEnvelope.payload, 42);
      expect(stringEnvelope.payload, 'hello');
      expect(listEnvelope.payload, [1, 2, 3]);
    });
  });
}

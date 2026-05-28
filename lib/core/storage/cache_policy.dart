import 'cache_envelope.dart';

/// Current schema version. Bump when [CacheEnvelope] fields or DTO shapes
/// change in a breaking way. Document the reason in a code comment here.
///
/// History:
///   1 — initial schema (Phase 03)
const int kSchemaVersion = 1;

/// Pure TTL helpers and constants. No I/O — easy to unit test.
class CachePolicy {
  const CachePolicy._();

  /// Movies (now-showing, coming-soon, recommended) expire after 6 hours.
  static const Duration moviesTtl = Duration(hours: 6);

  /// Banner carousel data expires after 1 hour.
  static const Duration bannersTtl = Duration(hours: 1);

  /// Returns true when [env] is younger than [ttl].
  ///
  /// Clock-skew edge case: [CacheEnvelope.age] may be negative when the
  /// device clock is moved backward — treated as fresh (acceptable for MVP).
  static bool isFresh<T>(CacheEnvelope<T> env, Duration ttl) =>
      env.age < ttl;

  /// Inverse of [isFresh]. Pass [Duration.zero] to force always-stale.
  static bool isStale<T>(CacheEnvelope<T> env, Duration ttl) =>
      !isFresh(env, ttl);

  /// Returns true iff the envelope's schema version matches [kSchemaVersion].
  /// Mismatch → treat as cache miss; caller should delete entry.
  static bool isCompatible<T>(CacheEnvelope<T> env) =>
      env.schemaVersion == kSchemaVersion;
}

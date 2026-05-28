/// Generic wrapper for every cached payload.
///
/// Stored in Hive with a timestamp and schema version so callers can compute
/// staleness and detect incompatible schema bumps.
///
/// TypeAdapter strategy (LLD 5.2): concrete typed adapters live next to the
/// DTOs they wrap (Phase 04). Reserved typeIds:
///   typeId 1  CacheEnvelope of List of MovieDto
///   typeId 2  CacheEnvelope of List of BannerDto
///   typeIds 3-15 reserved for future entities. Never reuse a typeId.
class CacheEnvelope<T> {
  final T payload;

  /// Epoch milliseconds at write time  use [savedAt] for a [DateTime].
  final int savedAtEpochMs;

  /// Must equal `kSchemaVersion` at write time. Mismatch  treat as cache miss.
  final int schemaVersion;

  const CacheEnvelope({
    required this.payload,
    required this.savedAtEpochMs,
    required this.schemaVersion,
  });

  DateTime get savedAt =>
      DateTime.fromMillisecondsSinceEpoch(savedAtEpochMs);

  /// Age of this entry. May be negative on clock-skew  treated as fresh.
  Duration get age => DateTime.now().difference(savedAt);
}

import 'package:hive_ce/hive.dart';

import 'movie_dto.dart';

part 'cached_movies_envelope.g.dart';

/// Concrete Hive-serialisable wrapper for a cached list of [MovieDto].
///
/// Mirrors the shape of [CacheEnvelope] but is a concrete class so that
/// Hive CE's code-generator can emit a typed [TypeAdapter].
/// Generic `CacheEnvelope<T>` cannot carry a `@HiveType` annotation directly.
///
/// typeId 1 (LLD §5.2). Never reuse.
@HiveType(typeId: 1)
class CachedMoviesEnvelope {
  @HiveField(0)
  final List<MovieDto> payload;

  /// Epoch milliseconds at write time.
  @HiveField(1)
  final int savedAtEpochMs;

  /// Schema version — compared against [kSchemaVersion] on read.
  @HiveField(2)
  final int schemaVersion;

  const CachedMoviesEnvelope({
    required this.payload,
    required this.savedAtEpochMs,
    required this.schemaVersion,
  });

  DateTime get savedAt =>
      DateTime.fromMillisecondsSinceEpoch(savedAtEpochMs);

  Duration get age => DateTime.now().difference(savedAt);
}

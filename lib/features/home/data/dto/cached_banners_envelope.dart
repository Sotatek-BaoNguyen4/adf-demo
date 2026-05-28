import 'package:hive_ce/hive.dart';

import 'banner_dto.dart';

part 'cached_banners_envelope.g.dart';

/// Concrete Hive-serialisable wrapper for a cached list of [BannerDto].
///
/// Mirrors the shape of [CacheEnvelope] but is a concrete class so that
/// Hive CE's code-generator can emit a typed [TypeAdapter].
///
/// typeId 2 (LLD §5.2). Never reuse.
@HiveType(typeId: 2)
class CachedBannersEnvelope {
  @HiveField(0)
  final List<BannerDto> payload;

  /// Epoch milliseconds at write time.
  @HiveField(1)
  final int savedAtEpochMs;

  /// Schema version — compared against [kSchemaVersion] on read.
  @HiveField(2)
  final int schemaVersion;

  const CachedBannersEnvelope({
    required this.payload,
    required this.savedAtEpochMs,
    required this.schemaVersion,
  });

  DateTime get savedAt =>
      DateTime.fromMillisecondsSinceEpoch(savedAtEpochMs);

  Duration get age => DateTime.now().difference(savedAt);
}

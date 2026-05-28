import 'dart:developer';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/home/data/dto/banner_dto.dart';
import '../../features/home/data/dto/cached_banners_envelope.dart';
import '../../features/home/data/dto/cached_movies_envelope.dart';
import '../../features/home/data/dto/movie_dto.dart';

const _kMoviesBox = 'movies_cache';
const _kBannersBox = 'banners_cache';

/// Pair of opened cache boxes returned from [bootstrapHive].
///
/// Callers should pass these into the [LocalCache] constructor rather than
/// re-fetching them via [Hive.box] — the box names are an implementation
/// detail of this file and must not leak to call sites.
typedef HiveBoxes = ({Box<dynamic> movies, Box<dynamic> banners});

/// Initialises Hive and opens both cache boxes before [runApp].
///
/// Returns the opened boxes so call sites stay DRY and decoupled from the
/// private box-name constants:
/// ```dart
/// final boxes = await bootstrapHive();
/// final cache = LocalCache(boxes.movies, boxes.banners);
/// ```
///
/// Adapter registration is guarded by [Hive.isAdapterRegistered] so this
/// function is safe to call multiple times (e.g. in tests).
///
/// Corrupt-box recovery (LLD §5.5):
///   1. Try to open box normally.
///   2. On error: delete the box file from disk and retry once.
///   3. If retry also fails: rethrow. The previous Uint8List(0) memory-box
///      fallback was read-only and caused every subsequent .put() to throw
///      [HiveError], permanently breaking the cache layer until restart.
///      Surfacing the failure here lets the caller decide (crash, show
///      degraded UI, fall back to direct-network mode, etc.).
Future<HiveBoxes> bootstrapHive() async {
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);

  // ── Register adapters (LLD §5.2 typeIds) ──────────────────────────────────
  // Guard with isAdapterRegistered for idempotency in test environments.
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(MovieDtoAdapter()); // typeId 3
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(BannerDtoAdapter()); // typeId 4
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(CachedMoviesEnvelopeAdapter()); // typeId 1
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CachedBannersEnvelopeAdapter()); // typeId 2
  }

  final results = await Future.wait([
    _openBoxSafe<dynamic>(_kMoviesBox),
    _openBoxSafe<dynamic>(_kBannersBox),
  ]);
  return (movies: results[0], banners: results[1]);
}

/// Opens a Hive box with corrupt-box recovery: one retry after wiping disk.
/// Rethrows on persistent failure — see [bootstrapHive] doc for rationale.
Future<Box<T>> _openBoxSafe<T>(String name) async {
  try {
    return await Hive.openBox<T>(name);
  } catch (e) {
    log(
      'Hive: box "$name" corrupt — deleting and retrying. cause: $e',
      name: 'HiveBootstrap',
    );
    await Hive.deleteBoxFromDisk(name);
    return await Hive.openBox<T>(name);
  }
}

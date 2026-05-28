import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/storage/hive_bootstrap.dart';
import 'core/storage/local_cache.dart';
import 'features/home/data/home_repository_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final boxes = await bootstrapHive();
  final localCache = LocalCache(boxes.movies, boxes.banners);

  runApp(
    ProviderScope(
      overrides: [
        localCacheProvider.overrideWithValue(localCache),
      ],
      child: const AdfCinemaApp(),
    ),
  );
}

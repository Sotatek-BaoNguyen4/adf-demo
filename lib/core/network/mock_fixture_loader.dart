import 'dart:convert';

import 'package:flutter/services.dart';

import '../errors/failure.dart';

/// Loads JSON fixture files from the asset bundle for mock mode.
///
/// Results are cached in-memory after the first read to avoid repeated
/// [AssetBundle.loadString] + [jsonDecode] calls across provider rebuilds.
///
/// Inject a custom [AssetBundle] for unit tests via the constructor.
class MockFixtureLoader {
  final AssetBundle bundle;

  /// In-memory cache: assetPath → decoded JSON value.
  final Map<String, dynamic> _cache;

  MockFixtureLoader({AssetBundle? bundle})
      : bundle = bundle ?? rootBundle,
        _cache = {};

  /// Returns the decoded JSON for [assetPath].
  ///
  /// Throws [FixtureMissingFailure] if the asset is not in the bundle.
  /// Throws [ParseFailure] if the content is not valid JSON.
  ///
  /// Subsequent calls for the same path return O(1) from in-memory cache.
  Future<dynamic> load(String assetPath) async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath];
    }

    final String raw;
    try {
      raw = await bundle.loadString(assetPath);
    } catch (e) {
      throw FixtureMissingFailure(
        'Fixture not found: $assetPath',
        assetPath: assetPath,
        cause: e,
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      throw ParseFailure(
        'Failed to parse fixture JSON: $assetPath',
        path: assetPath,
        cause: e,
      );
    }

    _cache[assetPath] = decoded;
    return decoded;
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';

import '../dto/banner_dto.dart';
import '../dto/movie_dto.dart';

/// Fetches home-screen data from the network via Dio.
///
/// All methods return parsed DTO lists. Exception mapping (DioException →
/// Failure) is the exclusive responsibility of [HomeRepositoryImpl].
/// Paths match LLD §4.3 / FSD §4 endpoint table.
class HomeRemoteSource {
  final Dio _dio;

  const HomeRemoteSource(this._dio);

  /// GET /api/v1/home/banners
  Future<List<BannerDto>> getBanners() async {
    final res = await _dio.get<dynamic>('/api/v1/home/banners');
    return _decodeList(res.data)
        .map((j) => BannerDto.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/movies/now-showing
  Future<List<MovieDto>> getNowShowing() async {
    final res = await _dio.get<dynamic>('/api/v1/movies/now-showing');
    return _decodeMovies(res.data);
  }

  /// GET /api/v1/movies/coming-soon
  Future<List<MovieDto>> getComingSoon() async {
    final res = await _dio.get<dynamic>('/api/v1/movies/coming-soon');
    return _decodeMovies(res.data);
  }

  /// GET /api/v1/movies/recommended
  Future<List<MovieDto>> getRecommended() async {
    final res = await _dio.get<dynamic>('/api/v1/movies/recommended');
    return _decodeMovies(res.data);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  /// Normalises Dio response bodies (String | List) into a `List<dynamic>`.
  ///
  /// Real backend responses arrive pre-decoded as List (Dio JSON transformer).
  /// Mock-mode `?_mock_error=parse` injects a malformed String body — routing
  /// it through [jsonDecode] surfaces a [FormatException] which the repository
  /// maps to [ParseFailure] (LLD §4.6). Any other shape is also treated as a
  /// parse failure for consistency.
  List<dynamic> _decodeList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
      throw const FormatException('Expected JSON array but got non-list body');
    }
    throw FormatException(
      'Unexpected response body type: ${raw.runtimeType}',
    );
  }

  List<MovieDto> _decodeMovies(dynamic raw) => _decodeList(raw)
      .map((j) => MovieDto.fromJson(j as Map<String, dynamic>))
      .toList();
}

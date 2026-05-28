import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie.freezed.dart';

/// Presentation-shaped entity for a movie.
///
/// Covers all four endpoints:
///   - now-showing:  rating + releaseDate
///   - coming-soon:  expectedReleaseDate (no rating)
///   - recommended:  rating + matchPercentage
///   - trending:     rating + rank + views
@freezed
class Movie with _$Movie {
  const factory Movie({
    required String id,
    required String title,
    required String posterUrl,

    /// IMDb-style rating (0-10). Null for coming-soon entries.
    double? rating,

    /// ISO-8601 date string (yyyy-MM-dd). Present in now-showing.
    String? releaseDate,

    /// ISO-8601 date string (yyyy-MM-dd). Present in coming-soon.
    String? expectedReleaseDate,

    /// 0-100 match percentage. Present in recommended.
    int? matchPercentage,

    /// 1-based weekly trending rank. Present in trending.
    int? rank,

    /// Formatted view count string (e.g. "2.4M"). Present in trending.
    String? views,
  }) = _Movie;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

import '../../domain/entities/movie.dart';

part 'movie_dto.freezed.dart';
part 'movie_dto.g.dart';

/// Data Transfer Object for a movie — mirrors FSD §4 response fields exactly.
///
/// Used for all three endpoints (now-showing, coming-soon, recommended).
/// Optional fields are null when absent from the endpoint's payload.
///
/// Hive typeId 3 (LLD §5.2). Never reuse this typeId.
@freezed
@HiveType(typeId: 3)
class MovieDto with _$MovieDto {
  const factory MovieDto({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String posterUrl,

    /// Rating (0-10). Present in now-showing + recommended; absent in coming-soon.
    @HiveField(3) double? rating,

    /// ISO-8601 date. Present in now-showing only.
    @HiveField(4) String? releaseDate,

    /// ISO-8601 date. Present in coming-soon only.
    @HiveField(5) String? expectedReleaseDate,

    /// 0-100 match score. Present in recommended only.
    @HiveField(6) int? matchPercentage,

    /// 1-based weekly trending rank. Present in trending only.
    @HiveField(7) int? rank,

    /// Formatted view count string (e.g. "2.4M"). Present in trending only.
    @HiveField(8) String? views,
  }) = _MovieDto;

  factory MovieDto.fromJson(Map<String, dynamic> json) =>
      _$MovieDtoFromJson(json);
}

/// Extension so callers can convert a DTO to its domain entity in one call.
extension MovieDtoMapper on MovieDto {
  Movie toEntity() => Movie(
        id: id,
        title: title,
        posterUrl: posterUrl,
        rating: rating,
        releaseDate: releaseDate,
        expectedReleaseDate: expectedReleaseDate,
        matchPercentage: matchPercentage,
        rank: rank,
        views: views,
      );
}

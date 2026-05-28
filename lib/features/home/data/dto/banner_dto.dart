import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

import '../../domain/entities/banner.dart';

part 'banner_dto.freezed.dart';
part 'banner_dto.g.dart';

/// Data Transfer Object for a banner — mirrors FSD §4 response fields exactly.
///
/// Hive typeId 4 (LLD §5.2). Never reuse this typeId.
/// Fields 4–6 are nullable for backward compatibility with cached payloads.
@freezed
@HiveType(typeId: 4)
class BannerDto with _$BannerDto {
  const factory BannerDto({
    @HiveField(0) required String id,
    @HiveField(1) required String imageUrl,

    /// Deep-link or web URL navigated to on tap.
    @HiveField(2) required String targetUrl,

    @HiveField(3) required String title,

    /// Optional overlay fields — nullable for backward compat.
    @HiveField(4) String? genre,
    @HiveField(5) double? rating,
    @HiveField(6) String? badgeKind,
  }) = _BannerDto;

  factory BannerDto.fromJson(Map<String, dynamic> json) =>
      _$BannerDtoFromJson(json);
}

/// Extension to convert a DTO to its domain entity in one call.
extension BannerDtoMapper on BannerDto {
  Banner toEntity() => Banner(
        id: id,
        imageUrl: imageUrl,
        targetUrl: targetUrl,
        title: title,
        genre: genre,
        rating: rating,
        badgeKind: _parseBadgeKind(badgeKind),
      );

  static BadgeKind? _parseBadgeKind(String? raw) {
    switch (raw) {
      case 'nowShowing':
        return BadgeKind.nowShowing;
      case 'comingSoon':
        return BadgeKind.comingSoon;
      default:
        return null;
    }
  }
}

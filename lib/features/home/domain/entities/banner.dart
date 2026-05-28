import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';

/// Variants for the banner badge pill (UC-HOME-001).
enum BadgeKind { nowShowing, comingSoon }

/// Presentation-shaped entity for a home-screen banner.
@freezed
class Banner with _$Banner {
  const factory Banner({
    required String id,
    required String imageUrl,

    /// Deep-link or web URL to navigate to when tapped.
    required String targetUrl,

    required String title,

    /// Optional overlay fields (FSD §4 banners endpoint).
    String? genre,
    double? rating,
    BadgeKind? badgeKind,
  }) = _Banner;
}

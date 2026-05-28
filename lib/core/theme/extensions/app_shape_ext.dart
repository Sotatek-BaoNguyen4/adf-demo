import 'package:flutter/material.dart';

import '../generated/radius_tokens.dart';

/// Custom shape radii not covered by M3 ShapeTheme.
/// Access via: Theme.of(context).extension<AppShapeExt>()!
@immutable
class AppShapeExt extends ThemeExtension<AppShapeExt> {
  const AppShapeExt({
    required this.extraSmall,
    required this.small,
    required this.medium,
    required this.large,
    required this.extraLarge,
    required this.full,
    required this.none,
  });

  final BorderRadius extraSmall;
  final BorderRadius small;
  final BorderRadius medium;
  final BorderRadius large;
  final BorderRadius extraLarge;
  final BorderRadius full;
  final BorderRadius none;

  /// Pre-built instance sourced entirely from [RadiusTokens].
  static final instance = AppShapeExt(
    none: BorderRadius.circular(RadiusTokens.none),
    extraSmall: BorderRadius.circular(RadiusTokens.extra_small),
    small: BorderRadius.circular(RadiusTokens.small),
    medium: BorderRadius.circular(RadiusTokens.medium),
    large: BorderRadius.circular(RadiusTokens.large),
    extraLarge: BorderRadius.circular(RadiusTokens.extra_large),
    full: BorderRadius.circular(RadiusTokens.full),
  );

  @override
  AppShapeExt copyWith({
    BorderRadius? extraSmall,
    BorderRadius? small,
    BorderRadius? medium,
    BorderRadius? large,
    BorderRadius? extraLarge,
    BorderRadius? full,
    BorderRadius? none,
  }) {
    return AppShapeExt(
      none: none ?? this.none,
      extraSmall: extraSmall ?? this.extraSmall,
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      extraLarge: extraLarge ?? this.extraLarge,
      full: full ?? this.full,
    );
  }

  @override
  AppShapeExt lerp(AppShapeExt? other, double t) {
    if (other == null) return this;
    return AppShapeExt(
      none: BorderRadius.lerp(none, other.none, t)!,
      extraSmall: BorderRadius.lerp(extraSmall, other.extraSmall, t)!,
      small: BorderRadius.lerp(small, other.small, t)!,
      medium: BorderRadius.lerp(medium, other.medium, t)!,
      large: BorderRadius.lerp(large, other.large, t)!,
      extraLarge: BorderRadius.lerp(extraLarge, other.extraLarge, t)!,
      full: BorderRadius.lerp(full, other.full, t)!,
    );
  }
}

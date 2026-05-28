import 'package:flutter/material.dart';

import '../generated/color_tokens.dart';

/// Custom gradient tokens not covered by M3 ColorScheme.
/// Access via: `Theme.of(context).extension<AppGradientsExt>()!`
@immutable
class AppGradientsExt extends ThemeExtension<AppGradientsExt> {
  const AppGradientsExt({
    required this.accent,
    required this.promo,
    required this.appBarFade,
    required this.bannerBottom,
    required this.bannerLeft,
  });

  /// Accent gradient — inverse_primary → interactive_primary_pressed (135°).
  /// Used for active category chips.
  final LinearGradient accent;

  /// Promo banner gradient — primary_container → secondary_container (135°).
  final LinearGradient promo;

  /// Top app bar fade: surface → surface@DD → transparent (mockup header bg).
  final LinearGradient appBarFade;

  /// Banner bottom scrim: nearly-transparent → solid surface (bottom-up).
  final LinearGradient bannerBottom;

  /// Banner left-side vignette (left-fade from mockup).
  final LinearGradient bannerLeft;

  /// Pre-built dark instance.
  static final dark = AppGradientsExt(
    accent: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [DarkColorTokens.inverse_primary, DarkColorTokens.interactive_primary_pressed],
    ),
    promo: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [DarkColorTokens.primary_container, DarkColorTokens.secondary_container],
    ),
    appBarFade: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.7, 1.0],
      colors: [
        DarkColorTokens.surface_default,
        DarkColorTokens.surface_default.withAlpha(0xDD),
        DarkColorTokens.surface_default.withAlpha(0x00),
      ],
    ),
    bannerBottom: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.5, 1.0],
      colors: [
        DarkColorTokens.surface_default.withAlpha(0x26), // ~15 %
        DarkColorTokens.surface_default.withAlpha(0x99), // ~60 %
        DarkColorTokens.surface_default,
      ],
    ),
    bannerLeft: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0.0, 0.6],
      colors: [
        DarkColorTokens.surface_default.withAlpha(0xB3), // ~70 %
        DarkColorTokens.surface_default.withAlpha(0x00),
      ],
    ),
  );

  /// Pre-built light instance (mirrors dark — update when light mode is used).
  static final light = AppGradientsExt(
    accent: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [LightColorTokens.inverse_primary, LightColorTokens.interactive_primary_pressed],
    ),
    promo: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [LightColorTokens.primary_container, LightColorTokens.secondary_container],
    ),
    appBarFade: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.7, 1.0],
      colors: [
        LightColorTokens.surface_default,
        LightColorTokens.surface_default.withAlpha(0xDD),
        LightColorTokens.surface_default.withAlpha(0x00),
      ],
    ),
    bannerBottom: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.5, 1.0],
      colors: [
        LightColorTokens.surface_default.withAlpha(0x26),
        LightColorTokens.surface_default.withAlpha(0x99),
        LightColorTokens.surface_default,
      ],
    ),
    bannerLeft: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0.0, 0.6],
      colors: [
        LightColorTokens.surface_default.withAlpha(0xB3),
        LightColorTokens.surface_default.withAlpha(0x00),
      ],
    ),
  );

  @override
  AppGradientsExt copyWith({
    LinearGradient? accent,
    LinearGradient? promo,
    LinearGradient? appBarFade,
    LinearGradient? bannerBottom,
    LinearGradient? bannerLeft,
  }) {
    return AppGradientsExt(
      accent: accent ?? this.accent,
      promo: promo ?? this.promo,
      appBarFade: appBarFade ?? this.appBarFade,
      bannerBottom: bannerBottom ?? this.bannerBottom,
      bannerLeft: bannerLeft ?? this.bannerLeft,
    );
  }

  @override
  AppGradientsExt lerp(AppGradientsExt? other, double t) {
    if (other == null) return this;
    return AppGradientsExt(
      accent: LinearGradient.lerp(accent, other.accent, t)!,
      promo: LinearGradient.lerp(promo, other.promo, t)!,
      appBarFade: LinearGradient.lerp(appBarFade, other.appBarFade, t)!,
      bannerBottom: LinearGradient.lerp(bannerBottom, other.bannerBottom, t)!,
      bannerLeft: LinearGradient.lerp(bannerLeft, other.bannerLeft, t)!,
    );
  }
}

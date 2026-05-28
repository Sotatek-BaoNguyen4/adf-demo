import 'package:flutter/material.dart';

import '../generated/color_tokens.dart';

/// Custom color tokens not covered by M3 ColorScheme.
/// Access via: Theme.of(context).extension<AppColorsExt>()!
@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  const AppColorsExt({
    required this.ratingGold,
    required this.badgeSuccess,
    required this.badgeNowShowing,
    required this.badgeComingSoon,
    required this.navBackground,
    required this.navActive,
    required this.navInactive,
    required this.backgroundApp,
    required this.backgroundElevated,
    required this.backgroundOverlay,
  });

  final Color ratingGold;
  final Color badgeSuccess;
  final Color badgeNowShowing;
  final Color badgeComingSoon;
  final Color navBackground;
  final Color navActive;
  final Color navInactive;
  final Color backgroundApp;
  final Color backgroundElevated;
  final Color backgroundOverlay;

  /// Pre-built dark instance sourced entirely from [DarkColorTokens].
  static const dark = AppColorsExt(
    ratingGold: DarkColorTokens.badge_rating,
    badgeSuccess: DarkColorTokens.badge_new,
    badgeNowShowing: DarkColorTokens.badge_now_showing,
    badgeComingSoon: DarkColorTokens.badge_coming_soon,
    navBackground: DarkColorTokens.nav_background,
    navActive: DarkColorTokens.nav_active,
    navInactive: DarkColorTokens.nav_inactive,
    backgroundApp: DarkColorTokens.background_app,
    backgroundElevated: DarkColorTokens.background_elevated,
    backgroundOverlay: DarkColorTokens.background_overlay,
  );

  /// Pre-built light instance sourced entirely from [LightColorTokens].
  static const light = AppColorsExt(
    ratingGold: LightColorTokens.badge_rating,
    badgeSuccess: LightColorTokens.badge_new,
    badgeNowShowing: LightColorTokens.badge_now_showing,
    badgeComingSoon: LightColorTokens.badge_coming_soon,
    navBackground: LightColorTokens.nav_background,
    navActive: LightColorTokens.nav_active,
    navInactive: LightColorTokens.nav_inactive,
    backgroundApp: LightColorTokens.background_app,
    backgroundElevated: LightColorTokens.background_elevated,
    backgroundOverlay: LightColorTokens.background_overlay,
  );

  @override
  AppColorsExt copyWith({
    Color? ratingGold,
    Color? badgeSuccess,
    Color? badgeNowShowing,
    Color? badgeComingSoon,
    Color? navBackground,
    Color? navActive,
    Color? navInactive,
    Color? backgroundApp,
    Color? backgroundElevated,
    Color? backgroundOverlay,
  }) {
    return AppColorsExt(
      ratingGold: ratingGold ?? this.ratingGold,
      badgeSuccess: badgeSuccess ?? this.badgeSuccess,
      badgeNowShowing: badgeNowShowing ?? this.badgeNowShowing,
      badgeComingSoon: badgeComingSoon ?? this.badgeComingSoon,
      navBackground: navBackground ?? this.navBackground,
      navActive: navActive ?? this.navActive,
      navInactive: navInactive ?? this.navInactive,
      backgroundApp: backgroundApp ?? this.backgroundApp,
      backgroundElevated: backgroundElevated ?? this.backgroundElevated,
      backgroundOverlay: backgroundOverlay ?? this.backgroundOverlay,
    );
  }

  @override
  AppColorsExt lerp(AppColorsExt? other, double t) {
    if (other == null) return this;
    return AppColorsExt(
      ratingGold: Color.lerp(ratingGold, other.ratingGold, t)!,
      badgeSuccess: Color.lerp(badgeSuccess, other.badgeSuccess, t)!,
      badgeNowShowing: Color.lerp(badgeNowShowing, other.badgeNowShowing, t)!,
      badgeComingSoon: Color.lerp(badgeComingSoon, other.badgeComingSoon, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
      backgroundApp: Color.lerp(backgroundApp, other.backgroundApp, t)!,
      backgroundElevated: Color.lerp(backgroundElevated, other.backgroundElevated, t)!,
      backgroundOverlay: Color.lerp(backgroundOverlay, other.backgroundOverlay, t)!,
    );
  }
}

import 'package:flutter/material.dart';

import 'generated/typography_tokens.dart';

/// Builds the [TextTheme] used by [AppTheme]. All sizes/weights/families come
/// from generated typography tokens — zero hardcoded values.
TextTheme buildAppTextTheme(Color onSurface) {
  return TextTheme(
    displayLarge: TextStyle(
      fontFamily: FontFamilyTokens.display,
      fontSize: FontSizeTokens.display_large,
      fontWeight: _fw(FontWeightTokens.bold),
      height: LineHeightTokens.display_large,
      color: onSurface,
    ),
    displayMedium: TextStyle(
      fontFamily: FontFamilyTokens.heading,
      fontSize: FontSizeTokens.display_medium,
      fontWeight: _fw(FontWeightTokens.bold),
      height: LineHeightTokens.display_medium,
      color: onSurface,
    ),
    displaySmall: TextStyle(
      fontFamily: FontFamilyTokens.heading,
      fontSize: FontSizeTokens.display_small,
      fontWeight: _fw(FontWeightTokens.semibold),
      height: LineHeightTokens.display_small,
      color: onSurface,
    ),
    headlineLarge: TextStyle(
      fontFamily: FontFamilyTokens.heading,
      fontSize: FontSizeTokens.headline_large,
      fontWeight: _fw(FontWeightTokens.bold),
      height: LineHeightTokens.headline_large,
      color: onSurface,
    ),
    headlineMedium: TextStyle(
      fontFamily: FontFamilyTokens.heading,
      fontSize: FontSizeTokens.headline_medium,
      fontWeight: _fw(FontWeightTokens.bold),
      height: LineHeightTokens.headline_medium,
      color: onSurface,
    ),
    headlineSmall: TextStyle(
      fontFamily: FontFamilyTokens.heading,
      fontSize: FontSizeTokens.headline_small,
      fontWeight: _fw(FontWeightTokens.semibold),
      height: LineHeightTokens.headline_small,
      color: onSurface,
    ),
    titleLarge: TextStyle(
      fontFamily: FontFamilyTokens.heading,
      fontSize: FontSizeTokens.title_large,
      fontWeight: _fw(FontWeightTokens.semibold),
      height: LineHeightTokens.title_large,
      color: onSurface,
    ),
    titleMedium: TextStyle(
      fontFamily: FontFamilyTokens.body,
      fontSize: FontSizeTokens.title_medium,
      fontWeight: _fw(FontWeightTokens.medium),
      height: LineHeightTokens.title_medium,
      color: onSurface,
    ),
    titleSmall: TextStyle(
      fontFamily: FontFamilyTokens.body,
      fontSize: FontSizeTokens.title_small,
      fontWeight: _fw(FontWeightTokens.medium),
      height: LineHeightTokens.title_small,
      color: onSurface,
    ),
    bodyLarge: TextStyle(
      fontFamily: FontFamilyTokens.body,
      fontSize: FontSizeTokens.body_large,
      fontWeight: _fw(FontWeightTokens.regular),
      height: LineHeightTokens.body_large,
      color: onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: FontFamilyTokens.body,
      fontSize: FontSizeTokens.body_medium,
      fontWeight: _fw(FontWeightTokens.regular),
      height: LineHeightTokens.body_medium,
      color: onSurface,
    ),
    bodySmall: TextStyle(
      fontFamily: FontFamilyTokens.body,
      fontSize: FontSizeTokens.body_small,
      fontWeight: _fw(FontWeightTokens.regular),
      height: LineHeightTokens.body_small,
      color: onSurface,
    ),
    labelLarge: TextStyle(
      fontFamily: FontFamilyTokens.body,
      fontSize: FontSizeTokens.label_large,
      fontWeight: _fw(FontWeightTokens.medium),
      height: LineHeightTokens.label_large,
      color: onSurface,
    ),
    labelMedium: TextStyle(
      fontFamily: FontFamilyTokens.body,
      fontSize: FontSizeTokens.label_medium,
      fontWeight: _fw(FontWeightTokens.medium),
      height: LineHeightTokens.label_medium,
      color: onSurface,
    ),
    labelSmall: TextStyle(
      fontFamily: FontFamilyTokens.body,
      fontSize: FontSizeTokens.label_small,
      fontWeight: _fw(FontWeightTokens.medium),
      height: LineHeightTokens.label_small,
      color: onSurface,
    ),
  );
}

/// Converts a numeric weight token (100..900) to a Flutter [FontWeight].
FontWeight _fw(int w) => switch (w) {
      100 => FontWeight.w100,
      200 => FontWeight.w200,
      300 => FontWeight.w300,
      400 => FontWeight.w400,
      500 => FontWeight.w500,
      600 => FontWeight.w600,
      700 => FontWeight.w700,
      800 => FontWeight.w800,
      900 => FontWeight.w900,
      _ => FontWeight.normal,
    };

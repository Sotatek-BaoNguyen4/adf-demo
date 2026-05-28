// NOTE: Bundle Poppins, Inter, Righteous .ttf files in assets/fonts/ and
// register them in pubspec.yaml flutter.fonts block. Until then, fontFamily
// names are declared as placeholders  Flutter falls back to system font at
// runtime without crashing.
import 'package:flutter/material.dart';

import 'extensions/app_colors_ext.dart';
import 'extensions/app_gradients_ext.dart';
import 'extensions/app_shape_ext.dart';
import 'generated/radius_tokens.dart';
import 'scheme_source.dart';
import 'text_theme_builder.dart';

/// Builds app-wide [ThemeData] for dark and light modes. All colors, radii,
/// typography come from generated tokens  zero hardcoded literals here.
abstract final class AppTheme {
  /// Dark theme  default for MVP (themeMode: ThemeMode.dark).
  static ThemeData dark() => _build(
        colors: const DarkScheme(),
        ext: AppColorsExt.dark,
        brightness: Brightness.dark,
      );

  /// Light theme  emitted but unused in MVP.
  static ThemeData light() => _build(
        colors: const LightScheme(),
        ext: AppColorsExt.light,
        brightness: Brightness.light,
      );

  static ThemeData _build({
    required SchemeSource colors,
    required AppColorsExt ext,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      secondaryContainer: colors.secondaryContainer,
      onSecondaryContainer: colors.onSecondaryContainer,
      tertiary: colors.tertiary,
      onTertiary: colors.onTertiary,
      tertiaryContainer: colors.tertiaryContainer,
      onTertiaryContainer: colors.onTertiaryContainer,
      error: colors.error,
      onError: colors.onError,
      errorContainer: colors.errorContainer,
      onErrorContainer: colors.onErrorContainer,
      surface: colors.surface,
      onSurface: colors.onSurface,
      surfaceContainerLow: colors.surfaceContainerLow,
      surfaceContainer: colors.surfaceContainer,
      surfaceContainerHigh: colors.surfaceContainerHigh,
      surfaceContainerHighest: colors.surfaceContainerHighest,
      onSurfaceVariant: colors.onSurfaceVariant,
      outline: colors.outline,
      outlineVariant: colors.outlineVariant,
      inverseSurface: colors.inverseSurface,
      onInverseSurface: colors.onInverseSurface,
      inversePrimary: colors.inversePrimary,
      scrim: colors.scrim,
      shadow: colors.shadow,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: buildAppTextTheme(colorScheme.onSurface),
      scaffoldBackgroundColor: colors.surface,
      cardTheme: CardThemeData(
        color: colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.medium),
        ),
        elevation: 0,
      ),
      extensions: [
        ext,
        AppShapeExt.instance,
        brightness == Brightness.dark ? AppGradientsExt.dark : AppGradientsExt.light,
      ],
    );
  }
}

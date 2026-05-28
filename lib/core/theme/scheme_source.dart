import 'package:flutter/material.dart';

import 'generated/color_tokens.dart';

/// Internal contract: provides one color per Material 3 ColorScheme slot.
/// Each theme (dark/light) supplies its own implementation backed by tokens.
abstract interface class SchemeSource {
  Color get primary;
  Color get onPrimary;
  Color get primaryContainer;
  Color get onPrimaryContainer;
  Color get secondary;
  Color get onSecondary;
  Color get secondaryContainer;
  Color get onSecondaryContainer;
  Color get tertiary;
  Color get onTertiary;
  Color get tertiaryContainer;
  Color get onTertiaryContainer;
  Color get error;
  Color get onError;
  Color get errorContainer;
  Color get onErrorContainer;
  Color get surface;
  Color get onSurface;
  Color get surfaceContainerLow;
  Color get surfaceContainer;
  Color get surfaceContainerHigh;
  Color get surfaceContainerHighest;
  Color get onSurfaceVariant;
  Color get outline;
  Color get outlineVariant;
  Color get inverseSurface;
  Color get onInverseSurface;
  Color get inversePrimary;
  Color get scrim;
  Color get shadow;
}

final class DarkScheme implements SchemeSource {
  const DarkScheme();
  @override Color get primary => DarkColorTokens.primary_default;
  @override Color get onPrimary => DarkColorTokens.primary_on;
  @override Color get primaryContainer => DarkColorTokens.primary_container;
  @override Color get onPrimaryContainer => DarkColorTokens.primary_on_container;
  @override Color get secondary => DarkColorTokens.secondary_default;
  @override Color get onSecondary => DarkColorTokens.secondary_on;
  @override Color get secondaryContainer => DarkColorTokens.secondary_container;
  @override Color get onSecondaryContainer => DarkColorTokens.secondary_on_container;
  @override Color get tertiary => DarkColorTokens.tertiary_default;
  @override Color get onTertiary => DarkColorTokens.tertiary_on;
  @override Color get tertiaryContainer => DarkColorTokens.tertiary_container;
  @override Color get onTertiaryContainer => DarkColorTokens.tertiary_on_container;
  @override Color get error => DarkColorTokens.error_default;
  @override Color get onError => DarkColorTokens.error_on;
  @override Color get errorContainer => DarkColorTokens.error_container;
  @override Color get onErrorContainer => DarkColorTokens.error_on_container;
  @override Color get surface => DarkColorTokens.surface_default;
  @override Color get onSurface => DarkColorTokens.on_surface_default;
  @override Color get surfaceContainerLow => DarkColorTokens.surface_container_low;
  @override Color get surfaceContainer => DarkColorTokens.surface_container;
  @override Color get surfaceContainerHigh => DarkColorTokens.surface_container_high;
  @override Color get surfaceContainerHighest => DarkColorTokens.surface_container_highest;
  @override Color get onSurfaceVariant => DarkColorTokens.on_surface_variant;
  @override Color get outline => DarkColorTokens.outline_default;
  @override Color get outlineVariant => DarkColorTokens.outline_variant;
  @override Color get inverseSurface => DarkColorTokens.inverse_surface;
  @override Color get onInverseSurface => DarkColorTokens.inverse_on_surface;
  @override Color get inversePrimary => DarkColorTokens.inverse_primary;
  @override Color get scrim => DarkColorTokens.scrim;
  @override Color get shadow => DarkColorTokens.shadow;
}

final class LightScheme implements SchemeSource {
  const LightScheme();
  @override Color get primary => LightColorTokens.primary_default;
  @override Color get onPrimary => LightColorTokens.primary_on;
  @override Color get primaryContainer => LightColorTokens.primary_container;
  @override Color get onPrimaryContainer => LightColorTokens.primary_on_container;
  @override Color get secondary => LightColorTokens.secondary_default;
  @override Color get onSecondary => LightColorTokens.secondary_on;
  @override Color get secondaryContainer => LightColorTokens.secondary_container;
  @override Color get onSecondaryContainer => LightColorTokens.secondary_on_container;
  @override Color get tertiary => LightColorTokens.tertiary_default;
  @override Color get onTertiary => LightColorTokens.tertiary_on;
  @override Color get tertiaryContainer => LightColorTokens.tertiary_container;
  @override Color get onTertiaryContainer => LightColorTokens.tertiary_on_container;
  @override Color get error => LightColorTokens.error_default;
  @override Color get onError => LightColorTokens.error_on;
  @override Color get errorContainer => LightColorTokens.error_container;
  @override Color get onErrorContainer => LightColorTokens.error_on_container;
  @override Color get surface => LightColorTokens.surface_default;
  @override Color get onSurface => LightColorTokens.on_surface_default;
  @override Color get surfaceContainerLow => LightColorTokens.surface_container_low;
  @override Color get surfaceContainer => LightColorTokens.surface_container;
  @override Color get surfaceContainerHigh => LightColorTokens.surface_container_high;
  @override Color get surfaceContainerHighest => LightColorTokens.surface_container_highest;
  @override Color get onSurfaceVariant => LightColorTokens.on_surface_variant;
  @override Color get outline => LightColorTokens.outline_default;
  @override Color get outlineVariant => LightColorTokens.outline_variant;
  @override Color get inverseSurface => LightColorTokens.inverse_surface;
  @override Color get onInverseSurface => LightColorTokens.inverse_on_surface;
  @override Color get inversePrimary => LightColorTokens.inverse_primary;
  @override Color get scrim => LightColorTokens.scrim;
  @override Color get shadow => LightColorTokens.shadow;
}

// Shared test harness for home widget tests.
//
// Wraps a widget in ProviderScope + MaterialApp using [AppTheme.dark] so every
// test gets the full theme extension chain (AppGradientsExt, AppColorsExt, etc.)
// without boilerplate repetition.
//
// Usage:
//   await pumpInProviderScope(tester, MyWidget(), overrides: [...]);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/core/theme/app_theme.dart';

/// Pumps [child] inside [ProviderScope] + [MaterialApp] with the dark theme.
///
/// [overrides] are forwarded to the [ProviderScope] — use them to inject
/// fixture data or stub async providers.
Future<void> pumpInProviderScope(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: child),
      ),
    ),
  );
}

// Widget tests for HomeTopAppBar.
//
// Verifies: logo container, wordmark text, Notifications button semantics,
// and Profile button semantics are all present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/presentation/widgets/home_top_app_bar.dart';

import '../../../_helpers/widget_test_harness.dart';

void main() {
  testWidgets('renders ADF Cinema wordmark', (tester) async {
    await pumpInProviderScope(tester, const HomeTopAppBar());
    expect(find.text('ADF Cinema'), findsOneWidget);
  });

  testWidgets('renders logo container with A letter', (tester) async {
    await pumpInProviderScope(tester, const HomeTopAppBar());
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('renders Notifications bell with semantics label', (tester) async {
    await pumpInProviderScope(tester, const HomeTopAppBar());
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
  });

  testWidgets('renders Profile avatar with semantics label', (tester) async {
    await pumpInProviderScope(tester, const HomeTopAppBar());
    expect(find.bySemanticsLabel('Profile'), findsOneWidget);
  });

  testWidgets('bell icon is present', (tester) async {
    await pumpInProviderScope(tester, const HomeTopAppBar());
    expect(
      find.byIcon(Icons.notifications_outlined),
      findsOneWidget,
    );
  });

  testWidgets('tapping bell does not throw (no-op)', (tester) async {
    await pumpInProviderScope(tester, const HomeTopAppBar());
    await tester.tap(find.bySemanticsLabel('Notifications'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

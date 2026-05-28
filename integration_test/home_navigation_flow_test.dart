// Integration tests for home shell navigation flow.
//
// Verifies the bottom-nav routing between all 5 branches:
//   Home / Explore / Tickets (FAB) / Saved / Profile
//
// Run on a real device or emulator:
//   fvm flutter test integration_test/home_navigation_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:adf_demo/main.dart' as app;
import 'package:adf_demo/app/shell/placeholder_tab.dart';
import 'package:adf_demo/core/navigation/tickets_fab_tile.dart';
import 'package:adf_demo/features/tickets/presentation/tickets_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home navigation flow', () {
    testWidgets('boot → Home tab is active', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Home destination icon (filled) indicates it is selected.
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('tap Explore → PlaceholderTab(Explore) visible', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.explore_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(PlaceholderTab), findsOneWidget);
      expect(find.text('Explore'), findsWidgets);
    });

    testWidgets('tap Saved → PlaceholderTab(Saved) visible', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark_outline));
      await tester.pumpAndSettle();

      expect(find.byType(PlaceholderTab), findsOneWidget);
      expect(find.text('Saved'), findsWidgets);
    });

    testWidgets('tap Profile → PlaceholderTab(Profile) visible', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      expect(find.byType(PlaceholderTab), findsOneWidget);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('tap Tickets FAB → TicketsScreen visible', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // TicketsFabTile is the raised center button overlaying the nav bar.
      await tester.tap(find.byType(TicketsFabTile));
      await tester.pumpAndSettle();

      expect(find.byType(TicketsScreen), findsOneWidget);
    });
  });
}

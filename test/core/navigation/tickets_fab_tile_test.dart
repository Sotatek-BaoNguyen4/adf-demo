// Widget tests for TicketsFabTile.
//
// TicketsFabTile calls context.go('/tickets') on tap, so tests wrap it in a
// GoRouter with a /tickets route. Verifies: icon renders, size matches spec,
// and tapping navigates to the tickets stub screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:adf_demo/core/navigation/tickets_fab_tile.dart';
import 'package:adf_demo/core/theme/app_theme.dart';

Widget _ticketsStub(BuildContext context, GoRouterState state) =>
    const Scaffold(body: Center(child: Text('Tickets Screen')));

Widget _homeStub(BuildContext context, GoRouterState state) =>
    const Scaffold(body: Center(child: TicketsFabTile()));

Future<void> pumpFab(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: _homeStub),
      GoRoute(path: '/tickets', builder: _ticketsStub),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        theme: AppTheme.dark(),
        routerConfig: router,
      ),
    ),
  );
}

void main() {
  testWidgets('renders ticket icon', (tester) async {
    await pumpFab(tester);
    expect(find.byIcon(Icons.confirmation_num_outlined), findsOneWidget);
  });

  testWidgets('container is 56x56', (tester) async {
    await pumpFab(tester);
    final size = tester.getSize(find.byType(TicketsFabTile));
    expect(size.width, TicketsFabTile.size);
    expect(size.height, TicketsFabTile.size);
  });

  testWidgets('tapping navigates to /tickets stub screen', (tester) async {
    await pumpFab(tester);
    await tester.tap(find.byType(TicketsFabTile));
    await tester.pumpAndSettle();
    expect(find.text('Tickets Screen'), findsOneWidget);
  });
}

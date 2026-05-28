import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/tickets/presentation/tickets_screen.dart';
import 'shell/home_shell.dart';
import 'shell/placeholder_tab.dart';

/// Global [GoRouter] instance with a [StatefulShellRoute.indexedStack].
///
/// Branches (mockup taxonomy):
///   0 /home     → [HomeScreen]
///   1 /explore  → [PlaceholderTab] (absorbs /search + /cinemas + /community)
///   2 /tickets  → [TicketsScreen]  (raised FAB tile)
///   3 /saved    → [PlaceholderTab] (renamed from /bookings)
///   4 /profile  → [PlaceholderTab]
///
/// Redirects map old paths so any cached deep-links remain functional:
///   /search     → /explore
///   /cinemas    → /explore
///   /community  → /explore
///   /bookings   → /saved
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    const redirects = {
      '/search': '/explore',
      '/cinemas': '/explore',
      '/community': '/explore',
      '/bookings': '/saved',
    };
    return redirects[state.uri.path];
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) =>
                  const PlaceholderTab(name: 'Explore'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tickets',
              builder: (context, state) => const TicketsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              builder: (context, state) =>
                  const PlaceholderTab(name: 'Saved'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const PlaceholderTab(name: 'Profile'),
            ),
          ],
        ),
      ],
    ),
  ],
);

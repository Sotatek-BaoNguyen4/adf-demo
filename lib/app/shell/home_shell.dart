import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/cinema_nav_bar.dart';

/// Root shell scaffold wrapping the [StatefulNavigationShell].
///
/// Provides the persistent [CinemaNavBar] at the bottom while each tab
/// maintains its own independent navigation stack (HLD §4.4).
class HomeShell extends StatelessWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CinemaNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          // Re-tapping the active tab returns to its initial route.
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

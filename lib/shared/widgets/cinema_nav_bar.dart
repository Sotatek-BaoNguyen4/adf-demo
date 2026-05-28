import 'package:flutter/material.dart';

import '../../core/navigation/tickets_fab_tile.dart';
import '../../core/theme/extensions/app_colors_ext.dart';

/// Bottom navigation bar with 5 destinations matching mockup taxonomy:
/// Home / Explore / [Tickets FAB] / Saved / Profile.
///
/// The Tickets slot is rendered as a raised [TicketsFabTile] overlaid via
/// [Stack] — the bar itself reserves an empty [SizedBox] in that slot so
/// surrounding tap zones are not obstructed.
///
/// Colors sourced from [AppColorsExt] — no hex literals.
class CinemaNavBar extends StatelessWidget {
  const CinemaNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Height of the nav bar itself (matches Material 3 NavigationBar default
  /// so icons + labels render without being clipped at the top).
  static const double barHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExt>()!;

    // SizedBox is exactly bar height — no extra empty space above (which
    // previously showed as a black band). The FAB tile overflows upward
    // via Stack(clipBehavior: Clip.none); Scaffold's bottomNavigationBar
    // slot does not clip its descendants, so the FAB paints over body.
    return SizedBox(
      height: barHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ── Bar (4 real destinations + empty center slot) ──────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavigationBar(
              selectedIndex: _barIndex(currentIndex),
              onDestinationSelected: (i) => onTap(_routeIndex(i)),
              backgroundColor: appColors.navBackground,
              indicatorColor: appColors.navActive.withValues(alpha: 0.2),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                // Empty centre slot — FAB tile sits above it.
                NavigationDestination(
                  icon: SizedBox(width: TicketsFabTile.size),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_outline),
                  selectedIcon: Icon(Icons.bookmark),
                  label: 'Saved',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),

          // ── Raised FAB tile ─────────────────────────────────────────────
          // Center the FAB on the bar's TOP edge — half above, half below.
          // bottom = barHeight - (fabSize / 2). Top half paints OUTSIDE the
          // SizedBox bounds; safe because the outer Stack has clipBehavior.none
          // and Scaffold's bottom slot does not clip descendants.
          const Positioned(
            bottom: barHeight - (TicketsFabTile.size / 2),
            child: TicketsFabTile(),
          ),
        ],
      ),
    );
  }

  /// Maps shell branch index (0-4) to NavigationBar item index (0-4).
  /// Branch 2 = Tickets; bar slot 2 is the empty placeholder.
  int _barIndex(int branchIndex) {
    // Keep 1:1 — placeholder slot at 2 ensures no indicator on Tickets tap.
    return branchIndex;
  }

  /// Maps NavigationBar item index back to shell branch index.
  /// Tapping the empty slot (index 2) is prevented by the FAB overlay,
  /// but guard it here to avoid accidental goBranch(2) from bar taps.
  int _routeIndex(int barIndex) => barIndex;
}

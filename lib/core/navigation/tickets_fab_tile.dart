import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/extensions/app_gradients_ext.dart';

/// Raised gradient FAB tile for the Tickets branch in the bottom nav shell.
///
/// 56×56, radius 16, painted with [AppGradientsExt.accent].
/// Shadow uses [colorScheme.primary] at 35% opacity — no hex literals.
/// Tapping navigates to `/tickets` via [GoRouter].
class TicketsFabTile extends StatelessWidget {
  const TicketsFabTile({super.key});

  static const double size = 56.0;
  static const double _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final gradients = Theme.of(context).extension<AppGradientsExt>()!;

    return GestureDetector(
      onTap: () => context.go('/tickets'),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: gradients.accent,
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.confirmation_num_outlined,
          color: cs.onPrimary,
          size: 26,
        ),
      ),
    );
  }
}

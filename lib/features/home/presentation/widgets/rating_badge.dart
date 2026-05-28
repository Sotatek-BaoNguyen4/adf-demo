import 'package:flutter/material.dart';

import '../../../../core/theme/extensions/app_colors_ext.dart';
import '../../../../core/theme/generated/spacing_tokens.dart';

/// Star icon + numeric score badge.
///
/// Gold color from [AppColorsExt.ratingGold] — never hardcoded.
/// Only rendered when [rating] is non-null.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColorsExt>()!.ratingGold;
    final labelSmall = Theme.of(context).textTheme.labelSmall;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.s1,
        vertical: SpacingTokens.s1,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(SpacingTokens.s1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: gold, size: SpacingTokens.s3),
          const SizedBox(width: SpacingTokens.s1),
          Text(
            rating.toStringAsFixed(1),
            style: labelSmall?.copyWith(
              color: gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

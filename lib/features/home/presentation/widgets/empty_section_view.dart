import 'package:flutter/material.dart';

import '../../../../core/theme/generated/spacing_tokens.dart';

/// Shown when a movie rail returns an empty list (UC EF-2).
///
/// Text styled via theme — no hardcoded colors or sizes.
class EmptySectionView extends StatelessWidget {
  const EmptySectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.s4,
        vertical: SpacingTokens.s6,
      ),
      child: Row(
        children: [
          Icon(
            Icons.movie_filter_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: SpacingTokens.s2),
          Text(
            'No movies available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

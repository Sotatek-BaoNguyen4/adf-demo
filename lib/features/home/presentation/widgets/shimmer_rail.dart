import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/generated/spacing_tokens.dart';
import 'shimmer_movie_card.dart';

/// Section header text shimmer + 3 [ShimmerMovieCard]s in a row.
///
/// Shown while the [MovieRail] is in loading state.
class ShimmerRail extends StatelessWidget {
  const ShimmerRail({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHigh;
    final highlight = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header placeholder
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.s4),
          child: Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            child: Container(
              width: SpacingTokens.s20,
              height: SpacingTokens.s6,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(SpacingTokens.s1),
              ),
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.s3),
        // 3 card skeletons
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.s4),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) =>
                const SizedBox(width: SpacingTokens.s3),
            itemBuilder: (_, __) => const ShimmerMovieCard(),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/generated/spacing_tokens.dart';
import 'movie_card.dart';

/// Shimmer skeleton matching [MovieCard] dimensions exactly.
///
/// Base/highlight colors from [ColorScheme] — no hex literals.
class ShimmerMovieCard extends StatelessWidget {
  const ShimmerMovieCard({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHigh;
    final highlight = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: SizedBox(
        width: MovieCard.cardWidth,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Container(
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(SpacingTokens.s3),
            ),
          ),
        ),
      ),
    );
  }
}

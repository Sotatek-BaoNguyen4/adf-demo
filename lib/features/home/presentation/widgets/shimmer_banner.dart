import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/generated/spacing_tokens.dart';

/// Full-width shimmer placeholder matching the banner carousel height.
///
/// Base/highlight from [ColorScheme] — no hex literals.
class ShimmerBanner extends StatelessWidget {
  const ShimmerBanner({super.key});

  /// Matches the banner carousel aspect ratio used in [BannerCarousel].
  static const double aspectRatio = 16 / 7;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHigh;
    final highlight = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          color: base,
          margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.s4),
        ),
      ),
    );
  }
}

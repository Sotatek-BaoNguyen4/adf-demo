import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/extensions/app_colors_ext.dart';
import '../../../../core/theme/extensions/app_gradients_ext.dart';
import '../../../../core/theme/generated/spacing_tokens.dart';
import '../../domain/entities/movie.dart';

/// Single row in the Trending This Week vertical list.
///
/// Layout: [rank gradient text] | [80×120 thumb] | [title + chips + rating + views]
/// Rank numeral painted via [ShaderMask] using [AppGradientsExt.accent].
/// All colors via [Theme] — no hex literals.
class TrendingListRow extends StatelessWidget {
  const TrendingListRow({super.key, required this.movie, this.onTap});

  final Movie movie;
  final VoidCallback? onTap;

  static const double _thumbWidth = 80.0;
  static const double _thumbHeight = 120.0;
  static const double _thumbRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).extension<AppGradientsExt>()!.accent;
    final gold = Theme.of(context).extension<AppColorsExt>()!.ratingGold;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.s4,
          vertical: SpacingTokens.s3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rank numeral — gradient via ShaderMask
            SizedBox(
              width: 36,
              child: ShaderMask(
                shaderCallback: (bounds) => accent.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  '${movie.rank ?? 0}',
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: SpacingTokens.s3),

            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(_thumbRadius),
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                width: _thumbWidth,
                height: _thumbHeight,
                fit: BoxFit.cover,
                memCacheWidth: (_thumbWidth * 2).toInt(),
                placeholder: (context, url) => ColoredBox(
                  color: colorScheme.surfaceContainerHigh,
                ),
                errorWidget: (context, url, error) => ColoredBox(
                  color: colorScheme.surfaceContainerHigh,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: SpacingTokens.s6,
                  ),
                ),
              ),
            ),

            const SizedBox(width: SpacingTokens.s3),

            // Meta column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: SpacingTokens.s1),

                  // Rating row
                  if (movie.rating != null)
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: gold,
                          size: SpacingTokens.s4,
                        ),
                        const SizedBox(width: SpacingTokens.s1),
                        Text(
                          movie.rating!.toStringAsFixed(1),
                          style: textTheme.labelSmall?.copyWith(
                            color: gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: SpacingTokens.s1),

                  // Views row
                  if (movie.views != null)
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: SpacingTokens.s4,
                        ),
                        const SizedBox(width: SpacingTokens.s1),
                        Text(
                          movie.views!,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

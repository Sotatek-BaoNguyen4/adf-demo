import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/generated/spacing_tokens.dart';
import '../../domain/entities/movie.dart';
import 'rating_badge.dart';

/// 128×188 poster card for the Now Showing horizontal rail.
///
/// Differs from the generic [MovieCard]:
///   - Rating pill is TOP-LEFT (not top-right)
///   - Title + genre rendered BELOW the poster (not overlaid)
/// All colors via [Theme] — no hex literals.
class NowShowingCard extends StatelessWidget {
  const NowShowingCard({super.key, required this.movie, this.onTap});

  final Movie movie;
  final VoidCallback? onTap;

  static const double _posterWidth = 128.0;
  static const double _posterHeight = 188.0;
  static const double _borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: _posterWidth,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poster with rating pill top-left
            ClipRRect(
              borderRadius: BorderRadius.circular(_borderRadius),
              child: SizedBox(
                width: _posterWidth,
                height: _posterHeight,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      width: _posterWidth,
                      height: _posterHeight,
                      fit: BoxFit.cover,
                      memCacheWidth: (_posterWidth * 2).toInt(),
                      placeholder: (context, url) => ColoredBox(
                        color: colorScheme.surfaceContainerHigh,
                      ),
                      errorWidget: (context, url, error) => ColoredBox(
                        color: colorScheme.surfaceContainerHigh,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (movie.rating != null)
                      Positioned(
                        top: SpacingTokens.s2,
                        left: SpacingTokens.s2,
                        child: RatingBadge(rating: movie.rating!),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: SpacingTokens.s2),

            // Title below poster
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),

            // Genre subtitle (releaseDate as fallback label)
            if (movie.releaseDate != null)
              Text(
                movie.releaseDate!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

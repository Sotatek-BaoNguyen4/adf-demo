import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/extensions/app_shape_ext.dart';
import '../../../../core/theme/generated/spacing_tokens.dart';
import '../../domain/entities/movie.dart';
import 'rating_badge.dart';

/// 2:3 poster card with gradient overlay, title, and optional rating badge.
///
/// Shape from [AppShapeExt.medium]; all colors from [Theme] — no hex literals.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});

  final Movie movie;

  /// Rendered card width used by [MovieRail] for list item sizing.
  static const double cardWidth = 120.0;

  @override
  Widget build(BuildContext context) {
    final shape = Theme.of(context).extension<AppShapeExt>()!.medium;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return SizedBox(
      width: cardWidth,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: shape),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster image
              CachedNetworkImage(
                imageUrl: movie.posterUrl,
                fit: BoxFit.cover,
                memCacheWidth: cardWidth.toInt() * 2,
                placeholder: (_, __) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                errorWidget: (_, __, ___) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // Bottom gradient overlay
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: SpacingTokens.s16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        surfaceColor.withValues(alpha: 0.0),
                        surfaceColor.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
              ),

              // Title at bottom
              Positioned(
                left: SpacingTokens.s2,
                right: SpacingTokens.s2,
                bottom: SpacingTokens.s2,
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),

              // Rating badge — top right, only when rating present
              if (movie.rating != null)
                Positioned(
                  top: SpacingTokens.s2,
                  right: SpacingTokens.s2,
                  child: RatingBadge(rating: movie.rating!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

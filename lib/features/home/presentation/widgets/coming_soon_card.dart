import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/generated/spacing_tokens.dart';
import '../../domain/entities/movie.dart';

/// 148×210 poster card for the Coming Soon horizontal rail.
///
/// Renders a date badge (MMM / day stacked) top-left using
/// [colorScheme.error] background — matches mockup COMING SOON badge.
/// Title + expected-release line rendered BELOW the poster.
/// All colors via [Theme] — no hex literals.
class ComingSoonCard extends StatelessWidget {
  const ComingSoonCard({super.key, required this.movie, this.onTap});

  final Movie movie;
  final VoidCallback? onTap;

  static const double _posterWidth = 148.0;
  static const double _posterHeight = 210.0;
  static const double _borderRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final dateLabel = _parseDateLabel(movie.expectedReleaseDate);

    return SizedBox(
      width: _posterWidth,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poster with top-left date badge
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
                    if (dateLabel != null)
                      Positioned(
                        top: SpacingTokens.s2,
                        left: SpacingTokens.s2,
                        child: _DateBadge(
                          month: dateLabel.month,
                          day: dateLabel.day,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: SpacingTokens.s2),

            // Text section — Flexible so it can absorb tight parent constraints
            // without throwing a RenderFlex overflow.
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (movie.expectedReleaseDate != null)
                    Text(
                      'Expected: ${_formatFull(movie.expectedReleaseDate!)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns (month abbr uppercase, day string) or null on parse failure.
  static _DateLabel? _parseDateLabel(String? iso) {
    if (iso == null) return null;
    try {
      final d = DateTime.parse(iso);
      return _DateLabel(
        month: DateFormat('MMM', 'en_US').format(d).toUpperCase(),
        day: DateFormat('d', 'en_US').format(d),
      );
    } catch (_) {
      return null;
    }
  }

  /// Full "Mon dd" label for the subtitle line.
  static String _formatFull(String iso) {
    try {
      final d = DateTime.parse(iso);
      return DateFormat('MMM d, yyyy', 'en_US').format(d);
    } catch (_) {
      return iso;
    }
  }
}

/// Simple data class — MMM (uppercase) + day numeral.
class _DateLabel {
  const _DateLabel({required this.month, required this.day});
  final String month;
  final String day;
}

/// Stacked month + day badge rendered with [colorScheme.error] background.
class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.month, required this.day});

  final String month;
  final String day;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.s2,
        vertical: SpacingTokens.s1,
      ),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(SpacingTokens.s2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            month,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onError,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
          Text(
            day,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onError,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/extensions/app_colors_ext.dart';
import '../../../../core/theme/generated/radius_tokens.dart';
import '../../../../core/theme/generated/spacing_tokens.dart';
import '../../domain/entities/banner.dart' as domain;

/// Stateless overlay rendered over the banner image.
///
/// Shows: badge pill → title → genre + star rating → Book Tickets / Trailer CTAs.
/// All colors sourced from theme tokens — no hex literals.
class BannerOverlayContent extends StatelessWidget {
  const BannerOverlayContent({
    super.key,
    required this.banner,
    required this.onBook,
    required this.onTrailer,
  });

  final domain.Banner banner;
  final VoidCallback onBook;
  final VoidCallback onTrailer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColorsExt>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.s5,
        0,
        SpacingTokens.s5,
        SpacingTokens.s5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (banner.badgeKind != null) ...[
            _BadgePill(kind: banner.badgeKind!, appColors: appColors),
            const SizedBox(height: SpacingTokens.s2),
          ],
          Text(
            banner.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: SpacingTokens.s1),
          _GenreRatingRow(
            genre: banner.genre,
            rating: banner.rating,
            ratingGold: appColors.ratingGold,
            secondaryText: cs.onSurfaceVariant,
          ),
          const SizedBox(height: SpacingTokens.s4),
          _CtaRow(
            cs: cs,
            onBook: onBook,
            onTrailer: onTrailer,
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.kind, required this.appColors});

  final domain.BadgeKind kind;
  final AppColorsExt appColors;

  @override
  Widget build(BuildContext context) {
    final isNowShowing = kind == domain.BadgeKind.nowShowing;
    final bg = isNowShowing ? appColors.badgeNowShowing : appColors.badgeComingSoon;
    final fg = isNowShowing
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSecondaryContainer;
    final label = isNowShowing ? 'NOW SHOWING' : 'COMING SOON';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.s3,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(RadiusTokens.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _GenreRatingRow extends StatelessWidget {
  const _GenreRatingRow({
    required this.genre,
    required this.rating,
    required this.ratingGold,
    required this.secondaryText,
  });

  final String? genre;
  final double? rating;
  final Color ratingGold;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    if (genre == null && rating == null) return const SizedBox.shrink();

    return Row(
      children: [
        if (genre != null)
          Text(
            genre!,
            style: TextStyle(fontSize: 13, color: secondaryText),
          ),
        if (genre != null && rating != null)
          const SizedBox(width: SpacingTokens.s3),
        if (rating != null) ...[
          Icon(Icons.star_rounded, size: 14, color: ratingGold),
          const SizedBox(width: SpacingTokens.s1),
          Text(
            rating!.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ratingGold,
            ),
          ),
        ],
      ],
    );
  }
}

class _CtaRow extends StatelessWidget {
  const _CtaRow({
    required this.cs,
    required this.onBook,
    required this.onTrailer,
  });

  final ColorScheme cs;
  final VoidCallback onBook;
  final VoidCallback onTrailer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onBook,
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.s3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.large - 2),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Book Tickets'),
          ),
        ),
        const SizedBox(width: SpacingTokens.s3),
        OutlinedButton.icon(
          onPressed: onTrailer,
          icon: const Icon(Icons.play_arrow_rounded, size: 16),
          label: const Text('Trailer'),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.onSurface,
            side: BorderSide(color: cs.outlineVariant),
            backgroundColor: cs.surfaceContainerHigh,
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.s4,
              vertical: SpacingTokens.s3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.large - 2),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

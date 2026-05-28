import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/generated/spacing_tokens.dart';
import '../providers/trending_provider.dart';
import 'empty_section_view.dart';
import 'error_section_view.dart';
import 'shimmer_rail.dart';
import 'trending_list_row.dart';

/// Vertical "Trending This Week" list consumed by [HomeScreen].
///
/// Renders a column (NOT a nested ListView) so the host [CustomScrollView]
/// owns the scroll — avoids nested-scroll friction (LLD risk §R4).
/// Each row delegates to [TrendingListRow].
class TrendingList extends ConsumerWidget {
  const TrendingList({super.key, this.onRetry, this.onMovieTap});

  final VoidCallback? onRetry;

  /// Called with the movie id when a row is tapped.
  final void Function(String movieId)? onMovieTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final trending = ref.watch(trendingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header + subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trending This Week',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: SpacingTokens.s1),
              Text(
                '🔥 Hot picks for you',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: SpacingTokens.s3),

        // Content
        trending.when(
          loading: () => const ShimmerRail(),
          error: (err, _) => ErrorSectionView(
            onRetry: onRetry ?? () => ref.invalidate(trendingProvider),
            message: 'Failed to load trending movies',
          ),
          data: (movies) {
            if (movies.isEmpty) return const EmptySectionView();
            return Column(
              children: movies
                  .map(
                    (m) => TrendingListRow(
                      movie: m,
                      onTap: onMovieTap != null
                          ? () => onMovieTap!(m.id)
                          : null,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/generated/spacing_tokens.dart';
import '../../domain/entities/movie.dart';
import 'empty_section_view.dart';
import 'error_section_view.dart';
import 'movie_card.dart';
import 'section_header.dart';
import 'shimmer_rail.dart';

/// Generic horizontal movie rail for a single endpoint.
///
/// Accepts [title] + [asyncMovies] + [onRetry] so the same widget serves
/// Now Showing, Coming Soon, and Recommended — only the provider differs.
class MovieRail extends StatelessWidget {
  const MovieRail({
    super.key,
    required this.title,
    required this.asyncMovies,
    required this.onRetry,
    this.onSeeAll,
  });

  final String title;
  final AsyncValue<List<Movie>> asyncMovies;
  final VoidCallback onRetry;
  final VoidCallback? onSeeAll;

  /// Height of the horizontal list area (matches [ShimmerRail]).
  static const double _listHeight = 180.0;

  @override
  Widget build(BuildContext context) {
    return asyncMovies.when(
      loading: () => const ShimmerRail(),
      error: (err, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, onSeeAll: onSeeAll),
          const SizedBox(height: SpacingTokens.s2),
          ErrorSectionView(
            onRetry: onRetry,
            message: 'Failed to load $title',
          ),
        ],
      ),
      data: (movies) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, onSeeAll: onSeeAll),
          const SizedBox(height: SpacingTokens.s3),
          if (movies.isEmpty)
            const EmptySectionView()
          else
            SizedBox(
              height: _listHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.s4,
                ),
                itemCount: movies.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: SpacingTokens.s3),
                itemBuilder: (_, index) => MovieCard(movie: movies[index]),
              ),
            ),
        ],
      ),
    );
  }
}

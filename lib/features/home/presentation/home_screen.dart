import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/generated/spacing_tokens.dart';
import 'providers/banners_provider.dart';
import 'providers/coming_soon_provider.dart';
import 'providers/now_showing_provider.dart';
import 'providers/trending_provider.dart';
import 'widgets/banner_section.dart';
import 'widgets/category_chips_bar.dart';
import 'widgets/coming_soon_card.dart';
import 'widgets/empty_section_view.dart';
import 'widgets/error_section_view.dart';
import 'widgets/home_top_app_bar.dart';
import 'widgets/now_showing_card.dart';
import 'widgets/promo_banner.dart';
import 'widgets/section_header.dart';
import 'widgets/shimmer_rail.dart';
import 'widgets/trending_list.dart';

/// Cinema home screen: layered app bar + banner section + 3 movie rails.
///
/// Layout: Stack with CustomScrollView behind + HomeTopAppBar on top.
/// Each section reads its own AsyncNotifier so failures stay isolated —
/// one rail failing does not blank the whole screen (LLD 8, FSD 2).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _nowShowingCardHeight = 188.0;
  static const double _comingSoonCardHeight = 210.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowShowing = ref.watch(nowShowingProvider);
    final comingSoon = ref.watch(comingSoonProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main scrollable content — fills the Stack.
          RefreshIndicator(
            onRefresh: () => _refreshAll(ref),
            child: CustomScrollView(
              slivers: [
                // Banner sits at top — no SafeArea padding so it bleeds edge-to-edge.
                const SliverToBoxAdapter(child: BannerSection()),
                // Category filter chips — UI-only in MVP.
                const SliverToBoxAdapter(child: CategoryChipsBar()),

                // ── Now Showing rail ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Now Showing'),
                      const SizedBox(height: SpacingTokens.s3),
                      _buildNowShowingRail(context, ref, nowShowing),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.s4)),

                // ── Trending This Week — vertical list ───────────────────────
                SliverToBoxAdapter(
                  child: TrendingList(
                    onRetry: () => ref.invalidate(trendingProvider),
                    onMovieTap: (id) => context.go('/movie/$id'),
                  ),
                ),

                // Promo banner between Trending and Coming Soon (per mockup).
                const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.s4)),
                const SliverToBoxAdapter(child: PromoBanner()),
                const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.s4)),

                // ── Coming Soon rail ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Coming Soon'),
                      const SizedBox(height: SpacingTokens.s3),
                      _buildComingSoonRail(context, ref, comingSoon),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.s6)),
              ],
            ),
          ),

          // Translucent app bar floats on top of the banner.
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeTopAppBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildNowShowingRail(
    BuildContext context,
    WidgetRef ref,
    AsyncValue asyncMovies,
  ) {
    return asyncMovies.when(
      loading: () => const ShimmerRail(),
      error: (err, _) => ErrorSectionView(
        onRetry: () => ref.invalidate(nowShowingProvider),
        message: 'Failed to load Now Showing',
      ),
      data: (movies) {
        if (movies.isEmpty) return const EmptySectionView();
        return SizedBox(
          height: _nowShowingCardHeight + 48, // poster + below-poster meta
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.s4),
            itemCount: movies.length,
            separatorBuilder: (_, _) => const SizedBox(width: SpacingTokens.s3),
            itemBuilder: (_, index) => NowShowingCard(
              movie: movies[index],
              onTap: () => context.go('/movie/${movies[index].id}'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComingSoonRail(
    BuildContext context,
    WidgetRef ref,
    AsyncValue asyncMovies,
  ) {
    return asyncMovies.when(
      loading: () => const ShimmerRail(),
      error: (err, _) => ErrorSectionView(
        onRetry: () => ref.invalidate(comingSoonProvider),
        message: 'Failed to load Coming Soon',
      ),
      data: (movies) {
        if (movies.isEmpty) return const EmptySectionView();
        return SizedBox(
          height: _comingSoonCardHeight + 64, // poster + below-poster meta
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.s4),
            itemCount: movies.length,
            separatorBuilder: (_, _) => const SizedBox(width: SpacingTokens.s3),
            itemBuilder: (_, index) => ComingSoonCard(
              movie: movies[index],
              onTap: () => context.go('/movie/${movies[index].id}'),
            ),
          ),
        );
      },
    );
  }

  /// Pull-to-refresh: re-invoke all 4 home providers in parallel.
  Future<void> _refreshAll(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(bannersProvider.future),
      ref.refresh(nowShowingProvider.future),
      ref.refresh(comingSoonProvider.future),
      ref.refresh(trendingProvider.future),
    ]);
  }
}

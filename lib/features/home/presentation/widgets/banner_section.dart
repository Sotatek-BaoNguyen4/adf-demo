import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/extensions/app_gradients_ext.dart';
import '../../../../core/theme/generated/spacing_tokens.dart';
import '../../domain/entities/banner.dart' as domain;
import '../providers/banners_provider.dart';
import 'banner_overlay_content.dart';
import 'banner_story_progress.dart';
import 'home_top_app_bar.dart';
import 'shimmer_banner.dart';

/// Banner section that replaces [BannerCarousel].
///
/// Orchestrates a single [AnimationController] (4 s linear) that drives
/// story-style progress bars and cross-fade between banner images.
/// Tapping a progress bar jumps to that banner and resets the controller.
class BannerSection extends ConsumerStatefulWidget {
  const BannerSection({super.key});

  /// Fixed height matching the mockup hero area.
  static const double height = 480.0;

  @override
  ConsumerState<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends ConsumerState<BannerSection>
    with SingleTickerProviderStateMixin {
  static const Duration _slideDuration = Duration(seconds: 4);

  late final AnimationController _ctrl;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _slideDuration);
    _ctrl.addStatusListener(_onAnimationStatus);
    // Start after first frame so banners have loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.removeStatusListener(_onAnimationStatus);
    _ctrl.dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      final banners = ref.read(bannersProvider).valueOrNull;
      if (banners == null || banners.isEmpty) return;
      setState(() {
        _activeIndex = (_activeIndex + 1) % banners.length;
      });
      _ctrl.forward(from: 0);
    }
  }

  void _jumpTo(int index) {
    setState(() => _activeIndex = index);
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bannersProvider);

    return async.when(
      loading: () => const ShimmerBanner(),
      error: (e, _) => const ShimmerBanner(),
      data: (List<domain.Banner> banners) {
        if (banners.isEmpty) return const SizedBox.shrink();

        // Clamp active index in case banner list shrinks.
        final active = _activeIndex.clamp(0, banners.length - 1);

        return SizedBox(
          height: BannerSection.height,
          child: Stack(
            children: [
              // Image layers — cross-fade via AnimatedOpacity.
              ...List.generate(banners.length, (i) {
                return AnimatedOpacity(
                  opacity: i == active ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 700),
                  child: _BannerImageLayer(banner: banners[i]),
                );
              }),

              // Gradient scrims over image.
              _GradientScrims(),

              // Banner overlay: badge / title / genre / rating / CTAs.
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: BannerOverlayContent(
                    key: ValueKey(active),
                    banner: banners[active],
                    onBook: () {}, // no-op; wired in later phase
                    onTrailer: () {},
                  ),
                ),
              ),

              // Story progress bars — positioned below the app-bar
              // (safe-area inset + app-bar content height + small gap).
              Positioned(
                top: MediaQuery.paddingOf(context).top +
                    HomeTopAppBar.height +
                    SpacingTokens.s2,
                left: SpacingTokens.s4,
                right: SpacingTokens.s4,
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, _) => BannerStoryProgress(
                    count: banners.length,
                    activeIndex: active,
                    progress01: _ctrl.value,
                    onTap: _jumpTo,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Full-bleed image for one banner slot.
class _BannerImageLayer extends StatelessWidget {
  const _BannerImageLayer({required this.banner});

  final domain.Banner banner;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CachedNetworkImage(
      imageUrl: banner.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, _) =>
          ColoredBox(color: cs.surfaceContainerHigh),
      errorWidget: (context, url, _) => ColoredBox(
        color: cs.surfaceContainerHigh,
        child: Icon(Icons.broken_image_outlined, color: cs.onSurfaceVariant),
      ),
    );
  }
}

/// Bottom + left gradient scrims drawn over the image.
class _GradientScrims extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final grad = Theme.of(context).extension<AppGradientsExt>()!;

    return Positioned.fill(
      child: Stack(
        children: [
          // Bottom-up scrim.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: grad.bannerBottom),
            ),
          ),
          // Left-side vignette.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: grad.bannerLeft),
            ),
          ),
        ],
      ),
    );
  }
}


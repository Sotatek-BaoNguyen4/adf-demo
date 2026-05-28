import 'package:flutter/material.dart';

import '../../../../core/theme/extensions/app_gradients_ext.dart';
import '../../../../core/theme/generated/radius_tokens.dart';
import '../../../../core/theme/generated/spacing_tokens.dart';

/// Translucent top app bar that floats over the banner Stack.
///
/// Layout: [logo + wordmark] — Spacer — [bell button] [avatar].
/// Background uses [AppGradientsExt.appBarFade] so banner bleeds through.
/// Bell and avatar are currently no-op; Semantics labels added for a11y.
class HomeTopAppBar extends StatelessWidget {
  const HomeTopAppBar({super.key});

  /// Content height (excluding top safe-area inset). Callers that need the
  /// fully-rendered height must add `MediaQuery.paddingOf(ctx).top`.
  static const double height = 64.0;

  @override
  Widget build(BuildContext context) {
    final grad = Theme.of(context).extension<AppGradientsExt>()!;
    final cs = Theme.of(context).colorScheme;
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: BoxDecoration(gradient: grad.appBarFade),
      padding: EdgeInsets.only(
        top: top + SpacingTokens.s3,
        bottom: SpacingTokens.s3,
        left: SpacingTokens.s4,
        right: SpacingTokens.s4,
      ),
      child: Row(
        children: [
          _LogoWordmark(accent: grad.accent, primary: cs.primary),
          const Spacer(),
          _BellButton(
            surfaceHigh: cs.surfaceContainerHigh,
            onSurface: cs.onSurface,
            dot: cs.tertiary,
          ),
          const SizedBox(width: SpacingTokens.s2),
          _ProfileAvatar(primaryBorder: cs.primary),
        ],
      ),
    );
  }
}

class _LogoWordmark extends StatelessWidget {
  const _LogoWordmark({required this.accent, required this.primary});

  final LinearGradient accent;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: SpacingTokens.s8,
          height: SpacingTokens.s8,
          decoration: BoxDecoration(
            gradient: accent,
            borderRadius: BorderRadius.circular(RadiusTokens.large - 6),
          ),
          alignment: Alignment.center,
          child: const Text(
            'A',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: SpacingTokens.s2),
        Text(
          'ADF Cinema',
          style: TextStyle(
            color: primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({
    required this.surfaceHigh,
    required this.onSurface,
    required this.dot,
  });

  final Color surfaceHigh;
  final Color onSurface;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Notifications',
      button: true,
      child: SizedBox(
        width: SpacingTokens.s10,
        height: SpacingTokens.s10,
        child: Material(
          color: surfaceHigh,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: null, // no-op in this phase
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications_outlined, color: onSurface, size: 20),
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dot,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.primaryBorder});

  final Color primaryBorder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Profile',
      button: true,
      child: GestureDetector(
        onTap: null, // no-op in this phase
        child: Container(
          width: SpacingTokens.s10,
          height: SpacingTokens.s10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryBorder.withAlpha(0x44),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=80&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, url, _) => CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

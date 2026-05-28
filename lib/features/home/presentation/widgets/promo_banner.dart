import 'package:flutter/material.dart';

import '../../../../core/theme/extensions/app_gradients_ext.dart';

/// Gradient promotional banner — "Student Discount" with a Claim Now CTA.
///
/// Uses [AppGradientsExt.promo] (primary_container → secondary_container).
/// "Claim Now" is intentionally no-op in MVP.
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<AppGradientsExt>()!;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradients.promo,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative circle — top-right.
            Positioned(
              right: -12,
              top: -12,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.onPrimaryContainer.withValues(alpha: 0.15),
                ),
              ),
            ),
            // Decorative circle — bottom-right.
            Positioned(
              right: 16,
              bottom: -8,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.secondaryContainer.withValues(alpha: 0.3),
                ),
              ),
            ),
            // Foreground content.
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge.
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'LIMITED OFFER',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: cs.onPrimaryContainer,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Heading.
                  Text(
                    'Student Discount',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Subtitle.
                  Text(
                    'Get 30% off on all movies\nwith valid student ID',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: cs.onSecondaryContainer,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // CTA button — no-op in MVP.
                  Semantics(
                    label: 'Claim student discount, coming soon',
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.onPrimaryContainer,
                        foregroundColor: cs.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      child: const Text('Claim Now'),
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
}

import 'package:flutter/material.dart';

/// Story-style progress bar row for [BannerSection].
///
/// Parent drives animation — this widget is purely presentational.
/// [progress01] is the fill fraction (0.0–1.0) for the active bar.
/// Tapping any bar calls [onTap] with that bar's index.
class BannerStoryProgress extends StatelessWidget {
  const BannerStoryProgress({
    super.key,
    required this.count,
    required this.activeIndex,
    required this.progress01,
    required this.onTap,
  });

  final int count;
  final int activeIndex;

  /// Fill progress for the currently active bar (0.0 → 1.0).
  final double progress01;

  final ValueChanged<int> onTap;

  static const double _barHeight = 2.0;
  static const double _gap = 4.0;
  // White overlays draw on top of banner imagery (intentional, theme-agnostic).
  static final Color _filled = Colors.white.withAlpha(0xD9); // ~85 %
  static final Color _track = Colors.white.withAlpha(0x2E); // ~18 %

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: Semantics(
              label: 'Slide ${i + 1}',
              button: true,
              child: Padding(
                padding: EdgeInsets.only(right: i < count - 1 ? _gap : 0),
                child: SizedBox(
                  height: _barHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9999),
                    child: Stack(
                      children: [
                        // Track (background)
                        Container(color: _track),
                        // Fill
                        FractionallySizedBox(
                          widthFactor: _fillFor(i),
                          child: Container(color: _filled),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  double _fillFor(int i) {
    if (i < activeIndex) return 1.0;
    if (i == activeIndex) return progress01.clamp(0.0, 1.0);
    return 0.0;
  }
}

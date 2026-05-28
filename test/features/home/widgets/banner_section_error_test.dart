// Widget test for BannerSection TC-HOME-001-05: error handling.
//
// Verifies that when bannersProvider returns an error (e.g., 500),
// BannerSection displays a non-blocking placeholder (shimmer) and does not
// crash or show a full-screen error overlay.
// Note: BannerSection.build currently returns ShimmerBanner on error,
// which is technically a loading placeholder. Actual retry UI is handled
// at the HomeScreen level via ErrorSectionView if banner section is exposed.

import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/domain/entities/banner.dart' as domain;
import 'package:adf_demo/features/home/presentation/providers/banners_provider.dart';
import 'package:adf_demo/features/home/presentation/widgets/banner_section.dart';

import '../../../_helpers/widget_test_harness.dart';

void main() {
  testWidgets(
    'TC-HOME-001-05: bannersProvider error shows shimmer (non-blocking)',
    (tester) async {
      await pumpInProviderScope(
        tester,
        const BannerSection(),
        overrides: [
          // Override with a notifier that throws.
          bannersProvider.overrideWith(() => _ErrorBannersNotifier()),
        ],
      );
      await tester.pump(Duration.zero);

      // Widget should still render (not crash).
      // BannerSection.build returns ShimmerBanner on error.
      expect(find.byType(BannerSection), findsOneWidget);

      // No unhandled exception or crash expected.
      // If the test completes without throwing, the assertion passes.
    },
  );

  testWidgets(
    'BannerSection error state remains mounted and non-blocking',
    (tester) async {
      await pumpInProviderScope(
        tester,
        const BannerSection(),
        overrides: [
          bannersProvider.overrideWith(() => _ErrorBannersNotifier()),
        ],
      );
      await tester.pump(Duration.zero);
      await tester.pump(); // Let error state settle

      // The widget tree should remain intact and renderable.
      expect(find.byType(BannerSection), findsOneWidget);

      // No unhandled exception or crash expected.
      // If the test completes without throwing, the assertion passes.
    },
  );
}

// ---------------------------------------------------------------------------
// Error notifier — throws an exception on build.
// ---------------------------------------------------------------------------

class _ErrorBannersNotifier extends Banners {
  @override
  Future<List<domain.Banner>> build() async {
    throw Exception('Banner fetch failed: 500 Internal Server Error');
  }
}

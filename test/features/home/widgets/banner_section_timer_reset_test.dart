// Widget test for BannerSection TC-HOME-001-03: timer reset on tap.
//
// Verifies that tapping a progress bar resets the auto-rotation timer.
// When a banner is manually selected, the 4 s interval restarts from zero,
// so the next auto-advance occurs 4 s after the tap, not at the original t+4 s.

import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/domain/entities/banner.dart' as domain;
import 'package:adf_demo/features/home/presentation/providers/banners_provider.dart';
import 'package:adf_demo/features/home/presentation/widgets/banner_section.dart';

import '../../../_helpers/widget_test_harness.dart';

final _banners = [
  const domain.Banner(
    id: 'b1',
    imageUrl: 'https://example.com/1.jpg',
    targetUrl: '',
    title: 'Banner One',
  ),
  const domain.Banner(
    id: 'b2',
    imageUrl: 'https://example.com/2.jpg',
    targetUrl: '',
    title: 'Banner Two',
  ),
  const domain.Banner(
    id: 'b3',
    imageUrl: 'https://example.com/3.jpg',
    targetUrl: '',
    title: 'Banner Three',
  ),
];

void main() {
  testWidgets(
    'TC-HOME-001-03: tapping progress bar resets timer; no advance within 4s; advances after 4s',
    (tester) async {
      await pumpInProviderScope(
        tester,
        const BannerSection(),
        overrides: [
          bannersProvider.overrideWith(() => _FakeBannersNotifier(_banners)),
        ],
      );
      await tester.pump(Duration.zero);

      // Verify initial state: Banner One.
      expect(find.text('Banner One'), findsOneWidget);

      // Advance to Banner Two (4 s + cross-fade).
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Banner Two'), findsOneWidget);

      // Now tap the first progress bar to jump back to Banner One.
      // This should reset the timer.
      await tester.tap(find.bySemanticsLabel('Slide 1'));
      await tester.pump(const Duration(milliseconds: 300)); // animation

      expect(find.text('Banner One'), findsOneWidget);

      // Wait 3 s (timer should NOT fire yet).
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 700)); // cross-fade

      // Still on Banner One (timer has not completed 4 s since tap).
      expect(find.text('Banner One'), findsOneWidget);

      // Wait 1 more second (total 4 s since tap).
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 700)); // cross-fade

      // Should have advanced to Banner Two (timer restarted correctly after tap).
      expect(find.text('Banner Two'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping progress bar in the middle (e.g., slide 3) and verifying next advance',
    (tester) async {
      await pumpInProviderScope(
        tester,
        const BannerSection(),
        overrides: [
          bannersProvider.overrideWith(() => _FakeBannersNotifier(_banners)),
        ],
      );
      await tester.pump(Duration.zero);

      // Jump directly to Banner Three via progress bar tap.
      await tester.tap(find.bySemanticsLabel('Slide 3'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Banner Three'), findsOneWidget);

      // Wait 4 s to trigger auto-advance (wraps to Banner One).
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Banner One'), findsOneWidget);
    },
  );
}

// ---------------------------------------------------------------------------
// Fake notifier — returns fixture list synchronously as AsyncData.
// ---------------------------------------------------------------------------

class _FakeBannersNotifier extends Banners {
  _FakeBannersNotifier(this._data);
  final List<domain.Banner> _data;

  @override
  Future<List<domain.Banner>> build() async => _data;
}

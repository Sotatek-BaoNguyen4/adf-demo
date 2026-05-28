// Widget tests for BannerSection.
//
// BannerSection is a ConsumerStatefulWidget that auto-advances via an
// AnimationController (default 4 s). Tests override bannersProvider with
// fixture data and drive time via tester.pump to verify:
//   - First banner visible on initial frame.
//   - activeIndex advances after one full slide duration.
//   - Tapping a progress bar jumps immediately to that banner.

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
    title: 'First Banner',
  ),
  const domain.Banner(
    id: 'b2',
    imageUrl: 'https://example.com/2.jpg',
    targetUrl: '',
    title: 'Second Banner',
  ),
];

void main() {
  testWidgets('shows first banner title on initial frame', (tester) async {
    await pumpInProviderScope(
      tester,
      const BannerSection(),
      overrides: [
        bannersProvider.overrideWith(() => _FakeBannersNotifier(_banners)),
      ],
    );
    // Let the post-frame callback fire and controller start.
    await tester.pump(Duration.zero);

    expect(find.text('First Banner'), findsOneWidget);
  });

  testWidgets('activeIndex advances after 4 s', (tester) async {
    await pumpInProviderScope(
      tester,
      const BannerSection(),
      overrides: [
        bannersProvider.overrideWith(() => _FakeBannersNotifier(_banners)),
      ],
    );
    await tester.pump(Duration.zero); // post-frame callback

    // Advance past the full slide duration + cross-fade.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 700)); // cross-fade

    expect(find.text('Second Banner'), findsOneWidget);
  });

  testWidgets('tapping first progress bar jumps back to first banner',
      (tester) async {
    await pumpInProviderScope(
      tester,
      const BannerSection(),
      overrides: [
        bannersProvider.overrideWith(() => _FakeBannersNotifier(_banners)),
      ],
    );
    await tester.pump(Duration.zero);
    // Advance to second banner.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Second Banner'), findsOneWidget);

    // Tap first progress bar → jump back.
    await tester.tap(find.bySemanticsLabel('Slide 1'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('First Banner'), findsOneWidget);
  });
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

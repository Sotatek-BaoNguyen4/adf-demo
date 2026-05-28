// Widget tests for BannerStoryProgress.
//
// Verifies bar count, active-bar fill fraction, and tap callback firing.

import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/presentation/widgets/banner_story_progress.dart';

import '../../../_helpers/widget_test_harness.dart';

void main() {
  testWidgets('renders N semantic slide buttons', (tester) async {
    await pumpInProviderScope(
      tester,
      BannerStoryProgress(
        count: 4,
        activeIndex: 0,
        progress01: 0.0,
        onTap: (_) {},
      ),
    );
    // Each bar has Semantics label "Slide N".
    expect(find.bySemanticsLabel('Slide 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Slide 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Slide 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Slide 4'), findsOneWidget);
  });

  testWidgets('renders exactly count bars (3)', (tester) async {
    await pumpInProviderScope(
      tester,
      BannerStoryProgress(
        count: 3,
        activeIndex: 1,
        progress01: 0.5,
        onTap: (_) {},
      ),
    );
    expect(find.bySemanticsLabel(RegExp(r'Slide \d')), findsNWidgets(3));
  });

  testWidgets('tap on bar fires onTap with correct index', (tester) async {
    int? tappedIndex;
    await pumpInProviderScope(
      tester,
      BannerStoryProgress(
        count: 3,
        activeIndex: 0,
        progress01: 0.3,
        onTap: (i) => tappedIndex = i,
      ),
    );
    await tester.tap(find.bySemanticsLabel('Slide 3'));
    expect(tappedIndex, 2);
  });

  testWidgets('tap on first bar fires index 0', (tester) async {
    int? tappedIndex;
    await pumpInProviderScope(
      tester,
      BannerStoryProgress(
        count: 4,
        activeIndex: 2,
        progress01: 0.8,
        onTap: (i) => tappedIndex = i,
      ),
    );
    await tester.tap(find.bySemanticsLabel('Slide 1'));
    expect(tappedIndex, 0);
  });
}

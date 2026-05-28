// Widget tests for CategoryChipsBar.
//
// Verifies all 8 chips render and that tapping chips updates state without
// throwing. The ProviderScope from the harness owns selectedCategoryProvider.

import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/presentation/constants/movie_categories.dart';
import 'package:adf_demo/features/home/presentation/widgets/category_chips_bar.dart';

import '../../../_helpers/widget_test_harness.dart';

void main() {
  testWidgets('renders all 8 category chip labels', (tester) async {
    await pumpInProviderScope(tester, const CategoryChipsBar());
    for (final label in movieCategories) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('tapping Action chip does not throw', (tester) async {
    await pumpInProviderScope(tester, const CategoryChipsBar());
    await tester.tap(find.text('Action'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Action'), findsOneWidget);
  });

  testWidgets('tapping Horror chip does not throw', (tester) async {
    await pumpInProviderScope(tester, const CategoryChipsBar());
    await tester.tap(find.text('Horror'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping All chip does not throw', (tester) async {
    await pumpInProviderScope(tester, const CategoryChipsBar());
    await tester.tap(find.text('All'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('chip count matches movieCategories length', (tester) async {
    await pumpInProviderScope(tester, const CategoryChipsBar());
    // Each category label appears exactly once.
    expect(movieCategories.length, 8);
    for (final label in movieCategories) {
      expect(find.text(label), findsOneWidget);
    }
  });
}

// Widget tests for PromoBanner.
//
// Verifies heading, subtitle, CTA text, and semantics label are present.
// CTA tap must not throw (no-op in MVP).

import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/presentation/widgets/promo_banner.dart';

import '../../../_helpers/widget_test_harness.dart';

void main() {
  testWidgets('renders Student Discount heading', (tester) async {
    await pumpInProviderScope(tester, const PromoBanner());
    expect(find.text('Student Discount'), findsOneWidget);
  });

  testWidgets('renders Claim Now CTA button', (tester) async {
    await pumpInProviderScope(tester, const PromoBanner());
    expect(find.text('Claim Now'), findsOneWidget);
  });

  testWidgets('renders subtitle copy', (tester) async {
    await pumpInProviderScope(tester, const PromoBanner());
    expect(
      find.textContaining('30% off'),
      findsOneWidget,
    );
  });

  testWidgets('CTA semantics label is present', (tester) async {
    await pumpInProviderScope(tester, const PromoBanner());
    expect(
      find.bySemanticsLabel('Claim student discount, coming soon'),
      findsOneWidget,
    );
  });

  testWidgets('tapping Claim Now does not throw', (tester) async {
    await pumpInProviderScope(tester, const PromoBanner());
    await tester.tap(find.text('Claim Now'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

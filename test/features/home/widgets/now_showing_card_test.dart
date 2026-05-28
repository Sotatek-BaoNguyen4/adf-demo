// Widget tests for NowShowingCard.
//
// Verifies: title renders below the poster image, rating pill is present,
// and the card taps without throwing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/domain/entities/movie.dart';
import 'package:adf_demo/features/home/presentation/widgets/now_showing_card.dart';
import 'package:adf_demo/features/home/presentation/widgets/rating_badge.dart';

import '../../../_helpers/widget_test_harness.dart';

const _movieFixture = Movie(
  id: 'ns1',
  title: 'Ocean Depths',
  posterUrl: 'https://example.com/ocean.jpg',
  rating: 7.9,
  releaseDate: '2026-05-01',
);

void main() {
  testWidgets('renders movie title', (tester) async {
    await pumpInProviderScope(
      tester,
      const NowShowingCard(movie: _movieFixture),
    );
    expect(find.text('Ocean Depths'), findsOneWidget);
  });

  testWidgets('renders RatingBadge widget', (tester) async {
    await pumpInProviderScope(
      tester,
      const NowShowingCard(movie: _movieFixture),
    );
    expect(find.byType(RatingBadge), findsOneWidget);
  });

  testWidgets('title appears below the poster (higher Y coordinate)',
      (tester) async {
    await pumpInProviderScope(
      tester,
      const NowShowingCard(movie: _movieFixture),
    );

    // ClipRRect wraps the poster stack; Text is below it in the Column.
    final posterTop = tester.getTopLeft(find.byType(ClipRRect)).dy;
    final titleTop = tester.getTopLeft(find.text('Ocean Depths')).dy;

    expect(titleTop, greaterThan(posterTop));
  });

  testWidgets('onTap callback fires', (tester) async {
    var tapped = false;
    await pumpInProviderScope(
      tester,
      NowShowingCard(movie: _movieFixture, onTap: () => tapped = true),
    );
    await tester.tap(find.byType(NowShowingCard));
    expect(tapped, isTrue);
  });

  testWidgets('releaseDate subtitle renders', (tester) async {
    await pumpInProviderScope(
      tester,
      const NowShowingCard(movie: _movieFixture),
    );
    expect(find.text('2026-05-01'), findsOneWidget);
  });
}

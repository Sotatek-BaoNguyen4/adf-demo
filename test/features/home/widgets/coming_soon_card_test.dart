// Widget tests for ComingSoonCard.
//
// Verifies: date badge shows formatted month + day (top-left),
// title renders below the poster, and subtitle is present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/domain/entities/movie.dart';
import 'package:adf_demo/features/home/presentation/widgets/coming_soon_card.dart';

import '../../../_helpers/widget_test_harness.dart';

const _movieFixture = Movie(
  id: 'cs1',
  title: 'Neon Horizon',
  posterUrl: 'https://example.com/neon.jpg',
  expectedReleaseDate: '2026-06-15',
);

void main() {
  testWidgets('renders month abbreviation JUN in date badge', (tester) async {
    await pumpInProviderScope(
      tester,
      const ComingSoonCard(movie: _movieFixture),
    );
    expect(find.text('JUN'), findsOneWidget);
  });

  testWidgets('renders day numeral 15 in date badge', (tester) async {
    await pumpInProviderScope(
      tester,
      const ComingSoonCard(movie: _movieFixture),
    );
    expect(find.text('15'), findsOneWidget);
  });

  testWidgets('renders movie title', (tester) async {
    await pumpInProviderScope(
      tester,
      const ComingSoonCard(movie: _movieFixture),
    );
    expect(find.text('Neon Horizon'), findsOneWidget);
  });

  testWidgets('title appears below the poster (higher Y coordinate)',
      (tester) async {
    await pumpInProviderScope(
      tester,
      const ComingSoonCard(movie: _movieFixture),
    );

    final posterTop = tester.getTopLeft(find.byType(ClipRRect)).dy;
    final titleTop = tester.getTopLeft(find.text('Neon Horizon')).dy;

    expect(titleTop, greaterThan(posterTop));
  });

  testWidgets('expected release subtitle contains formatted date',
      (tester) async {
    await pumpInProviderScope(
      tester,
      const ComingSoonCard(movie: _movieFixture),
    );
    expect(find.textContaining('Jun 15, 2026'), findsOneWidget);
  });

  testWidgets('no date badge when expectedReleaseDate is null', (tester) async {
    const noDateMovie = Movie(
      id: 'cs2',
      title: 'Untitled Project',
      posterUrl: 'https://example.com/untitled.jpg',
    );
    await pumpInProviderScope(
      tester,
      const ComingSoonCard(movie: noDateMovie),
    );
    expect(find.text('JUN'), findsNothing);
  });
}

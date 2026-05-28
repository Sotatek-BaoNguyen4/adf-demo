// Widget tests for TrendingListRow.
//
// Verifies rank, title, rating, and views render from a Movie fixture.

import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/domain/entities/movie.dart';
import 'package:adf_demo/features/home/presentation/widgets/trending_list_row.dart';

import '../../../_helpers/widget_test_harness.dart';

const _movieFixture = Movie(
  id: 't1',
  title: 'Starfall Rising',
  posterUrl: 'https://example.com/star.jpg',
  rank: 1,
  views: '2.4M',
  rating: 8.7,
);

void main() {
  testWidgets('renders rank numeral', (tester) async {
    await pumpInProviderScope(
      tester,
      const TrendingListRow(movie: _movieFixture),
    );
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('renders movie title', (tester) async {
    await pumpInProviderScope(
      tester,
      const TrendingListRow(movie: _movieFixture),
    );
    expect(find.text('Starfall Rising'), findsOneWidget);
  });

  testWidgets('renders rating value', (tester) async {
    await pumpInProviderScope(
      tester,
      const TrendingListRow(movie: _movieFixture),
    );
    expect(find.text('8.7'), findsOneWidget);
  });

  testWidgets('renders views string', (tester) async {
    await pumpInProviderScope(
      tester,
      const TrendingListRow(movie: _movieFixture),
    );
    expect(find.text('2.4M'), findsOneWidget);
  });

  testWidgets('onTap callback fires when row tapped', (tester) async {
    var tapped = false;
    await pumpInProviderScope(
      tester,
      TrendingListRow(movie: _movieFixture, onTap: () => tapped = true),
    );
    await tester.tap(find.text('Starfall Rising'));
    expect(tapped, isTrue);
  });
}

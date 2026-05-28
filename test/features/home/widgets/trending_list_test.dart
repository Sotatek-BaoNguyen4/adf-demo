// Widget tests for TrendingList.
//
// Uses trendingProvider overrides to test loading, error, and data states.
// Verifies TrendingListRow count and rank text for the data state.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/domain/entities/movie.dart';
import 'package:adf_demo/features/home/presentation/providers/trending_provider.dart';
import 'package:adf_demo/features/home/presentation/widgets/trending_list.dart';
import 'package:adf_demo/features/home/presentation/widgets/trending_list_row.dart';

import '../../../_helpers/widget_test_harness.dart';

final _trendingFixtures = [
  const Movie(
    id: 'm1',
    title: 'Alpha Strike',
    posterUrl: 'https://example.com/a.jpg',
    rank: 1,
    views: '3.1M',
    rating: 8.1,
  ),
  const Movie(
    id: 'm2',
    title: 'Beta Protocol',
    posterUrl: 'https://example.com/b.jpg',
    rank: 2,
    views: '2.4M',
    rating: 7.6,
  ),
  const Movie(
    id: 'm3',
    title: 'Gamma Force',
    posterUrl: 'https://example.com/c.jpg',
    rank: 3,
    views: '1.9M',
    rating: 7.2,
  ),
];

void main() {
  testWidgets('renders 3 TrendingListRow widgets from fixture data',
      (tester) async {
    await pumpInProviderScope(
      tester,
      const TrendingList(),
      overrides: [
        trendingProvider.overrideWith(() => _FakeTrendingNotifier(_trendingFixtures)),
      ],
    );
    await tester.pump(); // let async provider resolve

    expect(find.byType(TrendingListRow), findsNWidgets(3));
  });

  testWidgets('renders rank text 1, 2, 3', (tester) async {
    await pumpInProviderScope(
      tester,
      const TrendingList(),
      overrides: [
        trendingProvider.overrideWith(() => _FakeTrendingNotifier(_trendingFixtures)),
      ],
    );
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('renders movie titles', (tester) async {
    await pumpInProviderScope(
      tester,
      const TrendingList(),
      overrides: [
        trendingProvider.overrideWith(() => _FakeTrendingNotifier(_trendingFixtures)),
      ],
    );
    await tester.pump();

    expect(find.text('Alpha Strike'), findsOneWidget);
    expect(find.text('Beta Protocol'), findsOneWidget);
    expect(find.text('Gamma Force'), findsOneWidget);
  });

  testWidgets('shows shimmer while loading', (tester) async {
    await pumpInProviderScope(
      tester,
      const TrendingList(),
      overrides: [
        trendingProvider.overrideWith(() => _LoadingTrendingNotifier()),
      ],
    );
    await tester.pump();

    // No rows should appear in loading state.
    expect(find.byType(TrendingListRow), findsNothing);
  });

  testWidgets('shows error view on failure', (tester) async {
    await pumpInProviderScope(
      tester,
      const TrendingList(),
      overrides: [
        trendingProvider.overrideWith(() => _ErrorTrendingNotifier()),
      ],
    );
    await tester.pump();

    expect(find.byType(TrendingListRow), findsNothing);
    expect(find.textContaining('Failed'), findsOneWidget);
  });
}

// ---------------------------------------------------------------------------
// Fake notifiers
// ---------------------------------------------------------------------------

class _FakeTrendingNotifier extends Trending {
  _FakeTrendingNotifier(this._data);
  final List<Movie> _data;

  @override
  Future<List<Movie>> build() async => _data;
}

class _LoadingTrendingNotifier extends Trending {
  @override
  Future<List<Movie>> build() {
    // Returns a future that never settles — widget stays in loading state.
    return Completer<List<Movie>>().future;
  }
}

class _ErrorTrendingNotifier extends Trending {
  @override
  Future<List<Movie>> build() async =>
      throw Exception('network error');
}

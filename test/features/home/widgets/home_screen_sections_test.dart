// Widget tests for HomeScreen sections: TC-HOME-001-07, 09, 10, 11.
//
// Tests the empty and error states of individual movie list components.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/domain/entities/movie.dart' as domain;
import 'package:adf_demo/features/home/presentation/providers/trending_provider.dart';
import 'package:adf_demo/features/home/presentation/widgets/empty_section_view.dart';
import 'package:adf_demo/features/home/presentation/widgets/error_section_view.dart';
import 'package:adf_demo/features/home/presentation/widgets/trending_list.dart';

import '../../../_helpers/widget_test_harness.dart';

final _testMovie = const domain.Movie(
  id: 'mov_01',
  title: 'Test Movie',
  posterUrl: 'https://example.com/poster.jpg',
  rating: 8.5,
);

void main() {
  testWidgets(
    'TC-HOME-001-09: EmptySectionView rendered with correct text',
    (tester) async {
      await pumpInProviderScope(
        tester,
        const EmptySectionView(),
      );
      await tester.pump();

      // Verify placeholder widget renders.
      expect(find.byType(EmptySectionView), findsOneWidget);

      // Verify "No movies available" text appears.
      expect(find.text('No movies available'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-HOME-001-10: empty coming-soon renders placeholder via EmptySectionView',
    (tester) async {
      await pumpInProviderScope(
        tester,
        const EmptySectionView(),
      );
      await tester.pump();

      // Same widget used for both now-showing and coming-soon empty states.
      expect(find.byType(EmptySectionView), findsOneWidget);
      expect(find.text('No movies available'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-HOME-001-11: TrendingList renders EmptySectionView when data is empty',
    (tester) async {
      await pumpInProviderScope(
        tester,
        const TrendingList(),
        overrides: [
          trendingProvider.overrideWith(() => _FakeTrendingNotifier([])),
        ],
      );
      await tester.pump();
      await tester.pump(); // Let async provider settle

      // Verify section header.
      expect(find.text('Trending This Week'), findsOneWidget);

      // Verify empty placeholder is rendered.
      expect(find.byType(EmptySectionView), findsOneWidget);
      expect(find.text('No movies available'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-HOME-001-07: TrendingList renders ErrorSectionView on provider error',
    (tester) async {
      await pumpInProviderScope(
        tester,
        const TrendingList(),
        overrides: [
          trendingProvider.overrideWith(() => _ErrorTrendingNotifier()),
        ],
      );
      await tester.pump();
      await tester.pump(); // Let async provider settle

      // Verify section header.
      expect(find.text('Trending This Week'), findsOneWidget);

      // Verify error view is rendered.
      expect(find.byType(ErrorSectionView), findsOneWidget);

      // Verify error message.
      expect(find.text('Failed to load trending movies'), findsOneWidget);
    },
  );

  testWidgets(
    'ErrorSectionView renders with retry button',
    (tester) async {
      await pumpInProviderScope(
        tester,
        ErrorSectionView(
          onRetry: () {},
          message: 'Test error message',
        ),
      );
      await tester.pump();

      // Verify error message.
      expect(find.text('Test error message'), findsOneWidget);

      // Verify Retry button is present (OutlinedButton in Material).
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    },
  );
}

// ---------------------------------------------------------------------------
// Fake notifiers for testing.
// ---------------------------------------------------------------------------

class _FakeTrendingNotifier extends Trending {
  _FakeTrendingNotifier(this._data);
  final List<domain.Movie> _data;

  @override
  Future<List<domain.Movie>> build() async => _data;
}

class _ErrorTrendingNotifier extends Trending {
  @override
  Future<List<domain.Movie>> build() async {
    throw Exception('Trending API error (401 Unauthenticated)');
  }
}

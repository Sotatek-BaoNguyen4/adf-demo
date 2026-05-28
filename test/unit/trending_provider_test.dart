// Unit tests for Trending provider (async FutureProvider).
// Covers successful loads, error handling, and refresh behavior.
// Trending aliases the /recommended endpoint (same cache key, same network path).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/core/errors/failure.dart';
import 'package:adf_demo/features/home/data/home_repository_provider.dart';
import 'package:adf_demo/features/home/domain/entities/movie.dart';
import 'package:adf_demo/features/home/presentation/providers/trending_provider.dart';

import '../_helpers/fake_home_repository.dart';

void main() {
  group('Trending provider', () {
    test('loads trending movies successfully', () async {
      const movie = Movie(
        id: 't1',
        title: 'Trending Movie',
        posterUrl: 'trending.jpg',
        rating: 8.8,
        rank: 1,
        views: '2.4M',
      );
      final fakeRepo = FakeHomeRepository(trending: const [movie]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(trendingProvider.future);

      expect(result, hasLength(1));
      expect(result.first.id, 't1');
      expect(result.first.rank, 1);
      expect(result.first.views, '2.4M');
      expect(fakeRepo.trendingCallCount, 1);
    });

    test('returns empty list when no trending movies', () async {
      final fakeRepo = FakeHomeRepository(trending: const []);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(trendingProvider.future);

      expect(result, isEmpty);
    });

    test('propagates timeout failure', () async {
      final fakeRepo = FakeHomeRepository(
        throwOnTrending: const TimeoutFailure('Request timeout'),
      );
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(trendingProvider.future),
        throwsA(isA<TimeoutFailure>()),
      );
    });

    test('refresh reloads trending data', () async {
      const movie = Movie(
        id: 't2',
        title: 'This Weeks Trending',
        posterUrl: 'week_trending.jpg',
        rating: 8.5,
        rank: 3,
        views: '1.8M',
      );
      final fakeRepo = FakeHomeRepository(trending: const [movie]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(trendingProvider.future);
      expect(fakeRepo.trendingCallCount, 1);

      await container.read(trendingProvider.notifier).refresh();
      expect(fakeRepo.trendingCallCount, 2);
    });

    test('loads top trending movies with correct ranking', () async {
      const movies = [
        Movie(
          id: 't1',
          title: 'Top Trending',
          posterUrl: 'top.jpg',
          rating: 9.2,
          rank: 1,
          views: '5.1M',
        ),
        Movie(
          id: 't2',
          title: 'Second Trending',
          posterUrl: 'second.jpg',
          rating: 8.9,
          rank: 2,
          views: '3.7M',
        ),
        Movie(
          id: 't3',
          title: 'Third Trending',
          posterUrl: 'third.jpg',
          rating: 8.6,
          rank: 3,
          views: '2.1M',
        ),
      ];
      final fakeRepo = FakeHomeRepository(trending: movies);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(trendingProvider.future);

      expect(result, hasLength(3));
      expect(result[0].rank, 1);
      expect(result[1].views, '3.7M');
      expect(result[2].title, 'Third Trending');
    });

    test('propagates parse error', () async {
      final fakeRepo = FakeHomeRepository(
        throwOnTrending: const ParseFailure('Malformed JSON', path: 'api/recommended'),
      );
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(trendingProvider.future),
        throwsA(isA<ParseFailure>()),
      );
    });

    test('trending data persists across refresh cycles', () async {
      const movie = Movie(
        id: 't_persist',
        title: 'Persistent Trending',
        posterUrl: 'persist.jpg',
        rating: 8.7,
        rank: 5,
        views: '1.2M',
      );
      final fakeRepo = FakeHomeRepository(trending: const [movie]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result1 = await container.read(trendingProvider.future);
      await container.read(trendingProvider.notifier).refresh();
      final result2 = await container.read(trendingProvider.future);

      expect(result1.first.rank, result2.first.rank);
      expect(result1.first.views, result2.first.views);
    });

    test('propagates unknown failure', () async {
      final fakeRepo = FakeHomeRepository(
        throwOnTrending: const UnknownFailure('Unexpected error'),
      );
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(trendingProvider.future),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });
}

// Unit tests for NowShowing provider (async FutureProvider).
// Covers successful loads, error handling, and refresh behavior.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/core/errors/failure.dart';
import 'package:adf_demo/features/home/data/home_repository_provider.dart';
import 'package:adf_demo/features/home/domain/entities/movie.dart';
import 'package:adf_demo/features/home/presentation/providers/now_showing_provider.dart';

import '../_helpers/fake_home_repository.dart';

void main() {
  group('NowShowing provider', () {
    test('loads now-showing movies successfully', () async {
      const movie = Movie(
        id: 'm1',
        title: 'Movie 1',
        posterUrl: 'poster.jpg',
        rating: 8.5,
        releaseDate: '2026-05-28',
      );
      final fakeRepo = FakeHomeRepository(nowShowing: const [movie]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(nowShowingProvider.future);

      expect(result, hasLength(1));
      expect(result.first.id, 'm1');
      expect(result.first.rating, 8.5);
      expect(fakeRepo.nowShowingCallCount, 1);
    });

    test('returns empty list when no movies', () async {
      final fakeRepo = FakeHomeRepository(nowShowing: const []);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(nowShowingProvider.future);

      expect(result, isEmpty);
    });

    test('propagates timeout error', () async {
      final fakeRepo = FakeHomeRepository(
        throwOnNowShowing: const TimeoutFailure('Connection timeout'),
      );
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(nowShowingProvider.future),
        throwsA(isA<TimeoutFailure>()),
      );
    });

    test('refresh reloads movies from repository', () async {
      const movie = Movie(
        id: 'm2',
        title: 'Movie 2',
        posterUrl: 'poster2.jpg',
        rating: 7.0,
        releaseDate: '2026-05-25',
      );
      final fakeRepo = FakeHomeRepository(nowShowing: const [movie]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(nowShowingProvider.future);
      expect(fakeRepo.nowShowingCallCount, 1);

      await container.read(nowShowingProvider.notifier).refresh();
      expect(fakeRepo.nowShowingCallCount, 2);
    });

    test('loads multiple movies', () async {
      const movies = [
        Movie(
          id: 'm1',
          title: 'Movie 1',
          posterUrl: 'p1.jpg',
          rating: 8.0,
          releaseDate: '2026-05-20',
        ),
        Movie(
          id: 'm2',
          title: 'Movie 2',
          posterUrl: 'p2.jpg',
          rating: 7.5,
          releaseDate: '2026-05-21',
        ),
        Movie(
          id: 'm3',
          title: 'Movie 3',
          posterUrl: 'p3.jpg',
          rating: 9.0,
          releaseDate: '2026-05-22',
        ),
      ];
      final fakeRepo = FakeHomeRepository(nowShowing: movies);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(nowShowingProvider.future);

      expect(result, hasLength(3));
      expect(result[0].id, 'm1');
      expect(result[1].rating, 7.5);
      expect(result[2].title, 'Movie 3');
    });

    test('propagates parse error', () async {
      final fakeRepo = FakeHomeRepository(
        throwOnNowShowing: const ParseFailure('Invalid JSON', path: 'api/movies'),
      );
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(nowShowingProvider.future),
        throwsA(isA<ParseFailure>()),
      );
    });

    test('successive refreshes maintain data consistency', () async {
      const movie = Movie(
        id: 'm5',
        title: 'Consistent Movie',
        posterUrl: 'consistent.jpg',
        rating: 8.3,
        releaseDate: '2026-05-28',
      );
      final fakeRepo = FakeHomeRepository(nowShowing: const [movie]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result1 = await container.read(nowShowingProvider.future);
      await container.read(nowShowingProvider.notifier).refresh();
      final result2 = await container.read(nowShowingProvider.future);

      expect(result1.first.id, result2.first.id);
      expect(result1.first.title, result2.first.title);
    });
  });
}

// Unit tests for ComingSoon provider (async FutureProvider).
// Covers successful loads, error handling, and refresh behavior.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/core/errors/failure.dart';
import 'package:adf_demo/features/home/data/home_repository_provider.dart';
import 'package:adf_demo/features/home/domain/entities/movie.dart';
import 'package:adf_demo/features/home/presentation/providers/coming_soon_provider.dart';

import '../_helpers/fake_home_repository.dart';

void main() {
  group('ComingSoon provider', () {
    test('loads coming-soon movies successfully', () async {
      const movie = Movie(
        id: 'cs1',
        title: 'Coming Soon Movie',
        posterUrl: 'coming.jpg',
        expectedReleaseDate: '2026-06-15',
      );
      final fakeRepo = FakeHomeRepository(comingSoon: const [movie]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(comingSoonProvider.future);

      expect(result, hasLength(1));
      expect(result.first.id, 'cs1');
      expect(result.first.expectedReleaseDate, '2026-06-15');
      expect(result.first.rating, isNull);
      expect(fakeRepo.comingSoonCallCount, 1);
    });

    test('returns empty list when no coming-soon movies', () async {
      final fakeRepo = FakeHomeRepository(comingSoon: const []);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(comingSoonProvider.future);

      expect(result, isEmpty);
    });

    test('propagates network failure', () async {
      final fakeRepo = FakeHomeRepository(
        throwOnComingSoon: const NetworkFailure('Server unavailable', statusCode: 503),
      );
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(comingSoonProvider.future),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('refresh reloads coming-soon data', () async {
      const movie = Movie(
        id: 'cs2',
        title: 'Future Movie',
        posterUrl: 'future.jpg',
        expectedReleaseDate: '2026-07-01',
      );
      final fakeRepo = FakeHomeRepository(comingSoon: const [movie]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(comingSoonProvider.future);
      expect(fakeRepo.comingSoonCallCount, 1);

      await container.read(comingSoonProvider.notifier).refresh();
      expect(fakeRepo.comingSoonCallCount, 2);
    });

    test('loads multiple coming-soon movies', () async {
      const movies = [
        Movie(
          id: 'cs1',
          title: 'Coming 1',
          posterUrl: 'c1.jpg',
          expectedReleaseDate: '2026-06-01',
        ),
        Movie(
          id: 'cs2',
          title: 'Coming 2',
          posterUrl: 'c2.jpg',
          expectedReleaseDate: '2026-06-15',
        ),
        Movie(
          id: 'cs3',
          title: 'Coming 3',
          posterUrl: 'c3.jpg',
          expectedReleaseDate: '2026-07-01',
        ),
      ];
      final fakeRepo = FakeHomeRepository(comingSoon: movies);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(comingSoonProvider.future);

      expect(result, hasLength(3));
      expect(result[1].expectedReleaseDate, '2026-06-15');
    });

    test('propagates cache read failure', () async {
      final fakeRepo = FakeHomeRepository(
        throwOnComingSoon: const CacheReadFailure('Box corrupted', boxName: 'coming_soon_cache'),
      );
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(comingSoonProvider.future),
        throwsA(isA<CacheReadFailure>()),
      );
    });

    test('refresh multiple times works correctly', () async {
      const movie = Movie(
        id: 'cs_test',
        title: 'Test Coming Soon',
        posterUrl: 'test.jpg',
        expectedReleaseDate: '2026-06-30',
      );
      final fakeRepo = FakeHomeRepository(comingSoon: const [movie]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(comingSoonProvider.future);
      expect(fakeRepo.comingSoonCallCount, 1);

      await container.read(comingSoonProvider.notifier).refresh();
      await container.read(comingSoonProvider.notifier).refresh();
      expect(fakeRepo.comingSoonCallCount, 3);
    });
  });
}

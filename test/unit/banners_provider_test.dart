// Unit tests for Banners provider (async FutureProvider).
// Covers successful loads, error handling, and refresh behavior.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/core/errors/failure.dart';
import 'package:adf_demo/features/home/data/home_repository_provider.dart';
import 'package:adf_demo/features/home/domain/entities/banner.dart';
import 'package:adf_demo/features/home/presentation/providers/banners_provider.dart';

import '../_helpers/fake_home_repository.dart';

void main() {
  group('Banners provider', () {
    test('loads banners successfully', () async {
      const banner = Banner(
        id: 'b1',
        imageUrl: 'image.jpg',
        targetUrl: 'adf://target',
        title: 'Featured',
      );
      final fakeRepo = FakeHomeRepository(banners: const [banner]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(bannersProvider.future);

      expect(result, hasLength(1));
      expect(result.first.id, 'b1');
      expect(fakeRepo.bannersCallCount, 1);
    });

    test('returns empty list when no banners', () async {
      final fakeRepo = FakeHomeRepository(banners: const []);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(bannersProvider.future);

      expect(result, isEmpty);
    });

    test('propagates repository error as AsyncError', () async {
      final fakeRepo = FakeHomeRepository(
        throwOnBanners: const NetworkFailure('Network error', statusCode: 500),
      );
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(bannersProvider.future),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('refresh reloads banners via repository', () async {
      const banner = Banner(
        id: 'b2',
        imageUrl: 'new.jpg',
        targetUrl: 'adf://new',
        title: 'New',
      );
      final fakeRepo = FakeHomeRepository(banners: const [banner]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      // First read
      final result1 = await container.read(bannersProvider.future);
      expect(result1, hasLength(1));
      expect(fakeRepo.bannersCallCount, 1);

      // Refresh
      await container.read(bannersProvider.notifier).refresh();
      expect(fakeRepo.bannersCallCount, 2);
    });

    test('provider has AsyncValue wrapper', () async {
      const banner = Banner(
        id: 'b3',
        imageUrl: 'test.jpg',
        targetUrl: 'adf://test',
        title: 'Test',
      );
      final fakeRepo = FakeHomeRepository(banners: const [banner]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      // Provider is async, so first read may be loading or data
      // Call future to ensure resolution
      final result = await container.read(bannersProvider.future);
      expect(result, hasLength(1));
    });

    test('multiple refresh calls load new data', () async {
      final fakeRepo = FakeHomeRepository(banners: const [
        Banner(
          id: 'b1',
          imageUrl: 'i1.jpg',
          targetUrl: 'adf://1',
          title: 'T1',
        ),
      ]);
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(bannersProvider.future);
      expect(fakeRepo.bannersCallCount, 1);

      await container.read(bannersProvider.notifier).refresh();
      expect(fakeRepo.bannersCallCount, 2);

      await container.read(bannersProvider.notifier).refresh();
      expect(fakeRepo.bannersCallCount, 3);
    });
  });
}

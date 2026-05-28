// Unit tests for selectedCategoryProvider (StateProvider).
// Covers default state, mutation, and state reads.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/presentation/providers/selected_category_provider.dart';

void main() {
  group('selectedCategoryProvider', () {
    test('defaults to "All"', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(selectedCategoryProvider);
      expect(state, 'All');
    });

    test('can update state via notifier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedCategoryProvider), 'All');

      container.read(selectedCategoryProvider.notifier).state = 'Action';
      expect(container.read(selectedCategoryProvider), 'Action');
    });

    test('updates persist across multiple reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedCategoryProvider.notifier).state = 'Comedy';
      expect(container.read(selectedCategoryProvider), 'Comedy');
      expect(container.read(selectedCategoryProvider), 'Comedy');
    });

    test('different containers have independent state', () {
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();
      addTearDown(container1.dispose);
      addTearDown(container2.dispose);

      container1.read(selectedCategoryProvider.notifier).state = 'Drama';
      container2.read(selectedCategoryProvider.notifier).state = 'Horror';

      expect(container1.read(selectedCategoryProvider), 'Drama');
      expect(container2.read(selectedCategoryProvider), 'Horror');
    });

    test('can set to empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedCategoryProvider.notifier).state = '';
      expect(container.read(selectedCategoryProvider), '');
    });

    test('can set to various category strings', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const categories = ['All', 'Action', 'Comedy', 'Drama', 'Horror', 'Sci-Fi'];
      for (final cat in categories) {
        container.read(selectedCategoryProvider.notifier).state = cat;
        expect(container.read(selectedCategoryProvider), cat);
      }
    });
  });
}

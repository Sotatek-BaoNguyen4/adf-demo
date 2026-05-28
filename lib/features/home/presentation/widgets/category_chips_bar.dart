import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/movie_categories.dart';
import '../providers/selected_category_provider.dart';
import 'category_chip.dart';

/// Horizontal scrollable row of category filter chips with a right-edge fade.
///
/// Selection state is held in [selectedCategoryProvider] (UI-only in MVP).
/// The fade overlay uses [IgnorePointer] so touch scrolls pass through.
class CategoryChipsBar extends ConsumerWidget {
  const CategoryChipsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (int i = 0; i < movieCategories.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  CategoryChip(
                    label: movieCategories[i],
                    isSelected: selected == movieCategories[i],
                    onTap: () => ref
                        .read(selectedCategoryProvider.notifier)
                        .state = movieCategories[i],
                  ),
                ],
                // Trailing spacer keeps last chip clear of the fade overlay.
                const SizedBox(width: 44),
              ],
            ),
          ),

          // Right-edge fade — IgnorePointer so horizontal scroll is not blocked.
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Builder(
                builder: (context) {
                  final surface = Theme.of(context).colorScheme.surface;
                  return Container(
                    width: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          surface.withValues(alpha: 0),
                          surface,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

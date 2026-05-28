import 'package:flutter/material.dart';

import '../../../../core/theme/generated/spacing_tokens.dart';

/// Error icon + message + retry button for a single rail section.
///
/// Calls [onRetry] which maps to `ref.invalidate(provider)` in [MovieRail].
class ErrorSectionView extends StatelessWidget {
  const ErrorSectionView({
    super.key,
    required this.onRetry,
    this.message,
  });

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.s4,
        vertical: SpacingTokens.s4,
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: SpacingTokens.s2),
          Expanded(
            child: Text(
              message ?? 'Failed to load — pull to refresh',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: SpacingTokens.s2),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Generic placeholder shown for tabs not yet implemented.
///
/// Displays "{name} — Coming soon" centered, styled via theme — no hex literals.
class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$name — Coming soon',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

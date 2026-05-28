import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the active category filter chip on the home screen.
/// Defaults to 'All'. UI-only state — no data filtering in MVP.
final selectedCategoryProvider = StateProvider<String>((_) => 'All');

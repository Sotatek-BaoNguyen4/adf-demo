import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

/// Root application widget.
///
/// Uses [MaterialApp.router] wired to [appRouter] (go_router).
/// Dark theme is hard-coded for MVP per HLD §7.6.
class AdfCinemaApp extends StatelessWidget {
  const AdfCinemaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'ADF Cinema',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark, // HLD §7.6 — dark hard-coded for MVP
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      );
}

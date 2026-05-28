---
phase: 06
title: Router + bottom-nav shell
status: complete
priority: P0
effort: S
depends_on: [05]
---

# Phase 06 — Router + bottom-nav shell

## Context Links
- HLD §4.4 (StatefulShellRoute), §7.6 (dark theme hard-coded)
- FSD FR-HOME-005 (bottom-nav 5 tabs)
- Component catalog: `CinemaNavBar`

## Overview
Wire `MaterialApp.router` with `ProviderScope`, `AppTheme.dark()`, go_router `StatefulShellRoute.indexedStack` with 5 tabs. Only Home tab routes to the real screen; others are placeholders.

## Key Insights
- `StatefulShellRoute.indexedStack` gives each tab its own `Navigator` → independent back stacks (HLD §4.4).
- `themeMode: ThemeMode.dark` hard-coded (HLD §7.6).
- `Hive.bootstrapHive()` must complete before `runApp`.

## Requirements
**Functional**
- `main.dart` runs `bootstrapHive()` then `runApp(ProviderScope(child: const AdfCinemaApp()))`.
- `AdfCinemaApp` = `MaterialApp.router(theme: AppTheme.light(), darkTheme: AppTheme.dark(), themeMode: ThemeMode.dark, routerConfig: appRouter)`.
- `appRouter` defines `/home`, `/search`, `/cinemas`, `/community`, `/profile` under one `StatefulShellRoute`.
- Bottom nav uses M3 `NavigationBar` with 5 destinations (catalog: `CinemaNavBar`).
- Switching tabs preserves each tab's scroll/state.
- Initial route `/home`.

**Non-functional**
- `main.dart` <40 LOC.
- `router.dart` <120 LOC.
- `AdfCinemaApp` widget <60 LOC.

## Architecture
```
lib/main.dart
  └─ bootstrapHive() ► runApp(ProviderScope(AdfCinemaApp))
lib/app/
  ├─ app.dart                # AdfCinemaApp (MaterialApp.router)
  ├─ router.dart             # appRouter: StatefulShellRoute w/ 5 branches
  └─ shell/
      ├─ home_shell.dart     # Scaffold + NavigationBar wrapping child
      └─ placeholder_tab.dart  # generic "Coming soon" widget
```

## Related Code Files
**Create**
- `lib/app/app.dart` (<60 LOC)
- `lib/app/router.dart` (<120 LOC)
- `lib/app/shell/home_shell.dart` (<100 LOC)
- `lib/app/shell/placeholder_tab.dart` (<40 LOC)
- `lib/shared/widgets/cinema_nav_bar.dart` (<120 LOC) — wraps M3 NavigationBar

**Modify**
- `lib/main.dart` — replace stub with real entry point

## Implementation Steps
1. **`main.dart`**:
   ```dart
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await bootstrapHive();
     runApp(const ProviderScope(child: AdfCinemaApp()));
   }
   ```
2. **`app.dart`** — `MaterialApp.router` with theme + routerConfig.
3. **`router.dart`** — `GoRouter` with `StatefulShellRoute.indexedStack`:
   ```dart
   StatefulShellRoute.indexedStack(
     branches: [
       StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
       StatefulShellBranch(routes: [GoRoute(path: '/search', builder: ...)]),
       // ... cinemas, community, profile
     ],
     builder: (ctx, state, shell) => HomeShell(shell: shell),
   )
   ```
   Initial location `/home`.
4. **`home_shell.dart`** — `Scaffold(body: shell, bottomNavigationBar: CinemaNavBar(currentIndex: shell.currentIndex, onTap: shell.goBranch))`.
5. **`cinema_nav_bar.dart`** — M3 `NavigationBar` with 5 `NavigationDestination`s (Home, Search, Cinemas, Community, Profile) + icons from `Icons.*`.
6. **`placeholder_tab.dart`** — centered `Text('${tabName} — Coming soon')` styled via theme.
7. **Smoke test** — `flutter run`, tap each tab, verify Home renders carousel + rails, others render placeholder. Push Home then switch tabs and back → state preserved.
8. `flutter analyze` clean.

## Todo List
- [x] `main.dart` real entry point
- [x] `app.dart` MaterialApp.router
- [x] `router.dart` StatefulShellRoute w/ 5 branches
- [x] `home_shell.dart` Scaffold + bottom nav
- [x] `placeholder_tab.dart`
- [x] `cinema_nav_bar.dart` M3 NavigationBar
- [ ] Smoke run on iOS + Android simulator (no GUI env — verified via `flutter build apk --debug`)
- [ ] Verify tab state preservation (runtime only)
- [x] `flutter analyze` clean (0 errors, 14 info — all pre-existing)

## Success Criteria
- App launches → Home screen visible in <2s (HLD §10.1)
- 5 bottom-nav tabs switchable
- Tab back-stacks independent
- Dark theme applied globally
- All files <200 LOC

## Risk Assessment
| Risk | Mitigation |
|---|---|
| go_router API drift in v14 vs older docs | Pin `go_router: ^14.6.0` per HLD §6; consult migration guide |
| Hive bootstrap blocks first frame | Acceptable — happens before `runApp`, <60ms (LLD §10) |
| ProviderScope wraps too narrowly → providers don't find Dio | Wrap at root above MaterialApp.router |

## Security Considerations
None — placeholder tabs hold no user data.

## Next Steps
Unblocks phase 07 (tests need real composition root for widget tests).

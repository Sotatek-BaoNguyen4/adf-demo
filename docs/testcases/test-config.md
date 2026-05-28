# Test Configuration

**Last Updated**: 2026-05-28
**Default Environment**: local

## Environments

| Environment | Base URL / Target              | Purpose                        |
|------------|-------------------------------|--------------------------------|
| Local      | Flutter app on device/emulator | Development & widget testing   |
| Staging    | {staging-app-url}              | Pre-release validation         |
| Production | {prod-app-url}                 | Smoke tests only               |

> This is a Flutter mobile app. "Base URL" refers to the mock API interceptor base path configured in `lib/core/network/`.
> API base URL for mock interceptor: `http://localhost:8080` (override via `APP_API_BASE_URL` env var if running a real backend).

## Test Accounts

> **Security**: Never commit real passwords here. Use env var references or vault paths.
> AI agents: read credentials from the env var shown in the Password column.

| Role              | Username / Identifier      | Password / Token                 | Permissions                                      |
|-------------------|---------------------------|----------------------------------|--------------------------------------------------|
| Authenticated User | {test-user-email}        | `$TEST_USER_PASSWORD`            | Full Home screen including Recommended section   |
| Unauthenticated   | _(none)_                  | _(none)_                         | Public endpoints only (banners, now-showing, coming-soon) |
| Expired Token User | {test-user-email}        | _(inject expired JWT directly)_  | Triggers `401` on recommended endpoint           |

### How to retrieve credentials

```bash
# From .env file (local development)
source .env && echo $TEST_USER_PASSWORD

# From vault (staging/production)
{vault-command-here}
```

### Injecting test tokens (Flutter widget/integration tests)

```dart
// Inject a valid JWT for authenticated test scenarios
await tester.pumpWidget(ProviderScope(
  overrides: [
    authTokenProvider.overrideWithValue('$TEST_USER_JWT'),
  ],
  child: const App(),
));

// Inject an expired/forged JWT for security test scenarios
await tester.pumpWidget(ProviderScope(
  overrides: [
    authTokenProvider.overrideWithValue('eyJhbGciOiJIUzI1NiJ9.expired.sig'),
  ],
  child: const App(),
));
```

## API Authentication

| Method      | Header                          | Notes                                                      |
|-------------|----------------------------------|-------------------------------------------------------------|
| Bearer JWT  | `Authorization: Bearer <token>` | Required only for `GET /api/v1/movies/recommended`          |
| Public      | _(none)_                        | Banners, now-showing, coming-soon endpoints are public auth |

### Endpoints under test

| Endpoint                              | Auth     | Rate Limit        |
|---------------------------------------|----------|-------------------|
| `GET /api/v1/home/banners`            | Public   | 60 req/min per IP |
| `GET /api/v1/movies/now-showing`      | Public   | 60 req/min per IP |
| `GET /api/v1/movies/coming-soon`      | Public   | 60 req/min per IP |
| `GET /api/v1/movies/recommended`      | Bearer JWT | 120 req/min per user |

## Mock Interceptor

All API calls in this project are served by a fixture-based mock interceptor (`lib/core/network/mock_interceptor.dart`). No real network is required for unit/widget tests.

### Configuring mock responses for test scenarios

```dart
// Override mock to return 500 for banners (TC-HOME-001-05)
MockInterceptor.override(
  path: '/api/v1/home/banners',
  statusCode: 500,
  body: {'error': {'code': 'INTERNAL_ERROR'}},
);

// Override mock to return empty data (TC-HOME-001-09)
MockInterceptor.override(
  path: '/api/v1/movies/now-showing',
  statusCode: 200,
  body: {'data': [], 'meta': {'page': 1, 'limit': 10, 'total': 0, 'hasNext': false}},
);
```

## Local Cache (Hive)

| Store Key             | TTL     | Scope       | Notes                                     |
|-----------------------|---------|-------------|-------------------------------------------|
| `now_showing_cache`   | 300 s   | Per-device  | Public; safe to share across sessions     |
| `coming_soon_cache`   | 300 s   | Per-device  | Public; safe to share across sessions     |
| `recommended_cache`   | 120 s   | Per-user    | Private; must be cleared on logout        |
| `banners_cache`       | 300 s   | Per-device  | Public                                    |

### Reset cache between test runs

```bash
# Via Flutter integration test helper
fvm flutter test integration_test/ --dart-define=RESET_CACHE=true

# Manual: uninstall and reinstall app on device/emulator
adb uninstall {app.package.name}           # Android
xcrun simctl uninstall booted {bundle-id}  # iOS simulator
```

## Prerequisites Checklist

- [ ] Flutter 3.10+ installed via fvm (`fvm install`)
- [ ] Dependencies fetched (`fvm flutter pub get`)
- [ ] Code generation complete (`fvm flutter pub run build_runner build --delete-conflicting-outputs`)
- [ ] Device or emulator is running and recognized (`fvm flutter devices`)
- [ ] `.env` file has `TEST_USER_PASSWORD` and `TEST_USER_JWT` (for security TCs)
- [ ] Mock interceptor fixture files are present in `test/fixtures/`

## Test Execution

### Widget / Unit tests

```bash
# Run all tests
fvm flutter test

# Run home module tests only
fvm flutter test test/presentation/home/

# Run with coverage
fvm flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Integration / E2E tests

```bash
# Run on connected device or emulator
fvm flutter test integration_test/ -d <device-id>
```

## Execution Notes

- **UI tests**: Run on Chrome (web build) or Android emulator API 30+ / iOS 16+ simulator; viewport equivalent 390x844 (iPhone 14)
- **Timeouts**: API mock responses expected within 50 ms; shimmer-to-content transition must complete within 500 ms (NFR)
- **Auto-rotation timing**: Use `tester.pump(Duration(seconds: 5))` in widget tests to advance the timer without real-time waiting
- **Network simulation**: Use `flutter_test` `FakeAsync` or disable network adapter on emulator for offline cache tests (TC-HOME-001-06)
- **Carousel swipe**: Use `tester.drag(find.byType(PageView), Offset(-300, 0))` in widget tests to simulate left swipe
- **Known quirk**: Hive initialization requires `Hive.initFlutter()` in `setUp` — ensure test `main()` calls this before pumping widgets

# Deployment Guide — ADF Cinema MVP

**Objective**: Build, test, and deploy ADF Cinema to iOS, Android, web, and desktop platforms.  
**Last Updated**: 2026-05-28

---

## 1. Prerequisites

### System Requirements

| Component | Version | Installation |
|---|---|---|
| **Flutter** | 3.10.0+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| **Dart** | 3.10.0+ | Bundled with Flutter |
| **FVM** | Latest | `brew install fvm` (macOS) or [fvm.app](https://fvm.app/) |
| **Xcode** | 14.0+ | App Store (macOS / iOS development) |
| **Android Studio** | 2022.3+ | [developer.android.com](https://developer.android.com/studio) |
| **CocoaPods** | 1.11+ | `sudo gem install cocoapods` (iOS dependencies) |

### Device / Emulator Targets

- **iOS**: iPhone 13+ running iOS 12.0+
- **Android**: API level 21+ (Android 5.0+)
- **Web**: Chrome, Safari, Firefox (latest)
- **macOS**: 10.14+
- **Linux**: Ubuntu 20.04+ (desktop)
- **Windows**: Windows 10+ (desktop)

---

## 2. Local Development Setup

### Step 1: Clone & FVM Sync

```bash
# Clone repository
git clone <repo-url>
cd adf_demo

# Install Flutter version from .fvmrc
fvm install

# Verify version
fvm flutter --version
```

### Step 2: Get Dependencies

```bash
# Download pub packages
fvm flutter pub get

# Update iOS/macOS pods
fvm flutter pub get
cd ios && pod install && cd ..
```

### Step 3: Code Generation

```bash
# Generate Riverpod, Freezed, Hive, JSON serialization
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Generate design tokens
dart tool/gen_theme.dart

# Verify no analysis issues
fvm flutter analyze
```

### Step 4: Run on Device/Emulator

```bash
# List available devices
fvm flutter devices

# Run on specific device
fvm flutter run -d <device-id>

# Run with mock data (default)
fvm flutter run -d <device-id> --dart-define=USE_MOCK=true

# Run with real API (post-MVP)
fvm flutter run -d <device-id> --dart-define=USE_MOCK=false
```

### Step 5: Run Tests

```bash
# Run all tests
fvm flutter test

# Run with coverage
fvm flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 3. Build Commands

### Android

#### Debug Build (for testing)
```bash
# APK (single architecture, faster)
fvm flutter build apk --debug --target-platform android-arm64

# APK (all architectures)
fvm flutter build apk --debug
```

#### Release Build (for distribution)
```bash
# APK
fvm flutter build apk --release

# App Bundle (for Google Play)
fvm flutter build appbundle --release

# Output: build/app/outputs/apk/release/app-release.apk
#         build/app/outputs/bundle/release/app-release.aab
```

#### Signing (Pre-Release Checklist)
1. Create keystore (if not exists):
   ```bash
   keytool -genkey -v -keystore ~/key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload_key
   ```

2. Create `android/key.properties`:
   ```properties
   storeFile=~/key.jks
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload_key
   ```

3. Build signed release:
   ```bash
   fvm flutter build appbundle --release
   ```

### iOS

#### Debug Build (for testing)
```bash
fvm flutter build ios --debug
```

#### Release Build (for distribution)
```bash
# Creates release build in build/ios/ipa/
fvm flutter build ios --release

# Output: build/ios/ipa/adf_demo.ipa
```

#### Prepare for App Store
1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.0.0+1  # version+build-number
   ```

2. Build:
   ```bash
   fvm flutter build ios --release
   ```

3. Open in Xcode and archive:
   ```bash
   open ios/Runner.xcworkspace
   # → Product → Scheme: Runner → Archive
   ```

4. Distribute to App Store Connect or TestFlight

### Web

#### Debug Build
```bash
fvm flutter build web --debug
```

#### Release Build
```bash
fvm flutter build web --release

# Output: build/web/
# Deploy to any static hosting (Firebase, Netlify, Vercel)
```

#### Serve Locally
```bash
fvm flutter run -d chrome
# or
fvm flutter build web && cd build/web && python3 -m http.server 8000
```

### macOS / Linux / Windows

#### macOS
```bash
# Debug
fvm flutter run -d macos

# Release
fvm flutter build macos --release
# Output: build/macos/Build/Products/Release/adf_demo.app
```

#### Linux
```bash
# Debug
fvm flutter run -d linux

# Release
fvm flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

#### Windows
```bash
# Debug
fvm flutter run -d windows

# Release
fvm flutter build windows --release
# Output: build/windows/runner/Release/
```

---

## 4. Platform-Specific Configuration

### iOS

**File**: `ios/Runner/Info.plist`
- Minimum deployment target: iOS 12.0
- App name, bundle ID, permissions

**Font Bundling** (when fonts ready):
1. Copy `.ttf` files to `assets/fonts/`
2. Uncomment `fonts:` block in `pubspec.yaml`
3. Run `fvm flutter pub get && fvm flutter clean && fvm flutter pub get`

### Android

**File**: `android/app/build.gradle`
- Min SDK: API 21 (Android 5.0)
- Target SDK: API 35+ (latest)

**Permissions** (AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### Web

**File**: `web/index.html`
- Meta tags for responsive design
- Icons and PWA manifest

**Build Options**:
```bash
# Enable web compilation target
fvm flutter config --enable-web

# Run on web
fvm flutter run -d chrome
```

---

## 5. Mock vs. Real API Toggle

### Configuration

**File**: `lib/core/network/network_config.dart`

```dart
const bool useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

class NetworkConfig {
  static final String baseUrl = useMock
      ? 'http://localhost:8080'  // Local mock (ignored, MockInterceptor handles)
      : 'https://api.imdb.com';   // Real IMDB API (post-MVP)
  
  static final int connectTimeout = 30;
  static final int receiveTimeout = 30;
}
```

### Usage

**Default (Mock Mode)**:
```bash
fvm flutter run
# or explicitly
fvm flutter run --dart-define=USE_MOCK=true
```

**Real API (Post-MVP)**:
```bash
fvm flutter run --dart-define=USE_MOCK=false
```

**Build**:
```bash
# Mock
fvm flutter build apk --release --dart-define=USE_MOCK=true

# Real API
fvm flutter build apk --release --dart-define=USE_MOCK=false
```

---

## 6. Asset Management

### Current Assets

```
assets/
├── fixtures/             # Mock API responses (JSON)
│   ├── banners.json
│   ├── now-showing.json
│   ├── coming-soon.json
│   └── recommended.json
└── fonts/                # Font files (pending)
    ├── Poppins-Regular.ttf
    ├── Inter-Regular.ttf
    └── Righteous-Regular.ttf
```

### Adding Fonts (Post-MVP)

1. Download OFL `.ttf` files:
   - Poppins: https://fonts.google.com/specimen/Poppins
   - Inter: https://fonts.google.com/specimen/Inter
   - Righteous: https://fonts.google.com/specimen/Righteous

2. Place in `assets/fonts/`:
   ```
   assets/fonts/
   ├── Poppins-Regular.ttf
   ├── Poppins-Medium.ttf
   ├── Poppins-SemiBold.ttf
   ├── Poppins-Bold.ttf
   ├── Inter-Regular.ttf
   ├── Inter-Medium.ttf
   ├── Inter-SemiBold.ttf
   ├── Inter-Bold.ttf
   ├── Righteous-Regular.ttf
   └── Righteous-Bold.ttf
   ```

3. Uncomment in `pubspec.yaml`:
   ```yaml
   fonts:
     - family: Poppins
       fonts:
         - asset: assets/fonts/Poppins-Regular.ttf
           weight: 400
         - asset: assets/fonts/Poppins-Medium.ttf
           weight: 500
         # ... etc
   ```

4. Rebuild:
   ```bash
   fvm flutter clean
   fvm flutter pub get
   fvm flutter run
   ```

---

## 7. Testing & Quality Assurance

### Unit & Widget Tests

```bash
# Run all tests
fvm flutter test

# Run specific test file
fvm flutter test test/features/home/widgets/movie_card_test.dart

# Run with verbose output
fvm flutter test -v

# Generate coverage
fvm flutter test --coverage
```

### Code Analysis

```bash
# Static analysis
fvm flutter analyze

# Format check
fvm dart format lib/ test/ --set-exit-if-changed

# Fix formatting
fvm dart format lib/ test/
```

### Performance Profiling

```bash
# Run with performance overlay
fvm flutter run --profile

# DevTools profiler
fvm flutter pub global activate devtools
fvm devtools

# Profile app (in DevTools, select Performance tab)
```

---

## 8. CI/CD Integration

### GitHub Actions (Example)

**File**: `.github/workflows/build.yml`

```yaml
name: Build & Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.x'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Generate code
        run: flutter pub run build_runner build --delete-conflicting-outputs
      
      - name: Run tests
        run: flutter test
      
      - name: Analyze
        run: flutter analyze
      
      - name: Build APK (mock)
        run: flutter build apk --release --dart-define=USE_MOCK=true
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/apk/release/
```

---

## 9. Troubleshooting

### Common Issues

#### "Build fails: missing TypeAdapter"
```bash
# Solution: rebuild code generation
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

#### "Gradle build fails"
```bash
# Solution: clear Android build cache
fvm flutter clean
cd android && ./gradlew clean && cd ..
fvm flutter build apk --debug
```

#### "CocoaPods error (iOS)"
```bash
# Solution: reinstall pods
fvm flutter clean
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
fvm flutter run -d ios
```

#### "Device not found"
```bash
# List devices
fvm flutter devices

# Start emulator
emulator -avd <emulator-name>  # Android
xcrun simctl list devices       # iOS (see available simulators)
open -a Simulator               # Launch iOS Simulator
```

#### "Mock interceptor not working"
- Verify `USE_MOCK=true` (default)
- Check fixture JSON file exists in `assets/fixtures/`
- Verify JSON matches DTO schema in `project-fsd.md` § API Contracts
- Check `mock_fixture_loader.dart` loads asset correctly

#### "Theme tokens not updating"
```bash
# Regenerate tokens after design changes
dart tool/gen_theme.dart
fvm flutter clean
fvm flutter pub get
fvm flutter run
```

#### "Tests fail with 'ProviderScope not found'"
- Use `WidgetTestHarness` wrapper (see `test/_helpers/widget_test_harness.dart`)
- Ensure test imports `ProviderScope` from `flutter_riverpod`

### Logs & Debugging

```bash
# View device logs
fvm flutter logs

# Debug app with verbose output
fvm flutter run -v

# Attach debugger (breakpoints in IDE)
fvm flutter run --debug

# Monitor build progress
fvm flutter build apk --verbose
```

---

## 10. Release Checklist

### Pre-Release

- [ ] All tests pass: `fvm flutter test`
- [ ] No analysis issues: `fvm flutter analyze`
- [ ] Code formatted: `fvm dart format lib/ test/`
- [ ] Version bumped: `pubspec.yaml` (version: X.Y.Z+N)
- [ ] Design tokens updated: `dart tool/gen_theme.dart`
- [ ] Fonts bundled (if ready): uncomment `pubspec.yaml` fonts block
- [ ] Mock mode verified: `--dart-define=USE_MOCK=true`
- [ ] Changelog updated: `docs/project-changelog.md`
- [ ] README updated: `README.md` with features + build steps

### Android Release

- [ ] App signed (`key.properties` configured)
- [ ] App Bundle built: `fvm flutter build appbundle --release`
- [ ] Uploaded to Google Play Console

### iOS Release

- [ ] Version + build number updated
- [ ] Archive created in Xcode
- [ ] App Store Connect submission complete
- [ ] TestFlight QA passed

### Web Release

- [ ] Build optimized: `fvm flutter build web --release`
- [ ] Assets compressed (images, JSON)
- [ ] Deployment to hosting (Firebase, Netlify, Vercel)

### Post-Release

- [ ] Monitor crash logs (Firebase Crashlytics)
- [ ] User feedback channels monitored
- [ ] Version tag created: `git tag v1.0.0`

---

## 11. Performance Benchmarks

### Target Metrics (MVP)

| Metric | Target | Measurement |
|---|---|---|
| Cold start | <2s | Time from app launch to first home screen render |
| Warm start | <500ms | Time from app resume to home screen render (cached) |
| Banner auto-rotate | 5s | Interval between carousel slides |
| API response | <1s | Mock fixture load time (network included) |
| TTI (Time to Interactive) | <2s | Time to first tap responsiveness |
| Code analysis | 0 issues | `fvm flutter analyze` result |
| Test coverage | >80% (home) | Home feature unit + widget test coverage |

### Profiling Tools

```bash
# CPU profiler (CPU, GPU, memory)
fvm devtools --profile

# Memory profiler
fvm devtools --memory

# Network profiler
fvm devtools --network
```

---

## 12. Platform Availability & Limitations

| Platform | Status | Notes |
|---|---|---|
| **iOS** | ✅ Ready | Deploy to App Store via TestFlight |
| **Android** | ✅ Ready | Deploy to Google Play Console |
| **Web** | ✅ Ready | Deploy to static hosting (CORS-aware) |
| **macOS** | ✅ Ready | Desktop app (not primary target) |
| **Linux** | ✅ Ready | Desktop app (not primary target) |
| **Windows** | ✅ Ready | Desktop app (not primary target) |

### MVP Limitations

- **Light Theme**: Not user-toggleable (dark theme only)
- **Fonts**: Pending `.ttf` drop-in (using system fonts for now)
- **Mock Data**: All endpoints serve fixtures (real API post-MVP)
- **Auth**: No token-based auth (Recommended endpoint is public)
- **Search**: Not implemented (planned for Phase 2)
- **Deep Linking**: Basic routing only (not fully implemented)

---

## 13. Known Caveats

### Build Time
- **First build**: ~2–3 minutes (dependency download, code gen)
- **Incremental**: ~30–60s (cached)
- **Clean build**: ~2 minutes

### Asset Bundling
- Fixtures (`.json`) bundled with app (~100 KB)
- Images lazy-loaded via `CachedNetworkImage` (async)
- Fonts not yet bundled (pending `.ttf` download)

### Testing
- Widget tests require `WidgetTestHarness` wrapper
- Some Riverpod providers need `.select()` for test isolation
- `mocktail` mocks require `Fake` implementations

### Performance
- Hive cache can grow with repeated app uses (manual cleanup needed)
- Banner carousel may stutter on low-end devices (optimize animation)
- Image cache can consume >50 MB (monitor with DevTools)

---

## 14. Reference Documents

- **[README.md](../README.md)** — Quick start, features, contribution rules
- **[docs/project-overview-pdr.md](project-overview-pdr.md)** — Requirements, constraints, assumptions
- **[docs/code-standards.md](code-standards.md)** — Build commands, linting, testing
- **[docs/project-roadmap.md](project-roadmap.md)** — Phase timeline, upcoming features

---

**End of Deployment Guide**

/// Single source of network constants.
///
/// Switch mock mode at build time:
///   flutter run --dart-define=USE_MOCK=false
///   flutter run --dart-define=USE_MOCK=true  (default)
class NetworkConfig {
  const NetworkConfig._();

  static const String baseUrl = 'https://api.adf-cinema.local';
  static const Duration connect = Duration(seconds: 5);
  static const Duration receive = Duration(seconds: 10);

  /// When true, [MockInterceptor] is wired and real adapter is never reached.
  static const bool useMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: true);

  static const Duration mockMinLatency = Duration(milliseconds: 120);
  static const Duration mockMaxLatency = Duration(milliseconds: 320);
}

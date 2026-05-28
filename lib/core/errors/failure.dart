import 'package:flutter/foundation.dart';

/// Sealed failure hierarchy shared by core/network and core/storage.
///
/// Repository converts low-level exceptions to [Failure] before throwing
/// across the module boundary. UI receives [Failure] via AsyncValue.error.
///
/// Security: [toString] redacts [cause] in release builds to prevent
/// leaking stack traces or internal detail to logs/crash reporters.
sealed class Failure implements Exception {
  final String message;

  /// The underlying exception; never surfaced in release builds.
  final Object? cause;

  const Failure(this.message, [this.cause]);

  @override
  String toString() {
    if (kReleaseMode) {
      return '$runtimeType: $message';
    }
    return cause != null
        ? '$runtimeType: $message (cause: $cause)'
        : '$runtimeType: $message';
  }
}

/// HTTP 4xx / 5xx response from server or mock error injection.
final class NetworkFailure extends Failure {
  final int? statusCode;

  const NetworkFailure(String message, {this.statusCode, Object? cause})
      : super(message, cause);
}

/// Dio connection timeout or receive timeout; also `?_mock_error=timeout`.
final class TimeoutFailure extends Failure {
  const TimeoutFailure(String message, [Object? cause]) : super(message, cause);
}

/// JSON decode error or malformed fixture body; also `?_mock_error=parse`.
final class ParseFailure extends Failure {
  /// The asset path or URL being parsed when the failure occurred.
  final String? path;

  const ParseFailure(String message, {this.path, Object? cause})
      : super(message, cause);
}

/// Hive [HiveError] during a box read operation.
final class CacheReadFailure extends Failure {
  final String boxName;

  const CacheReadFailure(String message, {required this.boxName, Object? cause})
      : super(message, cause);
}

/// Hive write operation failed (e.g. disk full, corrupted box).
final class CacheWriteFailure extends Failure {
  final String boxName;

  const CacheWriteFailure(
    String message, {
    required this.boxName,
    Object? cause,
  }) : super(message, cause);
}

/// Asset path not found in the pubspec assets bundle (mock-mode only).
final class FixtureMissingFailure extends Failure {
  final String assetPath;

  const FixtureMissingFailure(
    String message, {
    required this.assetPath,
    Object? cause,
  }) : super(message, cause);
}

/// Catch-all for exceptions not mapped to a more specific subclass.
final class UnknownFailure extends Failure {
  const UnknownFailure(String message, [Object? cause]) : super(message, cause);
}

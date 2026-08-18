import 'package:flutter/foundation.dart';

abstract interface class BinnoLogger {
  void info(String message, [Map<String, Object?> context = const {}]);
  void warning(String message, [Map<String, Object?> context = const {}]);
}

final class DebugBinnoLogger implements BinnoLogger {
  const DebugBinnoLogger();

  @override
  void info(String message, [Map<String, Object?> context = const {}]) {
    debugPrint('$message ${LogRedactor.redact(context)}');
  }

  @override
  void warning(String message, [Map<String, Object?> context = const {}]) {
    debugPrint('$message ${LogRedactor.redact(context)}');
  }
}

abstract final class LogRedactor {
  static Map<String, Object?> redact(Map<String, Object?> input) {
    return input.map((key, value) {
      final normalized = key.toLowerCase();
      if (normalized.contains('token') ||
          normalized.contains('otp') ||
          normalized.contains('phone')) {
        return MapEntry(key, '[REDACTED]');
      }
      return MapEntry(key, value);
    });
  }
}

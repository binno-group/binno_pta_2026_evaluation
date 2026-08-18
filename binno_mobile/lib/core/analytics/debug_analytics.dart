import 'package:binno_app/core/analytics/analytics.dart';
import 'package:binno_app/core/logging/binno_logger.dart';
import 'package:flutter/foundation.dart';

final class DebugAnalytics implements Analytics {
  const DebugAnalytics(this.logger);

  final BinnoLogger logger;

  @override
  Future<void> track(
    String event,
    Map<String, Object?> properties,
  ) async {
    final sanitized = AnalyticsRedactor.sanitize(properties);
    if (kDebugMode) {
      logger.info(event, sanitized);
    }
  }
}

abstract final class AnalyticsRedactor {
  static const _blocked = {
    'phone',
    'otp',
    'token',
    'bank_account',
    'address',
  };

  static Map<String, Object?> sanitize(Map<String, Object?> input) {
    return {
      for (final entry in input.entries)
        if (!_blocked.contains(entry.key.toLowerCase())) entry.key: entry.value,
    };
  }
}

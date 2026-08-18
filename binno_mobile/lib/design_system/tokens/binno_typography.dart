import 'package:binno_app/design_system/tokens/binno_colors.dart';
import 'package:flutter/material.dart';

abstract final class BinnoTypography {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    height: 1.05,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    color: BinnoColors.textPrimary,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: BinnoColors.textPrimary,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: BinnoColors.textPrimary,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: BinnoColors.textPrimary,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w600,
    color: BinnoColors.textPrimary,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: BinnoColors.textPrimary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    color: BinnoColors.textSecondary,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
  );
}

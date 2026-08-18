import 'package:binno_app/design_system/tokens/binno_colors.dart';
import 'package:binno_app/design_system/tokens/binno_radius.dart';
import 'package:binno_app/design_system/tokens/binno_typography.dart';
import 'package:flutter/material.dart';

abstract final class BinnoTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: BinnoColors.navy900,
      primary: BinnoColors.navy900,
      surface: BinnoColors.canvas,
      error: BinnoColors.danger,
    ).copyWith(tertiary: BinnoColors.success);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BinnoColors.canvas,
      textTheme: const TextTheme(
        displayLarge: BinnoTypography.displayLarge,
        headlineLarge: BinnoTypography.headlineLarge,
        headlineMedium: BinnoTypography.headlineMedium,
        titleLarge: BinnoTypography.titleLarge,
        titleMedium: BinnoTypography.titleMedium,
        bodyLarge: BinnoTypography.bodyLarge,
        bodyMedium: BinnoTypography.bodyMedium,
        labelLarge: BinnoTypography.labelLarge,
        labelMedium: BinnoTypography.labelMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BinnoColors.navy50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BinnoRadius.lg),
          borderSide: const BorderSide(color: BinnoColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BinnoRadius.lg),
          borderSide: const BorderSide(color: BinnoColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BinnoRadius.lg),
          borderSide: const BorderSide(
            color: BinnoColors.navy950,
            width: 1.5,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: BinnoColors.canvas,
        foregroundColor: BinnoColors.navy950,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BinnoColors.navy950,
          foregroundColor: BinnoColors.canvas,
          disabledBackgroundColor: BinnoColors.navy100,
          disabledForegroundColor: BinnoColors.textTertiary,
          shape: const StadiumBorder(),
          textStyle: BinnoTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BinnoColors.navy950,
          side: const BorderSide(color: BinnoColors.borderStrong),
          shape: const StadiumBorder(),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: BinnoColors.canvas,
        indicatorColor: Colors.transparent,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(BinnoTypography.labelMedium),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text.dart';

/// The single (light) theme of the BINNO app.
///
/// There is deliberately no dark mode: the app is used outdoors, in the
/// sun, where a white background with high contrast reads best.
abstract class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: AppText.family,
    scaffoldBackgroundColor: AppColors.white,
    canvasColor: AppColors.white,
    // Tap feedback: a navy tint at low opacity, calm but visible (§14).
    // It used to be grey (surface2) and was barely noticeable.
    splashColor: AppColors.navy950.withValues(alpha: 0.09),
    highlightColor: AppColors.navy950.withValues(alpha: 0.05),
    dividerColor: AppColors.hairline,
    colorScheme: const ColorScheme.light(
      primary: AppColors.navy950,
      onPrimary: AppColors.white,
      secondary: AppColors.navy700,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.ink,
      error: AppColors.danger,
      onError: AppColors.white,
      outline: AppColors.edge,
    ),

    // The app is used in sunlight; text sizes are chosen for that, and
    // the system text scale is respected.
    textTheme: TextTheme(
      displayLarge: AppText.display(34),
      displayMedium: AppText.display(28),
      displaySmall: AppText.display(24),
      headlineMedium: AppText.display(22),
      titleLarge: AppText.s(17, FontWeight.w600),
      titleMedium: AppText.s(15, FontWeight.w600),
      bodyLarge: AppText.s(16, FontWeight.w400),
      bodyMedium: AppText.body(),
      bodySmall: AppText.meta(),
      labelLarge: AppText.s(14, FontWeight.w600),
      labelMedium: AppText.s(12, FontWeight.w600),
      labelSmall: AppText.eyebrow(),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),

    dividerTheme: const DividerThemeData(
      thickness: AppDimens.bwHairline,
      space: AppDimens.bwHairline,
      color: AppColors.hairline,
    ),

    // Every interactive element must be ≥48dp (sunlight, one-handed use).
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.rSheet),
        ),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.navy950,
      contentTextStyle: AppText.s(14, FontWeight.w500, color: AppColors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.rThumb),
      ),
    ),

    // Page transitions stay platform-default: edge swipe on iOS, the
    // Material transition on Android. The `Cupertino*` builders live in
    // `package:flutter/cupertino.dart`, and importing that here risks name
    // clashes with material, so they are not used.
  );

  /// The dark theme, ready as infrastructure. Screens still use light
  /// colours directly, so a full dark look needs every page moved to
  /// theme-aware colours; that is a later stage. Here the Material-level
  /// basics (background, app bar, dialogs, text) switch to dark.
  static ThemeData get dark {
    const bg = Color(0xFF0B1220);
    const surface = Color(0xFF121B2E);
    const onSurface = Color(0xFFE8EDF5);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppText.family,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      splashColor: AppColors.white.withValues(alpha: 0.06),
      highlightColor: AppColors.white.withValues(alpha: 0.04),
      dividerColor: AppColors.white.withValues(alpha: 0.08),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.white,
        onPrimary: AppColors.navy950,
        secondary: AppColors.onNavy3,
        surface: surface,
        onSurface: onSurface,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.rSheet),
          ),
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  /// For screens with a navy header (white status bar icons).
  static const SystemUiOverlayStyle overlayOnNavy = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  /// For screens on a white background (dark status bar icons).
  static const SystemUiOverlayStyle overlayOnLight = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );
}

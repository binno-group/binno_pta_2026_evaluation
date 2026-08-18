import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// BINNO typography, a single family: **Montserrat**.
///
/// The design used two families (Archivo for numbers, Inter for text);
/// here both are covered by Montserrat:
///   * [display] covers all numbers and large headings (tabular figures,
///     negative letter-spacing), standing in for Archivo.
///   * [s] covers everything else, standing in for Inter.
///
/// Money rule: the number and the unit ("so'm", "so'm / qop") are
/// **separate** elements; a card price is ≥17sp semibold.
abstract class AppText {
  static const family = 'Montserrat';

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// The general text style (in place of Inter).
  static TextStyle s(
    double size,
    FontWeight weight, {
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );

  /// The display/number style (in place of Archivo): tabular figures, tight tracking.
  static TextStyle display(
    double size, {
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w700,
    double? height,
    double? tracking,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: tracking ?? -size * 0.03,
    fontFeatures: _tabular,
  );

  // ── Ready-made styles ─────────────────────────────────────────────────────

  /// The UPPERCASE label above a section.
  static TextStyle eyebrow({
    Color color = AppColors.ink2,
    double size = 11,
    FontWeight weight = FontWeight.w600,
  }) => s(size, weight, color: color, letterSpacing: size * 0.12);

  /// A list row title.
  static TextStyle rowTitle({Color color = AppColors.ink, double size = 15}) =>
      s(size, FontWeight.w600, color: color);

  /// A meta/secondary line.
  static TextStyle meta({Color color = AppColors.ink2, double size = 12}) =>
      s(size, FontWeight.w400, color: color, height: 1.5);

  /// Long-form text (body).
  static TextStyle body({Color color = AppColors.ink2, double size = 14}) =>
      s(size, FontWeight.w400, color: color, height: 1.6);

  /// A note/footnote.
  static TextStyle note({Color color = AppColors.ink2, double size = 11}) =>
      s(size, FontWeight.w400, color: color, height: 1.5);

  /// Button text.
  static TextStyle button({Color color = AppColors.white, double size = 15}) =>
      s(size, FontWeight.w600, color: color);

  /// Pill/chip text.
  static TextStyle pill({required Color color, double size = 11}) =>
      s(size, FontWeight.w600, color: color);

  /// A link or tertiary action.
  static TextStyle link({Color color = AppColors.navy700, double size = 13}) =>
      s(size, FontWeight.w600, color: color);
}

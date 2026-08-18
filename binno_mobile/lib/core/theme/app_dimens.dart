import 'package:flutter/material.dart';

import 'app_colors.dart';

/// BINNO size, radius, and shadow tokens.
///
/// An 8dp rhythm (4dp micro). Elevation philosophy: borders first, shadows
/// only on sheets, modals, and the primary CTA.
abstract class AppDimens {
  // ── Gutter and rhythm ─────────────────────────────────────────────────────
  static const double gutter = 24;
  static const double gutterTight = 16;

  // ── Radii ─────────────────────────────────────────────────────────────────
  static const double rSheet = 34; // bottom sheet top corners
  static const double rHeader = 32; // navy header bottom corners
  static const double rHero = 28;
  static const double rImage = 26;
  static const double rCard = 22;
  static const double rCardSm = 20;
  static const double rField = 18;
  static const double rTile = 16;
  static const double rThumb = 14;
  static const double rSm = 10;
  static const double rPill = 999;

  // ── Heights ───────────────────────────────────────────────────────────────
  static const double hControl = 44;
  static const double hSegment = 48;
  static const double hTapTarget = 48;
  static const double hSecondaryCta = 52;
  static const double hPrimaryCta = 56;
  static const double hSearch = 56;
  static const double avatar = 48;
  static const double circleControl = 52;

  // ── Border widths ─────────────────────────────────────────────────────────
  static const double bwHairline = 1;
  static const double bwControl = 1.5;

  // ── Shadows ───────────────────────────────────────────────────────────────
  static const List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: Color(0x42101D33), // rgba(16,29,51,.26)
      blurRadius: 28,
      offset: Offset(0, 14),
    ),
  ];

  static const List<BoxShadow> shadowFloating = [
    BoxShadow(
      color: Color(0x24101D33), // rgba(16,29,51,.14)
      blurRadius: 30,
      offset: Offset(0, 14),
    ),
  ];

  /// The white-card shadow, for the light grey background.
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x0F101D33), // rgba(16,29,51,.06)
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  /// The floating search bar shadow.
  static const List<BoxShadow> shadowSearch = [
    BoxShadow(
      color: Color(0x14101D33), // rgba(16,29,51,.08)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowPill = [
    BoxShadow(
      color: Color(0x47101D33), // rgba(16,29,51,.28)
      blurRadius: 26,
      offset: Offset(0, 12),
    ),
  ];

  // ── Motion ────────────────────────────────────────────────────────────────
  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionBase = Duration(milliseconds: 240);
  static const Duration motionSlow = Duration(milliseconds: 300);

  // ── Ready-made decorations ────────────────────────────────────────────────
  static BoxDecoration softCard({double radius = rCard}) => BoxDecoration(
    color: AppColors.navy50,
    borderRadius: BorderRadius.circular(radius),
  );

  static BoxDecoration outlined({
    double radius = rField,
    Color color = AppColors.border15,
    double width = bwControl,
  }) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: color, width: width),
  );
}

import 'package:flutter/material.dart';

/// BINNO design system colour tokens (the v2 "sheet" system).
///
/// Rule: navy and white dominate. Orange `#F25912` is for brand moments
/// ONLY (logo, splash, one hero per flow). Never a status colour.
abstract class AppColors {
  // ── Brand / navy ──────────────────────────────────────────────────────────
  /// The primary surface: header, primary button, avatar, icon stroke.
  static const navy950 = Color(0xFF101D33);
  static const navy900 = Color(0xFF1B2A4A);
  static const navy800 = Color(0xFF24365C);

  /// Links and tertiary actions ("O'zgartirish", "Do'kon").
  static const navy700 = Color(0xFF2F4574);
  static const navy100 = Color(0xFFE8EDF5);
  static const navy50 = Color(0xFFF3F6FA);

  /// The brand accent, for the logo/splash only.
  static const orange = Color(0xFFF25912);

  // ── Surfaces ──────────────────────────────────────────────────────────────
  static const white = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8FAFC);
  static const surface2 = Color(0xFFF1F5F9);
  static const surface3 = Color(0xFFF1F4F9);
  static const canvas = Color(0xFFE9ECF2);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const edge = Color(0xFFE2E8F0);
  static const edge2 = Color(0xFFCBD5E1);

  /// The 1px divider (v2).
  static const hairline = Color(0xFFEDF0F5);

  /// 1.5px inactive border.
  static const border15 = Color(0xFFE4E9F1);

  /// 1.5px doiraviy kontrol border.
  static const border16 = Color(0xFFD9E0EA);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const ink = Color(0xFF0F172A);
  static const ink2 = Color(0xFF64748B);
  static const ink3 = Color(0xFF94A3B8);
  static const slate700 = Color(0xFF4A5A75);

  // ── On navy ───────────────────────────────────────────────────────────────
  static const onNavy = Color(0xFFFFFFFF);
  static const onNavy2 = Color(0xFFC6D3EA);
  static const onNavy3 = Color(0xFF9FB3D9);
  static const onNavyMeta = Color(0xFF8598BC);
  static const onNavySuccess = Color(0xFF9FE8B6);

  // ── Semantic, for real states only ────────────────────────────────────────
  static const success = Color(0xFF16A34A);
  static const successDot = Color(0xFF22C55E);
  static const successText = Color(0xFF15803D);
  static const successBg = Color(0xFFE6F4EB);
  static const successInk = Color(0xFF06240F);

  static const warning = Color(0xFFD97706);
  static const warningText = Color(0xFF92400E);
  static const warningBg = Color(0xFFFCEFD5);
  static const warningBg2 = Color(0xFFFEF6E7);
  static const warningBorder = Color(0xFFF0DDB4);
  static const warningBadgeBg = Color(0xFFFDF8EC);

  static const danger = Color(0xFFDC2626);
  static const dangerBg = Color(0xFFFBEDEE);

  /// The verified ✓ and info colour.
  static const info = Color(0xFF2563EB);

  // ── Timeline ──────────────────────────────────────────────────────────────
  static const railLine = Color(0xFFDFE5EE);
  static const railFuture = Color(0xFFCFD7E3);

  // ── Payment providers ─────────────────────────────────────────────────────
  static const payme = Color(0xFF00C1C1);
  static const click = Color(0xFF0072C6);
  static const paynet = Color(0xFFE4002B);
}

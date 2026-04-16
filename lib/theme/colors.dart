import 'package:flutter/material.dart';

/// SpotIt Design System — Modern Color Palette
class AppColors {
  // ── Primary Brand (Emerald Green) ────────────────────────────────────────
  static const Color primary = Color(0xFF16A34A); // emerald-600
  static const Color primaryLight = Color(0xFF22C55E); // emerald-500
  static const Color primaryContainer = Color(0xFFDCFCE7); // emerald-100
  static const Color onPrimary = Colors.white;

  // ── Secondary (Teal accent) ───────────────────────────────────────────────
  static const Color secondary = Color(0xFF0EA5E9); // sky-500
  static const Color secondaryContainer = Color(0xFFE0F2FE); // sky-100
  static const Color onSecondary = Colors.white;

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color warningContainer = Color(0xFFFEF3C7); // amber-100
  static const Color error = Color(0xFFDC2626); // red-600
  static const Color errorContainer = Color(0xFFFEE2E2); // red-100

  // ── Neutrals ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF9FAFB); // gray-50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6); // gray-100
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  static const Color onSurface = Color(0xFF111827); // gray-900
  static const Color onSurfaceVariant = Color(0xFF6B7280); // gray-500
  static const Color onSurfaceMuted = Color(0xFF9CA3AF); // gray-400

  static const Color outline = Color(0xFFE5E7EB); // gray-200
  static const Color outlineFocus = Color(0xFF16A34A); // primary

  // ── Category Colors ───────────────────────────────────────────────────────
  static const Color garbage = Color(0xFF16A34A);
  static const Color pothole = Color(0xFF92400E);
  static const Color waterLeakage = Color(0xFF0369A1);
  static const Color streetlight = Color(0xFFD97706);
  static const Color other = Color(0xFF6B7280);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF15803D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF15803D), Color(0xFF166534)],
    begin: Alignment.topLeft,
    end: Alignment.bottomCenter,
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: const Color(0xFF16A34A).withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

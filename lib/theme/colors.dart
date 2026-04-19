import 'package:flutter/material.dart';

/// SpotIt Design System — Color Palette
/// All alpha variants are pre-computed as static constants to avoid
/// allocating new Color objects inside build() on every frame.
class AppColors {
  // ── Primary Brand (Emerald Green) ────────────────────────────────────────
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryLight = Color(0xFF22C55E);
  static const Color primaryContainer = Color(0xFFDCFCE7);
  static const Color onPrimary = Colors.white;

  // Pre-computed primary alpha variants
  static const Color primary08 = Color(0x1416A34A);
  static const Color primary12 = Color(0x1F16A34A);
  static const Color primary20 = Color(0x3316A34A);
  static const Color primary35 = Color(0x5916A34A);

  // ── Secondary ─────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryContainer = Color(0xFFE0F2FE);
  static const Color onSecondary = Colors.white;
  static const Color secondary10 = Color(0x1A0EA5E9);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);

  // ── Neutrals ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color onSurface = Color(0xFF111827);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color onSurfaceMuted = Color(0xFF9CA3AF);
  static const Color outline = Color(0xFFE5E7EB);
  static const Color outlineFocus = Color(0xFF16A34A);

  // ── Category Colors ───────────────────────────────────────────────────────
  static const Color garbage = Color(0xFF16A34A);
  static const Color pothole = Color(0xFF92400E);
  static const Color waterLeakage = Color(0xFF0369A1);
  static const Color streetlight = Color(0xFFD97706);
  static const Color other = Color(0xFF6B7280);

  // Pre-computed category alpha variants
  static const Color garbage10 = Color(0x1A16A34A);
  static const Color pothole10 = Color(0x1A92400E);
  static const Color waterLeakage10 = Color(0x1A0369A1);
  static const Color streetlight10 = Color(0x1AD97706);
  static const Color other10 = Color(0x1A6B7280);

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

  // ── Shadows — kept minimal for performance ────────────────────────────────
  // Use these only on non-scrolling surfaces (headers, FABs, modals).
  // Never apply boxShadow to ListView/GridView items.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000), // 4% black — very subtle
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: Color(0x5916A34A),
      blurRadius: 14,
      offset: Offset(0, 5),
    ),
  ];
}

import 'package:flutter/material.dart';

/// SpotIt Design System - Colors
/// Semantic palette for consistency & accessibility
class AppColors {
  // Primary Brand
  static const Color primary = Color(0xFF166534); // Deep Green
  static const Color primaryContainer = Color(0xFFCDDAC5);
  static const Color onPrimary = Colors.white;

  // Secondary
  static const Color secondary = Color(0xFF22C55E); // Lime Green
  static const Color secondaryContainer = Color(0xFFCDF3D2);

  // Semantic
  static const Color success = Color(0xFF166534);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Neutrals
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF334155);

  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineVariant = Color(0xFFD1D5DB);

  // Elevation overlays (Material 3)
  static Color surfaceShadow(Color surfaceColor, double elevation) {
    // Implementation based on Material 3 tonal elevation
    return surfaceColor;
  }
}

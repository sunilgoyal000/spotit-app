import 'package:flutter/material.dart';

/// SpotIt Typography Scale
/// 8pt scale following Material 3 guidelines
class AppTypography {
  // Display
  static TextStyle get displayLarge => TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.1,
      );

  static TextStyle get displayMedium => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.2,
      );

  // Headlines
  static TextStyle get headlineLarge => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.2,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.2,
      );

  // Titles
  static TextStyle get titleLarge => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600, // semibold
        letterSpacing: 0,
        height: 1.3,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.4,
      );

  // Body
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.4,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
      );

  // Labels
  static TextStyle get labelLarge => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500, // medium
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
      );

  static const String fontFamily = 'Inter'; // or Google Fonts
}

import 'package:app_ui/src/typography/app_font_weight.dart';
import 'package:flutter/material.dart';

/// The Material 3 type scale.
///
/// See: https://m3.material.io/styles/typography/type-scale-tokens
abstract class AppTextStyle {
  static const TextStyle _baseTextStyle = TextStyle(
    fontWeight: AppFontWeight.w400,
    decoration: TextDecoration.none,
  );

  /// Display large, 57/64.
  static final TextStyle displayLarge = _baseTextStyle.copyWith(
    fontSize: 57,
    height: 64 / 57,
    letterSpacing: -0.25,
  );

  /// Display medium, 45/52.
  static final TextStyle displayMedium = _baseTextStyle.copyWith(
    fontSize: 45,
    height: 52 / 45,
  );

  /// Display small, 36/44.
  static final TextStyle displaySmall = _baseTextStyle.copyWith(
    fontSize: 36,
    height: 44 / 36,
  );

  /// Headline large, 32/40.
  static final TextStyle headlineLarge = _baseTextStyle.copyWith(
    fontSize: 32,
    height: 40 / 32,
  );

  /// Headline medium, 28/36.
  static final TextStyle headlineMedium = _baseTextStyle.copyWith(
    fontSize: 28,
    height: 36 / 28,
  );

  /// Headline small, 24/32.
  static final TextStyle headlineSmall = _baseTextStyle.copyWith(
    fontSize: 24,
    height: 32 / 24,
  );

  /// Title large, 22/28.
  static final TextStyle titleLarge = _baseTextStyle.copyWith(
    fontSize: 22,
    height: 28 / 22,
  );

  /// Title medium, 16/24.
  static final TextStyle titleMedium = _baseTextStyle.copyWith(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: AppFontWeight.w500,
    letterSpacing: 0.15,
  );

  /// Title small, 14/20.
  static final TextStyle titleSmall = _baseTextStyle.copyWith(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: AppFontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Body large, 16/24.
  static final TextStyle bodyLarge = _baseTextStyle.copyWith(
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.5,
  );

  /// Body medium, 14/20.
  static final TextStyle bodyMedium = _baseTextStyle.copyWith(
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.25,
  );

  /// Body small, 12/16.
  static final TextStyle bodySmall = _baseTextStyle.copyWith(
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.4,
  );

  /// Label large, 14/20.
  static final TextStyle labelLarge = _baseTextStyle.copyWith(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: AppFontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Label medium, 12/16.
  static final TextStyle labelMedium = _baseTextStyle.copyWith(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: AppFontWeight.w500,
    letterSpacing: 0.5,
  );

  /// Label small, 11/16.
  static final TextStyle labelSmall = _baseTextStyle.copyWith(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: AppFontWeight.w500,
    letterSpacing: 0.5,
  );

  /// The full [TextTheme] built from this type scale, for use in [ThemeData].
  static final TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}

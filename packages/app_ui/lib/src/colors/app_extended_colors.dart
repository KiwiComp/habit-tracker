import 'package:flutter/material.dart';

/// Custom design tokens that don't fit [ColorScheme]'s fixed set of slots.
@immutable
class AppExtendedColors extends ThemeExtension<AppExtendedColors> {
  /// Creates an [AppExtendedColors].
  const AppExtendedColors({required this.accent});

  /// The light variant.
  static const AppExtendedColors light = AppExtendedColors(
    accent: Color(0xFFB6244F),
  );

  /// The dark variant.
  static const AppExtendedColors dark = AppExtendedColors(
    accent: Color(0xFFB6244F),
  );

  /// The accent color.
  final Color accent;

  @override
  AppExtendedColors copyWith({Color? accent}) {
    return AppExtendedColors(accent: accent ?? this.accent);
  }

  @override
  AppExtendedColors lerp(AppExtendedColors? other, double t) {
    if (other == null) return this;
    return AppExtendedColors(
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

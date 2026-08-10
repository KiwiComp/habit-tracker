import 'package:flutter/material.dart';

/// Custom design tokens that don't fit [ColorScheme]'s fixed set of slots.
@immutable
class AppExtendedColors extends ThemeExtension<AppExtendedColors> {
  /// Creates an [AppExtendedColors].
  const AppExtendedColors({
    required this.accent,
    required this.onAccent,
    required this.disabledBtn,
  });

  /// The light variant.
  static const AppExtendedColors light = AppExtendedColors(
    accent: Color(0xFFB6244F),
    onAccent: Color(0xFFFFFFFF),
    disabledBtn: Color(0xFFD0D3C8),
  );

  /// The dark variant.
  static const AppExtendedColors dark = AppExtendedColors(
    accent: Color(0xFFB6244F),
    onAccent: Color(0xFFFFFFFF),
    disabledBtn: Color.fromARGB(255, 154, 156, 149),
  );

  /// The accent color.
  final Color accent;

  /// The color for content (text, icons) drawn on top of [accent].
  final Color onAccent;

  /// The disabled button color.
  final Color disabledBtn;

  @override
  AppExtendedColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? disabledBtn,
  }) {
    return AppExtendedColors(
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      disabledBtn: disabledBtn ?? this.disabledBtn,
    );
  }

  @override
  AppExtendedColors lerp(AppExtendedColors? other, double t) {
    if (other == null) return this;
    return AppExtendedColors(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      disabledBtn: Color.lerp(disabledBtn, other.disabledBtn, t)!,
    );
  }
}

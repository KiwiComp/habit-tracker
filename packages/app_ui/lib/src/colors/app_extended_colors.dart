import 'package:flutter/material.dart';

/// Custom design tokens that don't fit [ColorScheme]'s fixed set of slots.
@immutable
class AppExtendedColors extends ThemeExtension<AppExtendedColors> {
  /// Creates an [AppExtendedColors].
  const AppExtendedColors({
    required this.accent,
    required this.onAccent,
    required this.disabledBtn,
    required this.taskTile,
    required this.habitTile,
  });

  /// The light variant.
  static const AppExtendedColors light = AppExtendedColors(
    accent: Color(0xFFB6244F),
    onAccent: Color(0xFFFFFFFF),
    disabledBtn: Color(0xFFD0D3C8),
    taskTile: Color(0xFFDAE3DA),
    habitTile: Color(0xFF87A39E),
  );

  /// The dark variant.
  static const AppExtendedColors dark = AppExtendedColors(
    accent: Color(0xFFB6244F),
    onAccent: Color(0xFFFFFFFF),
    disabledBtn: Color.fromARGB(255, 154, 156, 149),
    taskTile: Color(0xFFDAE3DA),
    habitTile: Color(0xFF87A39E),
  );

  /// The accent color.
  final Color accent;

  /// The color for content (text, icons) drawn on top of [accent].
  final Color onAccent;

  /// The disabled button color.
  final Color disabledBtn;

  final Color taskTile;

  final Color habitTile;

  @override
  AppExtendedColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? disabledBtn,
    Color? taskTile,
    Color? habitTile,
  }) {
    return AppExtendedColors(
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      disabledBtn: disabledBtn ?? this.disabledBtn,
      taskTile: taskTile ?? this.taskTile,
      habitTile: habitTile ?? this.habitTile,
    );
  }

  @override
  AppExtendedColors lerp(AppExtendedColors? other, double t) {
    if (other == null) return this;
    return AppExtendedColors(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      disabledBtn: Color.lerp(disabledBtn, other.disabledBtn, t)!,
      taskTile: Color.lerp(taskTile, other.taskTile, t)!,
      habitTile: Color.lerp(habitTile, other.habitTile, t)!,
    );
  }
}

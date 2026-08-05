import 'package:app_ui/src/colors/app_extended_colors.dart';
import 'package:app_ui/src/icon_size/app_icon_size.dart';
import 'package:app_ui/src/radius/app_radius.dart';
import 'package:app_ui/src/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

/// Convenience getters for reaching theme data from a [BuildContext].
extension AppContextExtension on BuildContext {
  /// The [AppExtendedColors] registered on the current [Theme].
  AppExtendedColors get extendedColors =>
      Theme.of(this).extension<AppExtendedColors>()!;

  /// The [ColorScheme] of the current [Theme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Whether the current [Theme] is rendering with [Brightness.dark].
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// The app's spacing scale.
  AppSpacing get spacing => const AppSpacing();

  /// The app's corner radius scale.
  AppRadius get radius => const AppRadius();

  /// The app's icon size scale.
  AppIconSize get iconSize => const AppIconSize();
}

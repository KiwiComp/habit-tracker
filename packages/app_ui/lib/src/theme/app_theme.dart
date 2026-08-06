import 'package:app_ui/src/colors/app_extended_colors.dart';
import 'package:app_ui/src/colors/colors.dart';
import 'package:app_ui/src/typography/app_text_style.dart';
import 'package:flutter/material.dart';

sealed class AppTheme {
  const AppTheme();

  const factory AppTheme.light() = _LightTheme;
  const factory AppTheme.dark() = _DarkTheme;

  AppColors get _colors;

  ColorScheme get _colorScheme {
    return ColorScheme.fromSeed(
      seedColor: _colors.seed,
      brightness: _colors.brightness,
      // DynamicSchemeVariant.fidelity if the brand color must survive exactly
    ).copyWith(
      primary: _colors.primary,
    );
  }

  ThemeData get themeData {
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: _colorScheme,
      textTheme: AppTextStyle.textTheme,
      extensions: [
        if (_colors.brightness == Brightness.light)
          AppExtendedColors.light
        else
          AppExtendedColors.dark,
      ],
    );
  }
}

final class _LightTheme extends AppTheme {
  const _LightTheme();
  @override
  AppColors get _colors => const LightAppColors();
}

final class _DarkTheme extends AppTheme {
  const _DarkTheme();
  @override
  AppColors get _colors => const DarkAppColors();
}

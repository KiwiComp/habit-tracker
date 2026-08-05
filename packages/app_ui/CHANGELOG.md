# Changelog

## 0.1.0+1

- Add `AppTheme` with light and dark `ThemeData`, built from `ColorScheme.fromSeed`.
- Add `AppColors`, `LightAppColors`, and `DarkAppColors` for brightness-specific color values.
- Add `AppExtendedColors`, a `ThemeExtension` for custom colors outside `ColorScheme`.
- Add `AppTextStyle` and `AppFontWeight`, following the Material 3 type scale.
- Add `AppSpacing`, `AppRadius`, and `AppIconSize` token scales.
- Add `AppContextExtension` for convenient `BuildContext` access to theme tokens (`colorScheme`, `extendedColors`, `isDarkMode`, `spacing`, `radius`, `iconSize`).

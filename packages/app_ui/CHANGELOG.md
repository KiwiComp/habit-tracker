# Changelog

## 0.1.0+3

- Add `initialValue` to `AppTextField`, to pre-fill the field when editing existing text.

## 0.1.0+2

- Add `onAccent` to `AppExtendedColors` for content drawn on top of `accent`-colored surfaces.

## 0.1.0+1

- Add `AppTheme` with light and dark `ThemeData`, built from `ColorScheme.fromSeed`.
- Add `AppColors`, `LightAppColors`, and `DarkAppColors` for brightness-specific color values.
- Add `AppExtendedColors`, a `ThemeExtension` for custom colors outside `ColorScheme`.
- Add `AppTextStyle` and `AppFontWeight`, following the Material 3 type scale.
- Add `AppSpacing`, `AppRadius`, and `AppIconSize` token scales.
- Add `AppContextExtension` for convenient `BuildContext` access to theme tokens (`colorScheme`, `extendedColors`, `isDarkMode`, `spacing`, `radius`, `iconSize`).

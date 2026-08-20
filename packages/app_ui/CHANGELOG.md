# Changelog

## 0.1.0+6

- Add `TaskAndHabitListEmptyView`, a shared empty-state view (`title`/`text`) shown by `HabitsListPage`/`TasksListPage` when their list has no items.

## 0.1.0+5

- Add `pickEndDate`, a shared "pick an end date, or clear it" flow (a "Never / pick a date" bottom sheet, skipped in favor of opening the calendar directly when there's no current end date to offer clearing) — used by both the create-activity end-date field and `HabitPage`'s end-date edit.
- Add `showConfirmationDialog`, a generic yes/no confirmation dialog (`message`/`yesLabel`/`noLabel`), replacing the app-level `ArchiveConfirmationDialog`.
- Add `showEditNameDialog`, a dialog for editing a name (`label`/`hint`/`saveButtonLabel`, pre-filled with the current value), replacing the app-level `EditNameDialog`.

## 0.1.0+4

- Add `WeekdayChipRow`, a row of seven toggleable weekday chips (pass `onToggled: null` for a read-only display).

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

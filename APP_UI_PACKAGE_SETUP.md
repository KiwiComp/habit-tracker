# app_ui package — setup instructions

This file is a blueprint for creating an `app_ui` design-system package (theming, colors,
typography, and layout tokens) inside a Flutter workspace, before the package exists. Follow it to
scaffold `packages/app_ui` from scratch, consistent with how this pattern has been built before.

`app_ui` must have no dependency on `bloc`/state-management packages and no app-specific logic —
it is pure design tokens and theming, nothing else.

## Package setup

Create it as a normal Flutter package (e.g. via `very_good_cli`'s package template, or by hand)
at `packages/app_ui`, added to the root `pubspec.yaml` workspace, and depended on by the app.

`packages/app_ui/analysis_options.yaml` should mirror whatever lint rules the repo root uses —
check the root `analysis_options.yaml` first and match its rule overrides (e.g. if the root
disables `public_member_api_docs`, disable it here too). Do **not** copy `include:` entries for
packages `app_ui` doesn't depend on (e.g. `bloc_lint`) — an include with no matching dev dependency
breaks `dart analyze`.

`packages/app_ui/CHANGELOG.md` must exist from the start (see "CHANGELOG discipline" below).

## Public API architecture

`lib/app_ui.dart` is the **only** file consumers should import
(`import 'package:app_ui/app_ui.dart';`). Everything under `lib/src/` is an implementation detail
unless deliberately re-exported. For every new file under `src/`, explicitly decide whether it
belongs in the public surface — don't export something just because the class itself is public.

Export rules:
- Give a folder its own barrel file (`folder_name.dart`, exporting the folder's other files) only
  once it holds 2+ files that all need exporting.
  ```dart
  // lib/src/colors/colors.dart
  export 'app_colors.dart';
  export 'dark_app_colors.dart';
  export 'light_app_colors.dart';
  ```
- A folder with a single file is exported directly from `app_ui.dart` — no barrel:
  ```dart
  // lib/app_ui.dart
  export 'src/theme/app_theme.dart';
  export 'src/extensions/app_context_extension.dart';
  ```
- Internal-only classes (see `AppColors` below) are deliberately **not** exported from
  `app_ui.dart`, even though other files inside the package import them directly via their full
  `package:app_ui/src/...` path. A folder-level barrel can still exist purely for that internal
  convenience without ever being re-exported at the top level.

## Core pieces to build, in order

### 1. `colors/` — brightness-specific colors (internal only)

Define an abstract interface with one getter per `ColorScheme` slot you intend to pin explicitly,
plus `brightness` and `seed`:

```dart
// lib/src/colors/app_colors.dart
abstract class AppColors {
  const AppColors();
  Brightness get brightness;
  Color get seed;
  Color get primary;
  // ...one getter per ColorScheme field you intend to override
}
```

Implement one concrete class per brightness (`LightAppColors`, `DarkAppColors`). Any value defined
here needs a **different** value per brightness — a color tuned for a light surface will usually
have wrong contrast on a dark one, and vice versa; never reuse the identical hex in both.

Do not export any of these three types from `app_ui.dart`. They're `AppTheme`'s internal building
blocks; consumers should never construct them directly or bypass `AppTheme.light()`/`.dark()`.

### 2. `theme/app_theme.dart` — `AppTheme` (exported)

A sealed class with `light()`/`dark()` const factories, building `ThemeData` from a seed color
plus targeted overrides:

```dart
sealed class AppTheme {
  const AppTheme();
  const factory AppTheme.light() = _LightTheme;
  const factory AppTheme.dark() = _DarkTheme;

  AppColors get _colors;

  ColorScheme get _colorScheme => ColorScheme.fromSeed(
        seedColor: _colors.seed,
        brightness: _colors.brightness,
      ).copyWith(
        primary: _colors.primary, // only override colors with a pinned brand value
      );

  ThemeData get themeData => ThemeData(
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
```

Key rule: only add a field to `copyWith` when there's a concrete reason to lock it to an exact
hex. Everything left out stays as the seed-derived, brightness-adapted, contrast-safe value —
that's the entire benefit of using `fromSeed` over hand-authoring a full `ColorScheme`.

### 3. `colors/app_extended_colors.dart` — custom colors beyond `ColorScheme` (exported)

`ColorScheme` is a fixed set of fields and cannot be extended. For any brand color that doesn't
map to an existing slot (a semantic "success" or "streak" color, for example), use a
`ThemeExtension`:

```dart
@immutable
class AppExtendedColors extends ThemeExtension<AppExtendedColors> {
  const AppExtendedColors({required this.accent});

  final Color accent;

  static const light = AppExtendedColors(accent: Color(0xFF000000)); // project-specific
  static const dark = AppExtendedColors(accent: Color(0xFF000000)); // project-specific

  @override
  AppExtendedColors copyWith({Color? accent}) =>
      AppExtendedColors(accent: accent ?? this.accent);

  @override
  AppExtendedColors lerp(AppExtendedColors? other, double t) {
    if (other == null) return this;
    return AppExtendedColors(accent: Color.lerp(accent, other.accent, t)!);
  }
}
```
Register the right instance in `AppTheme.themeData`'s `extensions:` list (shown above). Never call
`Theme.of(context).extension<AppExtendedColors>()` from app code directly — always go through the
context extension (step 6).

### 4. `typography/` — `AppTextStyle`, `AppFontWeight` (exported)

Text metrics don't vary by brightness (only color does, and `ThemeData` already handles that via
its merge with `colorScheme`), so this is a **static class**, not a brightness-swapped pair:

```dart
abstract class AppFontWeight {
  static const w400 = FontWeight.w400;
  static const w500 = FontWeight.w500;
  // ...
}

abstract class AppTextStyle {
  static const _base = TextStyle(fontWeight: AppFontWeight.w400);

  // Follow the Material 3 type scale exactly:
  // https://m3.material.io/styles/typography/type-scale-tokens
  static final displayLarge = _base.copyWith(fontSize: 57, height: 64 / 57, letterSpacing: -0.25);
  // ...all 15 M3 type-scale styles (display/headline/title/body/label × large/medium/small)

  static final textTheme = TextTheme(displayLarge: displayLarge /* ... */);
}
```
Leave `fontFamily` unset until a custom font is chosen; when one is added, set it on `_base` and
register the font in this package's `pubspec.yaml`.

### 5. `spacing/`, `radius/`, `icon_size/` — token scales (exported)

Same reasoning as typography: not brightness-dependent, so a plain `const`-constructible class
with instance getters, one folder per scale:

```dart
class AppSpacing {
  const AppSpacing();
  double get xs => 4;
  double get sm => 8;
  double get md => 16;
  double get lg => 24;
  double get xl => 32;
  double get xxl => 48;
  double get xxxl => 64;
}
```
Base values on an established design-system convention and cite the source in a doc comment —
don't invent arbitrary numbers:
- **Spacing**: Material's 4dp grid.
- **Radius**: Material 3's shape scale (`none`/`extra-small`/`small`/`medium`/`large`/`extra-large`
  /`full`).
- **Icon size**: Material's standard icon sizes (18/24/36/48, with 24 as the default — it matches
  Flutter's own `Icon` widget default).

When a new scale is needed later (motion/duration, elevation, breakpoints, etc.), follow this same
shape: a small `const`-constructible class, named getters mapped to a cited convention, its own
single-file folder.

### 6. `extensions/app_context_extension.dart` — `AppContextExtension` (exported)

One `BuildContext` extension gathering every convenience accessor — this is the only place
`Theme.of(context)` should be called from within the package's public surface:

```dart
extension AppContextExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  AppExtendedColors get extendedColors =>
      Theme.of(this).extension<AppExtendedColors>()!;
  AppSpacing get spacing => const AppSpacing();
  AppRadius get radius => const AppRadius();
  AppIconSize get iconSize => const AppIconSize();
}
```
Every new `context.xyz` token getter is added here — don't scatter ad hoc `Theme.of(context)`
calls through app code.

## Conventions to carry through

- **Naming**: `App`-prefixed class names throughout (`AppTheme`, `AppColors`, `AppTextStyle`, ...).
  Token scales use t-shirt sizing (`xs`/`sm`/`md`/`lg`/`xl`/...).
- **Sequencing**: it's fine — often correct — to defer building actual reusable widgets
  (`AppButton`, `AppCard`, ...) and their tests until the app's visual design is settled. Don't add
  speculative components or tests ahead of that decision; building out the token layer first
  (colors, type, spacing, radius, icon size) is legitimate, load-bearing groundwork on its own.
  Component-level `ThemeData` entries (`ElevatedButtonThemeData`, `InputDecorationTheme`,
  `AppBarTheme`, etc.) fall into the same "defer until design is decided" bucket.

## CHANGELOG.md discipline

`packages/app_ui/CHANGELOG.md` must be kept current. Whenever anything under `packages/app_ui/`
changes (new token, new class, behavior change, bug fix), in the **same** change:
1. Add an entry describing it to `CHANGELOG.md`, newest section on top.
2. Bump the version in `packages/app_ui/pubspec.yaml` to match (patch for fixes, minor for
   additions, major for breaking changes — standard semver), using that version as the new
   changelog section's heading.

A version bump with no changelog entry, or a changelog entry with no version bump, is exactly the
inconsistency this convention exists to prevent — don't let either happen without the other.

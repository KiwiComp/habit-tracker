# Development

Day-to-day commands and workflows for working on this project. For what the
app does and how it is structured, start with the [README](../README.md); for
installing the toolchain and running the app, see its
[Getting started](../README.md#getting-started) section.

---

## Contents

- [Everyday commands](#everyday-commands)
  - [Tests and coverage](#tests-and-coverage)
  - [Static analysis](#static-analysis)
  - [Bloc lints](#bloc-lints)
  - [Database code generation](#database-code-generation)
  - [Localizations](#localizations)
- [Translations](#translations)
  - [Adding a string](#adding-a-string)
  - [Strings with values in them](#strings-with-values-in-them)
  - [Adding a locale](#adding-a-locale)

---

## Everyday commands

### Tests and coverage

```sh
very_good test --coverage --test-randomize-ordering-seed random
```

Run it in the root for the app's tests, or inside a package directory for that
package's own suite. To read the coverage report:

```sh
genhtml coverage/lcov.info -o coverage/ && open coverage/index.html
```

([lcov](https://github.com/linux-test-project/lcov) provides `genhtml`.)

### Static analysis

```sh
flutter analyze
```

Lints come from [`very_good_analysis`][very_good_analysis_link], with
`public_member_api_docs` off in the app and `lib/l10n/gen/` excluded.

### Bloc lints

[`bloc_lint`][bloc_lint_link] enforces bloc best practices on top of the
analyzer:

```sh
dart run bloc_tools:bloc lint .
```

The [official bloc extension][bloc_extension_link] surfaces the same warnings
inside VS Code.

### Database code generation

`habits_repository` uses Drift's code generator. After changing a table or the
database class, regenerate `database.g.dart`:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Run that inside `packages/habits_repository`. `drift_dev` is intentionally
pinned to `^2.33.0` — a newer version conflicts with the analyzer the rest of
the workspace resolves.

### Localizations

```sh
flutter gen-l10n --arb-dir="lib/l10n/arb"
```

`flutter run` also regenerates them automatically.

---

## Translations

The project follows Flutter's [official internationalization guide][internationalization_link],
using [ARB files][arb_documentation_link] in `lib/l10n/arb`:

```
lib/l10n/arb/
├── app_en.arb   # template (source language)
├── app_es.arb
└── app_sv.arb
```

Strings are reached through `context.l10n`, an extension on `BuildContext`
defined in `lib/l10n/l10n.dart`. Every user-facing string in the app goes
through it — none are hard-coded in widgets.

### Adding a string

1. Add the key, its English value, and a `description` to the template file,
   `lib/l10n/arb/app_en.arb`:

   ```arb
   "createActivitySaveButton": "Save",
   "@createActivitySaveButton": {
       "description": "Label for the button that saves the new habit/task"
   }
   ```

   Keys are prefixed with the feature that owns them — `start*`,
   `addActivity*`, `createActivity*`, `habitsList*`, `tasksList*`,
   `habitPage*`, `taskPage*` — with `common*` reserved for strings genuinely
   reused across features (`commonYes`, `commonNo`). The `description` is
   developer-facing documentation for whoever translates the string, so say
   where it appears, not what the word means.

2. Add the translated value to every other ARB file. Descriptions only need to
   exist in the template, so leave the `@key` blocks out of the other locales:

   `app_es.arb`:

   ```arb
   "createActivitySaveButton": "Guardar",
   ```

   `app_sv.arb`:

   ```arb
   "createActivitySaveButton": "Spara",
   ```

3. Regenerate (`flutter gen-l10n --arb-dir="lib/l10n/arb"`, or just
   `flutter run`) and use it:

   ```dart
   import 'package:habit_tracker/l10n/l10n.dart';

   @override
   Widget build(BuildContext context) {
     final l10n = context.l10n;
     return AppButton.primary(
       onPressed: _onSave,
       child: Text(l10n.createActivitySaveButton),
     );
   }
   ```

### Strings with values in them

Declare a `placeholders` block instead of concatenating strings, so each
language can put the value where its grammar needs it:

```arb
"habitsListTileCurrentStreak": "Current streak: {count}",
"@habitsListTileCurrentStreak": {
    "description": "Current streak count shown on a habit's row on the Habits tab",
    "placeholders": {
        "count": {
            "type": "int"
        }
    }
}
```

The generated getter becomes a method, taking the placeholder as an argument:

```dart
Text(l10n.habitsListTileCurrentStreak(stats.currentStreak))
```

### Adding a locale

Add an `app_<locale>.arb` file as above, then add the locale to the
`CFBundleLocalizations` array in `ios/Runner/Info.plist`:

```xml
<key>CFBundleLocalizations</key>
<array>
    <string>en</string>
    <string>es</string>
    <string>sv</string>
</array>
```

[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[bloc_lint_link]: https://pub.dev/packages/bloc_lint
[bloc_extension_link]: https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc
[internationalization_link]: https://docs.flutter.dev/ui/internationalization
[arb_documentation_link]: https://github.com/google/app-resource-bundle

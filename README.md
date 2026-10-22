# Habit Tracker

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

> **Status:** work in progress — the core flows work, but the app is not
> finished; what's deliberately left undone is listed in
> [KNOWN_GAPS.md](KNOWN_GAPS.md).

A Flutter app for building habits: create recurring habits and one-off tasks,
tick them off day by day, and watch your streaks grow. Everything is stored
locally on the device in SQLite — there is no account, no server, and no
network calls.

Built with [bloc][bloc_link] for state management, [go_router][go_router_link]
for navigation, and [Drift][drift_link] for persistence, split into a thin app
layer plus three local packages.

---

## Contents

- [What the app does](#what-the-app-does)
- [How it's put together](#how-its-put-together)
- [Project layout](#project-layout)
- [The data model](#the-data-model)
- [Getting started](#getting-started)
- [Continuous integration](#continuous-integration)
- [Further reading](#further-reading)

---

## What the app does

The app has three tabs behind a persistent bottom navigation bar.

### Today (`/`)

The home screen. A horizontal day selector runs across the top; below it is
the schedule for the selected day — every habit and task due that day,
calculated from each habit's own schedule rather than from stored rows.

- Tap a row to toggle it done (future days can't be ticked off).
- Drag a row to the left to reveal an **Open details** action.
- The floating action button adds a new activity, pre-filled with the day you
  are looking at. When you're not on today, a second button jumps you back.
- When nothing is due, an empty-state message takes the list's place.

### Habits (`/habits`)

Every recurring habit, each row showing its current and longest streak. Tap a
row to open its detail page.

### Tasks (`/tasks`)

The same, for one-off dated tasks.

### Creating an activity (`/create`)

A bottom sheet asks whether you're adding a **Habit** (repeats on a schedule)
or a **Task** (happens once), then opens the create page: name, repeat pattern
(every day / specific weekdays), start date, and an optional end date. The
form warns you if the weekdays you picked never fall inside the start–end
window, which would produce a habit that never occurs.

### Detail pages (`/habit/:id`, `/task/:id`)

Full-screen pages — they cover the bottom navigation bar — for renaming an
activity, changing its dates (start and end for a habit, the single date for a
task), and deleting it. "Delete" currently *archives*, so past completions
survive; see
[KNOWN_GAPS.md](KNOWN_GAPS.md).

### Throughout

- Light and dark themes, both driven by the `app_ui` design system.
- English, Spanish, and Swedish translations.
- Screen-reader labels, hints, and semantic actions on the interactive bits
  (the slide-to-reveal gesture has an accessible equivalent).

---

## How it's put together

### Pub workspace

The root `pubspec.yaml` declares a [pub workspace][workspace_link] with three
member packages, so the whole repo resolves against one shared lockfile and a
single `flutter pub get` at the root covers everything.

| Package | What it owns |
| --- | --- |
| [`packages/habits_repository`](packages/habits_repository) | All persistence. Drift/SQLite tables, the domain models (`Habit`, `Entry`, `Frequency`), and `HabitsRepository` as the only public entry point. The generated Drift row classes never leave `src/`. |
| [`packages/app_ui`](packages/app_ui) | The design system: colors, typography, spacing/radius/icon-size tokens, themes, and shared widgets (`AppButton`, `AppTextField`, dialogs, pickers). No bloc dependency and no app logic — tokens and widgets only. |
| [`packages/error_tracking`](packages/error_tracking) | One `ErrorTracking.init` entry point that catches Flutter framework errors and uncaught async errors and routes both through a single reporter. That reporter only logs to the console in debug mode so far; the point of the single funnel is that a real backend can replace it without touching a call site. |

### App layer (`lib/`)

One folder per feature, each with the same shape:

```
lib/start_page/
├── bloc/          # bloc, events, states, plus a bloc.dart barrel
├── view/          # the page widget
├── widgets/       # widgets used only by this feature
└── start_page.dart  # the feature's public barrel
```

The bloc reads `HabitsRepository` out of the widget tree (a
`RepositoryProvider` in `App` owns the single instance) and exposes state the
views select from. `lib/habit_stats.dart` is the one piece of app-level
domain logic: it derives completion counts and streaks from a habit's schedule
and its entries.

### Navigation

`go_router` with a `StatefulShellRoute.indexedStack`: the three tabs are shell
branches, each keeping its own navigation stack, while the create and detail
routes sit on the root navigator so they cover the bottom bar.
[docs/ROUTING.md](docs/ROUTING.md) explains the route graph and why this shape was
chosen.

### Startup

Each flavor's `main_*.dart` calls `bootstrap(environment: ..., builder: ...)`,
which initializes `ErrorTracking`, installs `AppBlocObserver`, and runs the
app.

---

## Project layout

```
.
├── lib/
│   ├── app/                 # App widget, bloc observer
│   ├── bootstrap.dart       # shared startup for all flavors
│   ├── create_activity/     # new habit/task form
│   ├── habit_page/          # habit detail page
│   ├── habit_stats.dart     # completion + streak calculations
│   ├── habits_list/         # Habits tab
│   ├── l10n/                # ARB files and generated localizations
│   ├── main_development.dart
│   ├── main_production.dart
│   ├── main_staging.dart
│   ├── routing/             # go_router setup and the tab shell
│   ├── start_page/          # Today tab
│   ├── task_page/           # task detail page
│   ├── tasks_list/          # Tasks tab
│   └── widgets/             # widgets shared across features
├── packages/
│   ├── app_ui/
│   ├── error_tracking/
│   └── habits_repository/
├── test/                    # follows lib/'s structure
├── docs/
│   ├── development.md       # commands and translation workflow
│   ├── ROUTING.md           # the navigation model
│   └── plans/               # the briefs the code was built against
├── android/  ios/           # the supported platforms
├── macos/  web/  windows/   # unused Very Good CLI scaffolding
└── KNOWN_GAPS.md            # deferred work and accepted gaps
```

`test/` follows `lib/`'s structure, and every file that holds logic has
tests — most with their own `_test.dart` at the mirrored path. The files with
none are the barrels, the bloc event classes (plain data carriers), the
generated localizations, and the entry points, `bootstrap.dart` and
`main_*.dart`. Each package keeps its own `test/` folder on the same terms,
with a few small helpers — `date_only.dart`, `app_button_style.dart` —
covered through the tests of their callers rather than directly.

---

## The data model

Two tables, and one idea worth knowing before reading the code:

**A `Habit` describes only a schedule.** Whether it was done on a given day is
a separate `Entry` row — the row's *existence* is the completion, so there is
no `completed` flag to keep in sync. Nothing is ever written ahead of time:
the calendar is rendered by asking each habit `isScheduledOn(date)`.

```dart
class Habit {
  final String id;
  final String name;
  final Frequency frequency;   // daily | weekdays | once
  final Set<int> weekdays;     // DateTime.monday (1) .. DateTime.sunday (7)
  final DateTime startDate;    // local midnight
  final DateTime? endDate;     // inclusive; null = never ends
  final DateTime? archivedAt;  // set instead of deleting
  final DateTime createdAt;
}

class Entry {
  final String id;
  final String habitId;
  final DateTime date;         // the calendar day, local midnight
  final DateTime createdAt;
}
```

A `Frequency.once` habit is what the app calls a **task** — same table, same
model, `isTask` just asks whether the frequency is `once`.

`HabitsRepository` is the whole storage API: `watchHabits`, `getHabit`,
`createHabit`, `updateHabit`, `archiveHabit`, `unarchiveHabit`, `deleteHabit`,
`watchEntries`, `getEntries`, `watchAllEntries`, `watchEntriesOnDate`,
`logEntry`, and `unlogEntry`. Logging is idempotent, enforced by a unique
index on (habit, date), and deleting a habit cascades to its entries.

---

## Getting started

### Prerequisites

- Flutter `3.47.x` (Dart SDK `^3.13.0`) — see `environment` in `pubspec.yaml`
- Xcode and/or Android Studio for the mobile toolchains
- [Very Good CLI][very_good_cli_link] (`dart pub global activate very_good_cli`),
  used for the test commands in [docs/development.md](docs/development.md)

### Install

```sh
flutter pub get
```

Run it at the repo root — the workspace resolves every package at once.

### Run

The app has three flavors: **development**, **staging**, and **production**.
Use the launch configurations in VS Code / Android Studio, or:

```sh
flutter run --flavor development --target lib/main_development.dart
```

```sh
flutter run --flavor staging --target lib/main_staging.dart
```

```sh
flutter run --flavor production --target lib/main_production.dart
```

iOS and Android are the supported targets. The `web/`, `windows/`, and
`macos/` folders are leftover Very Good CLI scaffolding and are not
maintained.

### Next

Day-to-day work — running the tests, the analyzer and the bloc lints,
regenerating the Drift database code, and adding or translating strings — is
covered in [docs/development.md](docs/development.md).

---

## Continuous integration

GitHub Actions runs [Very Good Workflows][very_good_workflows_link] on every
pull request and push to `main`:

- **One build job per tested package** (`build-app`, `build-habits-repository`,
  `build-app-ui`, `build-error-tracking`) — each formats, analyzes, tests, and
  enforces its own coverage floor, with generated code excluded from the
  denominator.
- **Semantic pull request** — PR titles must follow
  [Conventional Commits][conventional_commits_link].
- **Spell check** on every Markdown file.

Each coverage floor is the level the finished package should hold, chosen
rather than lowered to match whatever coverage happened to be — all four are
met. The reasoning is recorded in [KNOWN_GAPS.md](KNOWN_GAPS.md).

---

## Further reading

### Reference

| Document | What's in it |
| --- | --- |
| [docs/development.md](docs/development.md) | Everyday commands (tests, analysis, bloc lints, code generation) and how to add strings, translations, and locales. |
| [KNOWN_GAPS.md](KNOWN_GAPS.md) | Deliberately deferred work and accepted gaps, with the reason for each. Read this before picking up new work. |
| [docs/ROUTING.md](docs/ROUTING.md) | The navigation design record: route graph, why `go_router` + `StatefulShellRoute`, the two call-site rules, and how each route loads its data. It states the agreed model, which may run ahead of the code. |

### Implementation plans (`docs/plans/`)

Specs written up front and handed to an AI coding agent to build against:
the target end state, the conventions to hold to, and how to verify the
result. They record how the work was specified rather than track the code, so
the code wins where the two differ. `CREATE_PACKAGE.md` is the live one — a
standing checklist for every new package.

| Plan | What it specifies |
| --- | --- |
| [docs/plans/APP_UI_PACKAGE_SETUP.md](docs/plans/APP_UI_PACKAGE_SETUP.md) | Building `packages/app_ui` from nothing: its export rules and public-API boundary, what to build in which order, and the rule that it may hold no bloc dependency and no app logic. |
| [docs/plans/ERROR_TRACKING.md](docs/plans/ERROR_TRACKING.md) | Building `packages/error_tracking`: why the `flutter_package` template rather than `dart_package`, the two error sources `ErrorTracking.init` has to cover, and how to test it. |
| [docs/plans/BOOTSTRAP.md](docs/plans/BOOTSTRAP.md) | Rewiring the generated `bootstrap.dart` onto `error_tracking`: the scaffold it starts from, the target end state, why the `builder` callback is kept rather than replaced, and how to verify. |
| [docs/plans/CREATE_PACKAGE.md](docs/plans/CREATE_PACKAGE.md) | The six steps for adding any new package to the workspace, from `very_good create` through resolving the shared lockfile. |

---

## License

MIT — see [LICENSE](LICENSE).

[bloc_link]: https://bloclibrary.dev
[drift_link]: https://drift.simonbinder.eu
[go_router_link]: https://pub.dev/packages/go_router
[workspace_link]: https://dart.dev/tools/pub/workspaces
[conventional_commits_link]: https://www.conventionalcommits.org
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli

# TODO

Known, accepted gaps and follow-ups — things we've deliberately deferred
rather than issues we've missed. Check this file when picking up new work,
and add an entry here (with a short reason) whenever you knowingly leave
something unfinished instead of just moving on.

## App icons

`ios/Runner/Assets.xcassets/AppIcon*.appiconset` are placeholder solid-color
icons (generated 2026-08-06 to unblock `flutter run` on the simulator — the
Very Good CLI scaffolding never had real icons for any flavor). Replace with
real branded icons before installing on a physical device outside debug, or
before any store submission.

## App/bundle identifiers

Android `applicationId` (`android/app/build.gradle.kts`) and the iOS bundle
identifier are still the Very Good CLI placeholder
(`com.example.verygoodcore.habit_tracker`). Fine for now; revisit before
real device distribution, store submission, or setting up a Firebase
project (Firebase config is tied to this identifier).

## CI coverage threshold

Coverage is at the implicit default of 100% (from
`VeryGoodOpenSource/very_good_workflows`'s reusable workflow) but actual
coverage is ~77%, driven by untested getters in `AppSpacing`/`AppRadius`/
`AppIconSize`/`AppExtendedColors`/`AppContextExtension`. Either write tests
for those or explicitly set a lower `min_coverage` once that's a deliberate
decision.

## No habit/task creation flow

The start page's FAB opens `AddActivitySheet`
(`lib/add_activity/view/add_activity_sheet.dart`) with tappable "Habit" and
"Task" options. Tapping either dispatches an event into `AddActivityBloc`
(`lib/add_activity/bloc`), which records the choice in
`AddActivityState.selectedType` — but nothing reads that state yet. There's
no habit/task creation form, and no wiring to `packages/habits_repository`.
Build that flow (and consume `selectedType` to open it) once the creation
UI/UX is decided.

## Habits tab

The bottom nav on the start screen (`lib/start_page/view/start_page.dart`)
shows a "Habits" destination, but there's no Habits page or route behind it
yet — tapping it currently does nothing.

## No real activity data source

`StartBloc` can hold and render scheduled activities (`StartState.activities`,
`StartActivitiesLoaded` event, `ScheduleList` widget in
`lib/start_page/widgets/schedule_list.dart`), but nothing populates it yet.
`packages/habits_repository` (Drift/SQLite-backed, exposing `Habit`/`Entry`)
now exists, but `StartBloc` isn't wired to it — the empty state still always
shows until something constructs a `HabitsRepository` and dispatches
`StartActivitiesLoaded` from its streams. `ScheduleList`'s visuals are also a
functional placeholder (no design reference for it yet, unlike
`EmptySchedule`/`DayChip`).

## habits_repository coverage gap

Coverage is dragged down by Drift's generated `database.g.dart` (~27%,
boilerplate no one hand-writes tests against) and by `HabitsTable`/
`EntriesTable` column getters showing as unhit despite being exercised
indirectly through `HabitsRepository`'s tests — the same
"untested getters" shape as the `CI coverage threshold` entry above, just in
a different package. Worth a `min_coverage` decision (and possibly excluding
`*.g.dart`) alongside that one rather than solving it separately.

## Leftover counter boilerplate

`lib/counter/` and `test/counter/` are the original Very Good CLI example
feature. `App` no longer renders `CounterPage` (it renders `StartPage`), so
this is now dead code — remove it, along with the unused `counterAppBarTitle`
string in `lib/l10n/arb/app_en.arb` / `app_es.arb`, once it's no longer
useful as a bloc/test-structure reference.

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

## Habit/task creation flow isn't tested

`CreateActivityBloc`'s `CreateActivitySaveRequested` handler now persists via
`HabitsRepository.createHabit` (which accepts `endDate`), and a
`HabitsRepository` is provided app-wide via `RepositoryProvider` in
`lib/app/view/app.dart` — also used by `StartBloc` (see "Activity/
ScheduleList still placeholder shapes" below). Neither the bloc's save/error
path nor the `endDate` addition has its own test yet, deferred alongside the
rest of `create_activity`'s test suite. Write these together once
`create_activity` gets a test pass.

## No behavior defined for a habit whose end date has passed

`Habit.endDate` (optional, inclusive) exists and `isScheduledOn` correctly
excludes a habit from any date after it, but nothing else reacts to it.
`HabitsRepository.watchHabits()` filters on `archivedAt`, not `endDate`, so
an ended-but-unarchived habit stays in the default (non-archived) result set
indefinitely — indistinguishable from a live habit at the query level.

This is deliberate so far, not an oversight: `endDate` (a scheduled
property) and `archivedAt` (a user action with a timestamp) are kept
orthogonal rather than having one write the other, since collapsing them
would mean either a background job writing `archivedAt` when a date passes
(no trigger mechanism exists for that) or `archivedAt` meaning two different
things depending on how it got set. But *something* still needs to decide
"is this habit finished" once a habits-list UI exists — e.g. a read-time
check like `archivedAt != null || (endDate != null &&
endDate.isBefore(today))`. Note that check is relative to "today", and a
Drift `Stream` query has no reason to re-emit when midnight passes on its
own — whatever implements this needs to either re-run the query or
recompute at the UI layer, not rely on the stream alone.

Flagged, not decided: whether an ended habit should disappear from the main
list, move to a distinct archived/ended section, or stay visible with its
history and streak stats intact.

## Habits tab

The bottom nav on the start screen (`lib/start_page/view/start_page.dart`)
shows a "Habits" destination, but there's no Habits page or route behind it
yet — tapping it currently does nothing.

## Activity/ScheduleList still placeholder shapes

`StartBloc` now watches `HabitsRepository.watchHabits()` and maps whatever's
due on the selected day (via `Habit.isScheduledOn`) into `StartState`, so
real habits/tasks show up on the start page. Two things are still
placeholder, though:

- `Activity` (`lib/start_page/models/activity.dart`) only carries
  `id`/`title`/`date` — `Habit` has no time-of-day, so every mapped
  `Activity` gets midnight and `ScheduleList`'s `DateFormat.Hm()` always
  shows 00:00. There's also no completion state shown (a `Habit` being
  scheduled vs. actually logged via an `Entry` are different things —
  `watchEntries`/`watchEntriesOnDate` aren't consulted yet).
- `ScheduleList`'s visuals are still a functional placeholder (no design
  reference for it yet, unlike `EmptySchedule`/`DayChip`) — revisit both
  points above once one exists; the mapping in `StartBloc` will likely need
  to change shape alongside it (e.g. carrying a `Habit`/`Entry` pair instead
  of the flattened `Activity`).
- See "No behavior defined for a habit whose end date has passed" above —
  that entry is about a habits-*list* view, not this one; `isScheduledOn`
  (which `StartBloc` uses) already excludes an ended habit correctly.

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

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

## Habits tab — resolved 2026-08-11

Resolved by the `go_router` migration (`ROUTING.md`): the bottom nav now
lives in `lib/routing/widgets/shell_scaffold.dart`, with a real third
`Tasks` destination alongside it, and `Habits`/`Tasks` tap through to
`HabitsListPage`/`TasksListPage` (routes `/habits`/`/tasks`). Both list
pages are still functional placeholders — a bare `ListTile` per habit/task,
name-only — same caveat as `ScheduleList` below; revisit once a design
exists.

## ScheduleList still has placeholder gaps

`StartBloc` now watches `HabitsRepository.watchHabits()` and maps whatever's
due on the selected day (via `Habit.isScheduledOn`) directly into
`StartState.activities: List<Habit>` — the old flattened `Activity`
placeholder model (`lib/start_page/models/activity.dart`) was removed
(2026-08-09) once every consumer worked with `Habit` directly instead. Two
things are still placeholder, though:

- `Habit` has no time-of-day, so `ScheduleList` shows the same
  `selectedDate` (formatted via `DateFormat.Hm()`, always 00:00) next to
  every row instead of a per-item time. There's also no completion state
  shown — a `Habit` being scheduled vs. actually logged via an `Entry` are
  different things, and `watchEntries`/`watchEntriesOnDate` aren't consulted
  yet.
- `ScheduleList`'s visuals are still a functional placeholder (no design
  reference for it yet, unlike `EmptySchedule`/`DayChip`) — revisit the
  point above once one exists.
- See "No behavior defined for a habit whose end date has passed" above —
  that entry is about a habits-*list* view, not this one; `isScheduledOn`
  (which `StartBloc` uses) already excludes an ended habit correctly.

## ScheduleList items aren't tappable yet — resolved 2026-08-11

Resolved by the `go_router` migration (`ROUTING.md`): each `ScheduleList`
row now pushes `/habit/:id` or `/task/:id` (chosen via the new `Habit.isTask`
helper), landing on `HabitPage`/`TaskPage`. Those load by a **one-shot**
`HabitsRepository.getHabit(id)` rather than a `watchHabit(id)` stream — a
deliberate choice, not an oversight: the page is a full-screen modal, so
it's the only possible writer of the habit while open, and a tapped
notification (planned) opens the app cold with only an id, which a static
`extra` payload can't serve. See `ROUTING.md`'s "Data loading" section for
the full reasoning.

Both pages are still stubs — they confirm the *right* entity loaded (show
its name) but have no edit form yet. That's the next gap, tracked below.

## HabitPage / TaskPage have no edit form yet

`ROUTING.md`'s routing migration deliberately stopped short of building
the edit section itself (form fields, Save, validation, save→pop-on-success)
for `HabitPage`/`TaskPage` — see its "Build order" step 3. Both pages
currently just load the habit/task by id and show its name.
`CreateActivityBloc`'s save/error shape (status enum + `BlocListener` +
SnackBar-on-failure, see its handler in
`lib/create_activity/bloc/create_activity_bloc.dart`) is the intended
pattern to reuse once this gets built.

## New feature folders' blocs/widgets have no tests yet

The `go_router` migration (`ROUTING.md`) added `HabitsListBloc`,
`TasksListBloc`, `HabitBloc`, `TaskBloc`, `HabitListTile`, `TaskListTile`,
and the `ShellScaffold`/`GoRouter` wiring in `lib/routing/` — none have
tests yet, deferred alongside the rest of these still-undesigned screens
(same standing decision as `create_activity`'s test suite, above). Write
these together once each screen gets a real design pass.

## habits_repository coverage gap

Coverage is dragged down by Drift's generated `database.g.dart` (~27%,
boilerplate no one hand-writes tests against) and by `HabitsTable`/
`EntriesTable` column getters showing as unhit despite being exercised
indirectly through `HabitsRepository`'s tests — the same
"untested getters" shape as the `CI coverage threshold` entry above, just in
a different package. Worth a `min_coverage` decision (and possibly excluding
`*.g.dart`) alongside that one rather than solving it separately.

## Leftover counter boilerplate — resolved 2026-08-10

`lib/counter/`/`test/counter/` (the original Very Good CLI example feature)
were already gone, and the unused `counterAppBarTitle` string was removed
from `lib/l10n/arb/app_en.arb`/`app_es.arb` in this pass. `README.md`'s
"Working with Translations" walkthrough was still using `counterAppBarTitle`
as its example key (and only listed `en`/`es`, not the newly-added `sv`) —
updated to use `helloWorld` instead and to reflect all three locales.

## AppBar + "jump to today" FAB (part of the go_router migration)

Planned alongside the routing restructure in `ROUTING.md` (kept out of that
file — it's chrome, not routing). **Do this *after* the go_router shell
exists**, not before: the routing work moves the add-activity FAB off
`StartPage`'s `Scaffold` and onto the shell, which frees `StartPage`'s
`Scaffold` for the new FAB below. Doing it earlier forces a throwaway
two-FABs-on-one-`Scaffold` layout that gets torn apart once the add FAB
relocates.

**Status as of the shell landing (2026-08-11): the FAB hasn't moved yet.**
`ROUTING.md` ended up explicitly scoping the add-activity FAB's relocation
*out* of the routing migration itself (it's chrome, not routing — same
reasoning as this whole section being kept out of `ROUTING.md`). The
add-activity FAB is still on `StartPage`'s `Scaffold`, just retargeted to
`context.push('/create', extra: type)`; only the bottom nav bar moved to
`lib/routing/widgets/shell_scaffold.dart`. So this task still needs to do
the FAB relocation itself, not assume it's already done.

**Shared `HabitTrackerAppBar` widget.** One `PreferredSizeWidget` with the
leading (menu) button and the actions (search, calendar-view, help) defined
*once*, so they're identical on every tab and any action wired up later behaves
the same app-wide. It takes a `title` parameter; each tab's `Scaffold` uses it.
No tab has a *tappable* title (see the FAB below) — the title is display-only:

- **Today:** the selected date, read from the page-local `StartBloc`
  (`selectedDate`), so it updates as the day changes.
- **Habits / Tasks:** the tab name (`"Habits"` / `"Tasks"`) — add l10n keys,
  don't hardcode.

Only meaningful once a second tab (`HabitsListPage`) exists to share it, so extract
it during the routing work, not before.

**"Jump to today" FAB.** Replaces the old tappable-title action. Lives inside
`StartPage` (owns its behaviour), positioned bottom-left
(`FloatingActionButtonLocation.startFloat`, not "left", for RTL-correctness),
paired with the shell's bottom-right add FAB. Visible only when the selected
date is not today (date-only comparison, matching `habits_repository`'s
`dateOnly` discipline); hidden when today is selected. On press it does what the
title's `onTap` does today (`_onDateTitleTap`): select today + scroll the
`DaySelector` to today via the existing `GlobalKey`. That logic transplants
directly from the title to the FAB.

Details still open / to watch:

- **Icon** — e.g. `Icons.today` or `Icons.event` (undecided).
- **Two FABs on two `Scaffold`s** (add on the shell, jump on `StartPage`) should
  align vertically since the page `Scaffold` sits above the shell's nav bar —
  verify visually when implementing; if they don't align, the fallback (both on
  one `Scaffold`) re-introduces `StartBloc` coupling we're avoiding.
- **Midnight rollover** — the FAB's visibility is relative to "today" and won't
  recompute on its own if the app sits open past midnight (same edge as the
  `ScheduleList` entry above).

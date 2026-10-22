# Known gaps & deferred follow-ups

Known, accepted gaps and follow-ups — things we've deliberately deferred
rather than issues we've missed. Check this file when picking up new work,
and add an entry here (with a short reason) whenever you knowingly leave
something unfinished instead of just moving on.

Each entry opens with what is true now; where the history behind a decision
still matters it follows as a dated note. Finished entries move to the
[archive](#archive--resolved) rather than being deleted — code comments and
`docs/ROUTING.md` cite some of them by name.

## Open

- [App icons](#app-icons) — placeholder solid-color icons, not fit for a device or the store.
- [App/bundle identifiers](#appbundle-identifiers) — still the Very Good CLI placeholders.
- [The app bar's buttons are no-ops](#the-app-bars-buttons-are-no-ops) — all four actions render and tap, but do nothing.
- [`bootstrap.dart` and `main_*.dart` are deliberately untested](#bootstrapdart-and-main_dart-are-deliberately-untested) — pure wiring, and the one accepted test gap.
- [No behavior defined for a habit whose end date has passed](#no-behavior-defined-for-a-habit-whose-end-date-has-passed) — an ended habit is indistinguishable from a live one at the query level.
- [Nothing recomputes when the day changes at midnight](#nothing-recomputes-when-the-day-changes-at-midnight) — everything that depends on "today" is computed at build time.
- [ScheduleList is still a functional placeholder](#schedulelist-is-still-a-functional-placeholder) — no time of day, and the slide-to-reveal gesture is undiscoverable.
- ["Delete" on HabitPage and TaskPage archives rather than deletes](#delete-on-habitpage-and-taskpage-archives-rather-than-deletes) — honest today, misleading once an archive view exists.
- [`unarchiveHabit`/`deleteHabit` still silently no-op on a missing id](#unarchivehabitdeletehabit-still-silently-no-op-on-a-missing-id) — their two siblings were hardened to throw; these weren't.
- [`HabitPage` doesn't display `HabitStats` yet](#habitpage-doesnt-display-habitstats-yet) — the stats are computed and unused on that page.
- [Entries logged for a future day before the tap-block landed still count](#entries-logged-for-a-future-day-before-the-tap-block-landed-still-count) — no migration or backfill was written.
- [`_CounterCubit` test fixture suppresses a bloc_lint rule](#_countercubit-test-fixture-suppresses-a-bloc_lint-rule) — suppressed rather than fixed, with the cost of each real fix.
- [`ShellScaffold` depends on `StartBloc` for the FAB's start date](#shellscaffold-depends-on-startbloc-for-the-fabs-start-date) — routing code carrying a feature bloc; a `SelectedDayCubit` was deferred.

### App icons

`ios/Runner/Assets.xcassets/AppIcon*.appiconset` are placeholder solid-color
icons (generated 2026-08-06 to unblock `flutter run` on the simulator — the
Very Good CLI scaffolding never had real icons for any flavor). Replace with
real branded icons before installing on a physical device outside debug, or
before any store submission.

### App/bundle identifiers

Android `applicationId` (`android/app/build.gradle.kts`) is still the Very
Good CLI placeholder (`com.example.verygoodcore.habit_tracker`). The iOS
bundle identifier (`ios/Runner.xcodeproj/project.pbxproj`,
`PRODUCT_BUNDLE_IDENTIFIER`) is the same placeholder but with a hyphen —
`com.example.verygoodcore.habit-tracker` — plus a `.dev`/`.stg`/
`.RunnerTests` suffix per flavor/test target. Fine for now; revisit before
real device distribution, store submission, or setting up a Firebase
project (Firebase config is tied to this identifier).

### The app bar's buttons are no-ops

All four actions in `HabitTrackerAppBar`
(`lib/widgets/habit_tracker_app_bar.dart`) — the leading menu button and the
search, calendar-view and help actions — are wired to `onPressed: () {}`.
They render with tooltips and are tappable, so they look functional. None of
the four has a feature behind it yet, and no design exists for what the menu
or the calendar view should open. `habit_tracker_app_bar_test.dart` asserts
only that they're enabled and don't throw.

They are defined once in that one widget deliberately, so whichever gets
wired up first behaves the same on every tab — see
[the archived AppBar entry](#appbar--jump-to-today-fab--resolved-2026-08-11)
for why it's shaped that way.

### `bootstrap.dart` and `main_*.dart` are deliberately untested

_Decided 2026-08-21._

`lib/bootstrap.dart` and `lib/main_development.dart`/`main_production.dart`/
`main_staging.dart` are the only files in `lib/` that no test loads at all.
That is a decision, not an oversight: they are pure wiring with no branching
logic, `ErrorTracking.init` isn't mockable without a refactor nobody asked
for, and nothing in this repo or the sibling packages tests the equivalent
Very Good CLI entry-point files. Not a gap to revisit unless `bootstrap()`
grows real logic.

Everything else in `lib/`, and all three packages, has tests — see
[the archived coverage campaign](#test-coverage-campaign--resolved-2026-08-21).

### No behavior defined for a habit whose end date has passed

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
"is this habit finished" once a habits-list UI needs the distinction — e.g. a
read-time check like `archivedAt != null || (endDate != null &&
endDate.isBefore(today))`. That check is relative to "today", which brings
its own problem — see
[midnight](#nothing-recomputes-when-the-day-changes-at-midnight).

Flagged, not decided: whether an ended habit should disappear from the main
list, move to a distinct archived/ended section, or stay visible with its
history and streak stats intact.

### Nothing recomputes when the day changes at midnight

_Noted 2026-08-11._

Everything that depends on "today" is computed when a widget builds, and
nothing triggers a rebuild when the date actually changes, so an app left
open past midnight keeps showing yesterday's answer:

- the "jump to today" FAB's visibility
  (`lib/start_page/view/start_page.dart` compares `selectedDate` against
  `DateTime.now()`, date-only),
- the Today tab's title and its `isToday` branch, in the same build method,
- the tap-block on marking a future day done, the same comparison,
- any read-time "is this habit finished" check against `endDate` (see the
  entry above).

A Drift `Stream` query has no reason to re-emit at midnight either, so a fix
has to re-run the query or recompute at the UI layer on a timer — the stream
alone won't carry it.

### ScheduleList is still a functional placeholder

_Noted 2026-08-09; last revised 2026-08-20._

`StartBloc` watches `HabitsRepository.watchHabits()` and maps whatever's due
on the selected day (via `Habit.isScheduledOn`) into `StartState.activities`,
with `watchEntriesOnDate` feeding `completedHabitIds` into each row's
checkbox; tapping a row toggles it via `logEntry`/`unlogEntry`. What's still
open is the presentation:

- **No time of day.** `Habit` has no time field, so rows show no time at all.
  That's honest rather than misleading, but it isn't the per-item time a real
  schedule wants. The visuals are a functional placeholder generally — there
  is no design reference for `ScheduleList` yet, unlike `EmptySchedule`/
  `DayChip` — so revisit the time question once one exists.
- **The slide-to-reveal gesture is undiscoverable.** Dragging a row left
  reveals its "open details" action, but there's no `onLongPress` fallback
  and no persistent visible affordance (a chevron, say) telling a *sighted*
  user the gesture exists. Screen readers are covered: each row exposes a
  named "open details" action through
  `Semantics(customSemanticsActions: {...})`
  (`l10n.startActivityOpenDetailsAction`), independent of the drag and
  covered by `schedule_list_test.dart`.
- **Two interaction details, both deliberate for now.** `_onDragEnd` settles
  on position only and ignores `details.primaryVelocity`, so a fast flick
  stopping short of halfway snaps closed; and a 45° drag resolves to the
  horizontal recognizer, so a sloppy diagonal swipe opens a row instead of
  scrolling the list (the same behavior as `Dismissible`).

### "Delete" on HabitPage and TaskPage archives rather than deletes

Both detail pages build a delete row inline (`_HabitDetails`/`_TaskDetails`,
via `app_ui`'s `DetailsActionTile`) labelled `l10n.deleteHabitOrTask`
("Delete"), with a confirmation dialog that reads as a hard delete ("Do you
wish to delete...?"). The action behind it —
`Habit/TaskArchiveRequestSubmitted` → `HabitsRepository.archiveHabit` — is a
soft delete: the row and its entries stay in the database with `archivedAt`
set, just filtered out of `watchHabits()`'s default result.

This is deliberate, not an oversight: there's no archived-items view anywhere
in the app yet, so "archive" and "delete" are functionally identical from the
user's perspective today — an archived item is gone from every list they can
see. "Delete" was chosen because it's the honest description of what the user
currently experiences, not because the operation was misidentified.

**Revisit once an archived-items view exists.** At that point "Delete"
becomes misleading — the item hasn't gone anywhere — and the UI should either
relabel the action (e.g. "Archive", with a separate real "Delete" calling
`HabitsRepository.deleteHabit`) or surface archived items somewhere, so the
label's implied permanence is no longer contradicted.

### `unarchiveHabit`/`deleteHabit` still silently no-op on a missing id

`HabitsRepository.updateHabit` and `archiveHabit` were hardened (2026-08-19)
to throw when the given id doesn't match any row, instead of resolving
successfully having written nothing — surfaced by `TaskPage`'s delete flow
silently "succeeding" (and popping the page) against a nonexistent id.
`unarchiveHabit` and `deleteHabit` have the identical shape
(`.write(...)`/`.go()` return an affected-row count that's discarded) and so
have the identical gap, but weren't touched since nothing in the app
currently calls either against a possibly-stale id. Worth the same treatment
once `HabitPage`/`TasksListPage` grow an unarchive or hard-delete action that
can race a deletion elsewhere.

### `HabitPage` doesn't display `HabitStats` yet

_Noted 2026-08-25._

`HabitBloc` loads a habit's entries and computes `HabitStats`
(`lib/habit_stats.dart`) into `HabitState.stats` on load, and recomputes it
whenever a start/end date edit changes the schedule — the same data
`HabitsListPage`'s rows show per habit
(`lib/habits_list/widgets/habit_list_tile.dart`). `HabitPage`'s own
`_HabitDetails` view never reads `state.stats`: the detail page shows the
name/start date/end date/delete rows only, with no completion or streak
section. The data is there; only the UI for it on this page is missing.

**Revisit** by adding a stats section to `_HabitDetails`, following the same
bounded-vs-unbounded split as `HabitListTile` (completed/total plus a
percentage only when `stats.totalScheduled != null`).

### Entries logged for a future day before the tap-block landed still count

_Noted 2026-08-25._

`StartPage` now disables marking a habit done for a day after today (the
`isAfterToday` guard on `ScheduleList.onActivityTap`) — added after a bug
where `HabitListTile`'s completion count silently excluded a future-dated
entry from `completedCount` while still including it in `totalScheduled`. The
fix in `computeHabitStats` (`lib/habit_stats.dart`) makes `completedCount`
count every logged entry regardless of date, and the `StartPage` guard stops
any *new* future-dated entries from being created.

Neither fix retroactively touches entries already logged for a future day
before this shipped — those rows still exist in the `entries` table and will
keep counting toward `completedCount` and the completion percentage on any
habit they belong to, exactly as if they'd been completed on time. No
migration or backfill was written to clean them up.

**Revisit if this surfaces in practice** — e.g. a habit's completion
percentage looking implausibly high — by finding and clearing entries whose
`date` is after their `createdAt`'s calendar day (the signature of a
pre-marked future entry), or simply by un-marking and re-marking the affected
day from the UI.

### `_CounterCubit` test fixture suppresses a bloc_lint rule

_Noted 2026-08-21._

`test/app/app_bloc_observer_test.dart` declares a tiny local `_CounterCubit`
(a `Cubit<int>` with `increment`/`fail`) purely to give `AppBlocObserver` a
real `BlocBase` to observe. `bloc_lint`'s `prefer_file_naming_conventions`
wants any file containing a Bloc/Cubit subclass to be named after that class,
which a test file isn't, and CI's bloc lint failed on it. Suppressed with a
documented `// ignore_for_file: prefer_file_naming_conventions` rather than
fixed, because every real fix has a real cost: extracting `_CounterCubit`
into its own file is what the rule wants but is a lot of ceremony for a
4-line throwaway fixture nothing else uses, and there's no precedent in this
repo for a test-local Bloc/Cubit to model it on. Reworking the test to drive
an existing app bloc instead would avoid the lint, but `addError` has no easy
public trigger on any of them — it's only reachable through a save-failure
path on `HabitBloc`/`TaskBloc`, which would couple this observer test to an
unrelated feature's wiring.

**Revisit if the pattern repeats** — a second test-local Bloc/Cubit would be
the signal to either give this one a proper file after all, or add a shared
minimal fixture to `test/helpers/` that every such test can reuse.

### `ShellScaffold` depends on `StartBloc` for the FAB's start date

_Noted 2026-08-22._

The add-activity FAB seeds its `startDate` from
`StartBloc.state.selectedDate` on the Today tab and `DateTime.now()`
elsewhere. To make `selectedDate` reachable from the FAB,
`BlocProvider<StartBloc>` moved from `StartPage` up into `ShellScaffold`
(`lib/routing/widgets/shell_scaffold.dart`) — so `lib/routing/`, a
navigation and chrome layer, now imports and constructs a full feature bloc
(habit/entry stream subscriptions, activity scheduling, completion toggling)
just to read one field off it. The coupling is narrow in practice —
`ShellScaffold` only ever does a one-off `context.read` on `selectedDate`,
never watches it — but `shell_scaffold_test.dart`'s `setUp` has to stub
`watchHabits()`/`watchEntriesOnDate()` purely so `StartBloc`'s internal
subscriptions don't throw, which is a concrete symptom of routing code
carrying business-logic dependencies it doesn't need.

**Considered and deferred: a small `SelectedDayCubit` owned by the shell.**
`ShellScaffold` would provide only a purpose-built `Cubit<DateTime>`;
`BlocProvider<StartBloc>` would move back down into `StartPage` (matching
every other page-owned bloc), constructed there with the cubit injected the
same way `StartPage` already injects `HabitsRepository`. `StartBloc` would
subscribe to the cubit's stream to drive its existing `_onDaySelected`
reaction instead of reacting to a directly-fired `StartDaySelected`.

Deferred because the blast radius is real: call sites in `day_selector.dart`
(read + write), `start_page.dart` (read for the title/`isToday`, write in
`_onJumpToTodayTap`) and `start_bloc.dart` itself would all change, plus the
8 tests in `start_bloc_test.dart` that construct
`StartBloc(..., initialDate: ...)` or drive it via
`add(StartDaySelected(...))`, and the `StartDaySelected`-driving tests in
`day_selector_test.dart`, `start_page_test.dart` and
`shell_scaffold_test.dart`. Risks worth remembering if it's picked up: seed
`StartBloc`'s initial state from `selectedDayCubit.state`, not a second
independent `DateTime.now()` (that would reintroduce the duplicate-default
bug fixed in this same change); decide whether `StartDaySelected` can still
be fired independently or becomes bloc-internal, driven only by the
cubit's stream (keeping both would reintroduce "two ways to change the date"
one layer down); and watch for timing drift, since routing the day change
through a stream subscription instead of a direct `add()` risks breaking the
exact emission sequences the existing `blocTest` assertions expect.

Revisit when next touching `start_bloc_test.dart` anyway, or before a third
consumer needs `selectedDate` and this shape gets copied again.

## Archive — resolved

Finished entries, oldest first. Kept because the reasoning is still useful,
and because code comments and `docs/ROUTING.md` cite several of them by name.

### Leftover counter boilerplate — resolved 2026-08-10

`lib/counter/`/`test/counter/` (the original Very Good CLI example feature)
were already gone, and the unused `counterAppBarTitle` string was removed
from the ARB files in this pass. `README.md`'s translation walkthrough had
been using that key as its example, and was switched to a placeholder one.

The walkthrough has since moved out of the README entirely, into
`docs/development.md` (2026-10-21), and uses real shipped strings —
`createActivitySaveButton` and `habitsListTileCurrentStreak` — so no invented
example keys are left anywhere. The `.github/cspell.json` allowlist entries
those invented strings needed went with them.

### Habits tab — resolved 2026-08-11

Resolved by the `go_router` migration (`docs/ROUTING.md`): the bottom nav
lives in `lib/routing/widgets/shell_scaffold.dart` with a real third `Tasks`
destination, and `Habits`/`Tasks` tap through to
`HabitsListPage`/`TasksListPage` (routes `/habits`/`/tasks`).

### ScheduleList items aren't tappable yet — resolved 2026-08-11

Resolved by the `go_router` migration (`docs/ROUTING.md`): a `ScheduleList`
row reaches `/habit/:id` or `/task/:id` (chosen via `Habit.isTask`), landing
on `HabitPage`/`TaskPage`. Those load by a **one-shot**
`HabitsRepository.getHabit(id)` rather than a `watchHabit(id)` stream — a
deliberate choice: the page is a full-screen modal, so it's the only possible
writer of the habit while open, and a tapped notification (planned) opens the
app cold with only an id, which a static `extra` payload can't serve. See
`docs/ROUTING.md`'s "Data loading" section for the full reasoning.

Since 2026-08-17 the row's *tap* no longer navigates — it toggles the habit
done for the selected day, and navigation moved to the action revealed by
dragging the row left (`SlideToRevealTile`), which pushes the same routes.
What that costs is tracked under
[ScheduleList](#schedulelist-is-still-a-functional-placeholder).

### AppBar + "jump to today" FAB — resolved 2026-08-11

Planned alongside the routing restructure but kept out of `docs/ROUTING.md`
(it's chrome, not routing) and landed after the go_router shell, so the
add-activity FAB could move off `StartPage`'s `Scaffold` onto the shell
without a throwaway two-FABs-on-one-`Scaffold` layout.

**Shared `HabitTrackerAppBar`.** One `PreferredSizeWidget` with the leading
menu button and the search/calendar-view/help actions defined once, so
they're identical on every tab and whichever is wired up later behaves the
same app-wide (they are all still no-ops — see
[the open entry](#the-app-bars-buttons-are-no-ops)). It takes a `title`,
which is display-only: the selected date on Today (read from `StartBloc`),
the tab name on Habits/Tasks.

**Location: `lib/widgets/habit_tracker_app_bar.dart`**, which created the
app-level shared-widgets folder. Deliberately not the three alternatives:
not `lib/routing/widgets/` next to `shell_scaffold.dart`, because the shell
does *not* own the app bar — each tab page renders its own, and colocating
would signal a coupling that was deliberately avoided; not a `lib/app_bar/`
feature folder, since it's a single stateless widget with no bloc/view split
to justify one; and not `packages/app_ui/`, because it uses the app's l10n
tooltips and app-specific nav actions, which a standalone design-system
package has no access to.

**"Jump to today" FAB.** Replaced the old tappable title. Lives inside
`StartPage`, positioned `FloatingActionButtonLocation.startFloat` (not
"left", for RTL-correctness), paired with the shell's bottom-right add FAB.
Icon `Icons.today`, which reads as "go to today" rather than as a generic
calendar glyph. Visible only when the selected date isn't today (date-only
comparison, matching `habits_repository`'s `dateOnly` discipline). On press
it selects today and scrolls the `DaySelector` there via the existing
`GlobalKey`.

Two caveats left behind: the two FABs' alignment was never checked on a
device or simulator (verified instead by a widget test for presence/absence,
plus the fact that both use `Scaffold`'s standard FAB positioning, which
aligns them by construction), and the FAB's visibility doesn't survive
midnight — now tracked under
[midnight](#nothing-recomputes-when-the-day-changes-at-midnight).

### Habit/task creation flow — resolved 2026-08-12

`lib/create_activity` has a full test suite: models, `CreateActivityBloc`
including the save success/failure paths, `CreateActivityState`'s
`canSave`/`hasUnreachableWeekdayWindow`/`copyWith`/equality, the page, and
every widget including the date-picker and end-date-sheet flows. The
same-day-end-date bug it surfaced is the next entry.

### Same-day end date can't be saved — resolved 2026-08-12

`CreateActivityState.startDate` used to default to `DateTime.now()` — an
instant with a time-of-day — while both date pickers yield date-only
midnight. A habit left on today's default start with its end date set to
today therefore had `canSave` compare midnight-today against now-today and
return `false`, silently disabling Save; the same mismatch could misfire
`hasUnreachableWeekdayWindow` on a window's final day. Fixed by normalizing
to local midnight in the state initializer (`_dateOnly(...)`), the same
"calendar day, not instant" discipline `habits_repository` enforces on write.
Regression tests live in `create_activity_state_test.dart`.

### CI coverage restructure — resolved 2026-08-12

A single root `build` job (implicit 100% coverage, root working directory
only) was replaced by one job per tested package, which is what
[the gates entry](#ci-coverage-gates--resolved-2026-10-21)
describes. The old shape meant `habits_repository`'s suite never ran in CI at
all, and `error_tracking` had no job until it gained a suite.

The percentages this file used to quote from that period (~77%, then ~28%
and ~81%) were a mismeasurement, corrected 2026-08-17: they came from running
coverage at the root, where `collect_coverage_from: imports` folds every
imported package's `lib` into the number. They aren't worth re-citing.

### habits_repository coverage — resolved 2026-08-13

At 99.4%, excluding the generated `database.g.dart` that
`build-habits-repository` already drops. The `HabitsTable`/`EntriesTable`
column-and-key getters turned out to be genuinely *uncoverable* — drift's
column builders throw "should not be called at runtime" because the
generated table overrides them, so they're build-time metadata, not runtime
logic. They're wrapped in `// coverage:ignore-start/end`, leaving the real
logic — the `DateOnlyConverter`/`WeekdaysConverter` and the whole
`HabitsRepository` API — counted and at 100%.

The one remaining uncovered line is `habits_repository.dart`'s
`?? HabitsDatabase()` default-constructor branch: it opens the real
on-device Drift database, which needs Flutter's file system and so can't run
in a unit test. Left honest (uncovered) rather than ignored, and the gate was
raised 90% → 95% to match the real number while keeping that line as
headroom.

### HabitPage / TaskPage edit forms — resolved 2026-08-20

The routing migration deliberately stopped short of building the edit
sections (`docs/ROUTING.md`'s "Build order" step 3), leaving both pages
loading a habit by id and showing its name. `TaskPage` was built out
2026-08-19 and `HabitPage` 2026-08-20; neither has a stubbed tile left.

Both have a name edit (`showEditNameDialog` + `…NameChangeSubmitted`), a
start-date edit (`showDatePicker` + `…StartDateChangeSubmitted`) and a delete
action (`…ArchiveRequestSubmitted` → `archiveHabit`, popping on success).
`HabitPage` additionally has an end-date edit, which a task has no equivalent
of: `HabitEndDateChangeSubmitted` takes a nullable `DateTime?` and the bloc
passes `clearEndDate: true` to `Habit.copyWith` when it's `null`.

The two field edits deliberately **share** one `…SaveStatus` and one
`BlocListener` failure branch (`editNameSaveError`) on each page, since both
are the same kind of operation — an in-place field update via `updateHabit` —
rather than adding a near-identical second enum. Archiving is a genuinely
different operation (soft-delete plus pop-on-success) and keeps its own
`…ArchiveStatus`. All of them follow `CreateActivityBloc`'s status-enum +
`BlocListener` + SnackBar-on-failure shape.

Along the way `EditNameDialog` and `ArchiveConfirmationDialog` (previously
`TaskPage`-only) were generalized — parameterized with plain strings instead
of reading the app's l10n internally — and moved into `packages/app_ui` as
`showEditNameDialog`/`showConfirmationDialog`, the latter renamed once
nothing archive-specific was left in it. A new `pickEndDate`, also in
`app_ui`, shares the "Never / pick a date" sheet between the create-activity
end-date field and `HabitPage`'s end-date tile, skipping the sheet and
opening the calendar directly when there's no current end date to clear. See
`packages/app_ui/CHANGELOG.md` (0.1.0+5).

### Test coverage campaign — resolved 2026-08-21

The "defer tests until the screen is designed" convention was retired
2026-08-12 (user decision), turning the untested feature folders from
accepted gaps into pending work. That work is done: every folder in `lib/`
and all three packages have tests, the only exception being the entry points
in [their own entry](#bootstrapdart-and-main_dart-are-deliberately-untested).

What landed, in the order it did: `packages/app_ui`,
`packages/error_tracking` and `packages/habits_repository`;
`lib/create_activity`, `lib/start_page`, `lib/widgets`, `lib/routing`; then
`lib/task_page` (2026-08-19); and finally `lib/habit_page`,
`lib/habits_list`, `lib/tasks_list` and `lib/app/app_bloc_observer.dart`
(2026-08-21).

Idioms worth copying, since the later suites all share them: mocktail mocks
of `HabitsRepository`; driving the real `showDatePicker` UI through a
day-cell tap plus OK rather than firing the bloc event directly; a
`Navigator.push` scaffold to assert pop-on-archive-success; and pushing two
or more items through a list's stream so the `ListView.separated`
`separatorBuilder` is actually reached.

Two of those suites moved code rather than only covering it:
`TaskDetailsTile` no longer exists (both detail pages build their rows inline
via `app_ui`'s `DetailsActionTile`), and the dialog tests moved into
`packages/app_ui/test/` with the dialogs themselves, so they no longer count
toward `lib/task_page`'s own number.

### CI coverage gates — resolved 2026-10-21

`.github/workflows/main.yaml` runs one job per tested package, each with a
`min_coverage` set to the level the finished package should hold and
`coverage_excludes` dropping generated code (`*.g.dart`, `lib/l10n/gen/`)
from the denominator:

| Job | Working directory | Target |
| --- | --- | --- |
| `build-app` | `.` — also excludes `packages/**`, so it measures the app's own `lib` only | 80% |
| `build-habits-repository` | `packages/habits_repository` | 95% |
| `build-app-ui` | `packages/app_ui` | 100% |
| `build-error-tracking` | `packages/error_tracking` | 100% |

The targets were set (2026-08-12) to what each finished package should hold,
deliberately above the coverage of the day, on the rule that a threshold is
never lowered to match reality — a green check should mean "at the approved
bar". **All four are met:** every gate passed on CI on 2026-10-21, with 247
tests for the app, 77 for `app_ui`, 53 for `habits_repository` and 5 for
`error_tracking`.

That was the first run to reach the coverage step since 2026-08-25, because
CI had been broken rather than idle in between: `very_good_workflows@v1` is
a moving tag, and it moved to a `very_good_cli` requiring a newer Dart than
this workflow pinned, so all four build jobs died at the CLI install step.
Raising the pin to Flutter 3.47.x fixed that and exposed the next step —
Dart 3.13's formatter wanted four files written differently. Worth
remembering that `@v1` can break this repo's CI with no change in the repo.

`run_bloc_lint` is on for `build-app` only — no other package has blocs or a
`bloc_tools` dependency.

**A local coverage number is not the gate's number.** `flutter test
--coverage` only reports libraries a test actually loaded, so it reads higher
than CI's `collect_coverage_from: imports`. Let the workflow answer it.

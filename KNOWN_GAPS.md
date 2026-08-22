# Known gaps & deferred follow-ups

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

Android `applicationId` (`android/app/build.gradle.kts`) is still the Very
Good CLI placeholder (`com.example.verygoodcore.habit_tracker`). The iOS
bundle identifier (`ios/Runner.xcodeproj/project.pbxproj`,
`PRODUCT_BUNDLE_IDENTIFIER`) is the same placeholder but with a hyphen —
`com.example.verygoodcore.habit-tracker` — plus a `.dev`/`.stg`/
`.RunnerTests` suffix per flavor/test target. Fine for now; revisit before
real device distribution, store submission, or setting up a Firebase
project (Firebase config is tied to this identifier).

## CI coverage — targets set, deliberately red until met (2026-08-12)

The single `build` job (implicit 100% coverage, root working directory only)
was replaced in `.github/workflows/main.yaml` by one job per *tested*
package, each with a `min_coverage` set to the level the finished package
should hold and `coverage_excludes` dropping generated code (`*.g.dart`,
`lib/l10n/gen/`) from the denominator:

- **`build-app`** (root, working dir `.`) — target **80%**. Also excludes
  `packages/**` so it measures the app's own `lib` only (the packages are
  gated by their own jobs), not the imported package code the root's tests
  happen to touch.
- **`build-habits-repository`** (`packages/habits_repository`) — target
  **95%** (raised from 90 on 2026-08-13 once the suite reached 99.4%; the one
  untestable real-DB-default line is left as honest headroom). This suite
  previously never ran in CI at all; the old root-only job is why.
  `run_bloc_lint: false` here (no blocs, no `bloc_tools` dep).
- **`build-app-ui`** (`packages/app_ui`) — target **100%**. Added
  2026-08-12 alongside a full test suite (tokens, typography, theme,
  context extension, `AppButton` across every variant/state/shape/size,
  `AppTextField`'s clear flow); the package is at 100% line coverage, no
  generated code, so this gate is **green**. `run_bloc_lint: false`.

The earlier "~77%, driven by `AppSpacing`/`AppRadius`/… getters" note was a
mismeasurement — that came from running coverage at the root, where
`collect_coverage_from: imports` folds every imported package's `lib` into
the number. Measured per package (generated code excluded), the real state
as of this change is: root app own-lib **~28%** (entire `create_activity`/
`habits_list`/`tasks_list`/`habit_page`/`task_page` folders untested — see
those entries), `habits_repository` **~81%**.

**Amended 2026-08-17 — treat the ~28% above as stale, and re-measure before
citing it.** Two corrections:

- The `create_activity` folder was never untested. The same commit that
  wrote this section (`0359243`) also added nine `test/create_activity/`
  files, so that parenthetical was wrong on arrival. Genuinely untested
  today: `habits_list`, `tasks_list`, `habit_page`, `task_page`.
- `start_page` gained two suites on 2026-08-17 —
  `slide_to_reveal_tile_test.dart` (7 tests) and an expanded
  `schedule_list_test.dart` (2 → 6) — plus a repaired `start_page_test.dart`.
  The root suite went from 104 passing / 1 failing to **117 passing, 0
  failing**.

No new percentage is recorded here on purpose: `flutter test --coverage`
only reports libraries a test actually loaded, so it reads higher than CI's
`collect_coverage_from: imports`. Re-measure with the CI tooling rather than
trusting a local number.

**Amended 2026-08-20 — test count is stale, and two more commits landed
since.** The suite is now **149 passing, 0 failing** (not 117), after
`129463e`/`4493655` (`task_page`/`habit_page` full builds) and `887232a`
(empty views + first tests for `habits_list`/`tasks_list`, see "Untested
feature folders" below). A local (non-CI-method) coverage run on root `lib`
now reads ~90%, but `lib/habit_page/bloc/habit_bloc.dart` and
`lib/habit_page/view/habit_page.dart` are still only incidentally exercised
(no dedicated suite), and `lib/bootstrap.dart`/`lib/main_*.dart`/
`lib/app/app_bloc_observer.dart` are still never loaded by any test at all.
Whether `build-app`'s CI gate itself is green or red hasn't been
re-confirmed by actually running the workflow — don't treat the local
number as settling it, per the caution above.

**Amended 2026-08-21 — dedicated suites for `habit_page`,
`habits_list`/`tasks_list`, and `app_bloc_observer` closed most of the
remaining gap.** See "Untested feature folders" below for what landed. The
suite is now **215 passing, 0 failing**. A local (non-CI-method) run on
root `lib`, excluding `packages/**`/`*.g.dart`/`lib/l10n/gen/`, now reads
**1250/1251 lines (99.9%)** — the one remaining locally-uncovered line is
`lib/start_page/widgets/schedule_list.dart:53`, unrelated to this pass.
`lib/bootstrap.dart`/`lib/main_*.dart` still never load under any test at
all (by deliberate choice, not oversight — see below), so they don't even
enter that denominator; the real CI-method
(`collect_coverage_from: imports`) percentage will read lower and hasn't
been re-confirmed by actually running the workflow.

**These gates are red right now, on purpose.** The decision (2026-08-12) was
*not* to lower thresholds to today's numbers just to go green — a green check
should mean "at the approved bar," so CI stays red until the deferred test
suites bring each package up to target. Path to green: write the deferred
feature tests (root) and cover the last `HabitsTable`/`EntriesTable` getters
(habits_repository, see below).

Every package now has a CI job: `app_ui`, `habits_repository`, and
`error_tracking` each gained a full suite and a matching gate
(`build-app-ui`/`build-habits-repository`/`build-error-tracking`) — the last
of the "no tests → no job" cases is closed.

## Habit/task creation flow — tested (2026-08-12)

`lib/create_activity` now has a full test suite (models, `CreateActivityBloc`
including the save success/failure paths, `CreateActivityState`'s `canSave`/
`hasUnreachableWeekdayWindow`/`copyWith`/equality, the page, and every widget
including the date-picker and end-date-sheet flows) — **100%** line coverage,
analyzer-clean. Part of retiring the "defer tests" convention (see "Untested
feature folders" below). The same-day-end-date bug this surfaced is fixed —
see its entry below.

## Same-day end date can't be saved — fixed (2026-08-12)

`CreateActivityState.startDate` used to default to `DateTime.now()` — an
instant with a time-of-day — while both date pickers yield date-only midnight,
so a habit left on today's default start with its end date set to today had
`canSave` compare midnight-today against now-today and return `false`, silently
disabling Save (and the same mismatch could misfire
`hasUnreachableWeekdayWindow` on a window's final day). Fixed by normalizing to
local midnight in the state initializer (`_dateOnly(...)`), the same "calendar
day, not instant" discipline `habits_repository` enforces on write. Covered by
regression tests in `create_activity_state_test.dart`.

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
(2026-08-09) once every consumer worked with `Habit` directly instead.
What's still open (revised 2026-08-17, after the done-toggle and
slide-to-reveal work):

- `Habit` still has no time-of-day. The always-00:00 `DateFormat.Hm()` stamp
  this entry used to describe was dropped (2026-08-17) when the row was
  rebuilt around a completion checkbox — rows now show no time at all, which
  is honest rather than misleading, but still not the per-item time a real
  schedule wants.
- `selectedDate` is **no longer dead weight**: removed from `ScheduleList`,
  `_HabitTile`, and the widget tests (2026-08-17), in the same change that
  added `Semantics` support — that work already had to touch every call
  site, so the unused param was deleted rather than left for later.
- Completion state is **no longer** a gap: `StartBloc` consults
  `watchEntriesOnDate` and feeds `completedHabitIds` into the row's
  checkbox, and tapping a row toggles it via `logEntry`/`unlogEntry`.
- **Correction (2026-08-20) — the slide-reveal action does have an
  accessible equivalent; the original bullet below was wrong on arrival.**
  It claimed a row's detail page was reachable *only* by a horizontal drag,
  with no `Semantics` action and no screen-reader path to open a habit at
  all — but the same commit (`50a4103`) that wrote that claim also wrapped
  each row in `Semantics(customSemanticsActions: {...})`, exposing a named
  "open details" action (`l10n.startActivityOpenDetailsAction`) independent
  of the drag gesture, covered by `schedule_list_test.dart`. So
  `customSemanticsActions` was the choice made, just not reflected in the
  text at the time. What's still genuinely missing: no `onLongPress`
  fallback, and no persistent visible affordance (e.g. a chevron) telling a
  *sighted* user the gesture exists in the first place.
- Two smaller interaction details, both deliberate-for-now: `_onDragEnd`
  settles on position only and ignores `details.primaryVelocity`, so a fast
  flick stopping short of halfway snaps closed; and a 45° drag resolves to
  the horizontal recognizer, so a sloppy diagonal swipe opens a row instead
  of scrolling the list (same behavior as `Dismissible`).
- `ScheduleList`'s visuals are still a functional placeholder (no design
  reference for it yet, unlike `EmptySchedule`/`DayChip`) — revisit the
  time-of-day point above once one exists.
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

**Amended 2026-08-17:** a row's *tap* no longer navigates — it toggles the
habit done for the selected day. Navigation moved to the action revealed by
dragging the row left (`SlideToRevealTile`), which still pushes the same
`/habit/:id` / `/task/:id` routes. See the accessibility bullet under
"ScheduleList still has placeholder gaps" for what that costs.

## HabitPage / TaskPage have no edit form yet

`ROUTING.md`'s routing migration deliberately stopped short of building
the edit section itself (form fields, Save, validation, save→pop-on-success)
for `HabitPage`/`TaskPage` — see its "Build order" step 3. Both pages
currently just load the habit/task by id and show its name.
`CreateActivityBloc`'s save/error shape (status enum + `BlocListener` +
SnackBar-on-failure, see its handler in
`lib/create_activity/bloc/create_activity_bloc.dart`) is the intended
pattern to reuse once this gets built.

**Amended 2026-08-19 — `TaskPage` fully built.** It now has a working name
edit (`EditNameDialog` + `TaskNameChangeSubmitted`), a start-date edit
(`showDatePicker` directly from `_TaskDetails` + `TaskStartDateChangeSubmitted`),
and a delete action (soft-delete via `ArchiveConfirmationDialog` +
`TaskArchiveRequestSubmitted` → `HabitsRepository.archiveHabit`, popping
the page on success). Name and start-date edits deliberately **share**
`TaskSaveStatus`/`saveStatus` — both are the same kind of operation (an
in-place field update via `updateHabit`), so one status enum and one
`BlocListener` failure branch (`editNameSaveError`) covers both, rather than
adding a third near-identical enum. Archiving is a genuinely different
operation (soft-delete + pop-on-success) and keeps its own
`TaskArchiveStatus`/`archiveStatus`. All three follow the same underlying
status-enum + `BlocListener` + SnackBar-on-failure shape referenced above.
No tiles left stubbed on `TaskPage`. `HabitPage` hasn't been touched at
all — no name edit, no start-date edit, no delete, still just loads and
shows the name.

**Amended 2026-08-20 — `HabitPage` fully built too.** Same shape as
`TaskPage`: name edit, start-date edit, and a delete action
(`HabitArchiveRequestSubmitted` → `HabitsRepository.archiveHabit`,
`HabitArchiveStatus`/`archiveStatus`, pop-on-success), all sharing
`HabitSaveStatus`/`saveStatus` for the in-place field edits, same reasoning
as `TaskPage`'s shared `saveStatus` above. `HabitPage` additionally has an
end-date edit that `TaskPage` has no equivalent of — a task has no end
date, but a habit does, and it's optional. `HabitEndDateChangeSubmitted`
takes a nullable `DateTime?`; the bloc passes `clearEndDate: true` to
`Habit.copyWith` when it's `null`. No tiles left stubbed on `HabitPage`
either.

Along the way, `EditNameDialog` and `ArchiveConfirmationDialog`
(previously `TaskPage`-only, in `lib/task_page/widgets/`, which no longer
exists) were generalized — parameterized with plain strings instead of
reading the app's l10n internally — and moved into `packages/app_ui` as
`showEditNameDialog`/`showConfirmationDialog` (renamed, since nothing
"archive"-specific was left in it once generic). Both pages now call them
with their own l10n strings. A new `pickEndDate` (also in `app_ui`) shares
the "Never / pick a date" bottom sheet between the create-activity
end-date field and `HabitPage`'s end-date tile — it skips the sheet and
opens the calendar directly whenever there's no current end date to offer
clearing (applies to the create-activity field too now, not just
`HabitPage`). See `packages/app_ui/CHANGELOG.md` (0.1.0+5).

## Untested feature folders — pending work, no longer deferred

The **"defer tests until the screen is designed" convention is retired**
(2026-08-12, stated by the user). These are now pending work to write, not
accepted gaps. Done so far: `packages/app_ui`, `packages/error_tracking`,
`lib/create_activity`, `lib/start_page`, `lib/widgets`, `lib/routing`,
`lib/task_page`, and `packages/habits_repository` (all 100% except
habits_repository's single untestable DB-default line). Still to do:

- `lib/habits_list`, `lib/tasks_list` (`HabitsListBloc`/`TasksListBloc` +
  `HabitListTile`/`TaskListTile` + views)
- `lib/habit_page` (`HabitBloc` + view)
- loose files: `lib/bootstrap.dart`, `lib/main_*.dart`,
  `lib/app/app_bloc_observer.dart`

Some of these widgets/screens are still visually placeholder; that doesn't
block testing their current behavior (a bare `ListTile` per row is still
testable). Bring each into CI (see "CI coverage" above) as its suite lands.

**Amended 2026-08-19 — `lib/task_page` done, 100% line coverage, no
exceptions.** `TaskBloc` (load, name-edit save success/failure, start-date
save success/failure, archive success/failure), `TaskState`'s `copyWith`/
equality across all three status enums, and every widget (`TaskPage`,
`EditNameDialog`, `ArchiveConfirmationDialog`, `TaskDetailsTile`) are
covered. The start-date widget test drives the real `showDatePicker` UI
(tap a day cell, tap OK — same idiom as
`test/create_activity/widgets/start_date_field_test.dart`), not just the
bloc event directly. `lib/habit_page` is now the only page-level folder
left on this list besides `habits_list`/`tasks_list`.

**Amended 2026-08-20:** `TaskDetailsTile` no longer exists (both pages
build their rows inline via `app_ui`'s `DetailsActionTile` now), and
`EditNameDialog`/`ArchiveConfirmationDialog` moved into `app_ui` as
`showEditNameDialog`/`showConfirmationDialog` — see the amendment on
"HabitPage / TaskPage have no edit form yet" above. Their tests moved with
them, into `packages/app_ui/test/`, so they no longer count toward
`lib/task_page`'s own coverage number; re-measure with the CI tooling
rather than assuming the 100% above still holds unchanged (same caveat as
the "CI coverage" section above).

**Amended 2026-08-20 (later same day) — `habits_list`/`tasks_list` gained
their first tests.** `887232a` added
`test/habits_list/view/habits_list_page_test.dart` and
`test/tasks_list/view/tasks_list_page_test.dart` (empty-view rendering,
list filtered by activity type, tap-to-navigate). That's page-level only —
there's still no dedicated `HabitsListBloc`/`TasksListBloc` test and no
`HabitListTile`/`TaskListTile` test, so bloc/tile coverage remains
incidental. `lib/habit_page` is untouched — `test/habit_page` still doesn't
exist at all, making it the one page-level folder with zero dedicated
coverage. Loose files (`lib/bootstrap.dart`, `lib/main_*.dart`,
`lib/app/app_bloc_observer.dart`) are still untested.

**Amended 2026-08-21 — `lib/habit_page`, `lib/habits_list`, and
`lib/tasks_list` are now done, 100% line coverage each.**

- `lib/habit_page`: mirrors `lib/task_page`'s three-file suite
  (`test/habit_page/bloc/habit_bloc_test.dart`,
  `.../habit_state_test.dart`, `test/habit_page/view/habit_page_test.dart`)
  — same idioms (mocktail `_MockHabitsRepository`, real `showDatePicker`
  UI driven via day-cell tap + OK, `Navigator.push` scaffold trick to
  assert pop-on-archive-success) — plus the one thing `TaskPage` has no
  equivalent of: the end-date tile, covered via `pickEndDate`'s sheet
  ("On a date" → picker, and "Never" → clears) rather than the direct-to-
  calendar path (that path is already covered in isolation by
  `packages/app_ui/test/src/widgets/end_date_picker_test.dart`).
- `lib/habits_list`/`lib/tasks_list`: added
  `test/{habits,tasks}_list/bloc/{habits,tasks}_list_bloc_test.dart`
  (initial state, filtered emission, repeated emissions, `close()`
  cancelling the repository subscription) and matching
  `bloc/{habits,tasks}_list_state_test.dart` (`copyWith`/equality/
  `hashCode`, previously only reachable incidentally and missing
  `hashCode` entirely), plus
  `test/{habits,tasks}_list/widgets/{habit,task}_list_tile_test.dart`
  (name rendering, `onTap`, and — for `HabitListTile` — that its
  `WeekdayChipRow` is read-only, `onToggled: null`). The existing page
  tests gained a "separates multiple rows" case pushing ≥2 items through
  the stream, closing the one line each page was missing (the
  `ListView.separated` `separatorBuilder`, never reached by a single-item
  list).
- `create_activity_page.dart` closed its 2-line gap too (not listed above,
  but same audit): a new `create_activity_page_test.dart` case taps
  `EndDateField` and drives its picker through the real UI, exercising the
  page's own `onChanged: (date) =>
  bloc.add(CreateActivityEndDateChanged(date))` closure, previously only
  reached indirectly via a raw bloc `add` in another test.
- `lib/app/app_bloc_observer.dart` gained
  `test/app/app_bloc_observer_test.dart`: `onChange`/`onError` call
  through without throwing, and — installed as `Bloc.observer` — a real
  `Cubit`'s state changes and `addError` calls still work normally
  (nothing swallowed).
- `lib/bootstrap.dart`/`lib/main_development.dart`/`main_production.dart`/
  `main_staging.dart` remain **deliberately** untested (user decision,
  2026-08-21): pure wiring with no branching logic, `ErrorTracking.init`
  isn't mockable without a refactor nobody asked for, and no precedent in
  this repo (or the sibling `packages/*`) tests the equivalent
  Very-Good-CLI entrypoint files. Not a gap to revisit unless `bootstrap()`
  grows real logic.

`lib/habit_page` and `lib/habits_list`/`lib/tasks_list` are no longer on
the "still to do" list above — the only items left there are the loose
files, now further scoped by the previous paragraph.

## habits_repository coverage — resolved 2026-08-13

Now at **99.4%** (excluding generated `database.g.dart`, which the
`build-habits-repository` job already drops via `coverage_excludes`). What
changed: the `HabitsTable`/`EntriesTable` column-and-key getters turned out to
be genuinely *uncoverable* — drift's column builders throw
"should not be called at runtime" (the generated table overrides them), so
they're build-time metadata, not runtime logic. They're now wrapped in
`// coverage:ignore-start/end`, leaving the real logic — the
`DateOnlyConverter`/`WeekdaysConverter` (tested directly) and the whole
`HabitsRepository` API including the new `getHabit` tests — counted and at
100%.

The single remaining uncovered line is `habits_repository.dart`'s
`?? HabitsDatabase()` default-constructor branch: it opens the real
on-device Drift database, which needs Flutter's file system and so can't run
in a unit test. Left honest (uncovered) rather than ignored.

Gate raised **90% → 95%** (2026-08-13) to match the real 99.4%, keeping the
one untestable real-DB-default line as honest headroom rather than ignoring
it to force 100%.

## `unarchiveHabit`/`deleteHabit` still silently no-op on a missing id

`HabitsRepository.updateHabit` and `archiveHabit` were hardened
(2026-08-19) to throw when the given id doesn't match any row, instead of
resolving successfully having written nothing — surfaced by `TaskPage`'s
delete flow silently "succeeding" (and popping the page) against a
nonexistent id. `unarchiveHabit` and `deleteHabit` have the identical shape
(`.write(...)`/`.go()` return an affected-row count that's discarded) and
so have the identical gap, but weren't touched since nothing in the app
currently calls either against a possibly-stale id. Worth the same
treatment once `HabitPage`/`TasksListPage` grow an unarchive or hard-delete
action that can race a deletion elsewhere.

## TaskPage's "Delete" tile actually archives, not deletes

`TaskDetailsTile`'s delete row (`l10n.deleteHabitOrTask`, "Delete") and its
confirmation dialog (`l10n.deleteConfirmationMessage`, "Do you wish to
delete...?") both read as a hard delete to the user, but the action behind
them (`TaskArchiveRequestSubmitted` → `HabitsRepository.archiveHabit`) is a
soft delete — the row and its entries stay in the database with
`archivedAt` set, just filtered out of `watchHabits()`'s default result.

This is deliberate, not an oversight: there's no archived-items view
anywhere in the app yet, so "archive" and "delete" are functionally
identical from the user's perspective today — an archived task is gone from
every list they can see, same as a real delete would look. "Delete" was
chosen as the user-facing word because it's the honest description of what
the user currently experiences, not because the underlying operation was
misidentified.

**Revisit once an archived-items view exists** (`HabitPage`/`TasksListPage`
gaining a way to browse/unarchive, per the entry above): at that point
"Delete" becomes misleading — the item hasn't actually gone anywhere — and
the UI should either relabel this action (e.g. "Archive", with a separate
real "Delete" for `HabitsRepository.deleteHabit`) or surface archived items
somewhere the "Delete" label's implied permanence is no longer contradicted.

**Amended 2026-08-20:** `TaskDetailsTile` no longer exists — both pages
build their delete row inline (`_TaskDetails`/`_HabitDetails`) via
`app_ui`'s `DetailsActionTile`. `HabitPage` now has the identical
archive-labeled-as-delete behavior too (`HabitArchiveRequestSubmitted` →
`archiveHabit`), so this entire entry — including "revisit once an
archived-items view exists" — applies to both pages now, not just
`TaskPage`.

## Leftover counter boilerplate — resolved 2026-08-10

`lib/counter/`/`test/counter/` (the original Very Good CLI example feature)
were already gone, and the unused `counterAppBarTitle` string was removed
from `lib/l10n/arb/app_en.arb`/`app_es.arb` in this pass. `README.md`'s
"Working with Translations" walkthrough was still using `counterAppBarTitle`
as its example key (and only listed `en`/`es`, not the newly-added `sv`) —
updated to use `helloWorld` instead and to reflect all three locales.

## AppBar + "jump to today" FAB — resolved 2026-08-11

Planned alongside the routing restructure in `ROUTING.md` (kept out of that
file — it's chrome, not routing). Landed after the go_router shell (the
`ROUTING.md` migration had explicitly scoped this relocation *out* of
routing itself), so it could move the add-activity FAB off `StartPage`'s
`Scaffold` onto the shell without a throwaway two-FABs-on-one-`Scaffold`
layout.

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

**Location: `lib/widgets/habit_tracker_app_bar.dart`** — a shared, app-level
widgets folder (this is the first genuinely cross-feature widget, so it creates
that bucket). Deliberately *not* the two homes first considered:

- *Not* `lib/routing/widgets/` (next to `shell_scaffold.dart`): the shell does
  **not** own the app bar — each tab page renders its own via
  `appBar: HabitTrackerAppBar(...)`. Colocating with the shell would signal a
  coupling we deliberately avoided (the per-page setup exists precisely because
  the Today title couples to `StartBloc`).
- *Not* a `lib/app_bar/` feature folder: it's a single stateless
  `PreferredSizeWidget`, not a screen — no bloc/view/widgets split to justify a
  feature folder.

It stays in `lib/` rather than `packages/app_ui/` because it uses the app's
l10n tooltips and app-specific nav actions (search / calendar-view / help),
which `app_ui` — a standalone, generic design-system package — has no access
to. Putting it inside any one feature (e.g. `start_page/widgets/`) is also out,
since `habits_list`/`tasks_list` would then have to depend on that feature.

**"Jump to today" FAB.** Replaces the old tappable-title action. Lives inside
`StartPage` (owns its behaviour), positioned bottom-left
(`FloatingActionButtonLocation.startFloat`, not "left", for RTL-correctness),
paired with the shell's bottom-right add FAB. Visible only when the selected
date is not today (date-only comparison, matching `habits_repository`'s
`dateOnly` discipline); hidden when today is selected. On press it does what the
title's `onTap` does today (`_onDateTitleTap`): select today + scroll the
`DaySelector` to today via the existing `GlobalKey`. That logic transplants
directly from the title to the FAB.

**Icon:** `Icons.today` — reads specifically as "go to today" rather than a
generic calendar/event glyph.

**Alignment:** the two FABs (`endFloat` on the shell, `startFloat` on
`StartPage`) weren't verified by tapping through the simulator — terminal
Accessibility access wasn't available in the environment this landed in, so
taps couldn't be simulated there. Verified instead via a temporary widget
test (both FABs' presence/absence toggling correctly with the selected
date) plus reasoning that both use `Scaffold`'s standard FAB positioning
(not custom layout code), which aligns them by construction. Worth an
actual glance next time this screen is open on a device/simulator.

Still open:

- **Midnight rollover** — the FAB's visibility is relative to "today" and won't
  recompute on its own if the app sits open past midnight (same edge as the
  `ScheduleList` entry above).

## `_CounterCubit` test fixture suppresses a bloc_lint rule (2026-08-21)

`test/app/app_bloc_observer_test.dart` declares a tiny local `_CounterCubit`
(a `Cubit<int>` with an `increment`/`fail` method) purely to give
`AppBlocObserver` a real `BlocBase` to observe in its unit tests.
`bloc_lint`'s `prefer_file_naming_conventions` rule wants any file
containing a Bloc/Cubit subclass to be named after that class, which this
test file isn't — CI's `Bloc Lint` job failed on it. Suppressed with a
documented `// ignore_for_file: prefer_file_naming_conventions` in that
file rather than fixed, since every real fix has a real cost: extracting
`_CounterCubit` into its own file is what the rule wants but is a lot of
ceremony for a 4-line throwaway fixture nothing else uses, and there's no
existing precedent in this repo for a test-local Bloc/Cubit to model it on
(every real Bloc already lives in its own file, for real reasons that
don't apply here). The alternative considered — reworking the test to
drive an existing app Bloc (e.g. `HabitsListBloc` with a mocked
`HabitsRepository`) instead of a custom fixture — avoids the lint
entirely, but `addError` specifically has no easy public trigger on any
existing bloc (it's only reachable indirectly through a save-failure path
on `HabitBloc`/`TaskBloc`, which would couple this observer test to an
unrelated feature's bloc wiring).

**Revisit if this pattern repeats** — a second test-local Bloc/Cubit
elsewhere would be a signal to either give this one a proper file after
all, or add a shared minimal test-fixture bloc/cubit to `test/helpers/`
that every such test can reuse instead of each inventing its own.

## `ShellScaffold` depends on `StartBloc` for the FAB's start date (2026-08-22)

Landed alongside linking the add-activity FAB's seeded `startDate` to
`StartBloc.state.selectedDate` on the Today tab (`ShellBranch.today`) and
`DateTime.now()` elsewhere. To make `selectedDate` reachable from the FAB,
`BlocProvider<StartBloc>` moved from `StartPage` up into `ShellScaffold`
(`lib/routing/widgets/shell_scaffold.dart`) — so `lib/routing/`, a
navigation/chrome layer, now imports and constructs a full feature bloc
(habit/entry stream subscriptions, activity scheduling, completion
toggling) just to read one field off it. In practice the coupling is
narrow — `ShellScaffold` only ever does a one-off `context.read` on
`selectedDate`, never watches it — but `shell_scaffold_test.dart`'s
`setUp` has to stub `HabitsRepository.watchHabits()`/`watchEntriesOnDate()`
purely so `StartBloc`'s internal subscriptions don't throw, which is a
concrete (if small) symptom of routing code carrying business-logic
dependencies it doesn't need.

**Considered and deferred: a small `SelectedDayCubit` owned by the shell,
consumed by `StartBloc`.** `ShellScaffold` would provide only a
purpose-built `Cubit<DateTime>`; `BlocProvider<StartBloc>` would move back
down into `StartPage` (matching every other page-owned bloc in this app),
constructed there with the cubit injected the same way `StartPage` already
injects `HabitsRepository`. `StartBloc` would subscribe to the cubit's
stream to drive its existing `_onDaySelected` reaction (re-subscribe to
entries, recompute scheduled activities, clear `completedHabitIds`)
instead of reacting to a directly-fired `StartDaySelected` event.

Deferred rather than done now because the blast radius is real: production
call sites in `day_selector.dart` (read + write), `start_page.dart` (read
for the title/`isToday`, write in `_onJumpToTodayTap`), and
`start_bloc.dart` itself (constructor + event handling) would all change,
plus **8 tests in `start_bloc_test.dart`** that construct
`StartBloc(..., initialDate: ...)` or drive it via
`add(StartDaySelected(...))` directly, and the `StartDaySelected`-driving
tests in `day_selector_test.dart`, `start_page_test.dart`, and
`shell_scaffold_test.dart`. Risks worth remembering if this is picked up:
seed `StartBloc`'s initial state from `selectedDayCubit.state` (not a
second independent `DateTime.now()`, which would reintroduce the exact
duplicate-default bug fixed in this same change); decide whether
`StartDaySelected` remains a bloc-internal event driven only by the
cubit's stream or stays independently triggerable (both would reintroduce
"two ways to change the date" one layer down); and watch for timing
drift — routing the day change through a stream subscription instead of a
direct `add()` risks breaking the exact emission sequences the existing
`blocTest` assertions expect.

Revisit when next touching `start_bloc_test.dart` anyway, or before a third
consumer needs `selectedDate` and this shape gets copied again.

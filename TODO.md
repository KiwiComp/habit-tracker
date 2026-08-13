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
those TODO entries), `habits_repository` **~81%**.

**These gates are red right now, on purpose.** The decision (2026-08-12) was
*not* to lower thresholds to today's numbers just to go green — a green check
should mean "at the approved bar," so CI stays red until the deferred test
suites bring each package up to target. Path to green: write the deferred
feature tests (root) and cover the last `HabitsTable`/`EntriesTable` getters
(habits_repository, see below).

`error_tracking` (~17%, one thin test) deliberately has **no CI job yet**;
add one once it has a real suite. (`app_ui`, previously in this same boat,
now has a full suite and its own `build-app-ui` job — see above.)

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

## Untested feature folders — pending work, no longer deferred

The **"defer tests until the screen is designed" convention is retired**
(2026-08-12, stated by the user). These are now pending work to write, not
accepted gaps. Done so far: `packages/app_ui`, `lib/create_activity`,
`lib/start_page`, `lib/widgets`, `lib/routing`, and
`packages/habits_repository` (all 100% except habits_repository's single
untestable DB-default line). Still to do:

- `lib/habits_list`, `lib/tasks_list` (`HabitsListBloc`/`TasksListBloc` +
  `HabitListTile`/`TaskListTile` + views)
- `lib/habit_page`, `lib/task_page` (`HabitBloc`/`TaskBloc` + views)
- `packages/error_tracking` (~17%, one thin test)
- loose files: `lib/bootstrap.dart`, `lib/main_*.dart`,
  `lib/app/app_bloc_observer.dart`

Some of these widgets/screens are still visually placeholder; that doesn't
block testing their current behavior (a bare `ListTile` per row is still
testable). Bring each into CI (see "CI coverage" above) as its suite lands.

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

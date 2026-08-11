# Routing

The navigation architecture for this app: the package we use, the route
graph, and the rules that make navigation behave the way we want. This is a
design/decision record — it describes the agreed model, not necessarily what
is implemented yet. Update it when the model changes.

## Scope

**Mobile only.** The `web/`, `windows/`, and `macos/` folders are unused
scaffolding from the Very Good CLI `create` command; they are not a target.
This rules out browser-URL concerns — but note that **notifications** (a
planned future feature) reintroduce deep-linking on mobile: a tapped
notification opens the app with only an id and no in-app origin (see
[Data loading](#data-loading)).

## Package: `go_router` + `StatefulShellRoute`

We use [`go_router`](https://pub.dev/packages/go_router) with a
`StatefulShellRoute.indexedStack` shell.

Why, specifically (the tab-shell shape is the reason, not web):

- **Mixed persistence.** The bottom nav bar must persist while switching
  between tabs, but disappear when opening a full-screen page. Each tab also
  needs its own independent navigation stack and state.
  `StatefulShellRoute` is purpose-built for exactly this.
- **Correct Android back behaviour.** With hand-rolled nested `Navigator`s
  inside an `IndexedStack`, the Android system/gesture back button pops the
  *root* navigator by default, not the active tab's stack — a classic source
  of bugs. `StatefulShellRoute` routes system-back to the active branch out of
  the box.
- **Notification deep-linking.** A tapped notification opens the app (possibly
  cold) with only an id. `go_router` lets that become a single
  `router.push('/habit/$id')`, reusing the same route the in-app flow uses.

Plain `Navigator` could do all of this, but only by re-implementing what
`StatefulShellRoute` already packages. It's the Flutter-team-endorsed solution
for this exact layout.

## The navigation model

```
StatefulShellRoute.indexedStack        <- shell: owns the persistent bottom nav
├── Branch 0: Today
│     └── /            StartPage
├── Branch 1: Habits
│     └── /habits      HabitsListPage
└── Branch 2: Tasks    (added later — same shape)
      └── /tasks       TasksListPage

Root navigator (ABOVE the shell -> full-screen, covers the bottom nav)
├── /create            CreateActivityPage   (initial type via `extra`)
├── /habit/:id         HabitPage            (from Today OR Habits list)
└── /task/:id          TaskPage             (from Today OR Tasks list)
```

| Route        | Page                 | Navigator     | Opened from                |
| ------------ | -------------------- | ------------- | -------------------------- |
| `/`          | `StartPage`          | Today branch  | initial / Today tab        |
| `/habits`    | `HabitsListPage`        | Habits branch | Habits tab              |
| `/tasks`     | `TasksListPage` (later) | Tasks branch  | Tasks tab               |
| `/create`    | `CreateActivityPage` | root          | add-activity sheet         |
| `/habit/:id` | `HabitPage`          | root          | Today, or Habits list      |
| `/task/:id`  | `TaskPage`           | root          | Today, or Tasks list       |

### Tabs (the shell)

- The shell owns the persistent bottom nav bar, shared across all tabs.
- Switching tabs **preserves each branch's stack and state** (the Today tab
  keeps its selected date, the Habits tab keeps its scroll position, etc.),
  because `indexedStack` keeps every branch mounted.
- Tab taps switch branches via `navigationShell.goBranch(index)` — **never**
  `context.go(...)`, which would rebuild from the route tree and lose branch
  state.

### Full-screen pages (create / edit / detail)

- `/create`, `/habit/:id`, and `/task/:id` are declared at the **root level**,
  as siblings of the shell, so they render on the root navigator — **above**
  the shell, covering the bottom nav bar.
- **A habit and a task open different pages.** `HabitPage` and `TaskPage` are
  separate widgets. This is deliberate: the habit page is expected to grow more
  complex over time, and separate routes let it diverge without touching the
  task page.
- **Detail and edit are the same page.** For a habit, the page opened from the
  Habits list is the *same* `HabitPage` opened from Today. There is one habit
  page (detail + edit unified), and one task page.
- **The same page is used regardless of origin.** A habit edited from Today and
  a habit edited from the Habits list are the same `HabitPage` — we do **not**
  define a separate route per origin.
- **Create** is reached from the add-activity entry point: a modal
  `AddActivitySheet` (a bottom sheet — *not* a route, orthogonal to go_router)
  → `push('/create')` with the chosen type.
- Full-screen pages are opened with **`context.push(...)`**, not `context.go`.

### Back / save always return to origin — automatically

Because a full-screen page is `push`-ed onto the root navigator *on top of the
still-alive shell*, both pressing back **and** a successful save (which pops the
page) simply reveal whatever was underneath:

- Opened from **Today** → returns to Today **on the exact date you came from**
  (the Today branch — and its `StartBloc.selectedDate` — is never disposed
  while the page is on top).
- Opened from the **Habits list** → returns to the Habits list.
- Opened from the **add-activity sheet** → returns to whichever tab was active.
- (Later) Opened from the **Tasks list** → returns to the Tasks list.

Same route, different origin, correct return — with **no per-origin wiring**.
"Where you came from" is just "what was on the stack underneath."

### Save / back semantics (create and edit pages)

`/create`, `/habit/:id`, and `/task/:id` all behave the same way:

- **Save succeeds** → the page pops itself, returning to the origin.
- **Save fails** → the page **stays**, showing an error (SnackBar). The user
  can retry.
- **Back button** → pops to the origin, discarding the in-progress edit.

The existing `CreateActivityPage` already implements this (its `BlocListener`
pops on `success` and shows a SnackBar on `failure`); the edit pages inherit
the same pattern.

## Two call-site rules

1. **Opening any full-screen page → `context.push`.** From any origin:

   ```dart
   context.push(item.isTask ? '/task/${item.id}' : '/habit/${item.id}');
   ```

2. **Switching tabs → `navigationShell.goBranch(index)`.** Never `context.go`
   for tab switches.

## Data loading

**Edit/detail pages load by id; the create page takes its initial type via
`extra`.** The two are asymmetric on purpose:

- **`/habit/:id`, `/task/:id` load by id** from `HabitsRepository`, via a new
  **`Future<Habit?> getHabit(String id)`** (one-shot). This is required because
  a tapped notification opens the app with only an id — no in-memory object, no
  origin — so the page *must* be able to self-load from a bare id. (Passing the
  object via `extra` can't serve that case: there's nothing to pass on a cold
  start.)

  *Why one-shot `getHabit`, not a `watchHabit` stream:* the page is a
  full-screen modal, so it's the only possible writer while it's open — nothing
  external can change the habit under it, and a stream would emit once and then
  sit idle. A one-shot read is the right fit. The genuine live-data case in this
  app is **completion/entry state** (`watchEntries(habitId)`), added only when
  the page shows a streak / "done today" toggle the user can mutate in place —
  that's a stream on *entries*, not on the habit definition.

  **Stale id:** a notification for a since-deleted habit yields `null`; the page
  shows a "not found" state or pops.

- **`/create` takes its initial type via `extra`.** Create is only ever started
  in-app from the add-activity entry point (never a notification/deep-link
  target), so there's no cold-start requirement. The chosen `ActivityType` is
  passed straight through as `extra`.

## Habit vs. task

In the domain, a "task" is a `Habit` with `Frequency.once`; a "habit" is
`Frequency.daily`/`weekdays` (see `packages/habits_repository`). The route to
open is chosen at the call site from this. Helper on `Habit` to keep call sites
readable:

```dart
bool get isTask => frequency == Frequency.once;
```

## Code structure (feature-first)

Matches the existing `start_page/` / `create_activity/` layout. Note the
plural/singular split: `..._list` screens (plural) are the tab lists of all
habits/tasks; `..._page` screens (singular) are the full-screen view of a
single one, opened by tapping a list item (or from Today).

- `lib/routing/` — the `GoRouter` config and the shell scaffold (the widget
  that owns the shared bottom nav bar).
- `lib/habits_list/` — `HabitsListPage`, the Habits tab: the list of all
  habits (route `/habits`).
- `lib/tasks_list/` — `TasksListPage`, the Tasks tab (route `/tasks`, added
  later).
- `lib/habit_page/` — `HabitPage`, the full-screen detail/edit page for one
  habit (route `/habit/:id`).
- `lib/task_page/` — `TaskPage`, the full-screen edit page for one task
  (route `/task/:id`).

## Impact on existing code

- **The bottom nav bar moves out of `StartView`** into the shell scaffold.
  Today it lives inside `StartPage`'s `Scaffold` (`_StartNavigationBar` in
  `lib/start_page/view/start_page.dart`); under the shell it belongs to the
  shared shell scaffold.
- **Create stays unified; edit is split.** The creation flow is one page with a
  habit/task toggle (`CreateActivityPage`). Editing is two separate pages
  (`HabitPage` / `TaskPage`). This asymmetry is intentional.
- `MaterialApp` becomes `MaterialApp.router(routerConfig: ...)`. The app-wide
  `RepositoryProvider<HabitsRepository>` stays above it, so route builders can
  still `context.read<HabitsRepository>()`.
- The current create flow uses `Navigator.of(context).push(...)` from within
  `StartPage`. Under the shell, opening a full-screen page must target the root
  navigator — with go_router this is `context.push('/create')` onto the
  root-level route.
- **New repository method:** `Future<Habit?> getHabit(String id)`.

## Build order

Build in this order — thin structure first, risky routing second, minimal
routing-verification last (no feature work). Do **not** flesh out page layouts
or build unrelated functionality before the routing works.

1. **Stub the four new feature folders.** For each of `HabitsListPage`,
   `TasksListPage`, `HabitPage`, and `TaskPage`, create the full feature-folder
   structure — `bloc/`, `view/`, and `widgets/` at minimum, plus a top-level
   barrel — mirroring the existing `start_page/` / `create_activity/` layout.
   The *structure* is real (folders, bloc + event + state, the page widget,
   barrels); only the *layout/design* is a stub (a placeholder `Scaffold`).
   `HabitPage`/`TaskPage` already take an `id` (loaded via `getHabit(id)` later;
   the stub can ignore it). `StartPage` already exists.

2. **Implement the routing.** Build `lib/routing/`: the `GoRouter` with the
   `StatefulShellRoute.indexedStack` shell and **three** branches
   (Today / Habits / Tasks); the shell scaffold that owns the bottom nav bar,
   its three destinations wired to `navigationShell.goBranch` (this is where the
   Tasks tab is born); and the root routes (`/create`, `/habit/:id`,
   `/task/:id`). Switch `MaterialApp` → `MaterialApp.router`, move the nav bar
   off `StartView`, and change navigation call sites to `context.push`. After
   this, the app is a *walking skeleton* — tabs switch and the full-screen stubs
   open/close, so the routing behaviour (back-to-origin, branch persistence,
   Android system-back, chrome hiding) is verifiable before any page is fleshed
   out.

3. **Wire only enough for the routing to be testable — not a polish pass.**
   Build the minimum that lets navigation be exercised, and leave everything
   else a stub. This step is easy to over-scope; the rule is *"if it isn't
   needed to prove a route works, it's a later PR."*

   In scope (routing needs it):

   - **List pages** (`HabitsListPage` / `TasksListPage`): a minimal tappable
     list of the real habits/tasks (`watchHabits`, filtered by `isTask`) —
     name + `onTap` only, so a row can `push` its `id`. The list's design is
     deferred.
   - **Single pages** (`HabitPage` / `TaskPage`): on open, load via
     `getHabit(id)` and show just enough to confirm the *correct* entity opened
     (e.g. its name). Nothing more.
   - **Today**: make list items trigger a `push` to the correct single page
     (habit vs task). A minimal trigger is fine — the polished swipe-to-reveal
     Edit action is deferred.
   - **Create**: point the existing `AddActivitySheet` flow at the `/create`
     root route (the create page already exists and works).

   Explicitly out of scope — a later PR: the **edit section itself** in
   `HabitPage` / `TaskPage` (form fields, a Save button, validation, the
   save→pop-on-success flow). Leave it a stub; do **not** build a functional
   edit layout or design.

   What this makes testable: opening a page shows the *right* habit/task; the
   back button returns to origin (the correct date on Today, or the originating
   list); tabs switch and keep their state; full-screen pages cover the chrome.
   Not yet testable, so don't build toward it: a successful **edit** routing
   back to origin — the edit logic doesn't exist yet. (Create's save→pop *does*
   already exist, so that path is testable.)

**Why this order:** the routing is the uncertain part; the pages are routine.
Stubbing first lets the router compile and the risky shell mechanics be tested
on day one, instead of after the pages are built out.

Out of scope for the whole migration — a separate post-shell workstream tracked
in `TODO.md`: the **AppBar + "jump to today" FAB** refactor.

## Example flows

- **Today → open a habit → back/save:** `/` → `push /habit/:id` (bottom nav
  hides) → back or successful save → `/` on the same date (bottom nav returns).
- **Habits → open a habit → back:** `/habits` → `push /habit/:id` → back →
  `/habits` list.
- **Any tab → add-activity sheet → create → save:** active tab →
  `AddActivitySheet` → `push /create` → successful save → back on the active
  tab.
- **(Later) Tasks → open a task → back:** `/tasks` → `push /task/:id` → back →
  `/tasks` list.
- **Notification tap:** app opens (possibly cold) → `router.push('/habit/:id')`
  → `HabitPage` self-loads via `getHabit(id)`.

## Future considerations

- **Tasks tab** (`/tasks`) — a third shell branch, same shape as Habits.
- **Unsaved-changes guard.** Pressing back on a create/edit page with
  in-progress input currently discards it silently. A `PopScope` "discard
  changes?" confirmation may be wanted later; deferred for now.
- **Notification payload + cold-start back.** The payload must carry enough to
  pick `/habit/:id` vs `/task/:id` (or load-then-branch on `isTask`). And a page
  opened cold from a notification has no origin underneath, so its back target
  is synthesized — decide where it should close to (e.g. Today). Deferred until
  notifications are built.

# Changelog

## 0.1.0+4

- Add `HabitsRepository.getHabit(String id)`, a one-shot lookup by id — needed by the new go_router-based habit/task detail routes, which must be able to self-load from a bare id (e.g. a tapped notification with no in-app origin).
- Add `Habit.isTask` (`frequency == Frequency.once`), a readability helper for call sites choosing between the habit and task routes.

## 0.1.0+3

- `createHabit` now accepts an optional `endDate`, matching `Habit`'s constructor. Previously only settable after creation via `updateHabit`.

## 0.1.0+2

- Add `Habit.endDate` (optional, inclusive) — a habit's recurrence can now have a scheduled end. `isScheduledOn` excludes any day after it.
- Store `startDate`, `endDate`, and `entries.date` as day-count integers via a new `DateOnlyConverter`, replacing ad-hoc `dateOnly()` calls at individual write sites (which were applied in `createHabit`/`logEntry`/`unlogEntry`/`watchEntriesOnDate` but skipped in `updateHabit` and `Habit.copyWith`). Fixes a latent bug: Drift's default `DateTimeColumn` stores an epoch instant and reconverts it to *the reading device's current* local timezone, so a calendar date could read back as the wrong day if the device's timezone changed between write and read. `DateOnlyConverter` does all conversion in UTC, so the stored value never depends on when or where it's read.
- `createHabit` now returns the row Drift actually persisted (via `insertReturning`) instead of the pre-insert in-memory value, so its `startDate`/`endDate` are guaranteed normalized — the previous behavior could make `isScheduledOn` wrongly return `false` for a habit created earlier the same day.
- Bump `schemaVersion` to 2 for the above. No migration: no shipped installs exist yet.

## 0.1.0+1

- Add `HabitsRepository`, backed by a Drift/SQLite database (`HabitsDatabase`). Exposes `Habit` and `Entry` as its only public types — Drift's generated rows and the database itself stay internal to the package.
- Add `Habit` (renamed from the original `Activity` design) with `isScheduledOn` scheduling logic for `Frequency.daily`, `.weekdays`, and `.once`.
- Add `Entry`, a record that a habit happened on a given day. Completion is represented purely by an entry's presence — there's no separate `completed` flag to keep in sync.
- `entries.habitId` cascades on habit deletion; `(habitId, date)` is unique, so logging the same habit/day twice is a no-op.

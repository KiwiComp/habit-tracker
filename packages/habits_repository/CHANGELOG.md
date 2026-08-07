# Changelog

## 0.1.0+1

- Add `HabitsRepository`, backed by a Drift/SQLite database (`HabitsDatabase`). Exposes `Habit` and `Entry` as its only public types — Drift's generated rows and the database itself stay internal to the package.
- Add `Habit` (renamed from the original `Activity` design) with `isScheduledOn` scheduling logic for `Frequency.daily`, `.weekdays`, and `.once`.
- Add `Entry`, a record that a habit happened on a given day. Completion is represented purely by an entry's presence — there's no separate `completed` flag to keep in sync.
- `entries.habitId` cascades on habit deletion; `(habitId, date)` is unique, so logging the same habit/day twice is a no-op.

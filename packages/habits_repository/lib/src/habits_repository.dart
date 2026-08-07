import 'package:drift/drift.dart';
import 'package:habits_repository/src/database/database.dart';
import 'package:habits_repository/src/models/date_only.dart';
import 'package:habits_repository/src/models/models.dart';
import 'package:uuid/uuid.dart';

/// Local persistence for habits and their completion history.
///
/// This is the only public entry point into the package's storage — the
/// underlying [HabitsDatabase] and its generated `HabitRow`/`EntryRow`
/// classes are Drift implementation details that never leave `src/`. Every
/// method here reads or returns the domain models in
/// `package:habits_repository/src/models/models.dart` instead.
class HabitsRepository {
  /// Creates a [HabitsRepository], optionally backed by a specific
  /// [database] (an in-memory one, for tests).
  HabitsRepository({HabitsDatabase? database})
      : _database = database ?? HabitsDatabase();

  final HabitsDatabase _database;
  static const _uuid = Uuid();

  /// Streams habits ordered by creation date, oldest first.
  ///
  /// Archived habits are excluded unless [includeArchived] is `true`.
  Stream<List<Habit>> watchHabits({bool includeArchived = false}) {
    final query = _database.select(_database.habitsTable)
      ..orderBy([(table) => OrderingTerm(expression: table.createdAt)]);
    if (!includeArchived) {
      query.where((table) => table.archivedAt.isNull());
    }
    return query.watch().map((rows) => rows.map(_habitFromRow).toList());
  }

  /// Creates a new habit and returns it.
  Future<Habit> createHabit({
    required String name,
    required Frequency frequency,
    required DateTime startDate,
    Set<int> weekdays = const {},
  }) async {
    final habit = Habit(
      id: _uuid.v4(),
      name: name,
      frequency: frequency,
      weekdays: weekdays,
      startDate: dateOnly(startDate),
      createdAt: DateTime.now(),
    );
    await _database
        .into(_database.habitsTable)
        .insert(_habitToCompanion(habit));
    return habit;
  }

  /// Persists edits to an existing habit (name, schedule, etc).
  Future<void> updateHabit(Habit habit) =>
      _database.update(_database.habitsTable).replace(_habitToCompanion(habit));

  /// Archives a habit. Its entries are kept, so past history survives.
  Future<void> archiveHabit(String id) =>
      (_database.update(_database.habitsTable)
            ..where((table) => table.id.equals(id)))
          .write(HabitsTableCompanion(archivedAt: Value(DateTime.now())));

  /// Restores a previously archived habit.
  Future<void> unarchiveHabit(String id) =>
      (_database.update(_database.habitsTable)
            ..where((table) => table.id.equals(id)))
          .write(const HabitsTableCompanion(archivedAt: Value(null)));

  /// Permanently deletes a habit and every entry logged against it.
  Future<void> deleteHabit(String id) => (_database.delete(
        _database.habitsTable,
      )..where((table) => table.id.equals(id)))
          .go();

  /// Streams every entry logged for [habitId], oldest first.
  Stream<List<Entry>> watchEntries(String habitId) {
    final query = _database.select(_database.entriesTable)
      ..where((table) => table.habitId.equals(habitId))
      ..orderBy([(table) => OrderingTerm(expression: table.date)]);
    return query.watch().map((rows) => rows.map(_entryFromRow).toList());
  }

  /// Streams every entry logged on [date], across all habits.
  Stream<List<Entry>> watchEntriesOnDate(DateTime date) {
    final day = dateOnly(date);
    final query = _database.select(_database.entriesTable)
      ..where((table) => table.date.equals(day));
    return query.watch().map((rows) => rows.map(_entryFromRow).toList());
  }

  /// Marks [habitId] as done on [date].
  ///
  /// Idempotent: logging the same habit/date combination twice has no
  /// additional effect, enforced by the `entries` table's unique index.
  Future<void> logEntry({required String habitId, required DateTime date}) {
    return _database.into(_database.entriesTable).insert(
          EntriesTableCompanion.insert(
            id: _uuid.v4(),
            habitId: habitId,
            date: dateOnly(date),
            createdAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Removes the entry logging [habitId] as done on [date], if any.
  Future<void> unlogEntry({required String habitId, required DateTime date}) {
    final day = dateOnly(date);
    return (_database.delete(_database.entriesTable)
          ..where(
            (table) => table.habitId.equals(habitId) & table.date.equals(day),
          ))
        .go();
  }

  /// Releases the underlying database connection.
  Future<void> close() => _database.close();

  HabitsTableCompanion _habitToCompanion(Habit habit) =>
      HabitsTableCompanion.insert(
        id: habit.id,
        name: habit.name,
        frequency: habit.frequency.name,
        weekdays: Value(habit.weekdays),
        startDate: habit.startDate,
        archivedAt: Value(habit.archivedAt),
        createdAt: habit.createdAt,
      );

  Habit _habitFromRow(HabitRow row) => Habit(
        id: row.id,
        name: row.name,
        frequency: Frequency.fromName(row.frequency),
        weekdays: row.weekdays,
        startDate: row.startDate,
        archivedAt: row.archivedAt,
        createdAt: row.createdAt,
      );

  Entry _entryFromRow(EntryRow row) => Entry(
        id: row.id,
        habitId: row.habitId,
        date: row.date,
        createdAt: row.createdAt,
      );
}

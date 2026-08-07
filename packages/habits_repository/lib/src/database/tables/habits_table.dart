import 'package:drift/drift.dart';

/// Stores a habit's weekdays as a sorted, comma-joined string (e.g.
/// `'1,3,5'`), since Drift has no native `Set<int>` column type.
class WeekdaysConverter extends TypeConverter<Set<int>, String> {
  const WeekdaysConverter();

  @override
  Set<int> fromSql(String fromDb) =>
      fromDb.isEmpty ? const {} : fromDb.split(',').map(int.parse).toSet();

  @override
  String toSql(Set<int> value) => (value.toList()..sort()).join(',');
}

/// The `habits` table.
///
/// Row values are exposed outside this package only as `Habit` (the domain
/// model in `package:habits_repository/src/models/habit.dart`) — `HabitRow`,
/// generated from this table, is a persistence-layer detail.
@DataClassName('HabitRow')
class HabitsTable extends Table {
  @override
  String get tableName => 'habits';

  /// Uniquely identifies the habit.
  TextColumn get id => text()();

  /// The habit's display name.
  TextColumn get name => text()();

  /// The `Frequency` enum name (`'daily'`, `'weekdays'`, `'once'`).
  TextColumn get frequency => text()();

  /// See [WeekdaysConverter].
  TextColumn get weekdays =>
      text().map(const WeekdaysConverter()).withDefault(const Constant(''))();

  /// First day the habit applies. Stored as local midnight.
  DateTimeColumn get startDate => dateTime()();

  /// When the habit was archived, if it has been.
  DateTimeColumn get archivedAt => dateTime().nullable()();

  /// When the habit was created.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

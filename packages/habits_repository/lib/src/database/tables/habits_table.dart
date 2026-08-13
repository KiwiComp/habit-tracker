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

/// Stores a calendar day as days since the Unix epoch.
///
/// [toSql] strips any time-of-day the caller supplies and does all arithmetic
/// in UTC, so the stored value never depends on the device's timezone. This is
/// the single enforcement point for the "these columns hold calendar days, not
/// instants" invariant — do not weaken it by accepting a raw instant here, as
/// `~/` truncates toward zero and would round pre-1970 dates the wrong way.
class DateOnlyConverter extends TypeConverter<DateTime, int> {
  const DateOnlyConverter();

  @override
  int toSql(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  @override
  DateTime fromSql(int days) {
    final utc = DateTime.utc(1970).add(Duration(days: days));
    return DateTime(utc.year, utc.month, utc.day);
  }
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

  // coverage:ignore-start
  // Drift reads these column and key definitions at build time to generate
  // the real table; the generated class overrides them, and the column
  // builders throw if called at runtime. There's no runtime logic to test
  // here — that lives in the converters above — so exclude them from coverage.

  /// Uniquely identifies the habit.
  TextColumn get id => text()();

  /// The habit's display name.
  TextColumn get name => text()();

  /// The `Frequency` enum name (`'daily'`, `'weekdays'`, `'once'`).
  TextColumn get frequency => text()();

  /// See [WeekdaysConverter].
  TextColumn get weekdays =>
      text().map(const WeekdaysConverter()).withDefault(const Constant(''))();

  /// First day the habit applies. See [DateOnlyConverter].
  IntColumn get startDate => integer().map(const DateOnlyConverter())();

  /// Last day the habit's recurrence applies, inclusive. `null` means it
  /// never ends. See [DateOnlyConverter].
  IntColumn get endDate =>
      integer().map(const DateOnlyConverter()).nullable()();

  /// When the habit was archived, if it has been.
  DateTimeColumn get archivedAt => dateTime().nullable()();

  /// When the habit was created.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
  // coverage:ignore-end
}

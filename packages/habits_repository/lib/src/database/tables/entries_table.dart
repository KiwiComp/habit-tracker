import 'package:drift/drift.dart';
import 'package:habits_repository/src/database/tables/habits_table.dart';

/// The `entries` table.
///
/// Row values are exposed outside this package only as `Entry` (the domain
/// model in `package:habits_repository/src/models/entry.dart`) — `EntryRow`,
/// generated from this table, is a persistence-layer detail.
@DataClassName('EntryRow')
class EntriesTable extends Table {
  @override
  String get tableName => 'entries';

  // coverage:ignore-start
  // Build-time schema metadata: drift's generated table overrides these, and
  // the column builders throw if called at runtime, so they can't be (and
  // needn't be) covered — see the note in habits_table.dart.

  /// Uniquely identifies the entry.
  TextColumn get id => text()();

  /// The habit this entry belongs to. Cascades on habit deletion.
  TextColumn get habitId =>
      text().references(HabitsTable, #id, onDelete: KeyAction.cascade)();

  /// The calendar day this completion belongs to. See [DateOnlyConverter].
  IntColumn get date => integer().map(const DateOnlyConverter())();

  /// When this entry was logged.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, date},
  ];
  // coverage:ignore-end
}

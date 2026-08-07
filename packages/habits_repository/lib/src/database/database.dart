import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:habits_repository/src/database/tables/entries_table.dart';
import 'package:habits_repository/src/database/tables/habits_table.dart';

part 'database.g.dart';

/// The habit tracker's on-device SQLite database.
///
/// [driftDatabase] handles platform-specific setup (file location on
/// native, IndexedDB on web) so this package doesn't need its own
/// `path_provider`/file-path wiring.
@DriftDatabase(tables: [HabitsTable, EntriesTable])
class HabitsDatabase extends _$HabitsDatabase {
  /// Creates a [HabitsDatabase] backed by a file on disk named
  /// `habits.sqlite`, or an in-memory/test [executor] when provided.
  HabitsDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'habits'));

  @override
  int get schemaVersion => 1;

  // SQLite has foreign-key enforcement off by default per connection, so
  // `entries`' `ON DELETE CASCADE` (see EntriesTable.habitId) is a no-op
  // without this — it must be set on every connection, not just once.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:habits_repository/src/database/tables/entries_table.dart';

void main() {
  group('EntriesTable', () {
    test('is named "entries"', () {
      expect(EntriesTable().tableName, 'entries');
    });
  });
}

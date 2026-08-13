import 'package:flutter_test/flutter_test.dart';
import 'package:habits_repository/habits_repository.dart';

void main() {
  group('Entry equality', () {
    test('two entries with the same id, habitId and date are equal', () {
      final a = Entry(
        id: '1',
        habitId: 'habit-1',
        date: DateTime(2026),
        createdAt: DateTime(2026, 1, 1, 8),
      );
      final b = Entry(
        id: '1',
        habitId: 'habit-1',
        date: DateTime(2026),
        createdAt: DateTime(2026, 1, 1, 20),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('entries with different dates are not equal', () {
      final a = Entry(
        id: '1',
        habitId: 'habit-1',
        date: DateTime(2026),
        createdAt: DateTime(2026),
      );
      final b = Entry(
        id: '1',
        habitId: 'habit-1',
        date: DateTime(2026, 1, 2),
        createdAt: DateTime(2026),
      );

      expect(a, isNot(b));
    });
  });

  group('Entry.toString', () {
    test('includes the habitId and date', () {
      final entry = Entry(
        id: '1',
        habitId: 'habit-1',
        date: DateTime(2026),
        createdAt: DateTime(2026),
      );

      expect(entry.toString(), startsWith('Entry('));
      expect(entry.toString(), contains('habit-1'));
    });
  });
}

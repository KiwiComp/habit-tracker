import 'package:flutter_test/flutter_test.dart';
import 'package:habits_repository/habits_repository.dart';

void main() {
  group('Habit.isScheduledOn', () {
    test('daily is due every day from startDate onward', () {
      final habit = Habit(
        id: '1',
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026, 1, 10),
        createdAt: DateTime(2026, 1, 10),
      );

      expect(habit.isScheduledOn(DateTime(2026, 1, 9)), isFalse);
      expect(habit.isScheduledOn(DateTime(2026, 1, 10)), isTrue);
      expect(habit.isScheduledOn(DateTime(2026, 3)), isTrue);
    });

    test('weekdays is due only on listed weekdays', () {
      final habit = Habit(
        id: '1',
        name: 'Gym',
        frequency: Frequency.weekdays,
        weekdays: const {DateTime.monday, DateTime.wednesday},
        startDate: DateTime(2026, 1, 5), // a Monday
        createdAt: DateTime(2026, 1, 5),
      );

      expect(habit.isScheduledOn(DateTime(2026, 1, 5)), isTrue); // Monday
      expect(habit.isScheduledOn(DateTime(2026, 1, 6)), isFalse); // Tuesday
      expect(habit.isScheduledOn(DateTime(2026, 1, 7)), isTrue); // Wednesday
    });

    test('once is due only on startDate', () {
      final habit = Habit(
        id: '1',
        name: 'Renew passport',
        frequency: Frequency.once,
        startDate: DateTime(2026, 6),
        createdAt: DateTime(2026),
      );

      expect(habit.isScheduledOn(DateTime(2026, 6)), isTrue);
      expect(habit.isScheduledOn(DateTime(2026, 6, 2)), isFalse);
    });

    test('ignores time-of-day when comparing dates', () {
      final habit = Habit(
        id: '1',
        name: 'Drink water',
        frequency: Frequency.once,
        startDate: DateTime(2026, 6),
        createdAt: DateTime(2026),
      );

      expect(habit.isScheduledOn(DateTime(2026, 6, 1, 23, 59)), isTrue);
    });

    test('is due on the end date itself, but not the day after', () {
      final habit = Habit(
        id: '1',
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
        endDate: DateTime(2026, 1, 10),
        createdAt: DateTime(2026),
      );

      expect(habit.isScheduledOn(DateTime(2026, 1, 10)), isTrue);
      expect(habit.isScheduledOn(DateTime(2026, 1, 11)), isFalse);
    });

    test('has no end when endDate is null', () {
      final habit = Habit(
        id: '1',
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
        createdAt: DateTime(2026),
      );

      expect(habit.isScheduledOn(DateTime(2099)), isTrue);
    });
  });

  group('Habit.weekdays', () {
    test('is always all seven days for a daily frequency', () {
      final habit = Habit(
        id: '1',
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
        createdAt: DateTime(2026),
      );

      expect(habit.weekdays, {
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      });
    });

    test('ignores an explicitly passed weekdays for a daily frequency', () {
      final habit = Habit(
        id: '1',
        name: 'Drink water',
        frequency: Frequency.daily,
        weekdays: const {DateTime.monday},
        startDate: DateTime(2026),
        createdAt: DateTime(2026),
      );

      expect(habit.weekdays.length, 7);
    });
  });

  group('Habit.isArchived', () {
    test('is false when archivedAt is null', () {
      final habit = Habit(
        id: '1',
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
        createdAt: DateTime(2026),
      );

      expect(habit.isArchived, isFalse);
    });

    test('is true when archivedAt is set', () {
      final habit = Habit(
        id: '1',
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
        createdAt: DateTime(2026),
        archivedAt: DateTime(2026, 2),
      );

      expect(habit.isArchived, isTrue);
    });
  });

  group('Habit.copyWith', () {
    final original = Habit(
      id: '1',
      name: 'Drink water',
      frequency: Frequency.daily,
      startDate: DateTime(2026),
      createdAt: DateTime(2026),
    );

    test('keeps unspecified fields unchanged', () {
      final copy = original.copyWith(name: 'Drink more water');

      expect(copy.id, original.id);
      expect(copy.frequency, original.frequency);
      expect(copy.startDate, original.startDate);
      expect(copy.name, 'Drink more water');
    });

    test('clearArchivedAt overrides a passed archivedAt', () {
      final copy = original.copyWith(
        archivedAt: DateTime(2026, 3),
        clearArchivedAt: true,
      );

      expect(copy.archivedAt, isNull);
    });
  });

  group('Habit.isTask', () {
    Habit habitWith(Frequency frequency) => Habit(
      id: '1',
      name: 'x',
      frequency: frequency,
      startDate: DateTime(2026),
      createdAt: DateTime(2026),
    );

    test('is true only for a once frequency', () {
      expect(habitWith(Frequency.once).isTask, isTrue);
      expect(habitWith(Frequency.daily).isTask, isFalse);
      expect(habitWith(Frequency.weekdays).isTask, isFalse);
    });
  });

  group('Habit.toString', () {
    test('includes the id, name and frequency', () {
      final habit = Habit(
        id: '1',
        name: 'Read',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
        createdAt: DateTime(2026),
      );

      expect(habit.toString(), 'Habit(1, Read, daily)');
    });
  });

  group('Habit equality', () {
    test('two habits with the same fields are equal', () {
      final a = Habit(
        id: '1',
        name: 'Drink water',
        frequency: Frequency.weekdays,
        weekdays: const {1, 3, 5},
        startDate: DateTime(2026),
        createdAt: DateTime(2026),
      );
      final b = Habit(
        id: '1',
        name: 'Drink water',
        frequency: Frequency.weekdays,
        weekdays: const {5, 3, 1},
        startDate: DateTime(2026),
        createdAt: DateTime(2026),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}

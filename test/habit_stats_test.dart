import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/habit_stats.dart';
import 'package:habits_repository/habits_repository.dart';

void main() {
  Habit buildHabit({
    required DateTime startDate,
    Frequency frequency = Frequency.daily,
    DateTime? endDate,
    Set<int> weekdays = const {},
  }) {
    return Habit(
      id: 'id',
      name: 'Drink water',
      frequency: frequency,
      weekdays: weekdays,
      startDate: startDate,
      endDate: endDate,
      createdAt: startDate,
    );
  }

  Entry entryOn(DateTime date) => Entry(
    id: date.toIso8601String(),
    habitId: 'id',
    date: date,
    createdAt: date,
  );

  group('computeHabitStats', () {
    test('an unbounded habit has no totalScheduled', () {
      final habit = buildHabit(startDate: DateTime(2026));

      final stats = computeHabitStats(habit, const [], asOf: DateTime(2026));

      expect(stats.totalScheduled, isNull);
      expect(stats.completionRatio, isNull);
    });

    test('a fresh habit with no entries has all-zero stats', () {
      final habit = buildHabit(
        startDate: DateTime(2026),
        endDate: DateTime(2026, 1, 10),
      );

      final stats = computeHabitStats(habit, const [], asOf: DateTime(2026));

      expect(stats.completedCount, 0);
      expect(stats.totalScheduled, 10);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
    });

    test('totalScheduled counts every scheduled day across the whole '
        "habit's lifespan, regardless of today", () {
      final habit = buildHabit(
        startDate: DateTime(2026),
        endDate: DateTime(2026, 1, 10),
      );

      // "Today" is in the middle of the range — totalScheduled still counts
      // the full startDate..endDate span, including days after today.
      final stats = computeHabitStats(
        habit,
        const [],
        asOf: DateTime(2026, 1, 5),
      );

      expect(stats.totalScheduled, 10);
    });

    test('completedCount counts every logged entry, including ones for a '
        'future scheduled day', () {
      // Regression test: completedCount used to be tallied inside the
      // streak walk (capped at "today"), so an entry logged for a future
      // scheduled day — the day selector allows marking a day done ahead of
      // time — was silently dropped from the count even though it was a
      // real, persisted entry.
      final habit = buildHabit(
        startDate: DateTime(2026),
        endDate: DateTime(2026, 1, 10),
      );
      final entries = [entryOn(DateTime(2026, 1, 8))];

      final stats = computeHabitStats(
        habit,
        entries,
        asOf: DateTime(2026, 1, 5),
      );

      expect(stats.completedCount, 1);
      // The streak walk stops at "today", so a future completion doesn't
      // extend it.
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
    });

    test('currentStreak counts back from today, longestStreak tracks the '
        'best run so far', () {
      final habit = buildHabit(
        startDate: DateTime(2026),
        endDate: DateTime(2026, 1, 10),
      );
      final entries = [
        DateTime(2026), // day 1: done
        DateTime(2026, 1, 2), // day 2: done
        DateTime(2026, 1, 3), // day 3: done (longest streak: 3)
        // day 4: missed, breaks the streak
        DateTime(2026, 1, 5), // day 5: done
        DateTime(2026, 1, 6), // day 6: done (current streak: 2)
      ].map(entryOn).toList();

      final stats = computeHabitStats(
        habit,
        entries,
        asOf: DateTime(2026, 1, 6),
      );

      expect(stats.completedCount, 5);
      expect(stats.currentStreak, 2);
      expect(stats.longestStreak, 3);
    });

    test(
      'a weekdays-only habit skips weekends without breaking the streak',
      () {
        // 2026-01-05 is a Monday.
        final habit = buildHabit(
          frequency: Frequency.weekdays,
          startDate: DateTime(2026, 1, 5),
          endDate: DateTime(2026, 1, 11),
          weekdays: {
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
          },
        );
        final entries = [
          DateTime(2026, 1, 5), // Mon: done
          DateTime(2026, 1, 6), // Tue: done
          DateTime(2026, 1, 7), // Wed: done
          DateTime(2026, 1, 8), // Thu: done
          DateTime(2026, 1, 9), // Fri: done
          // Sat/Sun: not scheduled, shouldn't count against the streak.
        ].map(entryOn).toList();

        final stats = computeHabitStats(
          habit,
          entries,
          asOf: DateTime(2026, 1, 11),
        );

        expect(stats.totalScheduled, 5);
        expect(stats.completedCount, 5);
        expect(stats.currentStreak, 5);
        expect(stats.longestStreak, 5);
      },
    );

    test('a bounded habit whose endDate has already passed stops counting '
        'the streak at endDate', () {
      final habit = buildHabit(
        startDate: DateTime(2026),
        endDate: DateTime(2026, 1, 5),
      );
      final entries = [
        DateTime(2026, 1, 4),
        DateTime(2026, 1, 5),
      ].map(entryOn).toList();

      final stats = computeHabitStats(
        habit,
        entries,
        asOf: DateTime(2026, 1, 20),
      );

      expect(stats.currentStreak, 2);
      expect(stats.longestStreak, 2);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/habit_stats.dart';
import 'package:habit_tracker/habits_list/habits_list.dart';
import 'package:habits_repository/habits_repository.dart';

void main() {
  final habit = Habit(
    id: '1',
    name: 'Read',
    frequency: Frequency.daily,
    startDate: DateTime(2020),
    createdAt: DateTime(2020),
  );

  const stats = HabitStats(
    completedCount: 1,
    totalScheduled: 2,
    currentStreak: 1,
    longestStreak: 1,
  );

  final habitWithStats = HabitWithStats(habit: habit, stats: stats);

  group('HabitWithStats', () {
    test('equal when habit and stats both match', () {
      expect(
        HabitWithStats(habit: habit, stats: stats),
        HabitWithStats(habit: habit, stats: stats),
      );
    });

    test('unequal when stats differs', () {
      expect(
        habitWithStats,
        isNot(
          HabitWithStats(
            habit: habit,
            stats: const HabitStats(
              completedCount: 0,
              totalScheduled: 2,
              currentStreak: 0,
              longestStreak: 0,
            ),
          ),
        ),
      );
    });

    test('hashCode matches for equal values', () {
      expect(
        HabitWithStats(habit: habit, stats: stats).hashCode,
        HabitWithStats(habit: habit, stats: stats).hashCode,
      );
    });
  });

  group('HabitsListState', () {
    test('defaults to an empty list of habits', () {
      const state = HabitsListState();

      expect(state.habits, isEmpty);
    });

    test('copyWith replaces habits', () {
      const state = HabitsListState();

      final updated = state.copyWith(habits: [habitWithStats]);

      expect(updated.habits, [habitWithStats]);
    });

    test('copyWith falls back to the receiver when no argument is given', () {
      final state = HabitsListState(habits: [habitWithStats]);

      expect(state.copyWith(), state);
    });

    group('equality', () {
      test('equal when the habit lists match', () {
        expect(
          HabitsListState(habits: [habitWithStats]),
          HabitsListState(habits: [habitWithStats]),
        );
      });

      test('unequal when the lists differ in length', () {
        expect(
          HabitsListState(habits: [habitWithStats]),
          isNot(const HabitsListState()),
        );
      });

      test('unequal when the lists differ in content', () {
        expect(
          HabitsListState(habits: [habitWithStats]),
          isNot(
            HabitsListState(
              habits: [
                HabitWithStats(
                  habit: habit.copyWith(name: 'Stretch'),
                  stats: stats,
                ),
              ],
            ),
          ),
        );
      });

      test('hashCode matches for equal states', () {
        expect(
          HabitsListState(habits: [habitWithStats]).hashCode,
          HabitsListState(habits: [habitWithStats]).hashCode,
        );
      });
    });
  });
}

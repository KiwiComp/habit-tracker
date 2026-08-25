import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/habit_page/habit_page.dart';
import 'package:habit_tracker/habit_stats.dart';
import 'package:habits_repository/habits_repository.dart';

void main() {
  final habit = Habit(
    id: 'id',
    name: 'Meditate',
    frequency: Frequency.daily,
    startDate: DateTime(2026, 1, 5),
    createdAt: DateTime(2026),
  );

  const stats = HabitStats(
    completedCount: 1,
    totalScheduled: 2,
    currentStreak: 1,
    longestStreak: 1,
  );

  group('HabitState', () {
    test(
      'defaults to loading, no habit, no stats, idle save, idle archive',
      () {
        const state = HabitState();

        expect(state.status, HabitStatus.loading);
        expect(state.habit, isNull);
        expect(state.stats, isNull);
        expect(state.saveStatus, HabitSaveStatus.idle);
        expect(state.archiveStatus, HabitArchiveStatus.idle);
      },
    );

    group('copyWith', () {
      test('replaces given fields and keeps the rest', () {
        final state = HabitState(status: HabitStatus.loaded, habit: habit);

        final updated = state.copyWith(saveStatus: HabitSaveStatus.saving);

        expect(updated.status, HabitStatus.loaded);
        expect(updated.habit, habit);
        expect(updated.saveStatus, HabitSaveStatus.saving);
      });

      test('replaces stats and keeps the rest', () {
        final state = HabitState(status: HabitStatus.loaded, habit: habit);

        final updated = state.copyWith(stats: stats);

        expect(updated.status, HabitStatus.loaded);
        expect(updated.habit, habit);
        expect(updated.stats, stats);
      });

      test('replaces archiveStatus and keeps the rest', () {
        final state = HabitState(status: HabitStatus.loaded, habit: habit);

        final updated = state.copyWith(
          archiveStatus: HabitArchiveStatus.archiving,
        );

        expect(updated.status, HabitStatus.loaded);
        expect(updated.habit, habit);
        expect(updated.archiveStatus, HabitArchiveStatus.archiving);
      });

      test('falls back to the receiver when no argument is given', () {
        final state = HabitState(status: HabitStatus.loaded, habit: habit);

        expect(state.copyWith(), state);
      });
    });

    group('equality', () {
      test('equal when status, habit, saveStatus, and archiveStatus '
          'all match', () {
        expect(
          HabitState(status: HabitStatus.loaded, habit: habit),
          HabitState(status: HabitStatus.loaded, habit: habit),
        );
      });

      test('unequal when saveStatus differs', () {
        expect(
          HabitState(status: HabitStatus.loaded, habit: habit),
          isNot(
            HabitState(
              status: HabitStatus.loaded,
              habit: habit,
              saveStatus: HabitSaveStatus.saving,
            ),
          ),
        );
      });

      test('unequal when archiveStatus differs', () {
        expect(
          HabitState(status: HabitStatus.loaded, habit: habit),
          isNot(
            HabitState(
              status: HabitStatus.loaded,
              habit: habit,
              archiveStatus: HabitArchiveStatus.archiving,
            ),
          ),
        );
      });

      test('unequal when stats differs', () {
        expect(
          HabitState(status: HabitStatus.loaded, habit: habit),
          isNot(
            HabitState(status: HabitStatus.loaded, habit: habit, stats: stats),
          ),
        );
      });

      test('hashCode matches for equal states', () {
        expect(
          HabitState(status: HabitStatus.loaded, habit: habit).hashCode,
          HabitState(status: HabitStatus.loaded, habit: habit).hashCode,
        );
      });
    });
  });
}

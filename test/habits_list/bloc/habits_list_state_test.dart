import 'package:flutter_test/flutter_test.dart';
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

  group('HabitsListState', () {
    test('defaults to an empty list of habits', () {
      const state = HabitsListState();

      expect(state.habits, isEmpty);
    });

    test('copyWith replaces habits', () {
      const state = HabitsListState();

      final updated = state.copyWith(habits: [habit]);

      expect(updated.habits, [habit]);
    });

    test('copyWith falls back to the receiver when no argument is given', () {
      final state = HabitsListState(habits: [habit]);

      expect(state.copyWith(), state);
    });

    group('equality', () {
      test('equal when the habit lists match', () {
        expect(
          HabitsListState(habits: [habit]),
          HabitsListState(habits: [habit]),
        );
      });

      test('unequal when the lists differ in length', () {
        expect(
          HabitsListState(habits: [habit]),
          isNot(const HabitsListState()),
        );
      });

      test('unequal when the lists differ in content', () {
        expect(
          HabitsListState(habits: [habit]),
          isNot(
            HabitsListState(habits: [habit.copyWith(name: 'Stretch')]),
          ),
        );
      });

      test('hashCode matches for equal states', () {
        expect(
          HabitsListState(habits: [habit]).hashCode,
          HabitsListState(habits: [habit]).hashCode,
        );
      });
    });
  });
}

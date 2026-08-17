import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/start_page/start_page.dart';
import 'package:habits_repository/habits_repository.dart';

void main() {
  final date = DateTime(2026, 1, 5);
  Habit habit(String id) => Habit(
    id: id,
    name: id,
    frequency: Frequency.daily,
    startDate: date,
    createdAt: date,
  );

  group('StartState', () {
    test('defaults activities to empty', () {
      expect(StartState(selectedDate: date).activities, isEmpty);
    });

    group('copyWith', () {
      test('replaces selectedDate and keeps activities', () {
        final state = StartState(selectedDate: date, activities: [habit('1')]);
        final updated = state.copyWith(selectedDate: DateTime(2026, 2));

        expect(updated.selectedDate, DateTime(2026, 2));
        expect(updated.activities, state.activities);
      });

      test('replaces activities and keeps selectedDate', () {
        final updated = StartState(
          selectedDate: date,
        ).copyWith(activities: [habit('1')]);

        expect(updated.selectedDate, date);
        expect(updated.activities, [habit('1')]);
      });

      test('with no arguments preserves everything', () {
        final state = StartState(selectedDate: date, activities: [habit('1')]);
        expect(state.copyWith(), state);
      });

      test('replaces completedHabitIds and keeps everything else', () {
        final state = StartState(selectedDate: date, activities: [habit('1')]);
        final updated = state.copyWith(completedHabitIds: {'1'});

        expect(updated.completedHabitIds, {'1'});
        expect(updated.selectedDate, state.selectedDate);
        expect(updated.activities, state.activities);
      });
    });

    group('equality', () {
      test('equal for the same date and activities', () {
        expect(
          StartState(selectedDate: date, activities: [habit('1')]),
          StartState(selectedDate: date, activities: [habit('1')]),
        );
        expect(
          StartState(selectedDate: date).hashCode,
          StartState(selectedDate: date).hashCode,
        );
      });

      test('not equal when the dates differ', () {
        expect(
          StartState(selectedDate: date),
          isNot(StartState(selectedDate: DateTime(2026, 2))),
        );
      });

      test('not equal when the activity lists differ in length', () {
        expect(
          StartState(selectedDate: date, activities: [habit('1')]),
          isNot(StartState(selectedDate: date)),
        );
      });

      test('not equal when an activity differs', () {
        expect(
          StartState(selectedDate: date, activities: [habit('1')]),
          isNot(StartState(selectedDate: date, activities: [habit('2')])),
        );
      });

      test('not equal when completedHabitIds differ', () {
        expect(
          StartState(selectedDate: date, completedHabitIds: const {'1'}),
          isNot(StartState(selectedDate: date)),
        );
      });

      test('equal regardless of completedHabitIds iteration order', () {
        expect(
          StartState(selectedDate: date, completedHabitIds: const {'1', '2'}),
          StartState(selectedDate: date, completedHabitIds: const {'2', '1'}),
        );
      });
    });
  });
}

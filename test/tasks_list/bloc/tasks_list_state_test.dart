import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/tasks_list/tasks_list.dart';
import 'package:habits_repository/habits_repository.dart';

void main() {
  final task = Habit(
    id: '2',
    name: 'Renew passport',
    frequency: Frequency.once,
    startDate: DateTime(2020),
    createdAt: DateTime(2020),
  );

  group('TasksListState', () {
    test('defaults to an empty list of tasks', () {
      const state = TasksListState();

      expect(state.tasks, isEmpty);
    });

    test('copyWith replaces tasks', () {
      const state = TasksListState();

      final updated = state.copyWith(tasks: [task]);

      expect(updated.tasks, [task]);
    });

    test('copyWith falls back to the receiver when no argument is given', () {
      final state = TasksListState(tasks: [task]);

      expect(state.copyWith(), state);
    });

    group('equality', () {
      test('equal when the task lists match', () {
        expect(
          TasksListState(tasks: [task]),
          TasksListState(tasks: [task]),
        );
      });

      test('unequal when the lists differ in length', () {
        expect(
          TasksListState(tasks: [task]),
          isNot(const TasksListState()),
        );
      });

      test('unequal when the lists differ in content', () {
        expect(
          TasksListState(tasks: [task]),
          isNot(
            TasksListState(tasks: [task.copyWith(name: 'Book dentist')]),
          ),
        );
      });

      test('hashCode matches for equal states', () {
        expect(
          TasksListState(tasks: [task]).hashCode,
          TasksListState(tasks: [task]).hashCode,
        );
      });
    });
  });
}

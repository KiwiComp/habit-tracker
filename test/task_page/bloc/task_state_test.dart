import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/task_page/task_page.dart';
import 'package:habits_repository/habits_repository.dart';

void main() {
  final task = Habit(
    id: 'id',
    name: 'Run',
    frequency: Frequency.once,
    startDate: DateTime(2026, 1, 5),
    createdAt: DateTime(2026),
  );

  group('TaskState', () {
    test('defaults to loading, no task, idle save', () {
      const state = TaskState();

      expect(state.status, TaskStatus.loading);
      expect(state.task, isNull);
      expect(state.saveStatus, TaskSaveStatus.idle);
    });

    group('copyWith', () {
      test('replaces given fields and keeps the rest', () {
        final state = TaskState(status: TaskStatus.loaded, task: task);

        final updated = state.copyWith(saveStatus: TaskSaveStatus.saving);

        expect(updated.status, TaskStatus.loaded);
        expect(updated.task, task);
        expect(updated.saveStatus, TaskSaveStatus.saving);
      });

      test('falls back to the receiver when no argument is given', () {
        final state = TaskState(status: TaskStatus.loaded, task: task);

        expect(state.copyWith(), state);
      });
    });

    group('equality', () {
      test('equal when status, task, and saveStatus all match', () {
        expect(
          TaskState(status: TaskStatus.loaded, task: task),
          TaskState(status: TaskStatus.loaded, task: task),
        );
      });

      test('unequal when saveStatus differs', () {
        expect(
          TaskState(status: TaskStatus.loaded, task: task),
          isNot(
            TaskState(
              status: TaskStatus.loaded,
              task: task,
              saveStatus: TaskSaveStatus.saving,
            ),
          ),
        );
      });

      test('hashCode matches for equal states', () {
        expect(
          TaskState(status: TaskStatus.loaded, task: task).hashCode,
          TaskState(status: TaskStatus.loaded, task: task).hashCode,
        );
      });
    });
  });
}

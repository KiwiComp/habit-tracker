import 'package:habits_repository/habits_repository.dart';
import 'package:meta/meta.dart';

/// The state of `TasksListBloc`.
@immutable
final class TasksListState {
  /// Creates a [TasksListState].
  const TasksListState({this.tasks = const []});

  /// The one-off tasks to show, excluding recurring habits.
  final List<Habit> tasks;

  /// Returns a copy of this state with the given fields replaced.
  TasksListState copyWith({List<Habit>? tasks}) {
    return TasksListState(tasks: tasks ?? this.tasks);
  }

  @override
  bool operator ==(Object other) {
    if (other is! TasksListState) return false;
    if (other.tasks.length != tasks.length) return false;
    for (var i = 0; i < tasks.length; i++) {
      if (other.tasks[i] != tasks[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(tasks);
}

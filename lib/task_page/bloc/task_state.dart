import 'package:habits_repository/habits_repository.dart';
import 'package:meta/meta.dart';

/// How `TaskBloc`'s load of its task is going.
enum TaskStatus {
  /// The initial `HabitsRepository.getHabit` call hasn't resolved yet.
  loading,

  /// The task loaded successfully — see `TaskState.task`.
  loaded,

  /// No task exists for the given id (e.g. a stale notification for a
  /// since-deleted task).
  notFound,
}

/// The state of `TaskBloc`.
@immutable
final class TaskState {
  /// Creates a [TaskState].
  const TaskState({this.status = TaskStatus.loading, this.task});

  /// How the load is going.
  final TaskStatus status;

  /// The loaded task. Only set once [status] is [TaskStatus.loaded].
  final Habit? task;

  /// Returns a copy of this state with the given fields replaced.
  TaskState copyWith({TaskStatus? status, Habit? task}) {
    return TaskState(status: status ?? this.status, task: task ?? this.task);
  }

  @override
  bool operator ==(Object other) =>
      other is TaskState && other.status == status && other.task == task;

  @override
  int get hashCode => Object.hash(status, task);
}

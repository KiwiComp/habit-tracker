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

/// How `TaskBloc`'s save of an edited field (e.g. name) is going.
enum TaskSaveStatus {
  /// No save in flight.
  idle,

  /// A `HabitsRepository.updateHabit` call hasn't resolved yet.
  saving,

  /// The edit persisted successfully.
  success,

  /// The edit failed to persist — see `TaskBloc`'s `addError` call for the
  /// underlying error.
  failure,
}

/// The state of `TaskBloc`.
@immutable
final class TaskState {
  /// Creates a [TaskState].
  const TaskState({
    this.status = TaskStatus.loading,
    this.task,
    this.saveStatus = TaskSaveStatus.idle,
  });

  /// How the load is going.
  final TaskStatus status;

  /// The loaded task. Only set once [status] is [TaskStatus.loaded].
  final Habit? task;

  /// How the most recent edit (e.g. a name change) is saving.
  final TaskSaveStatus saveStatus;

  /// Returns a copy of this state with the given fields replaced.
  TaskState copyWith({
    TaskStatus? status,
    Habit? task,
    TaskSaveStatus? saveStatus,
  }) {
    return TaskState(
      status: status ?? this.status,
      task: task ?? this.task,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TaskState &&
      other.status == status &&
      other.task == task &&
      other.saveStatus == saveStatus;

  @override
  int get hashCode => Object.hash(status, task, saveStatus);
}

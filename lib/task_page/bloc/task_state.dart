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

/// How `TaskBloc`'s archiving (soft-deleting) of the task is going.
enum TaskArchiveStatus {
  /// No archive request in flight.
  idle,

  /// A `HabitsRepository.archiveHabit` call hasn't resolved yet.
  archiving,

  /// The task was archived successfully.
  success,

  /// The archive request failed to persist — see `TaskBloc`'s `addError`
  /// call for the underlying error.
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
    this.archiveStatus = TaskArchiveStatus.idle,
  });

  /// How the load is going.
  final TaskStatus status;

  /// The loaded task. Only set once [status] is [TaskStatus.loaded].
  final Habit? task;

  /// How the most recent edit (e.g. a name change) is saving.
  final TaskSaveStatus saveStatus;

  /// How the most recent archive (soft-delete) request is going.
  final TaskArchiveStatus archiveStatus;

  /// Returns a copy of this state with the given fields replaced.
  TaskState copyWith({
    TaskStatus? status,
    Habit? task,
    TaskSaveStatus? saveStatus,
    TaskArchiveStatus? archiveStatus,
  }) {
    return TaskState(
      status: status ?? this.status,
      task: task ?? this.task,
      saveStatus: saveStatus ?? this.saveStatus,
      archiveStatus: archiveStatus ?? this.archiveStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TaskState &&
      other.status == status &&
      other.task == task &&
      other.saveStatus == saveStatus &&
      other.archiveStatus == archiveStatus;

  @override
  int get hashCode => Object.hash(status, task, saveStatus, archiveStatus);
}

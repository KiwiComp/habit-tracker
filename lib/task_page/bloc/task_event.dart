/// Events handled by `TaskBloc`.
sealed class TaskEvent {
  const TaskEvent();
}

/// The task should be (re)loaded by id. Added once, from `TaskBloc`'s
/// constructor.
final class TaskLoadRequested extends TaskEvent {
  const TaskLoadRequested();
}

/// The user submitted a new name from `showEditNameDialog`.
final class TaskNameChangeSubmitted extends TaskEvent {
  const TaskNameChangeSubmitted(this.name);

  /// The new, already-trimmed name to persist.
  final String name;
}

/// The user picked a new start date via `showDatePicker`, from
/// `_TaskDetails`.
final class TaskStartDateChangeSubmitted extends TaskEvent {
  const TaskStartDateChangeSubmitted(this.date);

  /// The new start date to persist.
  final DateTime date;
}

/// The user confirmed archiving (soft-deleting) the task from
/// `showConfirmationDialog`.
final class TaskArchiveRequestSubmitted extends TaskEvent {
  const TaskArchiveRequestSubmitted();
}

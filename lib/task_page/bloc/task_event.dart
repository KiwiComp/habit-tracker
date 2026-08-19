/// Events handled by `TaskBloc`.
sealed class TaskEvent {
  const TaskEvent();
}

/// The task should be (re)loaded by id. Added once, from `TaskBloc`'s
/// constructor.
final class TaskLoadRequested extends TaskEvent {
  const TaskLoadRequested();
}

/// The user submitted a new name from `EditNameDialog`.
final class TaskNameChangeSubmitted extends TaskEvent {
  const TaskNameChangeSubmitted(this.name);

  /// The new, already-trimmed name to persist.
  final String name;
}

/// The user confirmed archiving (soft-deleting) the task from
/// `ArchiveConfirmationDialog`.
final class TaskArchiveRequestSubmitted extends TaskEvent {
  const TaskArchiveRequestSubmitted();
}

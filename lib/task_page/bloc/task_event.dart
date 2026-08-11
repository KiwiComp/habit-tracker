/// Events handled by `TaskBloc`.
sealed class TaskEvent {
  const TaskEvent();
}

/// The task should be (re)loaded by id. Added once, from `TaskBloc`'s
/// constructor.
final class TaskLoadRequested extends TaskEvent {
  const TaskLoadRequested();
}

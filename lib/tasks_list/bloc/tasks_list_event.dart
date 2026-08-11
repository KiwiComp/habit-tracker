import 'package:habits_repository/habits_repository.dart';

/// Events handled by `TasksListBloc`.
sealed class TasksListEvent {
  const TasksListEvent();
}

/// The set of one-off tasks (from `HabitsRepository.watchHabits`) changed.
final class TasksListTasksChanged extends TasksListEvent {
  /// Creates a [TasksListTasksChanged] event with the latest [tasks].
  const TasksListTasksChanged(this.tasks);

  /// The one-off tasks to show, excluding recurring habits.
  final List<Habit> tasks;
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:habit_tracker/tasks_list/bloc/tasks_list_event.dart';
import 'package:habit_tracker/tasks_list/bloc/tasks_list_state.dart';
import 'package:habits_repository/habits_repository.dart';

/// Watches `HabitsRepository` for the one-off tasks shown on the Tasks tab
/// — everything `watchHabits` returns that's a task, per `Habit.isTask`.
class TasksListBloc extends Bloc<TasksListEvent, TasksListState> {
  /// Creates a [TasksListBloc], subscribing to `habitsRepository` for the
  /// tasks to show.
  TasksListBloc({required this._habitsRepository})
    : super(const TasksListState()) {
    on<TasksListTasksChanged>(_onTasksChanged);
    _habitsSubscription = _habitsRepository.watchHabits().listen(
      (habits) => add(
        TasksListTasksChanged(habits.where((habit) => habit.isTask).toList()),
      ),
    );
  }

  final HabitsRepository _habitsRepository;
  late final StreamSubscription<List<Habit>> _habitsSubscription;

  void _onTasksChanged(
    TasksListTasksChanged event,
    Emitter<TasksListState> emit,
  ) {
    emit(state.copyWith(tasks: event.tasks));
  }

  @override
  Future<void> close() async {
    await _habitsSubscription.cancel();
    return super.close();
  }
}

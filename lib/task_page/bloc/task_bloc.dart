import 'package:bloc/bloc.dart';
import 'package:habit_tracker/task_page/bloc/task_event.dart';
import 'package:habit_tracker/task_page/bloc/task_state.dart';
import 'package:habits_repository/habits_repository.dart';

/// Loads a single task by id for `TaskPage`.
///
/// A one-shot `HabitsRepository.getHabit` read, not a stream — the page is
/// a full-screen modal, so it's the only possible writer of the task while
/// it's open. A "task" is just a `Habit` with `Frequency.once`, so this
/// reads through the same repository method as `HabitBloc`.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  /// Creates a [TaskBloc] that loads `id` via `habitsRepository`.
  TaskBloc({required this._id, required this._habitsRepository})
    : super(const TaskState()) {
    on<TaskLoadRequested>(_onLoadRequested);
    add(const TaskLoadRequested());
  }

  final String _id;
  final HabitsRepository _habitsRepository;

  Future<void> _onLoadRequested(
    TaskLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    final task = await _habitsRepository.getHabit(_id);
    emit(
      task == null
          ? state.copyWith(status: TaskStatus.notFound)
          : state.copyWith(status: TaskStatus.loaded, task: task),
    );
  }
}

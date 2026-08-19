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
    on<TaskNameChangeSubmitted>(_onNameChangeSubmitted);
    on<TaskArchiveRequestSubmitted>(_onTaskArchiveRequestSubmitted);
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

  Future<void> _onNameChangeSubmitted(
    TaskNameChangeSubmitted event,
    Emitter<TaskState> emit,
  ) async {
    final currentTask = state.task;
    if (currentTask == null) return;

    emit(state.copyWith(saveStatus: TaskSaveStatus.saving));
    try {
      final updatedTask = currentTask.copyWith(name: event.name);
      await _habitsRepository.updateHabit(updatedTask);
      emit(
        state.copyWith(
          saveStatus: TaskSaveStatus.success,
          task: updatedTask,
        ),
      );
    } on Exception catch (error, stackTrace) {
      // Reported through the existing BlocObserver.onError logging (see
      // AppBlocObserver) rather than rethrown, so the bloc keeps working —
      // emitting failure below resets to idle instead of leaving the sheet's
      // Save button stuck disabled after a failed retry.
      addError(error, stackTrace);
      emit(state.copyWith(saveStatus: TaskSaveStatus.failure));
      emit(state.copyWith(saveStatus: TaskSaveStatus.idle));
    }
  }

  Future<void> _onTaskArchiveRequestSubmitted(
    TaskArchiveRequestSubmitted event,
    Emitter<TaskState> emit,
  ) async {
    final currentTask = state.task;
    if (currentTask == null) return;

    emit(state.copyWith(archiveStatus: TaskArchiveStatus.archiving));
    try {
      await _habitsRepository.archiveHabit(currentTask.id);
      emit(
        state.copyWith(
          archiveStatus: TaskArchiveStatus.success,
        ),
      );
    } on Exception catch (error, stackTrace) {
      // Reported through the existing BlocObserver.onError logging (see
      // AppBlocObserver) rather than rethrown, so the bloc keeps working —
      // emitting failure below resets to idle instead of leaving the delete
      // tile stuck mid-request after a failed retry.
      addError(error, stackTrace);
      emit(state.copyWith(archiveStatus: TaskArchiveStatus.failure));
      emit(state.copyWith(archiveStatus: TaskArchiveStatus.idle));
    }
  }
}

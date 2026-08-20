import 'package:bloc/bloc.dart';
import 'package:habit_tracker/habit_page/bloc/habit_event.dart';
import 'package:habit_tracker/habit_page/bloc/habit_state.dart';
import 'package:habits_repository/habits_repository.dart';

/// Loads a single habit by id for `HabitPage`.
///
/// A one-shot `HabitsRepository.getHabit` read, not a stream — the page is
/// a full-screen modal, so it's the only possible writer of the habit while
/// it's open.
class HabitBloc extends Bloc<HabitEvent, HabitState> {
  /// Creates a [HabitBloc] that loads `id` via `habitsRepository`.
  HabitBloc({required this._id, required this._habitsRepository})
    : super(const HabitState()) {
    on<HabitLoadRequested>(_onLoadRequested);
    on<HabitNameChangeSubmitted>(_onHabitNameChangeSubmitted);
    on<HabitStartDateChangeSubmitted>(_onHabitStartDateChangeSubmitted);
    on<HabitEndDateChangeSubmitted>(_onHabitEndDateChangeSubmitted);
    add(const HabitLoadRequested());
  }

  final String _id;
  final HabitsRepository _habitsRepository;

  Future<void> _onLoadRequested(
    HabitLoadRequested event,
    Emitter<HabitState> emit,
  ) async {
    final habit = await _habitsRepository.getHabit(_id);
    emit(
      habit == null
          ? state.copyWith(status: HabitStatus.notFound)
          : state.copyWith(status: HabitStatus.loaded, habit: habit),
    );
  }

  Future<void> _onHabitNameChangeSubmitted(
    HabitNameChangeSubmitted event,
    Emitter<HabitState> emit,
  ) async {
    final currentHabit = state.habit;
    if (currentHabit == null) return;

    emit(state.copyWith(saveStatus: HabitSaveStatus.saving));
    try {
      final updatedHabit = currentHabit.copyWith(name: event.name);
      await _habitsRepository.updateHabit(updatedHabit);
      emit(
        state.copyWith(
          saveStatus: HabitSaveStatus.success,
          habit: updatedHabit,
        ),
      );
    } on Exception catch (error, stackTrace) {
      // Reported through the existing BlocObserver.onError logging (see
      // AppBlocObserver) rather than rethrown, so the bloc keeps working —
      // emitting failure below resets to idle instead of leaving the sheet's
      // Save button stuck disabled after a failed retry.
      addError(error, stackTrace);
      emit(state.copyWith(saveStatus: HabitSaveStatus.failure));
      emit(state.copyWith(saveStatus: HabitSaveStatus.idle));
    }
  }

  Future<void> _onHabitStartDateChangeSubmitted(
    HabitStartDateChangeSubmitted event,
    Emitter<HabitState> emit,
  ) async {
    final currentHabit = state.habit;
    if (currentHabit == null) return;

    emit(state.copyWith(saveStatus: HabitSaveStatus.saving));
    try {
      final updatedHabit = currentHabit.copyWith(startDate: event.date);
      await _habitsRepository.updateHabit(updatedHabit);
      emit(
        state.copyWith(
          saveStatus: HabitSaveStatus.success,
          habit: updatedHabit,
        ),
      );
    } on Exception catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(saveStatus: HabitSaveStatus.failure));
      emit(state.copyWith(saveStatus: HabitSaveStatus.idle));
    }
  }

  Future<void> _onHabitEndDateChangeSubmitted(
    HabitEndDateChangeSubmitted event,
    Emitter<HabitState> emit,
  ) async {
    final currentHabit = state.habit;
    if (currentHabit == null) return;

    emit(state.copyWith(saveStatus: HabitSaveStatus.saving));
    try {
      final updatedHabit = currentHabit.copyWith(
        endDate: event.date,
        clearEndDate: event.date == null,
      );
      await _habitsRepository.updateHabit(updatedHabit);
      emit(
        state.copyWith(
          saveStatus: HabitSaveStatus.success,
          habit: updatedHabit,
        ),
      );
    } on Exception catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(saveStatus: HabitSaveStatus.failure));
      emit(state.copyWith(saveStatus: HabitSaveStatus.idle));
    }
  }
}

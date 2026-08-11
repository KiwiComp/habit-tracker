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
}

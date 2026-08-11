import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:habit_tracker/habits_list/bloc/habits_list_event.dart';
import 'package:habit_tracker/habits_list/bloc/habits_list_state.dart';
import 'package:habits_repository/habits_repository.dart';

/// Watches `HabitsRepository` for the recurring habits shown on the
/// Habits tab — everything `watchHabits` returns except one-off tasks.
class HabitsListBloc extends Bloc<HabitsListEvent, HabitsListState> {
  /// Creates a [HabitsListBloc], subscribing to `habitsRepository` for the
  /// habits to show.
  HabitsListBloc({required this._habitsRepository})
    : super(const HabitsListState()) {
    on<HabitsListHabitsChanged>(_onHabitsChanged);
    _habitsSubscription = _habitsRepository.watchHabits().listen(
      (habits) => add(
        HabitsListHabitsChanged(
          habits.where((habit) => !habit.isTask).toList(),
        ),
      ),
    );
  }

  final HabitsRepository _habitsRepository;
  late final StreamSubscription<List<Habit>> _habitsSubscription;

  void _onHabitsChanged(
    HabitsListHabitsChanged event,
    Emitter<HabitsListState> emit,
  ) {
    emit(state.copyWith(habits: event.habits));
  }

  @override
  Future<void> close() async {
    await _habitsSubscription.cancel();
    return super.close();
  }
}

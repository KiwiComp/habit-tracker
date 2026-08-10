import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:habit_tracker/start_page/bloc/start_event.dart';
import 'package:habit_tracker/start_page/bloc/start_state.dart';
import 'package:habits_repository/habits_repository.dart';

/// Manages which day is selected on the start page, and which activities
/// are scheduled for it.
class StartBloc extends Bloc<StartEvent, StartState> {
  /// Creates a [StartBloc], defaulting the selected day to today. The
  /// `habitsRepository` argument is watched for the habits to schedule.
  StartBloc({
    required this._habitsRepository,
    DateTime? initialDate,
  }) : super(StartState(selectedDate: initialDate ?? DateTime.now())) {
    on<StartDaySelected>(_onDaySelected);
    on<StartActivitiesLoaded>(_onActivitiesLoaded);
    _habitsSubscription = _habitsRepository.watchHabits().listen(
      _onHabitsChanged,
    );
  }

  final HabitsRepository _habitsRepository;
  late final StreamSubscription<List<Habit>> _habitsSubscription;
  List<Habit> _habits = [];

  void _onHabitsChanged(List<Habit> habits) {
    _habits = habits;
    add(StartActivitiesLoaded(_scheduledActivities(state.selectedDate)));
  }

  void _onDaySelected(StartDaySelected event, Emitter<StartState> emit) {
    emit(
      state.copyWith(
        selectedDate: event.date,
        activities: _scheduledActivities(event.date),
      ),
    );
  }

  void _onActivitiesLoaded(
    StartActivitiesLoaded event,
    Emitter<StartState> emit,
  ) {
    emit(state.copyWith(activities: event.activities));
  }

  /// The habits due on [date], per [Habit.isScheduledOn].
  List<Habit> _scheduledActivities(DateTime date) {
    return _habits.where((habit) => habit.isScheduledOn(date)).toList();
  }

  @override
  Future<void> close() async {
    await _habitsSubscription.cancel();
    return super.close();
  }
}

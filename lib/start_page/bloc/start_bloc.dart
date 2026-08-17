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
    on<StartEntriesLoaded>(_onEntriesLoaded);
    on<ToggleActivityMarking>(_onToggleActivityMarking);
    _habitsSubscription = _habitsRepository.watchHabits().listen(
      _onHabitsChanged,
    );
    _watchEntriesFor(state.selectedDate);
  }

  final HabitsRepository _habitsRepository;
  late final StreamSubscription<List<Habit>> _habitsSubscription;
  StreamSubscription<List<Entry>>? _entriesSubscription;
  List<Habit> _habits = [];

  void _onHabitsChanged(List<Habit> habits) {
    _habits = habits;
    add(StartActivitiesLoaded(_scheduledActivities(state.selectedDate)));
  }

  /// (Re)subscribes to the entries logged on [date], replacing whichever
  /// day's subscription was previously open — `watchEntriesOnDate` is scoped
  /// to a single day at the query level, so it can't just be re-filtered
  /// in memory the way `_scheduledActivities` re-filters habits.
  void _watchEntriesFor(DateTime date) {
    unawaited(_entriesSubscription?.cancel());
    _entriesSubscription = _habitsRepository
        .watchEntriesOnDate(date)
        .listen(_onEntriesChanged);
  }

  void _onEntriesChanged(List<Entry> entries) {
    add(StartEntriesLoaded(entries));
  }

  void _onDaySelected(StartDaySelected event, Emitter<StartState> emit) {
    _watchEntriesFor(event.date);
    emit(
      state.copyWith(
        selectedDate: event.date,
        activities: _scheduledActivities(event.date),
        // Cleared so a stale previous day's completions can't briefly show
        // against the new day's rows before the new subscription emits.
        completedHabitIds: const {},
      ),
    );
  }

  void _onActivitiesLoaded(
    StartActivitiesLoaded event,
    Emitter<StartState> emit,
  ) {
    emit(state.copyWith(activities: event.activities));
  }

  void _onEntriesLoaded(StartEntriesLoaded event, Emitter<StartState> emit) {
    emit(
      state.copyWith(
        completedHabitIds: event.entries.map((entry) => entry.habitId).toSet(),
      ),
    );
  }

  void _onToggleActivityMarking(
    ToggleActivityMarking event,
    Emitter<StartState> emit,
  ) {
    if (state.completedHabitIds.contains(event.habitId)) {
      unawaited(
        _habitsRepository.unlogEntry(
          habitId: event.habitId,
          date: event.date,
        ),
      );
    } else {
      unawaited(
        _habitsRepository.logEntry(habitId: event.habitId, date: event.date),
      );
    }
  }

  /// The habits due on [date], per [Habit.isScheduledOn].
  List<Habit> _scheduledActivities(DateTime date) {
    return _habits.where((habit) => habit.isScheduledOn(date)).toList();
  }

  @override
  Future<void> close() async {
    await _habitsSubscription.cancel();
    await _entriesSubscription?.cancel();
    return super.close();
  }
}

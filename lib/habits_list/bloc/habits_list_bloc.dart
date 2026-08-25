import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:habit_tracker/habit_stats.dart';
import 'package:habit_tracker/habits_list/bloc/habits_list_event.dart';
import 'package:habit_tracker/habits_list/bloc/habits_list_state.dart';
import 'package:habits_repository/habits_repository.dart';

/// Watches `HabitsRepository` for the recurring habits shown on the
/// Habits tab — everything `watchHabits` returns except one-off tasks —
/// and their entries, keeping each habit's stats current as either
/// changes.
class HabitsListBloc extends Bloc<HabitsListEvent, HabitsListState> {
  /// Creates a [HabitsListBloc], subscribing to `habitsRepository` for the
  /// habits and entries to show.
  HabitsListBloc({required this._habitsRepository})
    : super(const HabitsListState()) {
    on<HabitsListHabitsChanged>(_onHabitsChanged);
    on<HabitsListEntriesChanged>(_onEntriesChanged);
    _habitsSubscription = _habitsRepository.watchHabits().listen(
      (habits) => add(
        HabitsListHabitsChanged(
          habits.where((habit) => !habit.isTask).toList(),
        ),
      ),
    );
    _entriesSubscription = _habitsRepository.watchAllEntries().listen(
      (entries) => add(HabitsListEntriesChanged(entries)),
    );
  }

  final HabitsRepository _habitsRepository;
  late final StreamSubscription<List<Habit>> _habitsSubscription;
  late final StreamSubscription<List<Entry>> _entriesSubscription;

  // Latest values from each stream, combined into `HabitWithStats` below
  // whenever either changes. There's no rxdart dependency here to combine
  // the two streams directly, so this tracks them manually instead.
  List<Habit> _habits = const [];
  List<Entry> _entries = const [];

  void _onHabitsChanged(
    HabitsListHabitsChanged event,
    Emitter<HabitsListState> emit,
  ) {
    _habits = event.habits;
    emit(state.copyWith(habits: _habitsWithStats()));
  }

  void _onEntriesChanged(
    HabitsListEntriesChanged event,
    Emitter<HabitsListState> emit,
  ) {
    _entries = event.entries;
    emit(state.copyWith(habits: _habitsWithStats()));
  }

  List<HabitWithStats> _habitsWithStats() {
    final entriesByHabitId = <String, List<Entry>>{};
    for (final entry in _entries) {
      (entriesByHabitId[entry.habitId] ??= []).add(entry);
    }
    return [
      for (final habit in _habits)
        HabitWithStats(
          habit: habit,
          stats: computeHabitStats(
            habit,
            entriesByHabitId[habit.id] ?? const [],
          ),
        ),
    ];
  }

  @override
  Future<void> close() async {
    await _habitsSubscription.cancel();
    await _entriesSubscription.cancel();
    return super.close();
  }
}

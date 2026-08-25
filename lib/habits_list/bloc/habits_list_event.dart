import 'package:habits_repository/habits_repository.dart';

/// Events handled by `HabitsListBloc`.
sealed class HabitsListEvent {
  const HabitsListEvent();
}

/// The set of recurring habits (from `HabitsRepository.watchHabits`) changed.
final class HabitsListHabitsChanged extends HabitsListEvent {
  /// Creates a [HabitsListHabitsChanged] event with the latest [habits].
  const HabitsListHabitsChanged(this.habits);

  /// The recurring habits to show, excluding one-off tasks.
  final List<Habit> habits;
}

/// The set of entries (from `HabitsRepository.watchAllEntries`) changed.
final class HabitsListEntriesChanged extends HabitsListEvent {
  /// Creates a [HabitsListEntriesChanged] event with the latest [entries].
  const HabitsListEntriesChanged(this.entries);

  /// Every entry logged across every habit.
  final List<Entry> entries;
}

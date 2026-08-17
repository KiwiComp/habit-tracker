import 'package:habits_repository/habits_repository.dart';

/// Events handled by `StartBloc`.
sealed class StartEvent {
  const StartEvent();
}

/// The user selected a different day in the day strip.
final class StartDaySelected extends StartEvent {
  /// Creates a [StartDaySelected] event for the given [date].
  const StartDaySelected(this.date);

  /// The day that was selected.
  final DateTime date;
}

/// The activities scheduled for the currently selected day were (re)loaded.
final class StartActivitiesLoaded extends StartEvent {
  /// Creates a [StartActivitiesLoaded] event with the loaded [activities].
  const StartActivitiesLoaded(this.activities);

  /// The habits scheduled for the currently selected day.
  final List<Habit> activities;
}

/// The entries logged for the currently selected day were (re)loaded.
final class StartEntriesLoaded extends StartEvent {
  /// Creates a [StartEntriesLoaded] event with the loaded [entries].
  const StartEntriesLoaded(this.entries);

  /// The entries logged on the currently selected day, across all habits.
  final List<Entry> entries;
}

/// The user tapped a `ScheduleList` row's completion control for [habitId].
final class ToggleActivityMarking extends StartEvent {
  /// Creates a [ToggleActivityMarking] event for [habitId] on [date].
  const ToggleActivityMarking(this.habitId, this.date);

  /// The habit whose completion is being toggled.
  final String habitId;

  /// The day being toggled — always the currently selected day.
  final DateTime date;
}

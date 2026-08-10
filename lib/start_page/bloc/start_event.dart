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

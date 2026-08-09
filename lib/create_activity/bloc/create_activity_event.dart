import 'package:habit_tracker/create_activity/models/models.dart';
import 'package:habits_repository/habits_repository.dart';

/// Events handled by `CreateActivityBloc`.
sealed class CreateActivityEvent {
  const CreateActivityEvent();
}

/// The user switched between creating a habit and a task.
final class CreateActivityTypeChanged extends CreateActivityEvent {
  /// Creates a [CreateActivityTypeChanged] event for the given [type].
  const CreateActivityTypeChanged(this.type);

  /// The newly selected activity type.
  final ActivityType type;
}

/// The user edited the activity's name.
final class CreateActivityNameChanged extends CreateActivityEvent {
  /// Creates a [CreateActivityNameChanged] event for the given [name].
  const CreateActivityNameChanged(this.name);

  /// The name as currently typed.
  final String name;
}

/// The user chose how a habit repeats: every day, or on specific days.
final class CreateActivityRepeatPatternChanged extends CreateActivityEvent {
  /// Creates a [CreateActivityRepeatPatternChanged] event.
  ///
  /// [frequency] is always [Frequency.daily] or [Frequency.weekdays] — this
  /// event only exists while the form's activity type is
  /// [ActivityType.habit].
  const CreateActivityRepeatPatternChanged(this.frequency);

  /// The newly selected repeat pattern.
  final Frequency frequency;
}

/// The user toggled a single weekday on or off for a [Frequency.weekdays]
/// habit.
final class CreateActivityWeekdayToggled extends CreateActivityEvent {
  /// Creates a [CreateActivityWeekdayToggled] event.
  ///
  /// [weekday] uses `DateTime.monday` (1) through `DateTime.sunday` (7).
  const CreateActivityWeekdayToggled(this.weekday);

  /// The weekday that was tapped.
  final int weekday;
}

/// The user picked a new start date (habit) or occurrence date (task).
final class CreateActivityStartDateChanged extends CreateActivityEvent {
  /// Creates a [CreateActivityStartDateChanged] event for the given [date].
  const CreateActivityStartDateChanged(this.date);

  /// The newly picked date.
  final DateTime date;
}

/// The user tapped "Save".
final class CreateActivitySaveRequested extends CreateActivityEvent {
  const CreateActivitySaveRequested();
}

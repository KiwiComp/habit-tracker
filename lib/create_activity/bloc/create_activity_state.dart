import 'package:habit_tracker/add_activity/models/models.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:meta/meta.dart';

/// The state of `CreateActivityBloc`.
///
/// Shaped to match `HabitsRepository.createHabit`'s parameters exactly
/// (`name`/`frequency`/`startDate`/`weekdays`), so wiring the eventual save
/// call is a matter of passing these fields straight through — see
/// `CreateActivityBloc`'s `CreateActivitySaveRequested` handler.
@immutable
final class CreateActivityState {
  /// Creates a [CreateActivityState].
  CreateActivityState({
    required this.activityType,
    required this.frequency,
    this.name = '',
    this.weekdays = const {},
    DateTime? startDate,
  }) : startDate = startDate ?? DateTime.now();

  /// Whether the user is creating a recurring habit or a one-off task.
  final ActivityType activityType;

  /// The activity's name, as typed so far.
  final String name;

  /// How often the activity repeats.
  ///
  /// Always [Frequency.once] when [activityType] is [ActivityType.task] —
  /// only a [ActivityType.habit] can be [Frequency.daily] or
  /// [Frequency.weekdays].
  final Frequency frequency;

  /// Days the activity is due, using `DateTime.monday` (1) through
  /// `DateTime.sunday` (7). Only meaningful when [frequency] is
  /// [Frequency.weekdays].
  final Set<int> weekdays;

  /// The day the activity starts (habit) or occurs (task).
  final DateTime startDate;

  /// Whether the form has enough to be saved.
  bool get canSave =>
      name.trim().isNotEmpty &&
      (frequency != Frequency.weekdays || weekdays.isNotEmpty);

  /// Returns a copy of this state with the given fields replaced.
  CreateActivityState copyWith({
    ActivityType? activityType,
    String? name,
    Frequency? frequency,
    Set<int>? weekdays,
    DateTime? startDate,
  }) {
    return CreateActivityState(
      activityType: activityType ?? this.activityType,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      weekdays: weekdays ?? this.weekdays,
      startDate: startDate ?? this.startDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CreateActivityState &&
        other.activityType == activityType &&
        other.name == name &&
        other.frequency == frequency &&
        other.weekdays.length == weekdays.length &&
        other.weekdays.containsAll(weekdays) &&
        other.startDate == startDate;
  }

  @override
  int get hashCode => Object.hash(
    activityType,
    name,
    frequency,
    Object.hashAllUnordered(weekdays),
    startDate,
  );
}

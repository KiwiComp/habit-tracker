/// Events handled by `HabitBloc`.
sealed class HabitEvent {
  const HabitEvent();
}

/// The habit should be (re)loaded by id. Added once, from `HabitBloc`'s
/// constructor.
final class HabitLoadRequested extends HabitEvent {
  const HabitLoadRequested();
}

/// The user submitted a new name from `EditNameDialog`.
final class HabitNameChangeSubmitted extends HabitEvent {
  const HabitNameChangeSubmitted(this.name);

  /// The new, already-trimmed name to persist.
  final String name;
}

final class HabitStartDateChangeSubmitted extends HabitEvent {
  const HabitStartDateChangeSubmitted(this.date);

  final DateTime date;
}

final class HabitEndDateChangeSubmitted extends HabitEvent {
  const HabitEndDateChangeSubmitted(this.date);

  /// The new end date, or `null` to clear it ("Never").
  final DateTime? date;
}

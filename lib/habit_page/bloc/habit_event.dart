/// Events handled by `HabitBloc`.
sealed class HabitEvent {
  const HabitEvent();
}

/// The habit should be (re)loaded by id. Added once, from `HabitBloc`'s
/// constructor.
final class HabitLoadRequested extends HabitEvent {
  const HabitLoadRequested();
}

/// The user submitted a new name from `showEditNameDialog`.
final class HabitNameChangeSubmitted extends HabitEvent {
  const HabitNameChangeSubmitted(this.name);

  /// The new, already-trimmed name to persist.
  final String name;
}

/// The user picked a new start date via `showDatePicker`, from
/// `_HabitDetails`.
final class HabitStartDateChangeSubmitted extends HabitEvent {
  const HabitStartDateChangeSubmitted(this.date);

  /// The new start date to persist.
  final DateTime date;
}

/// The user picked a new end date, or chose "Never", via `pickEndDate`,
/// from `_HabitDetails`.
final class HabitEndDateChangeSubmitted extends HabitEvent {
  const HabitEndDateChangeSubmitted(this.date);

  /// The new end date, or `null` to clear it ("Never").
  final DateTime? date;
}

/// The user confirmed archiving (soft-deleting) the habit from
/// `showConfirmationDialog`.
final class HabitArchiveRequestSubmitted extends HabitEvent {
  const HabitArchiveRequestSubmitted();
}

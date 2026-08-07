/// Events handled by `AddActivityBloc`.
sealed class AddActivityEvent {
  const AddActivityEvent();
}

/// The user tapped the "Habit" option in the add-activity sheet.
final class AddActivityHabitTapped extends AddActivityEvent {
  const AddActivityHabitTapped();
}

/// The user tapped the "Task" option in the add-activity sheet.
final class AddActivityTaskTapped extends AddActivityEvent {
  const AddActivityTaskTapped();
}

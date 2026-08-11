/// Events handled by `HabitBloc`.
sealed class HabitEvent {
  const HabitEvent();
}

/// The habit should be (re)loaded by id. Added once, from `HabitBloc`'s
/// constructor.
final class HabitLoadRequested extends HabitEvent {
  const HabitLoadRequested();
}

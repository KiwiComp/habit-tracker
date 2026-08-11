import 'package:habits_repository/habits_repository.dart';
import 'package:meta/meta.dart';

/// The state of `HabitsListBloc`.
@immutable
final class HabitsListState {
  /// Creates a [HabitsListState].
  const HabitsListState({this.habits = const []});

  /// The recurring habits to show, excluding one-off tasks.
  final List<Habit> habits;

  /// Returns a copy of this state with the given fields replaced.
  HabitsListState copyWith({List<Habit>? habits}) {
    return HabitsListState(habits: habits ?? this.habits);
  }

  @override
  bool operator ==(Object other) {
    if (other is! HabitsListState) return false;
    if (other.habits.length != habits.length) return false;
    for (var i = 0; i < habits.length; i++) {
      if (other.habits[i] != habits[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(habits);
}

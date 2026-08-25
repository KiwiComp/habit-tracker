import 'package:habit_tracker/habit_stats.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:meta/meta.dart';

/// A habit paired with its computed [HabitStats], as shown per-row on the
/// Habits list.
@immutable
class HabitWithStats {
  /// Creates a [HabitWithStats].
  const HabitWithStats({required this.habit, required this.stats});

  /// The habit this row represents.
  final Habit habit;

  /// [habit]'s completion/streak numbers, derived from its entries.
  final HabitStats stats;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitWithStats && other.habit == habit && other.stats == stats;

  @override
  int get hashCode => Object.hash(habit, stats);
}

/// The state of `HabitsListBloc`.
@immutable
final class HabitsListState {
  /// Creates a [HabitsListState].
  const HabitsListState({this.habits = const []});

  /// The recurring habits to show, excluding one-off tasks, each paired
  /// with its computed stats.
  final List<HabitWithStats> habits;

  /// Returns a copy of this state with the given fields replaced.
  HabitsListState copyWith({List<HabitWithStats>? habits}) {
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

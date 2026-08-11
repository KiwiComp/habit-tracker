import 'package:habits_repository/habits_repository.dart';
import 'package:meta/meta.dart';

/// How `HabitBloc`'s load of its habit is going.
enum HabitStatus {
  /// The initial `HabitsRepository.getHabit` call hasn't resolved yet.
  loading,

  /// The habit loaded successfully — see `HabitState.habit`.
  loaded,

  /// No habit exists for the given id (e.g. a stale notification for a
  /// since-deleted habit).
  notFound,
}

/// The state of `HabitBloc`.
@immutable
final class HabitState {
  /// Creates a [HabitState].
  const HabitState({this.status = HabitStatus.loading, this.habit});

  /// How the load is going.
  final HabitStatus status;

  /// The loaded habit. Only set once [status] is [HabitStatus.loaded].
  final Habit? habit;

  /// Returns a copy of this state with the given fields replaced.
  HabitState copyWith({HabitStatus? status, Habit? habit}) {
    return HabitState(
      status: status ?? this.status,
      habit: habit ?? this.habit,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HabitState && other.status == status && other.habit == habit;

  @override
  int get hashCode => Object.hash(status, habit);
}

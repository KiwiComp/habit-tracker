import 'package:habit_tracker/habit_stats.dart';
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

/// How `HabitBloc`'s save of an edited field (e.g. name) is going.
enum HabitSaveStatus {
  /// No save in flight.
  idle,

  /// A `HabitsRepository.updateHabit` call hasn't resolved yet.
  saving,

  /// The edit persisted successfully.
  success,

  /// The edit failed to persist — see `HabitBloc`'s `addError` call for the
  /// underlying error.
  failure,
}

/// How `HabitBloc`'s archiving (soft-deleting) of the habit is going.
enum HabitArchiveStatus {
  /// No archive request in flight.
  idle,

  /// A `HabitsRepository.archiveHabit` call hasn't resolved yet.
  archiving,

  /// The habit was archived successfully.
  success,

  /// The archive request failed to persist — see `HabitBloc`'s `addError`
  /// call for the underlying error.
  failure,
}

/// The state of `HabitBloc`.
@immutable
final class HabitState {
  /// Creates a [HabitState].
  const HabitState({
    this.status = HabitStatus.loading,
    this.habit,
    this.stats,
    this.saveStatus = HabitSaveStatus.idle,
    this.archiveStatus = HabitArchiveStatus.idle,
  });

  /// How the load is going.
  final HabitStatus status;

  /// The loaded habit. Only set once [status] is [HabitStatus.loaded].
  final Habit? habit;

  /// Completion/streak numbers for [habit], derived from its entries.
  /// Recomputed whenever an edit changes the habit's schedule. Only set
  /// once [status] is [HabitStatus.loaded].
  final HabitStats? stats;

  /// How the most recent edit (e.g. a name change) is saving.
  final HabitSaveStatus saveStatus;

  /// How the most recent archive (soft-delete) request is going.
  final HabitArchiveStatus archiveStatus;

  /// Returns a copy of this state with the given fields replaced.
  HabitState copyWith({
    HabitStatus? status,
    Habit? habit,
    HabitStats? stats,
    HabitSaveStatus? saveStatus,
    HabitArchiveStatus? archiveStatus,
  }) {
    return HabitState(
      status: status ?? this.status,
      habit: habit ?? this.habit,
      stats: stats ?? this.stats,
      saveStatus: saveStatus ?? this.saveStatus,
      archiveStatus: archiveStatus ?? this.archiveStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HabitState &&
      other.status == status &&
      other.habit == habit &&
      other.stats == stats &&
      other.saveStatus == saveStatus &&
      other.archiveStatus == archiveStatus;

  @override
  int get hashCode =>
      Object.hash(status, habit, stats, saveStatus, archiveStatus);
}

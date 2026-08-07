import 'package:habit_tracker/start_page/models/models.dart';
import 'package:meta/meta.dart';

/// The state of `StartBloc`.
@immutable
final class StartState {
  /// Creates a [StartState].
  const StartState({
    required this.selectedDate,
    this.activities = const [],
  });

  /// The currently selected day.
  final DateTime selectedDate;

  /// The activities scheduled for [selectedDate].
  ///
  /// Empty until something populates it — there's no data source wired up
  /// yet. See `StartActivitiesLoaded`.
  final List<Activity> activities;

  /// Returns a copy of this state with the given fields replaced.
  StartState copyWith({DateTime? selectedDate, List<Activity>? activities}) {
    return StartState(
      selectedDate: selectedDate ?? this.selectedDate,
      activities: activities ?? this.activities,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StartState &&
        other.selectedDate == selectedDate &&
        _activitiesEqual(other.activities, activities);
  }

  @override
  int get hashCode => Object.hash(selectedDate, Object.hashAll(activities));

  bool _activitiesEqual(List<Activity> a, List<Activity> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

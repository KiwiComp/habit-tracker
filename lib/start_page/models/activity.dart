import 'package:meta/meta.dart';

/// A single activity scheduled for a specific day.
///
/// Minimal placeholder shape — extend once the app's actual scheduling
/// domain (recurring habits vs. one-off activities, duration, etc.) is
/// decided.
@immutable
class Activity {
  /// Creates an [Activity].
  const Activity({required this.id, required this.title, required this.date});

  /// A stable identifier for this activity.
  final String id;

  /// The activity's display title.
  final String title;

  /// The day (and time) this activity is scheduled for.
  final DateTime date;

  @override
  bool operator ==(Object other) {
    return other is Activity &&
        other.id == id &&
        other.title == title &&
        other.date == date;
  }

  @override
  int get hashCode => Object.hash(id, title, date);
}

import 'package:habits_repository/src/models/date_only.dart';
import 'package:habits_repository/src/models/frequency.dart';
import 'package:meta/meta.dart';

/// The definition of a habit: what it's called and when it's due.
///
/// Whether a habit was actually done on a given day is tracked separately,
/// by the presence of an `Entry` — a [Habit] on its own only describes the
/// schedule.
@immutable
class Habit {
  /// Creates a [Habit].
  const Habit({
    required this.id,
    required this.name,
    required this.frequency,
    required this.startDate,
    required this.createdAt,
    Set<int> weekdays = const {},
    this.endDate,
    this.archivedAt,
  }) : weekdays = frequency == Frequency.daily ? _allWeekdays : weekdays;

  static const Set<int> _allWeekdays = {
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  };

  /// Uniquely identifies this habit.
  final String id;

  /// The habit's display name, e.g. `'Drink water'`.
  final String name;

  /// How often this habit is due.
  final Frequency frequency;

  /// Days this habit is due, using `DateTime.monday` (1) through
  /// `DateTime.sunday` (7). Always all seven days when [frequency] is
  /// [Frequency.daily] — enforced by the constructor regardless of what's
  /// passed in, so it reads correctly for both newly-created habits and rows
  /// loaded from storage. Empty when [frequency] is [Frequency.once].
  final Set<int> weekdays;

  /// First day the habit applies. Local midnight.
  final DateTime startDate;

  /// Last day the habit's recurrence applies, inclusive — the habit is still
  /// due on this day, just not after it. `null` means the habit never ends.
  final DateTime? endDate;

  /// When the habit was archived, if it has been.
  ///
  /// Set instead of deleting, so past entries keep their history.
  final DateTime? archivedAt;

  /// When the habit was created.
  final DateTime createdAt;

  /// Whether this habit has been archived.
  bool get isArchived => archivedAt != null;

  /// Whether this is a one-off task rather than a recurring habit.
  bool get isTask => frequency == Frequency.once;

  /// Whether this habit is due on [date] according to its schedule.
  ///
  /// The calendar is rendered from this rather than from stored rows — no
  /// future entries are ever written to the database.
  bool isScheduledOn(DateTime date) {
    final day = dateOnly(date);
    if (day.isBefore(startDate)) return false;
    if (endDate != null && day.isAfter(endDate!)) return false;

    switch (frequency) {
      case Frequency.daily:
        return true;
      case Frequency.weekdays:
        return weekdays.contains(day.weekday);
      case Frequency.once:
        return isSameDate(day, startDate);
    }
  }

  /// Returns a copy of this habit with the given fields replaced.
  Habit copyWith({
    String? name,
    Frequency? frequency,
    Set<int>? weekdays,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      weekdays: weekdays ?? this.weekdays,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          other.id == id &&
          other.name == name &&
          other.frequency == frequency &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.archivedAt == archivedAt &&
          other.weekdays.length == weekdays.length &&
          other.weekdays.containsAll(weekdays);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    frequency,
    startDate,
    endDate,
    archivedAt,
    Object.hashAllUnordered(weekdays),
  );

  @override
  String toString() => 'Habit($id, $name, ${frequency.name})';
}

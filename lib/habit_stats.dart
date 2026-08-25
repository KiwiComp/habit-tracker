import 'package:habits_repository/habits_repository.dart';
import 'package:meta/meta.dart';

/// Completion and streak numbers for one habit, derived from its schedule
/// and logged entries.
///
/// [totalScheduled] is `null` exactly when the habit's `endDate` is `null`
/// (an open-ended habit has no fixed total to measure completion against),
/// mirroring `Habit.endDate`'s own nullability rather than needing a
/// separate bounded/unbounded type.
@immutable
class HabitStats {
  /// Creates a [HabitStats].
  const HabitStats({
    required this.completedCount,
    required this.totalScheduled,
    required this.currentStreak,
    required this.longestStreak,
  });

  /// How many scheduled days have a logged [Entry].
  final int completedCount;

  /// How many days the habit is scheduled across its whole lifespan
  /// (`startDate` through `endDate`, inclusive), or `null` if it never
  /// ends.
  final int? totalScheduled;

  /// The streak of consecutive scheduled days completed, ending today (or
  /// at `endDate`, if the habit has already ended).
  final int currentStreak;

  /// The longest streak of consecutive scheduled days completed at any
  /// point in the habit's history so far.
  final int longestStreak;

  /// [completedCount] divided by [totalScheduled], or `null` when
  /// [totalScheduled] is `null`.
  double? get completionRatio =>
      totalScheduled == null ? null : completedCount / totalScheduled!;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitStats &&
          other.completedCount == completedCount &&
          other.totalScheduled == totalScheduled &&
          other.currentStreak == currentStreak &&
          other.longestStreak == longestStreak;

  @override
  int get hashCode =>
      Object.hash(completedCount, totalScheduled, currentStreak, longestStreak);
}

/// Computes [HabitStats] for [habit] from its [entries].
///
/// [asOf] defaults to today and is normalized to local midnight; days after
/// it are never counted toward [HabitStats.currentStreak] or
/// [HabitStats.longestStreak] since they haven't happened yet, even for a
/// habit whose `endDate` is still in the future.
HabitStats computeHabitStats(
  Habit habit,
  List<Entry> entries, {
  DateTime? asOf,
}) {
  final today = _dateOnly(asOf ?? DateTime.now());
  final entryDates = entries.map((entry) => _dateOnly(entry.date)).toSet();

  final endDate = habit.endDate;
  int? totalScheduled;
  if (endDate != null) {
    var scheduledCount = 0;
    for (
      var day = habit.startDate;
      !day.isAfter(endDate);
      day = day.add(const Duration(days: 1))
    ) {
      if (habit.isScheduledOn(day)) scheduledCount++;
    }
    totalScheduled = scheduledCount;
  }

  final lastCountableDay = endDate != null && endDate.isBefore(today)
      ? endDate
      : today;

  // Entries can exist for scheduled days after `today` — the day selector
  // lets a day be marked done ahead of time — so this counts every logged
  // entry, not just ones within the streak walk below (which stops at
  // `today` since a streak can't include days that haven't happened yet).
  final completedCount = entries.length;

  var currentStreak = 0;
  var longestStreak = 0;
  for (
    var day = habit.startDate;
    !day.isAfter(lastCountableDay);
    day = day.add(const Duration(days: 1))
  ) {
    if (!habit.isScheduledOn(day)) continue;
    if (entryDates.contains(day)) {
      currentStreak++;
      if (currentStreak > longestStreak) longestStreak = currentStreak;
    } else {
      currentStreak = 0;
    }
  }

  return HabitStats(
    completedCount: completedCount,
    totalScheduled: totalScheduled,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
  );
}

/// Strips the time component, returning local midnight.
///
/// `Habit`/`Entry` dates are calendar dates, not instants, but
/// `habits_repository` doesn't publicly export its own `dateOnly` helper
/// (`Habit.isScheduledOn` already normalizes internally), so this mirrors
/// it for use against `asOf` and entry dates here.
DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

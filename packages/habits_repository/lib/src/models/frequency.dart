/// How often a habit is scheduled.
enum Frequency {
  /// Every day from `Habit.startDate` onward.
  daily,

  /// Only on the days listed in `Habit.weekdays`.
  weekdays,

  /// A single dated task on `Habit.startDate`.
  once;

  /// Parses a [Frequency] from its [name], e.g. `'daily'`.
  static Frequency fromName(String name) =>
      Frequency.values.firstWhere((frequency) => frequency.name == name);
}

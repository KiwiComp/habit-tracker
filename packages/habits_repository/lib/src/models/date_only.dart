/// Strips the time component, returning local midnight.
///
/// Habit dates are calendar dates, not instants. Always pass user-facing
/// dates through this before comparing or persisting them.
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

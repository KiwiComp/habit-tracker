/// Date-comparison helpers used across the start page.
extension DateTimeDayComparison on DateTime {
  /// Whether this and [other] fall on the same calendar day, ignoring the
  /// time of day.
  bool isSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

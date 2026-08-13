import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/start_page/utils/date_time_x.dart';

void main() {
  group('DateTimeDayComparison.isSameDayAs', () {
    test('is true for the same calendar day regardless of time', () {
      expect(
        DateTime(2026, 1, 5, 9, 30).isSameDayAs(DateTime(2026, 1, 5, 23, 59)),
        isTrue,
      );
    });

    test('is false for different days', () {
      expect(
        DateTime(2026, 1, 5).isSameDayAs(DateTime(2026, 1, 6)),
        isFalse,
      );
      expect(
        DateTime(2026, 1, 5).isSameDayAs(DateTime(2025, 1, 5)),
        isFalse,
      );
    });
  });
}

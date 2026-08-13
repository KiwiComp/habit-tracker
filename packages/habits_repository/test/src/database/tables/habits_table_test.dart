import 'package:flutter_test/flutter_test.dart';
import 'package:habits_repository/src/database/tables/habits_table.dart';

void main() {
  group('HabitsTable', () {
    test('is named "habits"', () {
      expect(HabitsTable().tableName, 'habits');
    });
  });

  group('WeekdaysConverter', () {
    const converter = WeekdaysConverter();

    test('serializes to a sorted, comma-joined string', () {
      expect(converter.toSql({3, 1, 5}), '1,3,5');
    });

    test('serializes an empty set to an empty string', () {
      expect(converter.toSql(const {}), '');
    });

    test('parses a comma-joined string', () {
      expect(converter.fromSql('1,3,5'), {1, 3, 5});
    });

    test('parses an empty string to an empty set', () {
      expect(converter.fromSql(''), const <int>{});
    });
  });

  group('DateOnlyConverter', () {
    const converter = DateOnlyConverter();

    void expectRoundTrip(DateTime date) {
      final days = converter.toSql(date);
      final back = converter.fromSql(days);
      expect(
        back,
        DateTime(date.year, date.month, date.day),
        reason: 'round-tripping $date',
      );
    }

    test('round-trips the Unix epoch as day 0', () {
      expect(converter.toSql(DateTime(1970)), 0);
      expectRoundTrip(DateTime(1970));
    });

    test('round-trips a leap day', () {
      expectRoundTrip(DateTime(2000, 2, 29));
    });

    test('round-trips a pre-epoch date', () {
      expect(converter.toSql(DateTime(1969, 12, 31)), -1);
      expectRoundTrip(DateTime(1969, 12, 31));
    });

    test('round-trips across the spring-forward DST boundary', () {
      // US: clocks skip 2am -> 3am on the second Sunday of March.
      expectRoundTrip(DateTime(2026, 3, 7));
      expectRoundTrip(DateTime(2026, 3, 8));
      expectRoundTrip(DateTime(2026, 3, 9));
      expect(
        converter.toSql(DateTime(2026, 3, 8)) -
            converter.toSql(DateTime(2026, 3, 7)),
        1,
      );
      expect(
        converter.toSql(DateTime(2026, 3, 9)) -
            converter.toSql(DateTime(2026, 3, 8)),
        1,
      );
    });

    test('round-trips across the fall-back DST boundary', () {
      // US: clocks repeat 1am -> 2am on the first Sunday of November.
      expectRoundTrip(DateTime(2026, 10, 31));
      expectRoundTrip(DateTime(2026, 11));
      expectRoundTrip(DateTime(2026, 11, 2));
      expect(
        converter.toSql(DateTime(2026, 11)) -
            converter.toSql(DateTime(2026, 10, 31)),
        1,
      );
      expect(
        converter.toSql(DateTime(2026, 11, 2)) -
            converter.toSql(DateTime(2026, 11)),
        1,
      );
    });

    test('toSql strips time-of-day', () {
      expect(
        converter.toSql(DateTime(2026, 8, 9, 14, 32)),
        converter.toSql(DateTime(2026, 8, 9)),
      );
    });
  });
}

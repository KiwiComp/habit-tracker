import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';
import 'package:habits_repository/habits_repository.dart';

void main() {
  // All dates here are already date-only (local midnight), matching what the
  // form's pickers produce, so comparisons are unambiguous.
  final start = DateTime(2026, 1, 5); // a Monday
  CreateActivityState build({
    ActivityType activityType = ActivityType.habit,
    Frequency frequency = Frequency.daily,
    String name = 'Run',
    Set<int> weekdays = const {},
    DateTime? startDate,
    DateTime? endDate,
    CreateActivitySaveStatus status = CreateActivitySaveStatus.idle,
  }) {
    return CreateActivityState(
      activityType: activityType,
      frequency: frequency,
      name: name,
      weekdays: weekdays,
      startDate: startDate ?? start,
      endDate: endDate,
      status: status,
    );
  }

  group('CreateActivityState', () {
    test('defaults startDate to today, normalized to local midnight', () {
      final state = CreateActivityState(
        activityType: ActivityType.habit,
        frequency: Frequency.daily,
      );
      final today = DateTime.now();

      expect(state.startDate, DateTime(today.year, today.month, today.day));
    });

    test('strips the time-of-day from a supplied startDate', () {
      final state = CreateActivityState(
        activityType: ActivityType.habit,
        frequency: Frequency.daily,
        startDate: DateTime(2026, 1, 5, 14, 30),
      );

      expect(state.startDate, DateTime(2026, 1, 5));
    });

    test('a habit ending the same day it starts can be saved', () {
      // Regression: the default startDate used to keep a time-of-day, so an
      // end date of the same calendar day (picker returns midnight) read as
      // "before" the start and wrongly disabled Save.
      final today = DateTime.now();
      final state = CreateActivityState(
        activityType: ActivityType.habit,
        frequency: Frequency.daily,
        name: 'Run',
        endDate: DateTime(today.year, today.month, today.day),
      );

      expect(state.canSave, isTrue);
    });

    group('canSave', () {
      test('is false while a save is in flight', () {
        expect(
          build(status: CreateActivitySaveStatus.saving).canSave,
          isFalse,
        );
      });

      test('is false when the name is empty or whitespace', () {
        expect(build(name: '').canSave, isFalse);
        expect(build(name: '   ').canSave, isFalse);
      });

      test('is true for a valid daily habit', () {
        expect(build().canSave, isTrue);
      });

      test('requires at least one weekday for a weekdays habit', () {
        expect(
          build(frequency: Frequency.weekdays).canSave,
          isFalse,
        );
        expect(
          build(
            frequency: Frequency.weekdays,
            weekdays: {DateTime.monday},
          ).canSave,
          isTrue,
        );
      });

      test('rejects an end date before the start date', () {
        expect(
          build(endDate: start.subtract(const Duration(days: 1))).canSave,
          isFalse,
        );
      });

      test('allows an end date on or after the start date', () {
        expect(build(endDate: start).canSave, isTrue);
        expect(
          build(endDate: start.add(const Duration(days: 1))).canSave,
          isTrue,
        );
      });
    });

    group('hasUnreachableWeekdayWindow', () {
      test('is false unless the frequency is weekdays', () {
        expect(
          build(
            endDate: start.add(const Duration(days: 2)),
          ).hasUnreachableWeekdayWindow,
          isFalse,
        );
      });

      test('is false when there is no end date', () {
        expect(
          build(
            frequency: Frequency.weekdays,
            weekdays: {DateTime.saturday},
          ).hasUnreachableWeekdayWindow,
          isFalse,
        );
      });

      test('is false when no weekday is selected', () {
        expect(
          build(
            frequency: Frequency.weekdays,
            endDate: start.add(const Duration(days: 2)),
          ).hasUnreachableWeekdayWindow,
          isFalse,
        );
      });

      test('is false when a selected weekday falls within the range', () {
        // Mon–Wed range, Monday selected → reachable.
        expect(
          build(
            frequency: Frequency.weekdays,
            weekdays: {DateTime.monday},
            endDate: start.add(const Duration(days: 2)),
          ).hasUnreachableWeekdayWindow,
          isFalse,
        );
      });

      test('is true when no selected weekday falls within the range', () {
        // Mon–Wed range, only Saturday selected → never occurs.
        expect(
          build(
            frequency: Frequency.weekdays,
            weekdays: {DateTime.saturday},
            endDate: start.add(const Duration(days: 2)),
          ).hasUnreachableWeekdayWindow,
          isTrue,
        );
      });
    });

    group('copyWith', () {
      test('replaces only the given fields', () {
        final updated = build().copyWith(
          name: 'Swim',
          frequency: Frequency.once,
        );
        expect(updated.name, 'Swim');
        expect(updated.frequency, Frequency.once);
        expect(updated.startDate, start);
      });

      test('clearEndDate wins over a passed endDate', () {
        final withEnd = build(endDate: start);
        expect(withEnd.copyWith(clearEndDate: true).endDate, isNull);
        expect(
          withEnd.copyWith(endDate: start.add(const Duration(days: 3))).endDate,
          start.add(const Duration(days: 3)),
        );
      });

      test('with no arguments preserves every field', () {
        final state = build(
          frequency: Frequency.weekdays,
          weekdays: {DateTime.monday, DateTime.friday},
          endDate: start,
        );
        expect(state.copyWith(), state);
      });
    });

    group('equality', () {
      test('two states with the same fields are equal', () {
        expect(build(), build());
        expect(build().hashCode, build().hashCode);
      });

      test('weekday ordering does not affect equality', () {
        final a = build(weekdays: {DateTime.monday, DateTime.friday});
        final b = build(weekdays: {DateTime.friday, DateTime.monday});
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('differing fields are not equal', () {
        expect(build(name: 'a'), isNot(build(name: 'b')));
      });
    });
  });
}

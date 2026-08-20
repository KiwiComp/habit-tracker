import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';

import '../../helpers/helpers.dart';

void main() {
  final firstDate = DateTime(2026, 1, 15);

  group('EndDateField', () {
    testWidgets('shows "Never" when there is no end date', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: EndDateField(
            date: null,
            firstDate: firstDate,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Never'), findsOneWidget);
    });

    testWidgets('shows the end date, formatted, when set', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: EndDateField(
            date: DateTime(2026, 1, 20),
            firstDate: firstDate,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('20 Jan 2026'), findsOneWidget);
    });

    testWidgets('choosing "Never" reports null', (tester) async {
      var called = false;
      DateTime? result = DateTime(2026, 1, 20);
      await tester.pumpApp(
        Scaffold(
          body: EndDateField(
            // Start from a set date so the only "Never" is the sheet option.
            date: DateTime(2026, 1, 20),
            firstDate: firstDate,
            onChanged: (date) {
              called = true;
              result = date;
            },
          ),
        ),
      );

      await tester.tap(find.text('20 Jan 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Never'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(result, isNull);
    });

    testWidgets('opens the picker directly when there is no end date yet', (
      tester,
    ) async {
      DateTime? picked;
      await tester.pumpApp(
        Scaffold(
          body: EndDateField(
            date: null,
            firstDate: firstDate,
            onChanged: (date) => picked = date,
          ),
        ),
      );

      await tester.tap(find.text('Never'));
      await tester.pumpAndSettle();

      // No "Never / On a date" sheet — nothing to offer clearing when the
      // end date is already unset, so it jumps straight to the calendar.
      expect(find.text('On a date'), findsNothing);

      // Picker opens on the firstDate month (January 2026); pick the 20th.
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(picked, DateTime(2026, 1, 20));
    });

    testWidgets('reopening seeds the picker with the existing end date', (
      tester,
    ) async {
      DateTime? picked;
      await tester.pumpApp(
        Scaffold(
          body: EndDateField(
            date: DateTime(2026, 1, 25),
            firstDate: firstDate,
            onChanged: (date) => picked = date,
          ),
        ),
      );

      await tester.tap(find.text('25 Jan 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('On a date'));
      await tester.pumpAndSettle();

      // The picker opens on the existing end date (the 25th); move to the 28th.
      await tester.tap(find.text('28'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(picked, DateTime(2026, 1, 28));
    });
  });
}

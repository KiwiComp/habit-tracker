import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';

import '../../helpers/helpers.dart';

void main() {
  group('StartDateField', () {
    testWidgets('shows the current date, formatted', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: StartDateField(
            label: 'Date',
            date: DateTime(2026, 1, 15),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('15 Jan 2026'), findsOneWidget);
    });

    testWidgets('opens a date picker and reports the picked date', (
      tester,
    ) async {
      DateTime? picked;
      await tester.pumpApp(
        Scaffold(
          body: StartDateField(
            label: 'Date',
            date: DateTime(2026, 1, 15),
            onChanged: (date) => picked = date,
          ),
        ),
      );

      await tester.tap(find.text('15 Jan 2026'));
      await tester.pumpAndSettle();

      // The picker opens on January 2026; choose the 20th and confirm.
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(picked, DateTime(2026, 1, 20));
    });
  });
}

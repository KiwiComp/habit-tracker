import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/start_page/widgets/widgets.dart';

import '../../helpers/helpers.dart';

void main() {
  group('EmptySchedule', () {
    testWidgets('shows the empty-state title, subtitle and icons', (
      tester,
    ) async {
      await tester.pumpApp(const Scaffold(body: EmptySchedule()));

      expect(find.text('There is nothing scheduled'), findsOneWidget);
      expect(find.text('Try adding new activities'), findsOneWidget);
      expect(find.byIcon(Icons.edit_calendar_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });
  });
}

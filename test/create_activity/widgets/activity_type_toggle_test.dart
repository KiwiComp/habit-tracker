import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ActivityTypeToggle', () {
    testWidgets('renders a Habit and a Task segment', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: ActivityTypeToggle(
            selected: ActivityType.habit,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Habit'), findsOneWidget);
      expect(find.text('Task'), findsOneWidget);
    });

    testWidgets('reports the newly selected type', (tester) async {
      ActivityType? changed;
      await tester.pumpApp(
        Scaffold(
          body: ActivityTypeToggle(
            selected: ActivityType.habit,
            onChanged: (type) => changed = type,
          ),
        ),
      );

      await tester.tap(find.text('Task'));
      expect(changed, ActivityType.task);
    });
  });
}

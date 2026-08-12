import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';
import 'package:habits_repository/habits_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  group('RepeatPatternSelector', () {
    testWidgets('renders the daily and weekdays options', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: RepeatPatternSelector(
            selected: Frequency.daily,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Every day'), findsOneWidget);
      expect(find.text('Specific days'), findsOneWidget);
    });

    testWidgets('reports the newly selected pattern', (tester) async {
      Frequency? changed;
      await tester.pumpApp(
        Scaffold(
          body: RepeatPatternSelector(
            selected: Frequency.daily,
            onChanged: (frequency) => changed = frequency,
          ),
        ),
      );

      await tester.tap(find.text('Specific days'));
      expect(changed, Frequency.weekdays);
    });
  });
}

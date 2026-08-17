import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/start_page/widgets/widgets.dart';
import 'package:habits_repository/habits_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  final selectedDate = DateTime(2026, 1, 5);

  Habit habit(String id, String name, Frequency frequency) => Habit(
    id: id,
    name: name,
    frequency: frequency,
    startDate: selectedDate,
    createdAt: selectedDate,
  );

  final readHabit = habit('h', 'Read', Frequency.daily);
  final passportTask = habit('t', 'Passport', Frequency.once);

  Widget list({
    required ValueChanged<Habit> onTap,
    Set<String> completedHabitIds = const {},
  }) => Scaffold(
    body: ScheduleList(
      activities: [readHabit, passportTask],
      completedHabitIds: completedHabitIds,
      selectedDate: selectedDate,
      onActivityTap: onTap,
    ),
  );

  group('ScheduleList', () {
    testWidgets('renders a row per activity, with a type-specific icon', (
      tester,
    ) async {
      await tester.pumpApp(list(onTap: (_) {}));

      expect(find.text('Read'), findsOneWidget);
      expect(find.text('Passport'), findsOneWidget);
      // Habit vs task get different glyphs.
      expect(find.byIcon(Icons.military_tech_outlined), findsOneWidget);
      expect(find.byIcon(Icons.task_alt_outlined), findsOneWidget);
    });

    testWidgets('reports the tapped activity', (tester) async {
      Habit? tapped;
      await tester.pumpApp(list(onTap: (habit) => tapped = habit));

      await tester.tap(find.text('Passport'));
      expect(tapped, passportTask);
    });
  });
}

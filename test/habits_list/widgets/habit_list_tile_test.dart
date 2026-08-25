import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/habit_stats.dart';
import 'package:habit_tracker/habits_list/widgets/widgets.dart';
import 'package:habits_repository/habits_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  final habit = Habit(
    id: '1',
    name: 'Read',
    frequency: Frequency.weekdays,
    weekdays: const {DateTime.monday, DateTime.wednesday},
    startDate: DateTime(2020),
    endDate: DateTime(2020, 2),
    createdAt: DateTime(2020),
  );

  const stats = HabitStats(
    completedCount: 3,
    totalScheduled: 8,
    currentStreak: 2,
    longestStreak: 5,
  );

  group('HabitListTile', () {
    testWidgets('shows the habit name and its read-only weekday chips', (
      tester,
    ) async {
      await tester.pumpApp(
        HabitListTile(habit: habit, stats: stats, onTap: () {}),
      );

      expect(find.text('Read'), findsOneWidget);
      final chipRow = tester.widget<WeekdayChipRow>(
        find.byType(WeekdayChipRow),
      );
      expect(chipRow.weekdays, habit.weekdays);
      expect(chipRow.onToggled, isNull);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        HabitListTile(habit: habit, stats: stats, onTap: () => tapped = true),
      );

      await tester.tap(find.byType(HabitListTile));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets(
      'shows completed/total when the habit has an end date',
      (tester) async {
        await tester.pumpApp(
          HabitListTile(habit: habit, stats: stats, onTap: () {}),
        );

        expect(find.text('3/8'), findsOneWidget);
      },
    );

    testWidgets(
      'shows just the completed count when the habit has no end date',
      (tester) async {
        final unboundedHabit = habit.copyWith(clearEndDate: true);
        const unboundedStats = HabitStats(
          completedCount: 3,
          totalScheduled: null,
          currentStreak: 2,
          longestStreak: 5,
        );

        await tester.pumpApp(
          HabitListTile(
            habit: unboundedHabit,
            stats: unboundedStats,
            onTap: () {},
          ),
        );

        expect(find.text('3'), findsOneWidget);
        expect(find.text('3/8'), findsNothing);
      },
    );

    testWidgets(
      'shows the all_inclusive icon only when the habit has no end date',
      (tester) async {
        await tester.pumpApp(
          HabitListTile(habit: habit, stats: stats, onTap: () {}),
        );
        expect(find.byIcon(Icons.all_inclusive), findsNothing);

        final unboundedHabit = habit.copyWith(clearEndDate: true);
        await tester.pumpApp(
          HabitListTile(habit: unboundedHabit, stats: stats, onTap: () {}),
        );
        expect(find.byIcon(Icons.all_inclusive), findsOneWidget);
      },
    );

    testWidgets('shows the current and longest streak', (tester) async {
      await tester.pumpApp(
        HabitListTile(habit: habit, stats: stats, onTap: () {}),
      );

      expect(find.text('Current streak: 2'), findsOneWidget);
      expect(find.text('Longest streak: 5'), findsOneWidget);
    });
  });
}

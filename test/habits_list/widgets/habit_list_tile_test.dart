import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';
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
    createdAt: DateTime(2020),
  );

  group('HabitListTile', () {
    testWidgets('shows the habit name and its read-only weekday chips', (
      tester,
    ) async {
      await tester.pumpApp(HabitListTile(habit: habit, onTap: () {}));

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
        HabitListTile(habit: habit, onTap: () => tapped = true),
      );

      await tester.tap(find.byType(HabitListTile));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/tasks_list/widgets/widgets.dart';
import 'package:habits_repository/habits_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  final task = Habit(
    id: '2',
    name: 'Renew passport',
    frequency: Frequency.once,
    startDate: DateTime(2020),
    createdAt: DateTime(2020),
  );

  group('TaskListTile', () {
    testWidgets('shows the task name', (tester) async {
      await tester.pumpApp(TaskListTile(task: task, onTap: () {}));

      expect(find.text('Renew passport'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        TaskListTile(task: task, onTap: () => tapped = true),
      );

      await tester.tap(find.byType(TaskListTile));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}

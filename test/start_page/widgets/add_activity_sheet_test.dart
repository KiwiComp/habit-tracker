import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/create_activity/models/models.dart';
import 'package:habit_tracker/start_page/widgets/widgets.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AddActivitySheet', () {
    testWidgets('renders the title and both options', (tester) async {
      await tester.pumpApp(const Scaffold(body: AddActivitySheet()));

      expect(find.text('Add activity'), findsOneWidget);
      expect(find.text('Habit'), findsOneWidget);
      expect(find.text('Repeats on a schedule'), findsOneWidget);
      expect(find.text('Task'), findsOneWidget);
      expect(find.text('Happens once'), findsOneWidget);
    });

    group('show', () {
      Future<ActivityType?> openAndTap(
        WidgetTester tester, {
        String? tap,
      }) async {
        ActivityType? result;
        await tester.pumpApp(
          Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async => result = await AddActivitySheet.show(
                  context,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        if (tap != null) {
          await tester.tap(find.text(tap));
        } else {
          // Dismiss by tapping the barrier above the sheet.
          await tester.tapAt(const Offset(400, 20));
        }
        await tester.pumpAndSettle();
        return result;
      }

      testWidgets('resolves with habit when the habit option is tapped', (
        tester,
      ) async {
        expect(await openAndTap(tester, tap: 'Habit'), ActivityType.habit);
      });

      testWidgets('resolves with task when the task option is tapped', (
        tester,
      ) async {
        expect(await openAndTap(tester, tap: 'Task'), ActivityType.task);
      });

      testWidgets('resolves with null when dismissed', (tester) async {
        expect(await openAndTap(tester), isNull);
      });
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app/app.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';
import 'package:habit_tracker/habits_list/habits_list.dart';
import 'package:habit_tracker/start_page/start_page.dart';
import 'package:habit_tracker/start_page/widgets/widgets.dart';
import 'package:habit_tracker/tasks_list/tasks_list.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  late _MockHabitsRepository repo;

  setUp(() {
    repo = _MockHabitsRepository();
    when(
      () => repo.watchHabits(),
    ).thenAnswer((_) => Stream.value(const <Habit>[]));
    when(
      () => repo.watchEntriesOnDate(any()),
    ).thenAnswer((_) => Stream.value(const <Entry>[]));
    when(() => repo.close()).thenAnswer((_) async {});
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(App(habitsRepository: repo));
    await tester.pump();
  }

  Finder navItem(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  group('ShellScaffold', () {
    testWidgets('the bottom nav switches between branches', (tester) async {
      await pumpApp(tester);

      await tester.tap(navItem('Habits'));
      await tester.pumpAndSettle();
      expect(find.byType(HabitsListPage), findsOneWidget);

      await tester.tap(navItem('Tasks'));
      await tester.pumpAndSettle();
      expect(find.byType(TasksListPage), findsOneWidget);

      await tester.tap(navItem('Today'));
      await tester.pumpAndSettle();
      expect(find.byType(StartPage), findsOneWidget);
    });

    testWidgets('the add-activity FAB opens the sheet and routes to create', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.byType(AddActivitySheet), findsOneWidget);

      // Picking a type pops the sheet and pushes the create route.
      await tester.tap(find.text('Habit'));
      await tester.pumpAndSettle();
      expect(find.byType(CreateActivityPage), findsOneWidget);
    });

    testWidgets('dismissing the sheet without a choice stays put', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      // Tap the barrier above the sheet to dismiss it.
      await tester.tapAt(const Offset(400, 20));
      await tester.pumpAndSettle();

      expect(find.byType(AddActivitySheet), findsNothing);
      expect(find.byType(CreateActivityPage), findsNothing);
      expect(find.byType(StartPage), findsOneWidget);
    });
  });
}

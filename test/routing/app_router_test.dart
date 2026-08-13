import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/app/app.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';
import 'package:habit_tracker/habit_page/habit_page.dart';
import 'package:habit_tracker/habits_list/habits_list.dart';
import 'package:habit_tracker/start_page/start_page.dart';
import 'package:habit_tracker/task_page/task_page.dart';
import 'package:habit_tracker/tasks_list/tasks_list.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  late _MockHabitsRepository repo;

  setUp(() {
    repo = _MockHabitsRepository();
    // A fresh stream per call so each bloc (start/list) gets its own.
    when(
      () => repo.watchHabits(),
    ).thenAnswer((_) => Stream.value(const <Habit>[]));
    when(() => repo.getHabit('h1')).thenAnswer((_) async => null);
    when(() => repo.getHabit('t1')).thenAnswer((_) async => null);
    when(() => repo.close()).thenAnswer((_) async {});
  });

  Future<GoRouter> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(App(habitsRepository: repo));
    await tester.pump();
    return GoRouter.of(tester.element(find.byType(StartPage)));
  }

  group('buildAppRouter', () {
    testWidgets('starts on the Today tab', (tester) async {
      await pumpApp(tester);
      expect(find.byType(StartPage), findsOneWidget);
    });

    testWidgets('/habits builds the habits list', (tester) async {
      final router = await pumpApp(tester);
      router.go('/habits');
      await tester.pumpAndSettle();
      expect(find.byType(HabitsListPage), findsOneWidget);
    });

    testWidgets('/tasks builds the tasks list', (tester) async {
      final router = await pumpApp(tester);
      router.go('/tasks');
      await tester.pumpAndSettle();
      expect(find.byType(TasksListPage), findsOneWidget);
    });

    testWidgets('/create builds the create page for the passed type', (
      tester,
    ) async {
      final router = await pumpApp(tester);
      unawaited(router.push('/create', extra: ActivityType.task));
      await tester.pumpAndSettle();
      expect(find.byType(CreateActivityPage), findsOneWidget);
    });

    testWidgets('/habit/:id builds the habit page', (tester) async {
      final router = await pumpApp(tester);
      unawaited(router.push('/habit/h1'));
      await tester.pumpAndSettle();
      expect(find.byType(HabitPage), findsOneWidget);
    });

    testWidgets('/task/:id builds the task page', (tester) async {
      final router = await pumpApp(tester);
      unawaited(router.push('/task/t1'));
      await tester.pumpAndSettle();
      expect(find.byType(TaskPage), findsOneWidget);
    });
  });
}

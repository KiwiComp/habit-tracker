import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/tasks_list/tasks_list.dart';
import 'package:habit_tracker/tasks_list/widgets/widgets.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  late _MockHabitsRepository repo;
  late StreamController<List<Habit>> habits;

  Habit habit({String id = '1', String name = 'Read'}) => Habit(
    id: id,
    name: name,
    frequency: Frequency.daily,
    startDate: DateTime(2020),
    createdAt: DateTime(2020),
  );

  Habit task({String id = '2', String name = 'Renew passport'}) => Habit(
    id: id,
    name: name,
    frequency: Frequency.once,
    startDate: DateTime(2020),
    createdAt: DateTime(2020),
  );

  setUp(() {
    repo = _MockHabitsRepository();
    habits = StreamController<List<Habit>>.broadcast();
    when(() => repo.watchHabits()).thenAnswer((_) => habits.stream);
  });

  tearDown(() async {
    await habits.close();
  });

  Future<void> pumpTasksListPage(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const TasksListPage()),
        GoRoute(
          path: '/task/:id',
          builder: (_, state) =>
              Scaffold(body: Text('task-${state.pathParameters['id']}')),
        ),
      ],
    );

    await tester.pumpWidget(
      RepositoryProvider<HabitsRepository>.value(
        value: repo,
        child: MaterialApp.router(
          theme: const AppTheme.light().themeData,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
  }

  group('TasksListPage', () {
    testWidgets('shows the empty view when there are no tasks', (
      tester,
    ) async {
      await pumpTasksListPage(tester);
      habits.add([]);
      await tester.pumpAndSettle();

      expect(find.byType(TaskAndHabitListEmptyView), findsOneWidget);
      expect(find.text('You have no created tasks yet'), findsOneWidget);
      expect(
        find.text('Click the plus button to create your first task'),
        findsOneWidget,
      );
      expect(find.byType(TaskListTile), findsNothing);
    });

    testWidgets('lists tasks and excludes habits', (tester) async {
      await pumpTasksListPage(tester);
      habits.add([habit(), task()]);
      await tester.pumpAndSettle();

      expect(find.byType(TaskAndHabitListEmptyView), findsNothing);
      expect(find.byType(TaskListTile), findsOneWidget);
      expect(find.text('Renew passport'), findsOneWidget);
      expect(find.text('Read'), findsNothing);
    });

    testWidgets('tapping a task opens its detail page', (tester) async {
      await pumpTasksListPage(tester);
      habits.add([task()]);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Renew passport'));
      await tester.pumpAndSettle();

      expect(find.text('task-2'), findsOneWidget);
    });
  });
}

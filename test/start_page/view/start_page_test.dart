import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/start_page/start_page.dart';
import 'package:habit_tracker/start_page/widgets/widgets.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  late _MockHabitsRepository repo;
  late StreamController<List<Habit>> habits;

  Habit dailyHabit({String id = '1', String name = 'Read'}) => Habit(
    id: id,
    name: name,
    frequency: Frequency.daily,
    startDate: DateTime(2020),
    createdAt: DateTime(2020),
  );

  setUp(() {
    repo = _MockHabitsRepository();
    habits = StreamController<List<Habit>>.broadcast();
    when(() => repo.watchHabits()).thenAnswer((_) => habits.stream);
  });

  tearDown(() => habits.close());

  Future<void> pumpStartPage(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const StartPage()),
        GoRoute(
          path: '/habit/:id',
          builder: (_, state) =>
              Scaffold(body: Text('habit-${state.pathParameters['id']}')),
        ),
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

  group('StartPage', () {
    testWidgets('shows the day selector and the empty schedule', (
      tester,
    ) async {
      await pumpStartPage(tester);
      habits.add([]);
      await tester.pumpAndSettle();

      expect(find.byType(DaySelector), findsOneWidget);
      expect(find.byType(EmptySchedule), findsOneWidget);
      expect(find.byType(ScheduleList), findsNothing);
    });

    testWidgets('lists due activities and opens the tapped one', (
      tester,
    ) async {
      await pumpStartPage(tester);
      habits.add([dailyHabit()]);
      await tester.pumpAndSettle();

      expect(find.byType(ScheduleList), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);

      await tester.tap(find.text('Read'));
      await tester.pumpAndSettle();

      expect(find.text('habit-1'), findsOneWidget);
    });

    testWidgets('jump-to-today FAB shows off-today and returns to today', (
      tester,
    ) async {
      await pumpStartPage(tester);
      habits.add([]);
      await tester.pumpAndSettle();

      // Hidden while today is selected.
      expect(find.byTooltip('Jump to today'), findsNothing);

      // Select a past day → the FAB appears.
      tester
          .element(find.byType(DaySelector))
          .read<StartBloc>()
          .add(StartDaySelected(DateTime(2020)));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Jump to today'), findsOneWidget);

      // Tapping it jumps back to today → the FAB hides again.
      await tester.tap(find.byTooltip('Jump to today'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Jump to today'), findsNothing);
    });
  });
}

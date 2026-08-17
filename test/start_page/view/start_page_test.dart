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
  late StreamController<List<Entry>> entries;

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
    entries = StreamController<List<Entry>>.broadcast();
    when(() => repo.watchHabits()).thenAnswer((_) => habits.stream);
    when(
      () => repo.watchEntriesOnDate(any()),
    ).thenAnswer((_) => entries.stream);
    when(
      () => repo.logEntry(
        habitId: any(named: 'habitId'),
        date: any(named: 'date'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => repo.unlogEntry(
        habitId: any(named: 'habitId'),
        date: any(named: 'date'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    await habits.close();
    await entries.close();
  });

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

    testWidgets('lists due activities and toggles the tapped one done', (
      tester,
    ) async {
      await pumpStartPage(tester);
      habits.add([dailyHabit()]);
      await tester.pumpAndSettle();

      expect(find.byType(ScheduleList), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);

      // Tapping a row marks it done for the selected day; opening its detail
      // page moved to the slide-reveal action (see the next test).
      await tester.tap(find.text('Read'));
      await tester.pumpAndSettle();

      verify(
        () => repo.logEntry(habitId: '1', date: any(named: 'date')),
      ).called(1);
    });

    testWidgets("a row's slide action opens its detail page", (tester) async {
      await pumpStartPage(tester);
      habits.add([dailyHabit()]);
      await tester.pumpAndSettle();

      // The action only becomes hit-testable once the row is open.
      await tester.drag(find.text('Read'), const Offset(-64, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_right));
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

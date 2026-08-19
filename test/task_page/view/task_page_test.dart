import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/task_page/task_page.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  late HabitsRepository habitsRepository;

  final task = Habit(
    id: 'id',
    name: 'Run',
    frequency: Frequency.once,
    startDate: DateTime(2026, 1, 5),
    createdAt: DateTime(2026),
  );

  setUpAll(() {
    registerFallbackValue(task);
  });

  setUp(() {
    habitsRepository = _MockHabitsRepository();
    when(
      () => habitsRepository.getHabit(task.id),
    ).thenAnswer((_) async => task);
  });

  Future<void> pumpPage(WidgetTester tester) {
    return tester.pumpApp(
      TaskPage(id: task.id),
      habitsRepository: habitsRepository,
    );
  }

  group('TaskPage', () {
    testWidgets('editing the name persists it and updates the tile', (
      tester,
    ) async {
      when(
        () => habitsRepository.updateHabit(any()),
      ).thenAnswer((_) async {});
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Run'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Sprint');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      verify(
        () => habitsRepository.updateHabit(
          any(that: isA<Habit>().having((h) => h.name, 'name', 'Sprint')),
        ),
      ).called(1);
      expect(find.text('Sprint'), findsOneWidget);
      expect(find.text('Run'), findsNothing);
    });

    testWidgets('shows a SnackBar when the name save fails', (tester) async {
      when(
        () => habitsRepository.updateHabit(any()),
      ).thenThrow(Exception('boom'));
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Run'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Sprint');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump(); // process the save
      await tester.pump(const Duration(seconds: 1)); // let the SnackBar in

      expect(find.text("Couldn't save. Please try again."), findsOneWidget);
      // The displayed name is left unchanged after a failed save.
      expect(find.text('Run'), findsOneWidget);

      await tester.pumpAndSettle(); // drain the SnackBar timer
    });

    testWidgets('editing the start date persists it and updates the tile', (
      tester,
    ) async {
      when(
        () => habitsRepository.updateHabit(any()),
      ).thenAnswer((_) async {});
      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('5/1/2026'), findsOneWidget);

      await tester.tap(find.text('Date'));
      await tester.pumpAndSettle();

      // The picker opens on January 2026 (task.startDate); pick the 20th.
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      verify(
        () => habitsRepository.updateHabit(
          any(
            that: isA<Habit>().having(
              (h) => h.startDate,
              'startDate',
              DateTime(2026, 1, 20),
            ),
          ),
        ),
      ).called(1);
      expect(find.text('20/1/2026'), findsOneWidget);
      expect(find.text('5/1/2026'), findsNothing);
    });

    testWidgets('shows a SnackBar when the start date save fails', (
      tester,
    ) async {
      when(
        () => habitsRepository.updateHabit(any()),
      ).thenThrow(Exception('boom'));
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pump(); // process the save
      await tester.pump(const Duration(seconds: 1)); // let the SnackBar in

      expect(find.text("Couldn't save. Please try again."), findsOneWidget);
      // The displayed date is left unchanged after a failed save.
      expect(find.text('5/1/2026'), findsOneWidget);

      await tester.pumpAndSettle(); // drain the SnackBar timer
    });

    testWidgets('archiving via the delete tile pops the page on success', (
      tester,
    ) async {
      when(
        () => habitsRepository.archiveHabit(task.id),
      ).thenAnswer((_) async {});

      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => TaskPage(id: task.id)),
              ),
              child: const Text('open'),
            ),
          ),
        ),
        habitsRepository: habitsRepository,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Yes'));
      await tester.pumpAndSettle();

      verify(() => habitsRepository.archiveHabit(task.id)).called(1);
      expect(find.byType(TaskPage), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('shows a SnackBar when archiving fails', (tester) async {
      when(
        () => habitsRepository.archiveHabit(task.id),
      ).thenThrow(Exception('boom'));
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Yes'));
      await tester.pump(); // process the archive
      await tester.pump(const Duration(seconds: 1)); // let the SnackBar in

      expect(find.text("Couldn't delete. Please try again."), findsOneWidget);
      // Still on the task page — a failed archive doesn't pop.
      expect(find.byType(TaskPage), findsOneWidget);

      await tester.pumpAndSettle(); // drain the SnackBar timer
    });

    testWidgets('tapping No on the confirmation dialog archives nothing', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'No'));
      await tester.pumpAndSettle();

      verifyNever(() => habitsRepository.archiveHabit(any()));
      expect(find.byType(TaskPage), findsOneWidget);
    });
  });
}

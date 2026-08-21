import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/habit_page/habit_page.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  late HabitsRepository habitsRepository;

  final habit = Habit(
    id: 'id',
    name: 'Meditate',
    frequency: Frequency.daily,
    startDate: DateTime(2026, 1, 5),
    createdAt: DateTime(2026),
  );

  setUpAll(() {
    registerFallbackValue(habit);
  });

  setUp(() {
    habitsRepository = _MockHabitsRepository();
    when(
      () => habitsRepository.getHabit(habit.id),
    ).thenAnswer((_) async => habit);
  });

  Future<void> pumpPage(WidgetTester tester) {
    return tester.pumpApp(
      HabitPage(id: habit.id),
      habitsRepository: habitsRepository,
    );
  }

  group('HabitPage', () {
    testWidgets('editing the name persists it and updates the tile', (
      tester,
    ) async {
      when(
        () => habitsRepository.updateHabit(any()),
      ).thenAnswer((_) async {});
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Meditate'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Journal');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      verify(
        () => habitsRepository.updateHabit(
          any(that: isA<Habit>().having((h) => h.name, 'name', 'Journal')),
        ),
      ).called(1);
      expect(find.text('Journal'), findsOneWidget);
      expect(find.text('Meditate'), findsNothing);
    });

    testWidgets('shows a SnackBar when the name save fails', (tester) async {
      when(
        () => habitsRepository.updateHabit(any()),
      ).thenThrow(Exception('boom'));
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Meditate'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Journal');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump(); // process the save
      await tester.pump(const Duration(seconds: 1)); // let the SnackBar in

      expect(find.text("Couldn't save. Please try again."), findsOneWidget);
      // The displayed name is left unchanged after a failed save.
      expect(find.text('Meditate'), findsOneWidget);

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

      await tester.tap(find.text('Starts on'));
      await tester.pumpAndSettle();

      // The picker opens on January 2026 (habit.startDate); pick the 20th.
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

      await tester.tap(find.text('Starts on'));
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

    testWidgets(
      'editing the end date via "On a date" persists it and updates the '
      'tile',
      (tester) async {
        final habitWithEndDate = habit.copyWith(endDate: DateTime(2026, 6, 15));
        when(
          () => habitsRepository.getHabit(habit.id),
        ).thenAnswer((_) async => habitWithEndDate);
        when(
          () => habitsRepository.updateHabit(any()),
        ).thenAnswer((_) async {});
        await pumpPage(tester);
        await tester.pumpAndSettle();

        expect(find.text('15/6/2026'), findsOneWidget);

        await tester.tap(find.text('Ends'));
        await tester.pumpAndSettle();

        expect(find.text('Never'), findsOneWidget);
        expect(find.text('On a date'), findsOneWidget);

        await tester.tap(find.text('On a date'));
        await tester.pumpAndSettle();

        // The picker opens seeded on the current end date (June 2026).
        await tester.tap(find.text('20'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        verify(
          () => habitsRepository.updateHabit(
            any(
              that: isA<Habit>().having(
                (h) => h.endDate,
                'endDate',
                DateTime(2026, 6, 20),
              ),
            ),
          ),
        ).called(1);
        expect(find.text('20/6/2026'), findsOneWidget);
        expect(find.text('15/6/2026'), findsNothing);
      },
    );

    testWidgets('choosing "Never" clears the end date', (tester) async {
      final habitWithEndDate = habit.copyWith(endDate: DateTime(2026, 6, 15));
      when(
        () => habitsRepository.getHabit(habit.id),
      ).thenAnswer((_) async => habitWithEndDate);
      when(
        () => habitsRepository.updateHabit(any()),
      ).thenAnswer((_) async {});
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ends'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Never'));
      await tester.pumpAndSettle();

      verify(
        () => habitsRepository.updateHabit(
          any(that: isA<Habit>().having((h) => h.endDate, 'endDate', isNull)),
        ),
      ).called(1);
      expect(find.text('15/6/2026'), findsNothing);
      expect(find.byIcon(Icons.all_inclusive), findsOneWidget);
    });

    testWidgets('shows a SnackBar when the end date save fails', (
      tester,
    ) async {
      final habitWithEndDate = habit.copyWith(endDate: DateTime(2026, 6, 15));
      when(
        () => habitsRepository.getHabit(habit.id),
      ).thenAnswer((_) async => habitWithEndDate);
      when(
        () => habitsRepository.updateHabit(any()),
      ).thenThrow(Exception('boom'));
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ends'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Never'));
      await tester.pump(); // process the save
      await tester.pump(const Duration(seconds: 1)); // let the SnackBar in

      expect(find.text("Couldn't save. Please try again."), findsOneWidget);
      // The displayed date is left unchanged after a failed save.
      expect(find.text('15/6/2026'), findsOneWidget);

      await tester.pumpAndSettle(); // drain the SnackBar timer
    });

    testWidgets('archiving via the delete tile pops the page on success', (
      tester,
    ) async {
      when(
        () => habitsRepository.archiveHabit(habit.id),
      ).thenAnswer((_) async {});

      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HabitPage(id: habit.id),
                ),
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

      verify(() => habitsRepository.archiveHabit(habit.id)).called(1);
      expect(find.byType(HabitPage), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('shows a SnackBar when archiving fails', (tester) async {
      when(
        () => habitsRepository.archiveHabit(habit.id),
      ).thenThrow(Exception('boom'));
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Yes'));
      await tester.pump(); // process the archive
      await tester.pump(const Duration(seconds: 1)); // let the SnackBar in

      expect(find.text("Couldn't delete. Please try again."), findsOneWidget);
      // Still on the habit page — a failed archive doesn't pop.
      expect(find.byType(HabitPage), findsOneWidget);

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
      expect(find.byType(HabitPage), findsOneWidget);
    });
  });
}

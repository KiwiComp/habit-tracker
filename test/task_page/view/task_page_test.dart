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
  });
}

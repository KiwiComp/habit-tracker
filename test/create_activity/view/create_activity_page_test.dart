import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  late HabitsRepository habitsRepository;

  final savedHabit = Habit(
    id: 'id',
    name: 'Run',
    frequency: Frequency.daily,
    startDate: DateTime(2026, 1, 5),
    createdAt: DateTime(2026),
  );

  setUpAll(() {
    registerFallbackValue(Frequency.daily);
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(<int>{});
  });

  setUp(() {
    habitsRepository = _MockHabitsRepository();
  });

  void stubCreate({Object? throws}) {
    final call = when(
      () => habitsRepository.createHabit(
        name: any(named: 'name'),
        frequency: any(named: 'frequency'),
        startDate: any(named: 'startDate'),
        weekdays: any(named: 'weekdays'),
        endDate: any(named: 'endDate'),
      ),
    );
    if (throws != null) {
      call.thenThrow(throws);
    } else {
      call.thenAnswer((_) async => savedHabit);
    }
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    ActivityType initialType = ActivityType.habit,
  }) {
    return tester.pumpApp(
      CreateActivityPage(initialType: initialType),
      habitsRepository: habitsRepository,
    );
  }

  group('CreateActivityPage', () {
    testWidgets('renders the form scaffold', (tester) async {
      await pumpPage(tester);

      expect(find.text('New activity'), findsOneWidget);
      expect(find.byType(ActivityTypeToggle), findsOneWidget);
      expect(find.byType(AppTextField), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    });

    testWidgets('shows habit-only fields for a habit', (tester) async {
      await pumpPage(tester);

      expect(find.byType(RepeatPatternSelector), findsOneWidget);
      expect(find.byType(EndDateField), findsOneWidget);
    });

    testWidgets('hides habit-only fields once switched to a task', (
      tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.text('Task'));
      await tester.pumpAndSettle();

      expect(find.byType(RepeatPatternSelector), findsNothing);
      expect(find.byType(EndDateField), findsNothing);
    });

    testWidgets('reveals the weekday chips for a "Specific days" habit', (
      tester,
    ) async {
      await pumpPage(tester);
      expect(find.byType(WeekdayChipRow), findsNothing);

      await tester.tap(find.text('Specific days'));
      await tester.pumpAndSettle();

      expect(find.byType(WeekdayChipRow), findsOneWidget);
    });

    testWidgets('disables Save until a name is entered', (tester) async {
      await pumpPage(tester);

      ElevatedButton saveButton() => tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save'),
      );

      expect(saveButton().enabled, isFalse);

      await tester.enterText(find.byType(TextField), 'Run');
      await tester.pump();

      expect(saveButton().enabled, isTrue);
    });

    testWidgets('saves and pops on success', (tester) async {
      stubCreate();

      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const CreateActivityPage(initialType: ActivityType.habit),
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

      await tester.enterText(find.byType(TextField), 'Run');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      verify(
        () => habitsRepository.createHabit(
          name: 'Run',
          frequency: Frequency.daily,
          startDate: any(named: 'startDate'),
          weekdays: any(named: 'weekdays'),
        ),
      ).called(1);
      expect(find.byType(CreateActivityPage), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('shows a SnackBar when the save fails', (tester) async {
      stubCreate(throws: Exception('boom'));
      await pumpPage(tester);

      await tester.enterText(find.byType(TextField), 'Run');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump(); // process the save
      await tester.pump(const Duration(seconds: 1)); // let the SnackBar appear

      expect(find.text("Couldn't save. Please try again."), findsOneWidget);

      await tester.pumpAndSettle(); // drain the SnackBar timer
    });

    testWidgets('fills the whole form through the UI and saves', (
      tester,
    ) async {
      stubCreate();

      // Tall viewport so every field is on-screen (the form scrolls), keeping
      // the date/sheet taps from missing widgets below the fold.
      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const CreateActivityPage(initialType: ActivityType.habit),
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

      await tester.enterText(find.byType(TextField), 'Gym');

      // Switch to specific days and pick Monday via the chip.
      await tester.tap(find.text('Specific days'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Monday'));

      // Pick a start date (accept the default) via the field's picker.
      await tester.tap(find.byType(StartDateField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Set the end date to "Never" via the field's sheet. Target the sheet
      // option by its unique icon — the field itself also shows "Never".
      await tester.tap(find.byType(EndDateField));
      await tester.pumpAndSettle();
      await tester.tap(
        find.ancestor(
          of: find.byIcon(Icons.all_inclusive),
          matching: find.byType(InkWell),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      verify(
        () => habitsRepository.createHabit(
          name: 'Gym',
          frequency: Frequency.weekdays,
          startDate: any(named: 'startDate'),
          weekdays: {DateTime.monday},
        ),
      ).called(1);
      expect(find.byType(CreateActivityPage), findsNothing);
    });

    testWidgets('warns when the weekday window can never occur', (
      tester,
    ) async {
      await pumpPage(tester);

      final context = tester.element(find.byType(AppTextField));
      context.read<CreateActivityBloc>()
        ..add(const CreateActivityNameChanged('Run'))
        ..add(const CreateActivityRepeatPatternChanged(Frequency.weekdays))
        ..add(const CreateActivityWeekdayToggled(DateTime.saturday))
        // A Mon–Wed window that never includes a Saturday.
        ..add(CreateActivityStartDateChanged(DateTime(2026, 1, 5)))
        ..add(CreateActivityEndDateChanged(DateTime(2026, 1, 7)));
      await tester.pumpAndSettle();

      expect(find.textContaining('never occur'), findsOneWidget);
    });
  });
}

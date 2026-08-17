import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/start_page/start_page.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  group('StartBloc', () {
    final today = DateTime(2026, 8, 6);
    final tomorrow = DateTime(2026, 8, 7);

    late _MockHabitsRepository habitsRepository;
    late StreamController<List<Habit>> habitsController;
    late StreamController<List<Entry>> entriesController;

    Habit habit({
      required String id,
      required String name,
      Frequency frequency = Frequency.daily,
      DateTime? startDate,
    }) {
      return Habit(
        id: id,
        name: name,
        frequency: frequency,
        startDate: startDate ?? today,
        createdAt: today,
      );
    }

    Entry entry({required String habitId, required DateTime date}) {
      return Entry(
        id: 'entry-$habitId-${date.toIso8601String()}',
        habitId: habitId,
        date: date,
        createdAt: date,
      );
    }

    setUp(() {
      habitsRepository = _MockHabitsRepository();
      habitsController = StreamController<List<Habit>>.broadcast();
      entriesController = StreamController<List<Entry>>.broadcast();
      when(
        () => habitsRepository.watchHabits(),
      ).thenAnswer((_) => habitsController.stream);
      when(
        () => habitsRepository.watchEntriesOnDate(any()),
      ).thenAnswer((_) => entriesController.stream);
      when(
        () => habitsRepository.logEntry(
          habitId: any(named: 'habitId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => habitsRepository.unlogEntry(
          habitId: any(named: 'habitId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async {});
    });

    tearDown(() async {
      await habitsController.close();
      await entriesController.close();
    });

    test('initial state has no activities', () {
      expect(
        StartBloc(
          habitsRepository: habitsRepository,
          initialDate: today,
        ).state.activities,
        isEmpty,
      );
    });

    blocTest<StartBloc, StartState>(
      'emits activities when StartActivitiesLoaded is added',
      build: () =>
          StartBloc(habitsRepository: habitsRepository, initialDate: today),
      act: (bloc) =>
          bloc.add(StartActivitiesLoaded([habit(id: '1', name: 'Read')])),
      expect: () => [
        equals(
          StartState(
            selectedDate: today,
            activities: [habit(id: '1', name: 'Read')],
          ),
        ),
      ],
    );

    blocTest<StartBloc, StartState>(
      'loads habits scheduled on the selected day as they arrive from '
      'HabitsRepository',
      build: () =>
          StartBloc(habitsRepository: habitsRepository, initialDate: today),
      act: (_) => habitsController.add([habit(id: '1', name: 'Drink water')]),
      expect: () => [
        equals(
          StartState(
            selectedDate: today,
            activities: [habit(id: '1', name: 'Drink water')],
          ),
        ),
      ],
    );

    blocTest<StartBloc, StartState>(
      'recomputes activities for the newly selected day from the cached '
      'habit list, excluding ones not scheduled on it',
      build: () =>
          StartBloc(habitsRepository: habitsRepository, initialDate: today),
      act: (bloc) async {
        habitsController.add([
          habit(id: '1', name: 'One-off', frequency: Frequency.once),
        ]);
        await Future<void>.delayed(Duration.zero);
        bloc.add(StartDaySelected(tomorrow));
      },
      skip: 1,
      expect: () => [equals(StartState(selectedDate: tomorrow))],
    );

    blocTest<StartBloc, StartState>(
      'tracks completed habit ids as entries arrive for the selected day',
      build: () =>
          StartBloc(habitsRepository: habitsRepository, initialDate: today),
      act: (_) => entriesController.add([entry(habitId: '1', date: today)]),
      expect: () => [
        equals(
          StartState(selectedDate: today, completedHabitIds: const {'1'}),
        ),
      ],
    );

    blocTest<StartBloc, StartState>(
      'clears completed habit ids when the selected day changes, ahead of '
      "the new day's entries arriving",
      build: () =>
          StartBloc(habitsRepository: habitsRepository, initialDate: today),
      act: (bloc) async {
        entriesController.add([entry(habitId: '1', date: today)]);
        await Future<void>.delayed(Duration.zero);
        bloc.add(StartDaySelected(tomorrow));
      },
      skip: 1,
      expect: () => [
        equals(StartState(selectedDate: tomorrow)),
      ],
      verify: (_) {
        verify(() => habitsRepository.watchEntriesOnDate(tomorrow)).called(1);
      },
    );

    blocTest<StartBloc, StartState>(
      'logs an entry when toggling a habit with no entry yet',
      build: () =>
          StartBloc(habitsRepository: habitsRepository, initialDate: today),
      act: (bloc) => bloc.add(ToggleActivityMarking('1', today)),
      expect: () => <StartState>[],
      verify: (_) {
        verify(
          () => habitsRepository.logEntry(habitId: '1', date: today),
        ).called(1);
        verifyNever(
          () => habitsRepository.unlogEntry(
            habitId: any(named: 'habitId'),
            date: any(named: 'date'),
          ),
        );
      },
    );

    blocTest<StartBloc, StartState>(
      'unlogs an entry when toggling an already-completed habit',
      build: () =>
          StartBloc(habitsRepository: habitsRepository, initialDate: today),
      act: (bloc) async {
        entriesController.add([entry(habitId: '1', date: today)]);
        await Future<void>.delayed(Duration.zero);
        bloc.add(ToggleActivityMarking('1', today));
      },
      skip: 1,
      expect: () => <StartState>[],
      verify: (_) {
        verify(
          () => habitsRepository.unlogEntry(habitId: '1', date: today),
        ).called(1);
        verifyNever(
          () => habitsRepository.logEntry(
            habitId: any(named: 'habitId'),
            date: any(named: 'date'),
          ),
        );
      },
    );
  });
}

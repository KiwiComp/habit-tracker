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

    setUp(() {
      habitsRepository = _MockHabitsRepository();
      habitsController = StreamController<List<Habit>>.broadcast();
      when(
        () => habitsRepository.watchHabits(),
      ).thenAnswer((_) => habitsController.stream);
    });

    tearDown(() => habitsController.close());

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
  });
}

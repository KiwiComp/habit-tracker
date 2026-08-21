import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/tasks_list/tasks_list.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  late _MockHabitsRepository habitsRepository;
  late StreamController<List<Habit>> habitsController;

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
    habitsRepository = _MockHabitsRepository();
    habitsController = StreamController<List<Habit>>.broadcast();
    when(
      () => habitsRepository.watchHabits(),
    ).thenAnswer((_) => habitsController.stream);
  });

  tearDown(() async {
    await habitsController.close();
  });

  TasksListBloc buildBloc() =>
      TasksListBloc(habitsRepository: habitsRepository);

  group('TasksListBloc', () {
    test('starts with an empty list of tasks', () {
      expect(buildBloc().state, const TasksListState());
    });

    blocTest<TasksListBloc, TasksListState>(
      'emits the one-off tasks and excludes habits when the repository '
      'stream emits',
      build: buildBloc,
      act: (_) => habitsController.add([habit(), task()]),
      expect: () => [
        TasksListState(tasks: [task()]),
      ],
    );

    blocTest<TasksListBloc, TasksListState>(
      'emits again on each subsequent stream update',
      build: buildBloc,
      act: (_) async {
        habitsController.add([task()]);
        await Future<void>.delayed(Duration.zero);
        habitsController.add([
          task(),
          task(id: '3', name: 'Book dentist'),
        ]);
      },
      expect: () => [
        TasksListState(tasks: [task()]),
        TasksListState(tasks: [task(), task(id: '3', name: 'Book dentist')]),
      ],
    );

    test('close cancels the repository subscription', () async {
      final bloc = buildBloc();
      expect(habitsController.hasListener, isTrue);

      await bloc.close();

      expect(habitsController.hasListener, isFalse);
    });
  });
}

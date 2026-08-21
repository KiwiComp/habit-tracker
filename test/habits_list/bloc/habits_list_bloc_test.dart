import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/habits_list/habits_list.dart';
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

  HabitsListBloc buildBloc() =>
      HabitsListBloc(habitsRepository: habitsRepository);

  group('HabitsListBloc', () {
    test('starts with an empty list of habits', () {
      expect(buildBloc().state, const HabitsListState());
    });

    blocTest<HabitsListBloc, HabitsListState>(
      'emits the recurring habits and excludes tasks when the repository '
      'stream emits',
      build: buildBloc,
      act: (_) => habitsController.add([habit(), task()]),
      expect: () => [
        HabitsListState(habits: [habit()]),
      ],
    );

    blocTest<HabitsListBloc, HabitsListState>(
      'emits again on each subsequent stream update',
      build: buildBloc,
      act: (_) async {
        habitsController.add([habit()]);
        await Future<void>.delayed(Duration.zero);
        habitsController.add([habit(), habit(id: '3', name: 'Stretch')]);
      },
      expect: () => [
        HabitsListState(habits: [habit()]),
        HabitsListState(habits: [habit(), habit(id: '3', name: 'Stretch')]),
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

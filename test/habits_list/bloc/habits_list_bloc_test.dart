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
  late StreamController<List<Entry>> entriesController;

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

  Entry entry({required String habitId, required DateTime date}) => Entry(
    id: '$habitId-$date',
    habitId: habitId,
    date: date,
    createdAt: date,
  );

  setUp(() {
    habitsRepository = _MockHabitsRepository();
    habitsController = StreamController<List<Habit>>.broadcast();
    entriesController = StreamController<List<Entry>>.broadcast();
    when(
      () => habitsRepository.watchHabits(),
    ).thenAnswer((_) => habitsController.stream);
    when(
      () => habitsRepository.watchAllEntries(),
    ).thenAnswer((_) => entriesController.stream);
  });

  tearDown(() async {
    await habitsController.close();
    await entriesController.close();
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
        isA<HabitsListState>().having(
          (s) => s.habits.map((h) => h.habit),
          'habits',
          [habit()],
        ),
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
        isA<HabitsListState>().having(
          (s) => s.habits.map((h) => h.habit),
          'habits',
          [habit()],
        ),
        isA<HabitsListState>().having(
          (s) => s.habits.map((h) => h.habit),
          'habits',
          [habit(), habit(id: '3', name: 'Stretch')],
        ),
      ],
    );

    blocTest<HabitsListBloc, HabitsListState>(
      "computes each habit's stats from entries grouped by habitId, "
      'recomputing when entries change',
      build: buildBloc,
      act: (_) async {
        habitsController.add([habit(), habit(id: '3', name: 'Stretch')]);
        await Future<void>.delayed(Duration.zero);
        entriesController.add([
          entry(habitId: '1', date: DateTime(2020)),
          entry(habitId: '1', date: DateTime(2020, 1, 2)),
          entry(habitId: '3', date: DateTime(2020)),
        ]);
      },
      skip: 1, // the habits-only emission
      expect: () => [
        isA<HabitsListState>().having(
          (s) => {
            for (final h in s.habits) h.habit.id: h.stats.completedCount,
          },
          'completedCount by habit id',
          {'1': 2, '3': 1},
        ),
      ],
    );

    test('close cancels both repository subscriptions', () async {
      final bloc = buildBloc();
      expect(habitsController.hasListener, isTrue);
      expect(entriesController.hasListener, isTrue);

      await bloc.close();

      expect(habitsController.hasListener, isFalse);
      expect(entriesController.hasListener, isFalse);
    });
  });
}

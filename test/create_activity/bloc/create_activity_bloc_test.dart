import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  late HabitsRepository habitsRepository;

  final startDate = DateTime(2026, 1, 5);
  final savedHabit = Habit(
    id: 'id',
    name: 'Run',
    frequency: Frequency.daily,
    startDate: startDate,
    createdAt: DateTime(2026),
  );

  setUpAll(() {
    registerFallbackValue(Frequency.daily);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    habitsRepository = _MockHabitsRepository();
  });

  CreateActivityBloc buildBloc({
    ActivityType initialType = ActivityType.habit,
  }) {
    return CreateActivityBloc(
      initialType: initialType,
      habitsRepository: habitsRepository,
    );
  }

  CreateActivityState validState() => CreateActivityState(
    activityType: ActivityType.habit,
    frequency: Frequency.daily,
    name: 'Run',
    startDate: startDate,
  );

  group('CreateActivityBloc', () {
    group('initial state', () {
      test('a habit defaults to daily', () {
        final bloc = buildBloc();
        expect(bloc.state.activityType, ActivityType.habit);
        expect(bloc.state.frequency, Frequency.daily);
      });

      test('a task defaults to once', () {
        final bloc = buildBloc(initialType: ActivityType.task);
        expect(bloc.state.activityType, ActivityType.task);
        expect(bloc.state.frequency, Frequency.once);
      });

      test('startDate defaults to today when initialStartDate is omitted', () {
        final bloc = buildBloc();
        final today = DateTime.now();
        expect(bloc.state.startDate.year, today.year);
        expect(bloc.state.startDate.month, today.month);
        expect(bloc.state.startDate.day, today.day);
      });

      test('startDate uses initialStartDate when given', () {
        final bloc = CreateActivityBloc(
          initialType: ActivityType.habit,
          habitsRepository: habitsRepository,
          initialStartDate: startDate,
        );
        expect(bloc.state.startDate, startDate);
      });
    });

    blocTest<CreateActivityBloc, CreateActivityState>(
      'CreateActivityTypeChanged to task forces once and clears weekdays/end',
      build: buildBloc,
      seed: () => CreateActivityState(
        activityType: ActivityType.habit,
        frequency: Frequency.weekdays,
        weekdays: const {DateTime.monday},
        startDate: startDate,
        endDate: startDate,
      ),
      act: (bloc) =>
          bloc.add(const CreateActivityTypeChanged(ActivityType.task)),
      expect: () => [
        isA<CreateActivityState>()
            .having((s) => s.activityType, 'activityType', ActivityType.task)
            .having((s) => s.frequency, 'frequency', Frequency.once)
            .having((s) => s.weekdays, 'weekdays', isEmpty)
            .having((s) => s.endDate, 'endDate', isNull),
      ],
    );

    blocTest<CreateActivityBloc, CreateActivityState>(
      'CreateActivityTypeChanged to habit restores daily',
      build: () => buildBloc(initialType: ActivityType.task),
      act: (bloc) =>
          bloc.add(const CreateActivityTypeChanged(ActivityType.habit)),
      expect: () => [
        isA<CreateActivityState>()
            .having((s) => s.activityType, 'activityType', ActivityType.habit)
            .having((s) => s.frequency, 'frequency', Frequency.daily),
      ],
    );

    blocTest<CreateActivityBloc, CreateActivityState>(
      'CreateActivityNameChanged updates the name',
      build: buildBloc,
      act: (bloc) => bloc.add(const CreateActivityNameChanged('Meditate')),
      expect: () => [
        isA<CreateActivityState>().having((s) => s.name, 'name', 'Meditate'),
      ],
    );

    blocTest<CreateActivityBloc, CreateActivityState>(
      'RepeatPatternChanged to daily clears weekdays',
      build: buildBloc,
      seed: () => CreateActivityState(
        activityType: ActivityType.habit,
        frequency: Frequency.weekdays,
        weekdays: const {DateTime.monday, DateTime.friday},
        startDate: startDate,
      ),
      act: (bloc) =>
          bloc.add(const CreateActivityRepeatPatternChanged(Frequency.daily)),
      expect: () => [
        isA<CreateActivityState>()
            .having((s) => s.frequency, 'frequency', Frequency.daily)
            .having((s) => s.weekdays, 'weekdays', isEmpty),
      ],
    );

    blocTest<CreateActivityBloc, CreateActivityState>(
      'RepeatPatternChanged to weekdays keeps the existing weekdays',
      build: buildBloc,
      seed: () => CreateActivityState(
        activityType: ActivityType.habit,
        frequency: Frequency.daily,
        weekdays: const {DateTime.monday},
        startDate: startDate,
      ),
      act: (bloc) => bloc.add(
        const CreateActivityRepeatPatternChanged(Frequency.weekdays),
      ),
      expect: () => [
        isA<CreateActivityState>()
            .having((s) => s.frequency, 'frequency', Frequency.weekdays)
            .having((s) => s.weekdays, 'weekdays', {DateTime.monday}),
      ],
    );

    blocTest<CreateActivityBloc, CreateActivityState>(
      'WeekdayToggled adds an unselected day and removes a selected one',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const CreateActivityWeekdayToggled(DateTime.monday))
        ..add(const CreateActivityWeekdayToggled(DateTime.monday)),
      expect: () => [
        isA<CreateActivityState>().having((s) => s.weekdays, 'weekdays', {
          DateTime.monday,
        }),
        isA<CreateActivityState>().having(
          (s) => s.weekdays,
          'weekdays',
          isEmpty,
        ),
      ],
    );

    blocTest<CreateActivityBloc, CreateActivityState>(
      'StartDateChanged updates the start date',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(CreateActivityStartDateChanged(DateTime(2026, 2))),
      expect: () => [
        isA<CreateActivityState>().having(
          (s) => s.startDate,
          'startDate',
          DateTime(2026, 2),
        ),
      ],
    );

    blocTest<CreateActivityBloc, CreateActivityState>(
      'EndDateChanged sets a date, then clears it on null',
      build: buildBloc,
      seed: validState,
      act: (bloc) => bloc
        ..add(CreateActivityEndDateChanged(DateTime(2026, 3)))
        ..add(const CreateActivityEndDateChanged(null)),
      expect: () => [
        isA<CreateActivityState>().having(
          (s) => s.endDate,
          'endDate',
          DateTime(2026, 3),
        ),
        isA<CreateActivityState>().having((s) => s.endDate, 'endDate', isNull),
      ],
    );

    group('CreateActivitySaveRequested', () {
      blocTest<CreateActivityBloc, CreateActivityState>(
        'does nothing when the form cannot be saved',
        build: buildBloc,
        seed: () => CreateActivityState(
          activityType: ActivityType.habit,
          frequency: Frequency.daily,
          startDate: startDate,
        ),
        act: (bloc) => bloc.add(const CreateActivitySaveRequested()),
        expect: () => const <CreateActivityState>[],
        verify: (_) => verifyNever(
          () => habitsRepository.createHabit(
            name: any(named: 'name'),
            frequency: any(named: 'frequency'),
            startDate: any(named: 'startDate'),
          ),
        ),
      );

      blocTest<CreateActivityBloc, CreateActivityState>(
        'persists the habit and reports success',
        build: buildBloc,
        setUp: () {
          when(
            () => habitsRepository.createHabit(
              name: 'Run',
              frequency: Frequency.daily,
              startDate: startDate,
            ),
          ).thenAnswer((_) async => savedHabit);
        },
        seed: validState,
        act: (bloc) => bloc.add(const CreateActivitySaveRequested()),
        expect: () => [
          isA<CreateActivityState>().having(
            (s) => s.status,
            'status',
            CreateActivitySaveStatus.saving,
          ),
          isA<CreateActivityState>().having(
            (s) => s.status,
            'status',
            CreateActivitySaveStatus.success,
          ),
        ],
        verify: (_) {
          verify(
            () => habitsRepository.createHabit(
              name: 'Run',
              frequency: Frequency.daily,
              startDate: startDate,
            ),
          ).called(1);
        },
      );

      blocTest<CreateActivityBloc, CreateActivityState>(
        'on failure emits saving → failure → idle and reports the error',
        build: buildBloc,
        setUp: () {
          when(
            () => habitsRepository.createHabit(
              name: 'Run',
              frequency: Frequency.daily,
              startDate: startDate,
            ),
          ).thenThrow(Exception('boom'));
        },
        seed: validState,
        act: (bloc) => bloc.add(const CreateActivitySaveRequested()),
        expect: () => [
          isA<CreateActivityState>().having(
            (s) => s.status,
            'status',
            CreateActivitySaveStatus.saving,
          ),
          isA<CreateActivityState>().having(
            (s) => s.status,
            'status',
            CreateActivitySaveStatus.failure,
          ),
          isA<CreateActivityState>().having(
            (s) => s.status,
            'status',
            CreateActivitySaveStatus.idle,
          ),
        ],
        errors: () => [isA<Exception>()],
      );
    });
  });
}

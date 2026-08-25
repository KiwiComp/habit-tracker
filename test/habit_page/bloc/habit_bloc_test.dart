import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/habit_page/habit_page.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

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
      () => habitsRepository.getEntries(habit.id),
    ).thenAnswer((_) async => const <Entry>[]);
  });

  HabitBloc buildBloc() =>
      HabitBloc(id: habit.id, habitsRepository: habitsRepository);

  group('HabitBloc', () {
    group('HabitLoadRequested', () {
      blocTest<HabitBloc, HabitState>(
        'loads the habit by id',
        setUp: () => when(
          () => habitsRepository.getHabit(habit.id),
        ).thenAnswer((_) async => habit),
        build: buildBloc,
        expect: () => [
          isA<HabitState>()
              .having((s) => s.status, 'status', HabitStatus.loaded)
              .having((s) => s.habit, 'habit', habit),
        ],
      );

      blocTest<HabitBloc, HabitState>(
        'reports notFound when no habit exists for the id',
        setUp: () => when(
          () => habitsRepository.getHabit(habit.id),
        ).thenAnswer((_) async => null),
        build: buildBloc,
        expect: () => [
          isA<HabitState>().having(
            (s) => s.status,
            'status',
            HabitStatus.notFound,
          ),
        ],
      );

      blocTest<HabitBloc, HabitState>(
        'computes stats from the loaded habit and its entries',
        setUp: () {
          when(
            () => habitsRepository.getHabit(habit.id),
          ).thenAnswer((_) async => habit);
          when(() => habitsRepository.getEntries(habit.id)).thenAnswer(
            (_) async => [
              Entry(
                id: 'entry',
                habitId: habit.id,
                date: habit.startDate,
                createdAt: habit.startDate,
              ),
            ],
          );
        },
        build: buildBloc,
        expect: () => [
          isA<HabitState>().having(
            (s) => s.stats?.completedCount,
            'stats.completedCount',
            1,
          ),
        ],
      );
    });

    group('HabitNameChangeSubmitted', () {
      blocTest<HabitBloc, HabitState>(
        'does nothing before the habit has loaded',
        setUp: () => when(
          () => habitsRepository.getHabit(habit.id),
        ).thenAnswer((_) async => null),
        build: buildBloc,
        act: (bloc) => bloc.add(const HabitNameChangeSubmitted('Journal')),
        skip: 1, // the initial (notFound) load
        expect: () => const <HabitState>[],
        verify: (_) => verifyNever(() => habitsRepository.updateHabit(any())),
      );

      blocTest<HabitBloc, HabitState>(
        'persists the new name and reports success',
        setUp: () {
          when(
            () => habitsRepository.getHabit(habit.id),
          ).thenAnswer((_) async => habit);
          when(() => habitsRepository.updateHabit(any())).thenAnswer(
            (_) async {},
          );
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(const HabitNameChangeSubmitted('Journal'));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<HabitState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            HabitSaveStatus.saving,
          ),
          isA<HabitState>()
              .having(
                (s) => s.saveStatus,
                'saveStatus',
                HabitSaveStatus.success,
              )
              .having((s) => s.habit?.name, 'habit.name', 'Journal'),
        ],
        verify: (_) {
          verify(
            () => habitsRepository.updateHabit(
              any(
                that: isA<Habit>().having((h) => h.name, 'name', 'Journal'),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<HabitBloc, HabitState>(
        'on failure emits saving → failure → idle and reports the error, '
        'keeping the old name',
        setUp: () {
          when(
            () => habitsRepository.getHabit(habit.id),
          ).thenAnswer((_) async => habit);
          when(
            () => habitsRepository.updateHabit(any()),
          ).thenThrow(Exception('boom'));
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(const HabitNameChangeSubmitted('Journal'));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<HabitState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            HabitSaveStatus.saving,
          ),
          isA<HabitState>()
              .having(
                (s) => s.saveStatus,
                'saveStatus',
                HabitSaveStatus.failure,
              )
              .having((s) => s.habit?.name, 'habit.name', 'Meditate'),
          isA<HabitState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            HabitSaveStatus.idle,
          ),
        ],
        errors: () => [isA<Exception>()],
      );
    });

    group('HabitStartDateChangeSubmitted', () {
      final newDate = DateTime(2026, 2);

      blocTest<HabitBloc, HabitState>(
        'does nothing before the habit has loaded',
        setUp: () => when(
          () => habitsRepository.getHabit(habit.id),
        ).thenAnswer((_) async => null),
        build: buildBloc,
        act: (bloc) => bloc.add(HabitStartDateChangeSubmitted(newDate)),
        skip: 1, // the initial (notFound) load
        expect: () => const <HabitState>[],
        verify: (_) => verifyNever(() => habitsRepository.updateHabit(any())),
      );

      blocTest<HabitBloc, HabitState>(
        'persists the new start date and reports success',
        setUp: () {
          when(
            () => habitsRepository.getHabit(habit.id),
          ).thenAnswer((_) async => habit);
          when(() => habitsRepository.updateHabit(any())).thenAnswer(
            (_) async {},
          );
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(HabitStartDateChangeSubmitted(newDate));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<HabitState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            HabitSaveStatus.saving,
          ),
          isA<HabitState>()
              .having(
                (s) => s.saveStatus,
                'saveStatus',
                HabitSaveStatus.success,
              )
              .having((s) => s.habit?.startDate, 'habit.startDate', newDate),
        ],
        verify: (_) {
          verify(
            () => habitsRepository.updateHabit(
              any(
                that: isA<Habit>().having(
                  (h) => h.startDate,
                  'startDate',
                  newDate,
                ),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<HabitBloc, HabitState>(
        'on failure emits saving → failure → idle and reports the error, '
        'keeping the old start date',
        setUp: () {
          when(
            () => habitsRepository.getHabit(habit.id),
          ).thenAnswer((_) async => habit);
          when(
            () => habitsRepository.updateHabit(any()),
          ).thenThrow(Exception('boom'));
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(HabitStartDateChangeSubmitted(newDate));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<HabitState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            HabitSaveStatus.saving,
          ),
          isA<HabitState>()
              .having(
                (s) => s.saveStatus,
                'saveStatus',
                HabitSaveStatus.failure,
              )
              .having(
                (s) => s.habit?.startDate,
                'habit.startDate',
                habit.startDate,
              ),
          isA<HabitState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            HabitSaveStatus.idle,
          ),
        ],
        errors: () => [isA<Exception>()],
      );
    });

    group('HabitEndDateChangeSubmitted', () {
      final newEndDate = DateTime(2026, 6);

      blocTest<HabitBloc, HabitState>(
        'does nothing before the habit has loaded',
        setUp: () => when(
          () => habitsRepository.getHabit(habit.id),
        ).thenAnswer((_) async => null),
        build: buildBloc,
        act: (bloc) => bloc.add(HabitEndDateChangeSubmitted(newEndDate)),
        skip: 1, // the initial (notFound) load
        expect: () => const <HabitState>[],
        verify: (_) => verifyNever(() => habitsRepository.updateHabit(any())),
      );

      blocTest<HabitBloc, HabitState>(
        'persists the new end date and reports success',
        setUp: () {
          when(
            () => habitsRepository.getHabit(habit.id),
          ).thenAnswer((_) async => habit);
          when(() => habitsRepository.updateHabit(any())).thenAnswer(
            (_) async {},
          );
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(HabitEndDateChangeSubmitted(newEndDate));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<HabitState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            HabitSaveStatus.saving,
          ),
          isA<HabitState>()
              .having(
                (s) => s.saveStatus,
                'saveStatus',
                HabitSaveStatus.success,
              )
              .having((s) => s.habit?.endDate, 'habit.endDate', newEndDate),
        ],
        verify: (_) {
          verify(
            () => habitsRepository.updateHabit(
              any(
                that: isA<Habit>().having(
                  (h) => h.endDate,
                  'endDate',
                  newEndDate,
                ),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<HabitBloc, HabitState>(
        'recomputes stats against the new end date',
        setUp: () {
          when(
            () => habitsRepository.getHabit(habit.id),
          ).thenAnswer((_) async => habit);
          when(() => habitsRepository.updateHabit(any())).thenAnswer(
            (_) async {},
          );
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          // habit.startDate is 2026-01-05, daily — 6 scheduled days
          // (5th through 10th inclusive) once bounded by this end date.
          bloc.add(HabitEndDateChangeSubmitted(DateTime(2026, 1, 10)));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<HabitState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            HabitSaveStatus.saving,
          ),
          isA<HabitState>().having(
            (s) => s.stats?.totalScheduled,
            'stats.totalScheduled',
            6,
          ),
        ],
      );

      blocTest<HabitBloc, HabitState>(
        'clears the end date when the event date is null',
        setUp: () {
          when(
            () => habitsRepository.getHabit(habit.id),
          ).thenAnswer((_) async => habit.copyWith(endDate: newEndDate));
          when(() => habitsRepository.updateHabit(any())).thenAnswer(
            (_) async {},
          );
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(const HabitEndDateChangeSubmitted(null));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<HabitState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            HabitSaveStatus.saving,
          ),
          isA<HabitState>()
              .having(
                (s) => s.saveStatus,
                'saveStatus',
                HabitSaveStatus.success,
              )
              .having((s) => s.habit?.endDate, 'habit.endDate', isNull),
        ],
        verify: (_) {
          verify(
            () => habitsRepository.updateHabit(
              any(
                that: isA<Habit>().having(
                  (h) => h.endDate,
                  'endDate',
                  isNull,
                ),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<HabitBloc, HabitState>(
        'on failure emits saving → failure → idle and reports the error, '
        'keeping the old end date',
        setUp: () {
          when(
            () => habitsRepository.getHabit(habit.id),
          ).thenAnswer((_) async => habit);
          when(
            () => habitsRepository.updateHabit(any()),
          ).thenThrow(Exception('boom'));
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(HabitEndDateChangeSubmitted(newEndDate));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<HabitState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            HabitSaveStatus.saving,
          ),
          isA<HabitState>()
              .having(
                (s) => s.saveStatus,
                'saveStatus',
                HabitSaveStatus.failure,
              )
              .having((s) => s.habit?.endDate, 'habit.endDate', habit.endDate),
          isA<HabitState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            HabitSaveStatus.idle,
          ),
        ],
        errors: () => [isA<Exception>()],
      );
    });

    group('HabitArchiveRequestSubmitted', () {
      blocTest<HabitBloc, HabitState>(
        'does nothing before the habit has loaded',
        setUp: () => when(
          () => habitsRepository.getHabit(habit.id),
        ).thenAnswer((_) async => null),
        build: buildBloc,
        act: (bloc) => bloc.add(const HabitArchiveRequestSubmitted()),
        skip: 1, // the initial (notFound) load
        expect: () => const <HabitState>[],
        verify: (_) => verifyNever(() => habitsRepository.archiveHabit(any())),
      );

      blocTest<HabitBloc, HabitState>(
        'archives the habit and reports success',
        setUp: () {
          when(
            () => habitsRepository.getHabit(habit.id),
          ).thenAnswer((_) async => habit);
          when(
            () => habitsRepository.archiveHabit(habit.id),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(const HabitArchiveRequestSubmitted());
        },
        skip: 1, // the initial load
        expect: () => [
          isA<HabitState>().having(
            (s) => s.archiveStatus,
            'archiveStatus',
            HabitArchiveStatus.archiving,
          ),
          isA<HabitState>().having(
            (s) => s.archiveStatus,
            'archiveStatus',
            HabitArchiveStatus.success,
          ),
        ],
        verify: (_) {
          verify(() => habitsRepository.archiveHabit(habit.id)).called(1);
        },
      );

      blocTest<HabitBloc, HabitState>(
        'on failure emits archiving → failure → idle and reports the error',
        setUp: () {
          when(
            () => habitsRepository.getHabit(habit.id),
          ).thenAnswer((_) async => habit);
          when(
            () => habitsRepository.archiveHabit(habit.id),
          ).thenThrow(Exception('boom'));
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(const HabitArchiveRequestSubmitted());
        },
        skip: 1, // the initial load
        expect: () => [
          isA<HabitState>().having(
            (s) => s.archiveStatus,
            'archiveStatus',
            HabitArchiveStatus.archiving,
          ),
          isA<HabitState>().having(
            (s) => s.archiveStatus,
            'archiveStatus',
            HabitArchiveStatus.failure,
          ),
          isA<HabitState>().having(
            (s) => s.archiveStatus,
            'archiveStatus',
            HabitArchiveStatus.idle,
          ),
        ],
        errors: () => [isA<Exception>()],
      );
    });
  });
}

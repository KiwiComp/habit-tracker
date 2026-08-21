import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/task_page/task_page.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

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
  });

  TaskBloc buildBloc() =>
      TaskBloc(id: task.id, habitsRepository: habitsRepository);

  group('TaskBloc', () {
    group('TaskLoadRequested', () {
      blocTest<TaskBloc, TaskState>(
        'loads the task by id',
        setUp: () => when(
          () => habitsRepository.getHabit(task.id),
        ).thenAnswer((_) async => task),
        build: buildBloc,
        expect: () => [
          isA<TaskState>()
              .having((s) => s.status, 'status', TaskStatus.loaded)
              .having((s) => s.task, 'task', task),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'reports notFound when no task exists for the id',
        setUp: () => when(
          () => habitsRepository.getHabit(task.id),
        ).thenAnswer((_) async => null),
        build: buildBloc,
        expect: () => [
          isA<TaskState>().having(
            (s) => s.status,
            'status',
            TaskStatus.notFound,
          ),
        ],
      );
    });

    group('TaskNameChangeSubmitted', () {
      blocTest<TaskBloc, TaskState>(
        'does nothing before the task has loaded',
        setUp: () => when(
          () => habitsRepository.getHabit(task.id),
        ).thenAnswer((_) async => null),
        build: buildBloc,
        act: (bloc) => bloc.add(const TaskNameChangeSubmitted('Sprint')),
        skip: 1, // the initial (notFound) load
        expect: () => const <TaskState>[],
        verify: (_) => verifyNever(() => habitsRepository.updateHabit(any())),
      );

      blocTest<TaskBloc, TaskState>(
        'persists the new name and reports success',
        setUp: () {
          when(
            () => habitsRepository.getHabit(task.id),
          ).thenAnswer((_) async => task);
          when(() => habitsRepository.updateHabit(any())).thenAnswer(
            (_) async {},
          );
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(const TaskNameChangeSubmitted('Sprint'));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<TaskState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            TaskSaveStatus.saving,
          ),
          isA<TaskState>()
              .having(
                (s) => s.saveStatus,
                'saveStatus',
                TaskSaveStatus.success,
              )
              .having((s) => s.task?.name, 'task.name', 'Sprint'),
        ],
        verify: (_) {
          verify(
            () => habitsRepository.updateHabit(
              any(that: isA<Habit>().having((h) => h.name, 'name', 'Sprint')),
            ),
          ).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'on failure emits saving → failure → idle and reports the error, '
        'keeping the old name',
        setUp: () {
          when(
            () => habitsRepository.getHabit(task.id),
          ).thenAnswer((_) async => task);
          when(
            () => habitsRepository.updateHabit(any()),
          ).thenThrow(Exception('boom'));
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(const TaskNameChangeSubmitted('Sprint'));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<TaskState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            TaskSaveStatus.saving,
          ),
          isA<TaskState>()
              .having(
                (s) => s.saveStatus,
                'saveStatus',
                TaskSaveStatus.failure,
              )
              .having((s) => s.task?.name, 'task.name', 'Run'),
          isA<TaskState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            TaskSaveStatus.idle,
          ),
        ],
        errors: () => [isA<Exception>()],
      );
    });

    group('TaskStartDateChangeSubmitted', () {
      final newDate = DateTime(2026, 2);

      blocTest<TaskBloc, TaskState>(
        'does nothing before the task has loaded',
        setUp: () => when(
          () => habitsRepository.getHabit(task.id),
        ).thenAnswer((_) async => null),
        build: buildBloc,
        act: (bloc) => bloc.add(TaskStartDateChangeSubmitted(newDate)),
        skip: 1, // the initial (notFound) load
        expect: () => const <TaskState>[],
        verify: (_) => verifyNever(() => habitsRepository.updateHabit(any())),
      );

      blocTest<TaskBloc, TaskState>(
        'persists the new start date and reports success',
        setUp: () {
          when(
            () => habitsRepository.getHabit(task.id),
          ).thenAnswer((_) async => task);
          when(() => habitsRepository.updateHabit(any())).thenAnswer(
            (_) async {},
          );
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(TaskStartDateChangeSubmitted(newDate));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<TaskState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            TaskSaveStatus.saving,
          ),
          isA<TaskState>()
              .having(
                (s) => s.saveStatus,
                'saveStatus',
                TaskSaveStatus.success,
              )
              .having((s) => s.task?.startDate, 'task.startDate', newDate),
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

      blocTest<TaskBloc, TaskState>(
        'on failure emits saving → failure → idle and reports the error, '
        'keeping the old start date',
        setUp: () {
          when(
            () => habitsRepository.getHabit(task.id),
          ).thenAnswer((_) async => task);
          when(
            () => habitsRepository.updateHabit(any()),
          ).thenThrow(Exception('boom'));
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(TaskStartDateChangeSubmitted(newDate));
        },
        skip: 1, // the initial load
        expect: () => [
          isA<TaskState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            TaskSaveStatus.saving,
          ),
          isA<TaskState>()
              .having(
                (s) => s.saveStatus,
                'saveStatus',
                TaskSaveStatus.failure,
              )
              .having(
                (s) => s.task?.startDate,
                'task.startDate',
                task.startDate,
              ),
          isA<TaskState>().having(
            (s) => s.saveStatus,
            'saveStatus',
            TaskSaveStatus.idle,
          ),
        ],
        errors: () => [isA<Exception>()],
      );
    });

    group('TaskArchiveRequestSubmitted', () {
      blocTest<TaskBloc, TaskState>(
        'does nothing before the task has loaded',
        setUp: () => when(
          () => habitsRepository.getHabit(task.id),
        ).thenAnswer((_) async => null),
        build: buildBloc,
        act: (bloc) => bloc.add(const TaskArchiveRequestSubmitted()),
        skip: 1, // the initial (notFound) load
        expect: () => const <TaskState>[],
        verify: (_) => verifyNever(() => habitsRepository.archiveHabit(any())),
      );

      blocTest<TaskBloc, TaskState>(
        'archives the task and reports success',
        setUp: () {
          when(
            () => habitsRepository.getHabit(task.id),
          ).thenAnswer((_) async => task);
          when(
            () => habitsRepository.archiveHabit(task.id),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(const TaskArchiveRequestSubmitted());
        },
        skip: 1, // the initial load
        expect: () => [
          isA<TaskState>().having(
            (s) => s.archiveStatus,
            'archiveStatus',
            TaskArchiveStatus.archiving,
          ),
          isA<TaskState>().having(
            (s) => s.archiveStatus,
            'archiveStatus',
            TaskArchiveStatus.success,
          ),
        ],
        verify: (_) {
          verify(() => habitsRepository.archiveHabit(task.id)).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'on failure emits archiving → failure → idle and reports the error',
        setUp: () {
          when(
            () => habitsRepository.getHabit(task.id),
          ).thenAnswer((_) async => task);
          when(
            () => habitsRepository.archiveHabit(task.id),
          ).thenThrow(Exception('boom'));
        },
        build: buildBloc,
        act: (bloc) async {
          await Future<void>.delayed(Duration.zero);
          bloc.add(const TaskArchiveRequestSubmitted());
        },
        skip: 1, // the initial load
        expect: () => [
          isA<TaskState>().having(
            (s) => s.archiveStatus,
            'archiveStatus',
            TaskArchiveStatus.archiving,
          ),
          isA<TaskState>().having(
            (s) => s.archiveStatus,
            'archiveStatus',
            TaskArchiveStatus.failure,
          ),
          isA<TaskState>().having(
            (s) => s.archiveStatus,
            'archiveStatus',
            TaskArchiveStatus.idle,
          ),
        ],
        errors: () => [isA<Exception>()],
      );
    });
  });
}

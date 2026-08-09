import 'package:async/async.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:habits_repository/src/database/database.dart';

void main() {
  late HabitsRepository repository;

  setUp(() {
    repository = HabitsRepository(
      database: HabitsDatabase(NativeDatabase.memory()),
    );
  });

  tearDown(() => repository.close());

  group('createHabit', () {
    test('persists a habit retrievable through watchHabits', () async {
      final created = await repository.createHabit(
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
      );

      final habits = await repository.watchHabits().first;

      expect(habits, [created]);
    });

    test('normalizes startDate to a calendar date', () async {
      final created = await repository.createHabit(
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026, 1, 1, 14, 30),
      );

      expect(created.startDate, DateTime(2026));
    });

    test('returns the persisted row, not the pre-insert value', () async {
      // Regression test: createHabit used to return the in-memory Habit
      // built before the insert, which could disagree with what's actually
      // in the database (e.g. an un-normalized startDate). That made
      // isScheduledOn wrongly return false for a habit created earlier the
      // same day, and made the returned object compare unequal (via ==) to
      // what watchHabits later streams for the same row.
      final created = await repository.createHabit(
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026, 1, 1, 14, 30),
      );

      final habits = await repository.watchHabits().first;
      expect(created, habits.single);
      expect(created.isScheduledOn(DateTime(2026, 1, 1, 9)), isTrue);
    });
  });

  group('watchHabits', () {
    test('excludes archived habits by default', () async {
      final habit = await repository.createHabit(
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
      );
      await repository.archiveHabit(habit.id);

      final active = await repository.watchHabits().first;
      final all = await repository.watchHabits(includeArchived: true).first;

      expect(active, isEmpty);
      expect(all, hasLength(1));
    });

    test('emits a new list whenever a habit is added', () async {
      final queue = StreamQueue(
        repository.watchHabits().map((habits) => habits.length),
      );

      expect(await queue.next, 0);

      await repository.createHabit(
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
      );

      expect(await queue.next, 1);
      await queue.cancel();
    });
  });

  group('archiveHabit / unarchiveHabit', () {
    test('unarchiving restores a habit to the active list', () async {
      final habit = await repository.createHabit(
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
      );
      await repository.archiveHabit(habit.id);
      await repository.unarchiveHabit(habit.id);

      final active = await repository.watchHabits().first;

      expect(active, hasLength(1));
      expect(active.single.isArchived, isFalse);
    });
  });

  group('updateHabit', () {
    test(
      'normalizes startDate to a calendar date even though this call site '
      'never called dateOnly() itself — the converter is what makes this '
      'safe now',
      () async {
        final created = await repository.createHabit(
          name: 'Drink water',
          frequency: Frequency.daily,
          startDate: DateTime(2026),
        );

        await repository.updateHabit(
          created.copyWith(startDate: DateTime(2026, 3, 8, 14, 30)),
        );

        final habits = await repository.watchHabits().first;
        expect(habits.single.startDate, DateTime(2026, 3, 8));
      },
    );
  });

  group('deleteHabit', () {
    test("cascades to delete the habit's entries", () async {
      final habit = await repository.createHabit(
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
      );
      await repository.logEntry(habitId: habit.id, date: DateTime(2026));

      await repository.deleteHabit(habit.id);

      final entries = await repository.watchEntries(habit.id).first;
      expect(entries, isEmpty);
    });
  });

  group('logEntry', () {
    test('is idempotent for the same habit and date', () async {
      final habit = await repository.createHabit(
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
      );

      await repository.logEntry(habitId: habit.id, date: DateTime(2026));
      await repository.logEntry(habitId: habit.id, date: DateTime(2026));

      final entries = await repository.watchEntries(habit.id).first;
      expect(entries, hasLength(1));
    });

    test('normalizes the date to a calendar date', () async {
      final habit = await repository.createHabit(
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
      );

      await repository.logEntry(
        habitId: habit.id,
        date: DateTime(2026, 1, 1, 22),
      );

      final entries = await repository.watchEntries(habit.id).first;
      expect(entries.single.date, DateTime(2026));
    });
  });

  group('unlogEntry', () {
    test('removes a previously logged entry', () async {
      final habit = await repository.createHabit(
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
      );
      await repository.logEntry(habitId: habit.id, date: DateTime(2026));

      await repository.unlogEntry(habitId: habit.id, date: DateTime(2026));

      final entries = await repository.watchEntries(habit.id).first;
      expect(entries, isEmpty);
    });
  });

  group('watchEntriesOnDate', () {
    test('only includes entries logged on that date', () async {
      final habit = await repository.createHabit(
        name: 'Drink water',
        frequency: Frequency.daily,
        startDate: DateTime(2026),
      );
      await repository.logEntry(habitId: habit.id, date: DateTime(2026));
      await repository.logEntry(habitId: habit.id, date: DateTime(2026, 1, 2));

      final entries = await repository.watchEntriesOnDate(DateTime(2026)).first;

      expect(entries, hasLength(1));
      expect(entries.single.date, DateTime(2026));
    });
  });
}

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

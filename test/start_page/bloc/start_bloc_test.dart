import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/start_page/start_page.dart';

void main() {
  group('StartBloc', () {
    final today = DateTime(2026, 8, 6);
    final tomorrow = DateTime(2026, 8, 7);
    final activity = Activity(
      id: '1',
      title: 'Read',
      date: DateTime(2026, 8, 6, 9),
    );

    test('initial state has no activities', () {
      expect(StartBloc(initialDate: today).state.activities, isEmpty);
    });

    blocTest<StartBloc, StartState>(
      'emits activities when StartActivitiesLoaded is added',
      build: () => StartBloc(initialDate: today),
      act: (bloc) => bloc.add(StartActivitiesLoaded([activity])),
      expect: () => [
        equals(StartState(selectedDate: today, activities: [activity])),
      ],
    );

    blocTest<StartBloc, StartState>(
      'clears activities when a new day is selected',
      build: () => StartBloc(initialDate: today),
      seed: () => StartState(selectedDate: today, activities: [activity]),
      act: (bloc) => bloc.add(StartDaySelected(tomorrow)),
      expect: () => [
        equals(StartState(selectedDate: tomorrow)),
      ],
    );

    blocTest<StartBloc, StartState>(
      'keeps activities when the already-selected day is re-selected with '
      'a different time-of-day (e.g. tapping the app bar "today" shortcut)',
      build: () => StartBloc(initialDate: today),
      seed: () => StartState(selectedDate: today, activities: [activity]),
      act: (bloc) =>
          bloc.add(StartDaySelected(today.add(const Duration(hours: 5)))),
      expect: () => [
        equals(
          StartState(
            selectedDate: today.add(const Duration(hours: 5)),
            activities: [activity],
          ),
        ),
      ],
    );
  });
}

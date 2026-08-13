import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/start_page/start_page.dart';
import 'package:habit_tracker/start_page/utils/date_time_x.dart';
import 'package:habit_tracker/start_page/widgets/widgets.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  late _MockHabitsRepository repo;
  late StreamController<List<Habit>> habits;

  setUp(() {
    repo = _MockHabitsRepository();
    habits = StreamController<List<Habit>>.broadcast();
    when(() => repo.watchHabits()).thenAnswer((_) => habits.stream);
  });

  tearDown(() => habits.close());

  group('DaySelector', () {
    testWidgets('renders a chip per day in the rolling window', (tester) async {
      final bloc = StartBloc(habitsRepository: repo);
      addTearDown(bloc.close);

      await tester.pumpApp(
        BlocProvider.value(
          value: bloc,
          child: const Scaffold(body: DaySelector()),
        ),
      );
      await tester.pumpAndSettle();

      // A rolling window of 45 days on either side of today, plus today.
      expect(find.byType(InkWell), findsNWidgets(91));
    });

    testWidgets('tapping a day selects it on the bloc', (tester) async {
      final bloc = StartBloc(habitsRepository: repo);
      addTearDown(bloc.close);

      await tester.pumpApp(
        BlocProvider.value(
          value: bloc,
          child: const Scaffold(body: DaySelector()),
        ),
      );
      await tester.pumpAndSettle();

      // The first chip is the far-left day; scroll it into view, then tap.
      await tester.ensureVisible(find.byType(InkWell).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(bloc.state.selectedDate.isSameDayAs(DateTime.now()), isFalse);
    });
  });
}

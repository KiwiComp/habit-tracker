import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app/app.dart';
import 'package:habit_tracker/start_page/start_page.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  group('App', () {
    testWidgets('renders StartPage', (tester) async {
      final habitsRepository = _MockHabitsRepository();
      when(
        () => habitsRepository.watchHabits(),
      ).thenAnswer((_) => const Stream.empty());
      when(habitsRepository.close).thenAnswer((_) async {});

      await tester.pumpWidget(App(habitsRepository: habitsRepository));

      expect(find.byType(StartPage), findsOneWidget);
    });
  });
}

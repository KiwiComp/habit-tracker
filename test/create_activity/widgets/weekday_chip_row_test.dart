import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';

import '../../helpers/helpers.dart';

void main() {
  group('WeekdayChipRow', () {
    testWidgets('renders one chip per weekday', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: WeekdayChipRow(selected: const {}, onToggled: (_) {}),
        ),
      );

      // Seven tappable chips, one per day of the week.
      expect(find.byType(InkWell), findsNWidgets(7));
    });

    testWidgets('reports Monday as weekday 1 when tapped', (tester) async {
      int? toggled;
      await tester.pumpApp(
        Scaffold(
          body: WeekdayChipRow(
            selected: const {},
            onToggled: (weekday) => toggled = weekday,
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Monday'));
      expect(toggled, DateTime.monday);
    });

    testWidgets('reports Sunday as weekday 7 when tapped', (tester) async {
      int? toggled;
      await tester.pumpApp(
        Scaffold(
          body: WeekdayChipRow(
            selected: const {},
            onToggled: (weekday) => toggled = weekday,
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Sunday'));
      expect(toggled, DateTime.sunday);
    });

    testWidgets('marks a selected weekday via semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        Scaffold(
          body: WeekdayChipRow(
            selected: const {DateTime.monday},
            onToggled: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Monday')),
        isSemantics(isSelected: true),
      );
      handle.dispose();
    });
  });
}

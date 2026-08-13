import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/widgets/widgets.dart';

import '../helpers/helpers.dart';

void main() {
  group('HabitTrackerAppBar', () {
    testWidgets('renders the given title', (tester) async {
      await tester.pumpApp(
        const Scaffold(appBar: HabitTrackerAppBar(title: 'Today')),
      );

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('shows the shared leading and action buttons', (tester) async {
      await tester.pumpApp(
        const Scaffold(appBar: HabitTrackerAppBar(title: 'Today')),
      );

      expect(find.byTooltip('Menu'), findsOneWidget);
      expect(find.byTooltip('Search'), findsOneWidget);
      expect(find.byTooltip('Calendar view'), findsOneWidget);
      expect(find.byTooltip('Help'), findsOneWidget);
    });

    testWidgets('its buttons are tappable no-ops for now', (tester) async {
      // The actions are wired to `onPressed: () {}` until real behaviour
      // lands (see TODO.md) — tapping each just confirms they're enabled and
      // don't throw.
      await tester.pumpApp(
        const Scaffold(appBar: HabitTrackerAppBar(title: 'Today')),
      );

      for (final tooltip in const ['Menu', 'Search', 'Calendar view', 'Help']) {
        await tester.tap(find.byTooltip(tooltip));
        await tester.pump();
      }

      expect(tester.takeException(), isNull);
    });

    test('is the standard toolbar height', () {
      expect(
        const HabitTrackerAppBar(title: 'Today').preferredSize,
        const Size.fromHeight(kToolbarHeight),
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/start_page/widgets/widgets.dart';
import 'package:habits_repository/habits_repository.dart';

import '../../helpers/helpers.dart';

/// Default for `list`'s callbacks a given test doesn't care about — a
/// top-level function so it can be a `const` default argument.
void ignoreHabit(Habit _) {}

void main() {
  final selectedDate = DateTime(2026, 1, 5);

  Habit habit(String id, String name, Frequency frequency) => Habit(
    id: id,
    name: name,
    frequency: frequency,
    startDate: selectedDate,
    createdAt: selectedDate,
  );

  final readHabit = habit('h', 'Read', Frequency.daily);
  final passportTask = habit('t', 'Passport', Frequency.once);

  Widget list({
    required ValueChanged<Habit>? onTap,
    ValueChanged<Habit> onOpen = ignoreHabit,
    Set<String> completedHabitIds = const {},
  }) => Scaffold(
    body: ScheduleList(
      activities: [readHabit, passportTask],
      completedHabitIds: completedHabitIds,
      onActivityTap: onTap,
      onOpenActivity: onOpen,
    ),
  );

  /// The reveal action for one specific row.
  ///
  /// Scoped to the row's key on purpose: there is a chevron per row, so a
  /// bare `find.byIcon` matches every row and `tap` throws on the ambiguity.
  Finder actionFor(Habit target) => find.descendant(
    of: find.byKey(ValueKey(target.id)),
    matching: find.byIcon(Icons.chevron_right),
  );

  /// Width of the row's own tile — shrinks by the reveal width when open.
  double tileWidth(WidgetTester tester, String label) {
    final tile = find
        .ancestor(of: find.text(label), matching: find.byType(Material))
        .first;
    return tester.getSize(tile).width;
  }

  group('ScheduleList', () {
    testWidgets('renders a row per activity, with a type-specific icon', (
      tester,
    ) async {
      await tester.pumpApp(list(onTap: (_) {}));

      expect(find.text('Read'), findsOneWidget);
      expect(find.text('Passport'), findsOneWidget);
      // Habit vs task get different glyphs.
      expect(find.byIcon(Icons.military_tech_outlined), findsOneWidget);
      expect(find.byIcon(Icons.task_alt_outlined), findsOneWidget);
    });

    testWidgets('reports the tapped activity', (tester) async {
      Habit? tapped;
      await tester.pumpApp(list(onTap: (habit) => tapped = habit));

      await tester.tap(find.text('Passport'));
      expect(tapped, passportTask);
    });

    testWidgets('checks off only the completed activities', (tester) async {
      await tester.pumpApp(
        list(onTap: (_) {}, completedHabitIds: {readHabit.id}),
      );

      expect(find.byIcon(Icons.check_box), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    });

    testWidgets('opening a row reveals an action that opens that activity', (
      tester,
    ) async {
      Habit? opened;
      await tester.pumpApp(
        list(onTap: (_) {}, onOpen: (habit) => opened = habit),
      );

      // The drag is required, not incidental: while closed, the action is
      // painted underneath the tile, which absorbs the hit test — tapping it
      // in that state fires `onActivityTap` instead.
      await tester.drag(find.text('Passport'), const Offset(-64, 0));
      await tester.pumpAndSettle();

      await tester.tap(actionFor(passportTask));
      await tester.pumpAndSettle();

      expect(opened, passportTask);
    });

    testWidgets('only one row is open at a time', (tester) async {
      await tester.pumpApp(list(onTap: (_) {}));
      final closedWidth = tileWidth(tester, 'Read');

      await tester.drag(find.text('Read'), const Offset(-64, 0));
      await tester.pumpAndSettle();
      expect(tileWidth(tester, 'Read'), lessThan(closedWidth));

      // Opening the second row closes the first.
      await tester.drag(find.text('Passport'), const Offset(-64, 0));
      await tester.pumpAndSettle();

      expect(tileWidth(tester, 'Read'), moreOrLessEquals(closedWidth));
      expect(tileWidth(tester, 'Passport'), lessThan(closedWidth));
    });

    testWidgets(
      'dragging a different row without opening it past halfway leaves '
      'the already-open row untouched',
      (tester) async {
        await tester.pumpApp(list(onTap: (_) {}));
        final closedWidth = tileWidth(tester, 'Read');

        await tester.drag(find.text('Read'), const Offset(-64, 0));
        await tester.pumpAndSettle();
        expect(tileWidth(tester, 'Read'), lessThan(closedWidth));

        // A partial drag on Passport — past the gesture's touch slop (so it
        // registers as a drag at all) but short of halfway, so it snaps
        // back closed on release — reports itself closed, but it was never
        // the open row to begin with. Read stays the open row.
        await tester.drag(find.text('Passport'), const Offset(-40, 0));
        await tester.pumpAndSettle();

        expect(tileWidth(tester, 'Read'), lessThan(closedWidth));
        expect(tileWidth(tester, 'Passport'), moreOrLessEquals(closedWidth));
      },
    );

    testWidgets('exposes each row as one checkable node', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        list(onTap: (_) {}, completedHabitIds: {readHabit.id}),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Read')),
        isSemantics(isChecked: true, hasCheckedState: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Passport')),
        isSemantics(isChecked: false, hasCheckedState: true),
      );
      handle.dispose();
    });

    testWidgets('the reveal action is not its own semantics node', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(list(onTap: (_) {}));

      // The row is a leaf: nothing from its subtree — the chevron button
      // included — escapes as a node of its own. An unlabelled button per
      // row would be noise, so opening is offered as a named custom action
      // on the row instead (asserted below).
      final node = tester.getSemantics(find.bySemanticsLabel('Read'));
      expect(node.childrenCount, 0);
      expect(node, isSemantics(hasTapAction: true));
      handle.dispose();
    });

    testWidgets('offers opening the activity as a semantics action', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      Habit? opened;
      await tester.pumpApp(
        list(onTap: (_) {}, onOpen: (habit) => opened = habit),
      );

      final node = tester.getSemantics(find.bySemanticsLabel('Passport'));
      final actionId = CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Open details'),
      );
      // Not the only id on the node: `onTapHint` is itself implemented as an
      // overriding custom action, so it registers one too.
      expect(
        node.getSemanticsData().customSemanticsActionIds,
        contains(actionId),
      );

      // Performing it navigates without the drag gesture ever happening.
      node.owner!.performAction(
        node.id,
        SemanticsAction.customAction,
        actionId,
      );
      await tester.pumpAndSettle();

      expect(opened, passportTask);
      handle.dispose();
    });

    testWidgets(
      'a null onActivityTap disables tapping and removes the tap semantics',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpApp(list(onTap: null));

        // Tapping does nothing (and doesn't throw) — there's no callback to
        // report through.
        await tester.tap(find.text('Read'));
        await tester.pump();

        final node = tester.getSemantics(find.bySemanticsLabel('Read'));
        expect(node, isSemantics(hasTapAction: false));
        handle.dispose();
      },
    );

    testWidgets('a vertical drag does not open a row', (tester) async {
      await tester.pumpApp(list(onTap: (_) {}));
      final closedWidth = tileWidth(tester, 'Read');

      // Guards the list's own scrolling: swapping the horizontal drag for a
      // pan would let rows open on vertical scrolls.
      await tester.drag(find.text('Read'), const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(tileWidth(tester, 'Read'), moreOrLessEquals(closedWidth));
    });
  });
}

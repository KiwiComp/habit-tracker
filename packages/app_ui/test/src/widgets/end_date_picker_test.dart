import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

class _Trigger extends StatelessWidget {
  const _Trigger({
    required this.currentDate,
    required this.firstDate,
    required this.preferredInitialDate,
    required this.onChanged,
  });

  final DateTime? currentDate;
  final DateTime firstDate;
  final DateTime preferredInitialDate;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => pickEndDate(
        context,
        currentDate: currentDate,
        firstDate: firstDate,
        preferredInitialDate: preferredInitialDate,
        neverLabel: 'Never',
        pickDateLabel: 'Pick a date',
        onChanged: onChanged,
      ),
      child: const Text('Trigger'),
    );
  }
}

void main() {
  final firstDate = DateTime(2026, 1, 15);

  group('pickEndDate', () {
    testWidgets(
      'skips the sheet and opens the picker directly when currentDate is '
      'null',
      (tester) async {
        DateTime? picked;
        await tester.pumpApp(
          _Trigger(
            currentDate: null,
            firstDate: firstDate,
            preferredInitialDate: firstDate,
            onChanged: (date) => picked = date,
          ),
        );

        await tester.tap(find.text('Trigger'));
        await tester.pumpAndSettle();

        expect(find.text('Never'), findsNothing);
        expect(find.text('Pick a date'), findsNothing);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(picked, firstDate);
      },
    );

    testWidgets('shows the choice sheet when currentDate is set', (
      tester,
    ) async {
      DateTime? picked;
      await tester.pumpApp(
        _Trigger(
          currentDate: DateTime(2026, 1, 20),
          firstDate: firstDate,
          preferredInitialDate: DateTime(2026, 1, 20),
          onChanged: (date) => picked = date,
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Never'), findsOneWidget);
      expect(find.text('Pick a date'), findsOneWidget);

      await tester.tap(find.text('Never'));
      await tester.pumpAndSettle();

      expect(picked, isNull);
    });

    testWidgets(
      'choosing to pick a date opens the picker seeded with the preferred '
      'initial date',
      (tester) async {
        DateTime? picked;
        await tester.pumpApp(
          _Trigger(
            currentDate: DateTime(2026, 1, 20),
            firstDate: firstDate,
            preferredInitialDate: DateTime(2026, 1, 20),
            onChanged: (date) => picked = date,
          ),
        );

        await tester.tap(find.text('Trigger'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pick a date'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(picked, DateTime(2026, 1, 20));
      },
    );

    testWidgets(
      'clamps the initial date up to firstDate when the preferred initial '
      'date would precede it',
      (tester) async {
        DateTime? picked;
        await tester.pumpApp(
          _Trigger(
            currentDate: null,
            firstDate: firstDate,
            preferredInitialDate: DateTime(2025),
            onChanged: (date) => picked = date,
          ),
        );

        await tester.tap(find.text('Trigger'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(picked, firstDate);
      },
    );

    testWidgets('dismissing the sheet without a choice reports nothing', (
      tester,
    ) async {
      var called = false;
      await tester.pumpApp(
        _Trigger(
          currentDate: DateTime(2026, 1, 20),
          firstDate: firstDate,
          preferredInitialDate: DateTime(2026, 1, 20),
          onChanged: (_) => called = true,
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      // Tap the barrier outside the sheet to dismiss it without a choice.
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });
  });
}

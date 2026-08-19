import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/task_page/widgets/widgets.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pumpAndOpen(
    WidgetTester tester, {
    required ValueSetter<bool> onResult,
    String name = 'Run',
  }) async {
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              onResult(
                await showArchiveConfirmationDialog(context, name: name),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('showArchiveConfirmationDialog', () {
    testWidgets('shows the name in the confirmation message', (
      tester,
    ) async {
      await pumpAndOpen(tester, onResult: (_) {});

      expect(find.textContaining('Run'), findsOneWidget);
    });

    testWidgets('resolves to true when Yes is tapped', (tester) async {
      bool? result;
      await pumpAndOpen(tester, onResult: (value) => result = value);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Yes'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('resolves to false when No is tapped', (tester) async {
      bool? result;
      await pumpAndOpen(tester, onResult: (value) => result = value);

      await tester.tap(find.widgetWithText(ElevatedButton, 'No'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('resolves to false when dismissed without a choice', (
      tester,
    ) async {
      bool? result;
      await pumpAndOpen(tester, onResult: (value) => result = value);

      // Outside the dialog, on the modal barrier.
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}

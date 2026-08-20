import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> pumpAndOpen(
    WidgetTester tester, {
    required ValueSetter<bool> onResult,
    String message = 'Delete "Run"?',
  }) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            onResult(
              await showConfirmationDialog(
                context,
                message: message,
                yesLabel: 'Yes',
                noLabel: 'No',
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('showConfirmationDialog', () {
    testWidgets('shows the given message', (tester) async {
      await pumpAndOpen(tester, onResult: (_) {});

      expect(find.text('Delete "Run"?'), findsOneWidget);
    });

    testWidgets('resolves to true when the yes button is tapped', (
      tester,
    ) async {
      bool? result;
      await pumpAndOpen(tester, onResult: (value) => result = value);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Yes'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('resolves to false when the no button is tapped', (
      tester,
    ) async {
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

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> pumpAndOpen(
    WidgetTester tester, {
    required ValueSetter<String?> onResult,
    String currentName = 'Run',
  }) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            onResult(
              await showEditNameDialog(
                context,
                currentName: currentName,
                label: 'Name',
                hint: 'e.g. Run',
                saveButtonLabel: 'Save',
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

  group('showEditNameDialog', () {
    testWidgets('pre-fills the field with the current name', (tester) async {
      await pumpAndOpen(tester, onResult: (_) {});

      expect(find.text('Run'), findsOneWidget);
    });

    testWidgets('disables Save until the name actually changes', (
      tester,
    ) async {
      await pumpAndOpen(tester, onResult: (_) {});

      ElevatedButton saveButton() => tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save'),
      );
      expect(saveButton().enabled, isFalse);

      await tester.enterText(find.byType(TextField), 'Run');
      await tester.pump();
      expect(saveButton().enabled, isFalse);

      await tester.enterText(find.byType(TextField), 'Sprint');
      await tester.pump();
      expect(saveButton().enabled, isTrue);
    });

    testWidgets('disables Save once the name is cleared to blank', (
      tester,
    ) async {
      await pumpAndOpen(tester, onResult: (_) {});

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Save'),
            )
            .enabled,
        isFalse,
      );
    });

    testWidgets('pops with the trimmed name on Save', (tester) async {
      String? result = 'unset';
      await pumpAndOpen(tester, onResult: (value) => result = value);

      await tester.enterText(find.byType(TextField), '  Sprint  ');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(result, 'Sprint');
    });

    testWidgets('pops with null when dismissed without saving', (
      tester,
    ) async {
      String? result = 'unset';
      await pumpAndOpen(tester, onResult: (value) => result = value);

      // Outside the dialog, on the modal barrier.
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}

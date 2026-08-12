import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppTextField', () {
    testWidgets('renders label and hint text', (tester) async {
      await tester.pumpApp(
        const AppTextField(
          onChanged: null,
          label: 'Name',
          hint: 'e.g. Drink water',
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('e.g. Drink water'), findsOneWidget);
    });

    testWidgets('forwards typed text to onChanged', (tester) async {
      final changes = <String>[];
      await tester.pumpApp(
        AppTextField(
          onChanged: changes.add,
          label: 'Name',
          hint: 'hint',
        ),
      );

      await tester.enterText(find.byType(TextField), 'Run');
      expect(changes, ['Run']);
    });

    testWidgets('hides the clear button while empty', (tester) async {
      await tester.pumpApp(
        AppTextField(onChanged: (_) {}, label: 'Name', hint: 'hint'),
      );

      expect(find.byIcon(Icons.cancel), findsNothing);
    });

    testWidgets('shows the clear button once text is entered', (tester) async {
      await tester.pumpApp(
        AppTextField(onChanged: (_) {}, label: 'Name', hint: 'hint'),
      );

      await tester.enterText(find.byType(TextField), 'Run');
      await tester.pump();

      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('clear button empties the field and reports the change', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpApp(
        AppTextField(
          onChanged: changes.add,
          label: 'Name',
          hint: 'hint',
        ),
      );

      await tester.enterText(find.byType(TextField), 'Run');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pump();

      expect(find.text('Run'), findsNothing);
      expect(changes.last, '');
      // The clear button hides itself again once the field is empty.
      expect(find.byIcon(Icons.cancel), findsNothing);
    });
  });
}

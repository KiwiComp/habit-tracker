import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('DetailsActionTile', () {
    testWidgets('renders the label and leading icon', (tester) async {
      await tester.pumpApp(
        DetailsActionTile(label: 'Gym', leadingIcon: Icons.edit, onTap: () {}),
      );

      expect(find.text('Gym'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        DetailsActionTile(
          label: 'Gym',
          leadingIcon: Icons.edit,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('shows the formatted date when one is given', (tester) async {
      await tester.pumpApp(
        DetailsActionTile(
          label: 'Start date',
          leadingIcon: Icons.today,
          date: DateTime(2026, 3, 5),
          onTap: () {},
        ),
      );

      expect(find.text('5/3/2026'), findsOneWidget);
      expect(
        tester.widget<Visibility>(find.byType(Visibility)).visible,
        isTrue,
      );
    });

    testWidgets('hides the date box, keeping its space, when there is no '
        'date and no trailing icon', (tester) async {
      await tester.pumpApp(
        DetailsActionTile(
          label: 'Name',
          leadingIcon: Icons.edit,
          onTap: () {},
        ),
      );

      final visibility = tester.widget<Visibility>(find.byType(Visibility));
      expect(visibility.visible, isFalse);
      expect(visibility.maintainSize, isTrue);
      expect(visibility.maintainAnimation, isTrue);
      expect(visibility.maintainState, isTrue);
      expect(find.byIcon(Icons.all_inclusive), findsNothing);
    });

    testWidgets('shows the trailing icon when there is no date', (
      tester,
    ) async {
      await tester.pumpApp(
        DetailsActionTile(
          label: 'End date',
          leadingIcon: Icons.today,
          trailingIcon: Icons.all_inclusive,
          onTap: () {},
        ),
      );

      expect(find.byIcon(Icons.all_inclusive), findsOneWidget);
      expect(
        tester.widget<Visibility>(find.byType(Visibility)).visible,
        isFalse,
      );
    });

    testWidgets('shows the date instead of the trailing icon when both are '
        'given', (tester) async {
      await tester.pumpApp(
        DetailsActionTile(
          label: 'End date',
          leadingIcon: Icons.today,
          trailingIcon: Icons.all_inclusive,
          date: DateTime(2026, 3, 5),
          onTap: () {},
        ),
      );

      expect(find.text('5/3/2026'), findsOneWidget);
      expect(find.byIcon(Icons.all_inclusive), findsNothing);
    });
  });
}

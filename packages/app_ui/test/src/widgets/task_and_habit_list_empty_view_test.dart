import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('TaskAndHabitListEmptyView', () {
    testWidgets('renders the title and text', (tester) async {
      await tester.pumpApp(
        // Deliberately non-const: a fully-literal const invocation here can
        // be constant-folded away, so this line doesn't reliably register
        // as covered.
        // ignore: prefer_const_constructors
        TaskAndHabitListEmptyView(
          title: 'No items yet',
          text: 'Tap the plus button to add one',
        ),
      );

      expect(find.text('No items yet'), findsOneWidget);
      expect(find.text('Tap the plus button to add one'), findsOneWidget);
    });
  });
}

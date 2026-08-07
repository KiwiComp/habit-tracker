// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app/app.dart';
import 'package:habit_tracker/start_page/start_page.dart';

void main() {
  group('App', () {
    testWidgets('renders StartPage', (tester) async {
      await tester.pumpWidget(App());
      expect(find.byType(StartPage), findsOneWidget);
    });
  });
}

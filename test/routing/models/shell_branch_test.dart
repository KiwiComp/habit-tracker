import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/routing/routing.dart';

void main() {
  group('ShellBranch', () {
    test('has exactly today, habits and tasks, in that order', () {
      expect(ShellBranch.values, [
        ShellBranch.today,
        ShellBranch.habits,
        ShellBranch.tasks,
      ]);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/create_activity/models/models.dart';

void main() {
  group('ActivityType', () {
    test('has exactly habit and task, in that order', () {
      expect(ActivityType.values, [ActivityType.habit, ActivityType.task]);
    });
  });
}

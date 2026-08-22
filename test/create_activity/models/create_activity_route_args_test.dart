import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/create_activity/models/models.dart';

void main() {
  group('CreateActivityRouteArgs', () {
    test('equal when type and startDate match', () {
      final a = CreateActivityRouteArgs(
        type: ActivityType.habit,
        startDate: DateTime(2026, 1, 5),
      );
      final b = CreateActivityRouteArgs(
        type: ActivityType.habit,
        startDate: DateTime(2026, 1, 5),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('not equal when type or startDate differ', () {
      final base = CreateActivityRouteArgs(
        type: ActivityType.habit,
        startDate: DateTime(2026, 1, 5),
      );

      expect(
        base,
        isNot(
          CreateActivityRouteArgs(
            type: ActivityType.task,
            startDate: DateTime(2026, 1, 5),
          ),
        ),
      );
      expect(
        base,
        isNot(
          CreateActivityRouteArgs(
            type: ActivityType.habit,
            startDate: DateTime(2026, 1, 6),
          ),
        ),
      );
    });
  });
}

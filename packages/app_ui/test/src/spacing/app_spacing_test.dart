import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSpacing', () {
    const spacing = AppSpacing();

    test("follows Material's 4dp grid", () {
      expect(spacing.xs, 4);
      expect(spacing.sm, 8);
      expect(spacing.md, 16);
      expect(spacing.lg, 24);
      expect(spacing.xl, 32);
      expect(spacing.xxl, 48);
      expect(spacing.xxxl, 64);
    });

    test('steps increase monotonically', () {
      final steps = [
        spacing.xs,
        spacing.sm,
        spacing.md,
        spacing.lg,
        spacing.xl,
        spacing.xxl,
        spacing.xxxl,
      ];
      final sorted = [...steps]..sort();
      expect(steps, sorted);
    });
  });
}

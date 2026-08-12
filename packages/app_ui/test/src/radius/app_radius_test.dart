import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRadius', () {
    const radius = AppRadius();

    test('exposes the Material 3 shape scale', () {
      expect(radius.none, 0);
      expect(radius.xs, 4);
      expect(radius.sm, 8);
      expect(radius.md, 12);
      expect(radius.lg, 16);
      expect(radius.xl, 28);
      expect(radius.xxl, 36);
      expect(radius.full, 999);
    });

    test('full is large enough to render as a pill', () {
      expect(radius.full, greaterThan(radius.xxl));
    });
  });
}

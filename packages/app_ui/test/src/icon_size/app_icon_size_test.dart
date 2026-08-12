import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppIconSize', () {
    const iconSize = AppIconSize();

    test("exposes Material's standard icon sizes", () {
      expect(iconSize.xs, 12);
      expect(iconSize.sm, 18);
      expect(iconSize.md, 24);
      expect(iconSize.lg, 36);
      expect(iconSize.xl, 48);
    });

    test("md is Material's default 24dp size", () {
      expect(iconSize.md, 24);
    });
  });
}

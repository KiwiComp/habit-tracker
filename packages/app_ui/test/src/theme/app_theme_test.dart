import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    group('light', () {
      final themeData = const AppTheme.light().themeData;

      test('builds a light color scheme seeded with the brand primary', () {
        expect(themeData.colorScheme.brightness, Brightness.light);
        expect(themeData.colorScheme.primary, const Color(0xFF4F6D3A));
      });

      test('registers the light AppExtendedColors extension', () {
        final extended = themeData.extension<AppExtendedColors>();
        expect(extended, isNotNull);
        expect(extended!.disabledBtn, AppExtendedColors.light.disabledBtn);
      });
    });

    group('dark', () {
      final themeData = const AppTheme.dark().themeData;

      test('builds a dark color scheme with the dark primary', () {
        expect(themeData.colorScheme.brightness, Brightness.dark);
        expect(themeData.colorScheme.primary, const Color(0xFFC9DEBA));
      });

      test('registers the dark AppExtendedColors extension', () {
        final extended = themeData.extension<AppExtendedColors>();
        expect(extended, isNotNull);
        expect(extended!.disabledBtn, AppExtendedColors.dark.disabledBtn);
      });
    });

    test('applies the app text theme and standard visual density', () {
      final themeData = const AppTheme.light().themeData;
      // ThemeData runs the supplied textTheme through `.apply()` (adding a
      // default color and font family), so the stored styles aren't identical
      // to the raw AppTextStyle values — assert the metrics that survive.
      expect(
        themeData.textTheme.titleMedium!.fontSize,
        AppTextStyle.titleMedium.fontSize,
      );
      expect(
        themeData.textTheme.titleMedium!.fontWeight,
        AppTextStyle.titleMedium.fontWeight,
      );
      expect(
        themeData.textTheme.bodyLarge!.fontSize,
        AppTextStyle.bodyLarge.fontSize,
      );
      expect(themeData.visualDensity, VisualDensity.standard);
    });

    test('light and dark seeds match but primaries diverge', () {
      // Both variants share the same seed, so the scheme differs only by the
      // explicit primary override and the brightness.
      expect(
        const AppTheme.light().themeData.colorScheme.primary,
        isNot(const AppTheme.dark().themeData.colorScheme.primary),
      );
    });
  });
}

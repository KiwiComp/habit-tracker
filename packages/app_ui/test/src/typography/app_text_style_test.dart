import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTextStyle', () {
    test('exposes the Material 3 type scale font sizes', () {
      expect(AppTextStyle.displayLarge.fontSize, 57);
      expect(AppTextStyle.displayMedium.fontSize, 45);
      expect(AppTextStyle.displaySmall.fontSize, 36);
      expect(AppTextStyle.headlineLarge.fontSize, 32);
      expect(AppTextStyle.headlineMedium.fontSize, 28);
      expect(AppTextStyle.headlineSmall.fontSize, 24);
      expect(AppTextStyle.titleLarge.fontSize, 22);
      expect(AppTextStyle.titleMedium.fontSize, 16);
      expect(AppTextStyle.titleSmall.fontSize, 14);
      expect(AppTextStyle.bodyLarge.fontSize, 16);
      expect(AppTextStyle.bodyMedium.fontSize, 14);
      expect(AppTextStyle.bodySmall.fontSize, 12);
      expect(AppTextStyle.labelLarge.fontSize, 14);
      expect(AppTextStyle.labelMedium.fontSize, 12);
      expect(AppTextStyle.labelSmall.fontSize, 11);
    });

    test('title and label styles use medium (w500) weight', () {
      expect(AppTextStyle.titleMedium.fontWeight, AppFontWeight.w500);
      expect(AppTextStyle.titleSmall.fontWeight, AppFontWeight.w500);
      expect(AppTextStyle.labelLarge.fontWeight, AppFontWeight.w500);
      expect(AppTextStyle.labelMedium.fontWeight, AppFontWeight.w500);
      expect(AppTextStyle.labelSmall.fontWeight, AppFontWeight.w500);
    });

    test('display, headline and body styles use the regular (w400) base', () {
      expect(AppTextStyle.displayLarge.fontWeight, AppFontWeight.w400);
      expect(AppTextStyle.headlineLarge.fontWeight, AppFontWeight.w400);
      expect(AppTextStyle.bodyLarge.fontWeight, AppFontWeight.w400);
      expect(AppTextStyle.bodyMedium.fontWeight, AppFontWeight.w400);
      expect(AppTextStyle.bodySmall.fontWeight, AppFontWeight.w400);
    });

    test('every style opts out of text decoration', () {
      final styles = [
        AppTextStyle.displayLarge,
        AppTextStyle.displayMedium,
        AppTextStyle.displaySmall,
        AppTextStyle.headlineLarge,
        AppTextStyle.headlineMedium,
        AppTextStyle.headlineSmall,
        AppTextStyle.titleLarge,
        AppTextStyle.titleMedium,
        AppTextStyle.titleSmall,
        AppTextStyle.bodyLarge,
        AppTextStyle.bodyMedium,
        AppTextStyle.bodySmall,
        AppTextStyle.labelLarge,
        AppTextStyle.labelMedium,
        AppTextStyle.labelSmall,
      ];
      for (final style in styles) {
        expect(style.decoration, TextDecoration.none);
      }
    });

    test('displayLarge carries the tightened letter spacing', () {
      expect(AppTextStyle.displayLarge.letterSpacing, -0.25);
    });

    test('textTheme maps each slot to the matching style', () {
      final theme = AppTextStyle.textTheme;
      expect(theme.displayLarge, AppTextStyle.displayLarge);
      expect(theme.displayMedium, AppTextStyle.displayMedium);
      expect(theme.displaySmall, AppTextStyle.displaySmall);
      expect(theme.headlineLarge, AppTextStyle.headlineLarge);
      expect(theme.headlineMedium, AppTextStyle.headlineMedium);
      expect(theme.headlineSmall, AppTextStyle.headlineSmall);
      expect(theme.titleLarge, AppTextStyle.titleLarge);
      expect(theme.titleMedium, AppTextStyle.titleMedium);
      expect(theme.titleSmall, AppTextStyle.titleSmall);
      expect(theme.bodyLarge, AppTextStyle.bodyLarge);
      expect(theme.bodyMedium, AppTextStyle.bodyMedium);
      expect(theme.bodySmall, AppTextStyle.bodySmall);
      expect(theme.labelLarge, AppTextStyle.labelLarge);
      expect(theme.labelMedium, AppTextStyle.labelMedium);
      expect(theme.labelSmall, AppTextStyle.labelSmall);
    });
  });
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppExtendedColors', () {
    test('light variant holds the documented tokens', () {
      expect(AppExtendedColors.light.accent, const Color(0xFFB6244F));
      expect(AppExtendedColors.light.onAccent, const Color(0xFFFFFFFF));
      expect(AppExtendedColors.light.disabledBtn, const Color(0xFFD0D3C8));
    });

    test('dark variant differs from light only in the disabled color', () {
      expect(AppExtendedColors.dark.accent, AppExtendedColors.light.accent);
      expect(AppExtendedColors.dark.onAccent, AppExtendedColors.light.onAccent);
      expect(
        AppExtendedColors.dark.disabledBtn,
        const Color.fromARGB(255, 154, 156, 149),
      );
      expect(
        AppExtendedColors.dark.disabledBtn,
        isNot(AppExtendedColors.light.disabledBtn),
      );
    });

    group('copyWith', () {
      test('replaces only the given field', () {
        const base = AppExtendedColors.light;
        final updated = base.copyWith(accent: const Color(0xFF000000));

        expect(updated.accent, const Color(0xFF000000));
        expect(updated.onAccent, base.onAccent);
        expect(updated.disabledBtn, base.disabledBtn);
      });

      test('can replace onAccent and disabledBtn independently', () {
        const base = AppExtendedColors.light;
        final updated = base.copyWith(
          onAccent: const Color(0xFF111111),
          disabledBtn: const Color(0xFF222222),
        );

        expect(updated.accent, base.accent);
        expect(updated.onAccent, const Color(0xFF111111));
        expect(updated.disabledBtn, const Color(0xFF222222));
      });

      test('with no arguments keeps every field', () {
        const base = AppExtendedColors.light;
        final copy = base.copyWith();

        expect(copy.accent, base.accent);
        expect(copy.onAccent, base.onAccent);
        expect(copy.disabledBtn, base.disabledBtn);
      });
    });

    group('lerp', () {
      test('returns itself when other is null', () {
        expect(
          AppExtendedColors.light.lerp(null, 0.5),
          same(AppExtendedColors.light),
        );
      });

      test('at t = 0 equals the start', () {
        final start = AppExtendedColors.light.lerp(AppExtendedColors.dark, 0);
        expect(start.disabledBtn, AppExtendedColors.light.disabledBtn);
      });

      test('at t = 1 equals the end', () {
        final end = AppExtendedColors.light.lerp(AppExtendedColors.dark, 1);
        expect(end.disabledBtn, AppExtendedColors.dark.disabledBtn);
      });

      test('interpolates between start and end at t = 0.5', () {
        final mid = AppExtendedColors.light.lerp(AppExtendedColors.dark, 0.5);
        expect(
          mid.disabledBtn,
          Color.lerp(
            AppExtendedColors.light.disabledBtn,
            AppExtendedColors.dark.disabledBtn,
            0.5,
          ),
        );
      });
    });
  });
}

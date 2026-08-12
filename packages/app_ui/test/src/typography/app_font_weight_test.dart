import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFontWeight', () {
    test('aliases map to their FontWeight values', () {
      expect(AppFontWeight.w100, FontWeight.w100);
      expect(AppFontWeight.w200, FontWeight.w200);
      expect(AppFontWeight.w300, FontWeight.w300);
      expect(AppFontWeight.w400, FontWeight.w400);
      expect(AppFontWeight.w500, FontWeight.w500);
      expect(AppFontWeight.w600, FontWeight.w600);
      expect(AppFontWeight.w700, FontWeight.w700);
      expect(AppFontWeight.w800, FontWeight.w800);
      expect(AppFontWeight.w900, FontWeight.w900);
    });
  });
}

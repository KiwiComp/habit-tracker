import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppContextExtension', () {
    testWidgets('exposes colorScheme and extendedColors from the theme', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpApp(
        Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(context.colorScheme, const AppTheme.light().themeData.colorScheme);
      expect(
        context.extendedColors.disabledBtn,
        AppExtendedColors.light.disabledBtn,
      );
    });

    testWidgets('exposes the spacing, radius and icon-size token scales', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpApp(
        Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(context.spacing.md, const AppSpacing().md);
      expect(context.radius.full, const AppRadius().full);
      expect(context.iconSize.md, const AppIconSize().md);
    });

    testWidgets('isDarkMode is false under the light theme', (tester) async {
      late BuildContext context;
      await tester.pumpApp(
        Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(context.isDarkMode, isFalse);
    });

    testWidgets('isDarkMode is true under the dark theme', (tester) async {
      late BuildContext context;
      await tester.pumpApp(
        Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox.shrink();
          },
        ),
        theme: const AppTheme.dark(),
      );

      expect(context.isDarkMode, isTrue);
    });
  });
}

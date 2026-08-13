import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final scheme = const AppTheme.light().themeData.colorScheme;
  final disabledBg = AppExtendedColors.light.disabledBtn;

  ButtonStyle styleOf(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).style!;

  Color? bg(WidgetTester tester, Set<WidgetState> states) =>
      styleOf(tester).backgroundColor!.resolve(states);

  Color? fg(WidgetTester tester, Set<WidgetState> states) =>
      styleOf(tester).foregroundColor!.resolve(states);

  double radiusOf(WidgetTester tester) {
    final shape = styleOf(tester).shape!.resolve({})! as RoundedRectangleBorder;
    return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
  }

  group('AppButton', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpApp(
        AppButton.primary(onPressed: () {}, child: const Text('Save')),
      );
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        AppButton.primary(onPressed: () => taps++, child: const Text('Tap')),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(taps, 1);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpApp(
        const AppButton.primary(onPressed: null, child: Text('Off')),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.enabled, isFalse);
    });

    group('variant colors', () {
      testWidgets('primary uses the scheme primary, disabled token when off', (
        tester,
      ) async {
        await tester.pumpApp(
          AppButton.primary(onPressed: () {}, child: const Text('P')),
        );

        expect(bg(tester, {}), scheme.primary);
        expect(bg(tester, {WidgetState.disabled}), disabledBg);
        expect(fg(tester, {}), scheme.onPrimary);
        expect(
          fg(tester, {WidgetState.disabled}),
          scheme.onPrimary.withAlpha(100),
        );
      });

      testWidgets('secondary uses the secondary container colors', (
        tester,
      ) async {
        await tester.pumpApp(
          AppButton.secondary(onPressed: () {}, child: const Text('S')),
        );

        expect(bg(tester, {}), scheme.secondaryContainer);
        expect(bg(tester, {WidgetState.disabled}), disabledBg);
        expect(fg(tester, {}), scheme.onSecondaryContainer);
        expect(
          fg(tester, {WidgetState.disabled}),
          scheme.onSecondaryContainer.withAlpha(100),
        );
      });

      testWidgets('tertiary uses the tertiary colors', (tester) async {
        await tester.pumpApp(
          AppButton.tertiary(onPressed: () {}, child: const Text('T')),
        );

        expect(bg(tester, {}), scheme.tertiary);
        expect(bg(tester, {WidgetState.disabled}), disabledBg);
        expect(fg(tester, {}), scheme.onTertiary);
        expect(
          fg(tester, {WidgetState.disabled}),
          scheme.tertiary.withAlpha(100),
        );
      });
    });

    group('shape', () {
      testWidgets('round uses the full (pill) radius', (tester) async {
        await tester.pumpApp(
          AppButton.primary(onPressed: () {}, child: const Text('R')),
        );
        expect(radiusOf(tester), const AppRadius().full);
      });

      testWidgets('square uses the small radius', (tester) async {
        await tester.pumpApp(
          AppButton.primary(
            onPressed: () {},
            shape: AppButtonShape.square,
            child: const Text('Q'),
          ),
        );
        expect(radiusOf(tester), const AppRadius().sm);
      });
    });

    group('size', () {
      testWidgets('small', (tester) async {
        await tester.pumpApp(
          AppButton.primary(
            onPressed: () {},
            size: AppButtonSize.small,
            child: const Text('s'),
          ),
        );
        expect(styleOf(tester).minimumSize!.resolve({})!.height, 40);
        expect(
          styleOf(tester).textStyle!.resolve({})!.fontSize,
          AppTextStyle.labelLarge.fontSize,
        );
      });

      testWidgets('medium', (tester) async {
        await tester.pumpApp(
          AppButton.primary(
            onPressed: () {},
            child: const Text('m'),
          ),
        );
        expect(styleOf(tester).minimumSize!.resolve({})!.height, 56);
        expect(
          styleOf(tester).textStyle!.resolve({})!.fontSize,
          AppTextStyle.titleMedium.fontSize,
        );
      });

      testWidgets('large', (tester) async {
        await tester.pumpApp(
          AppButton.primary(
            onPressed: () {},
            size: AppButtonSize.large,
            child: const Text('l'),
          ),
        );
        expect(styleOf(tester).minimumSize!.resolve({})!.height, 96);
        expect(
          styleOf(tester).textStyle!.resolve({})!.fontSize,
          AppTextStyle.headlineSmall.fontSize,
        );
      });
    });

    group('width', () {
      testWidgets('expand stretches to the full available width', (
        tester,
      ) async {
        await tester.pumpApp(
          AppButton.primary(onPressed: () {}, child: const Text('E')),
        );
        // Default test surface is 800 logical pixels wide.
        expect(tester.getSize(find.byType(ElevatedButton)).width, 800);
      });

      testWidgets('shrink sizes to its content', (tester) async {
        await tester.pumpApp(
          AppButton.primary(
            onPressed: () {},
            width: AppButtonWidth.shrink,
            child: const Text('E'),
          ),
        );
        expect(
          tester.getSize(find.byType(ElevatedButton)).width,
          lessThan(800),
        );
      });
    });
  });
}

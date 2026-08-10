import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

extension AppButtonStyleX on BuildContext {
  /// Resolves the [ButtonStyle] for the given [variant] and [shape].
  ButtonStyle getStyle({
    required AppButtonVariant variant,
    required AppButtonShape shape,
    required AppButtonSize size,
  }) {
    return const ButtonStyle()
        ._forVariant(variant, this)
        ._forShape(shape, this)
        ._forSize(size, this);
  }
}

extension on ButtonStyle {
  ButtonStyle _forVariant(AppButtonVariant variant, BuildContext context) {
    return switch (variant) {
      AppButtonVariant.primary => copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return context.extendedColors.disabledBtn;
          }
          return context.colorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return context.colorScheme.onPrimary.withAlpha(100);
          }
          return context.colorScheme.onPrimary;
        }),
      ),
      AppButtonVariant.secondary => copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return context.extendedColors.disabledBtn;
          }
          return context.colorScheme.secondaryContainer;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return context.colorScheme.onSecondaryContainer.withAlpha(100);
          }
          return context.colorScheme.onSecondaryContainer;
        }),
      ),
      AppButtonVariant.tertiary => copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return context.extendedColors.disabledBtn;
          }
          return context.colorScheme.tertiary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return context.colorScheme.tertiary.withAlpha(100);
          }
          return context.colorScheme.onTertiary;
        }),
      ),
    };
  }

  ButtonStyle _forShape(AppButtonShape shape, BuildContext context) {
    return copyWith(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            shape == AppButtonShape.round
                ? context.radius.full
                : context.radius.sm,
          ),
        ),
      ),
    );
  }

  ButtonStyle _forSize(AppButtonSize size, BuildContext context) {
    final (double height, double padding, TextStyle textStyle) = switch (size) {
      AppButtonSize.small => (
        40.0,
        context.spacing.md,
        AppTextStyle.labelLarge,
      ),
      AppButtonSize.medium => (
        56.0,
        context.spacing.lg,
        AppTextStyle.titleMedium,
      ),
      AppButtonSize.large => (
        96.0,
        context.spacing.xl,
        AppTextStyle.headlineSmall,
      ),
    };
    return copyWith(
      minimumSize: WidgetStatePropertyAll(Size(64, height)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: padding),
      ),
      textStyle: WidgetStatePropertyAll(textStyle),
    );
  }
}

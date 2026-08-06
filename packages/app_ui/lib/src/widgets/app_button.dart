import 'package:app_ui/src/widgets/app_button_style.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, tertiary }

enum AppButtonWidth { shrink, expand }

enum AppButtonShape { round, square }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton._({
    required this.variant,
    required this.shape,
    required this.width,
    required this.size,
    required this.onPressed,
    required this.child,
    super.key,
  });

  const AppButton.primary({
    AppButtonWidth width = AppButtonWidth.expand,
    AppButtonShape shape = AppButtonShape.round,
    AppButtonSize size = AppButtonSize.medium,
    required void Function()? onPressed,
    required Widget child,
    Key? key,
  }) : this._(
         width: width,
         shape: shape,
         size: size,
         variant: AppButtonVariant.primary,
         onPressed: onPressed,
         child: child,
         key: key,
       );

  const AppButton.secondary({
    AppButtonWidth width = AppButtonWidth.expand,
    AppButtonShape shape = AppButtonShape.round,
    AppButtonSize size = AppButtonSize.medium,
    required void Function()? onPressed,
    required Widget child,
    Key? key,
  }) : this._(
         width: width,
         shape: shape,
         size: size,
         variant: AppButtonVariant.secondary,
         onPressed: onPressed,
         child: child,
         key: key,
       );

  const AppButton.tertiary({
    AppButtonWidth width = AppButtonWidth.expand,
    AppButtonShape shape = AppButtonShape.round,
    AppButtonSize size = AppButtonSize.medium,
    required void Function()? onPressed,
    required Widget child,
    Key? key,
  }) : this._(
         width: width,
         shape: shape,
         size: size,
         variant: AppButtonVariant.tertiary,
         onPressed: onPressed,
         child: child,
         key: key,
       );

  final AppButtonVariant variant;
  final AppButtonShape shape;
  final AppButtonWidth width;
  final AppButtonSize size;
  final void Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = context.getStyle(variant: variant, shape: shape, size: size);
    final button = ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: child,
    );
    return switch (width) {
      AppButtonWidth.expand => SizedBox(
        width: double.infinity,
        child: button,
      ),
      AppButtonWidth.shrink => button,
    };
    // return SizedBox(
    //   child: ElevatedButton(style: style, onPressed: onPressed, child: child),
    // );
  }
}

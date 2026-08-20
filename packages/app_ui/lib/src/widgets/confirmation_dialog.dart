import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Opens a dialog, centered on the screen, asking the user to confirm or
/// cancel [message].
///
/// Returns `true` once the user taps the "yes" button, or `false` if they
/// tap the "no" button or dismiss the dialog any other way. Doesn't persist
/// anything itself — same "dialog returns a choice, caller acts on it" shape
/// as `showEditNameDialog`.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String message,
  required String yesLabel,
  required String noLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => _ConfirmationDialog(
      message: message,
      yesLabel: yesLabel,
      noLabel: noLabel,
    ),
  );
  return confirmed ?? false;
}

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({
    required this.message,
    required this.yesLabel,
    required this.noLabel,
  });

  final String message;
  final String yesLabel;
  final String noLabel;

  @override
  Widget build(BuildContext context) {
    final borderRadius = context.radius.lg;
    final spacing = context.spacing;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.all(spacing.md),
        child: FractionallySizedBox(
          widthFactor: 1,
          child: Column(
            spacing: spacing.md,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                message,
                textAlign: .center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: spacing.md,
                children: [
                  AppButton.primary(
                    width: AppButtonWidth.shrink,
                    size: AppButtonSize.small,
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(noLabel),
                  ),
                  AppButton.secondary(
                    width: AppButtonWidth.shrink,
                    size: AppButtonSize.small,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(yesLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

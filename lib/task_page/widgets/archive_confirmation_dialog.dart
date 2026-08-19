import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/l10n.dart';

/// Opens a dialog, centered on the screen, confirming whether to archive
/// (soft-delete) the task/habit named [name].
///
/// Returns `true` once the user taps Yes, or `false` if they tap No or
/// dismiss the dialog any other way. Doesn't persist anything itself — same
/// "dialog returns a choice, caller acts on it" shape as `EditNameDialog`.
Future<bool> showArchiveConfirmationDialog(
  BuildContext context, {
  required String name,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => _ArchiveConfirmationDialog(
      name: name,
    ),
  );
  return confirmed ?? false;
}

class _ArchiveConfirmationDialog extends StatelessWidget {
  const _ArchiveConfirmationDialog({
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    final borderRadius = context.radius.lg;
    final spacing = context.spacing;
    final l10n = context.l10n;

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
                l10n.deleteConfirmationMessage(name),
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
                    child: Text(l10n.commonNo),
                  ),
                  AppButton.secondary(
                    width: AppButtonWidth.shrink,
                    size: AppButtonSize.small,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.commonYes),
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

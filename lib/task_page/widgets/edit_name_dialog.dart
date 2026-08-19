import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/l10n.dart';

/// Opens a dialog, centered on the screen, for editing a task/habit's name,
/// pre-filled with [currentName].
///
/// Returns the new, trimmed name once the user taps Save, or `null` if the
/// dialog was dismissed without saving. Doesn't persist anything itself —
/// same "dialog returns a choice, caller acts on it" shape as
/// `EndDateField`'s sheet.
Future<String?> showEditNameDialog(
  BuildContext context, {
  required String currentName,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _EditNameDialog(currentName: currentName),
  );
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.currentName});

  final String currentName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late String _name = widget.currentName;

  bool get _canSave =>
      _name.trim().isNotEmpty && _name.trim() != widget.currentName;

  void _save() => Navigator.of(context).pop(_name.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: FractionallySizedBox(
          widthFactor: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing.md,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                initialValue: widget.currentName,
                onChanged: (name) => setState(() => _name = name),
                label: l10n.createActivityNameLabel,
                hint: l10n.createActivityNameHintTask,
              ),
              AppButton.primary(
                onPressed: _canSave ? _save : null,
                child: Text(l10n.createActivitySaveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

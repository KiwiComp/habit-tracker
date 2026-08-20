import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Opens a dialog, centered on the screen, for editing a name, pre-filled
/// with [currentName].
///
/// Returns the new, trimmed name once the user taps the save button, or
/// `null` if the dialog was dismissed without saving. Doesn't persist
/// anything itself — same "dialog returns a choice, caller acts on it" shape
/// as `pickEndDate`'s sheet.
Future<String?> showEditNameDialog(
  BuildContext context, {
  required String currentName,
  required String label,
  required String hint,
  required String saveButtonLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _EditNameDialog(
      currentName: currentName,
      label: label,
      hint: hint,
      saveButtonLabel: saveButtonLabel,
    ),
  );
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({
    required this.currentName,
    required this.label,
    required this.hint,
    required this.saveButtonLabel,
  });

  final String currentName;
  final String label;
  final String hint;
  final String saveButtonLabel;

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
                label: widget.label,
                hint: widget.hint,
              ),
              AppButton.primary(
                onPressed: _canSave ? _save : null,
                child: Text(widget.saveButtonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

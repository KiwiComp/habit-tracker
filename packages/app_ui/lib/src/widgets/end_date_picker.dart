import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Prompts the user to choose a new end date, or clear it ("Never").
///
/// If [currentDate] is already `null`, there's nothing to offer clearing —
/// this skips straight to the date picker instead of showing the "Never /
/// pick a date" choice sheet. [onChanged] is called only on an explicit
/// choice: a picked date, or `null` for "Never". It's never called if a
/// sheet or the picker is dismissed without a choice.
Future<void> pickEndDate(
  BuildContext context, {
  required DateTime? currentDate,
  required DateTime firstDate,
  required DateTime preferredInitialDate,
  required String neverLabel,
  required String pickDateLabel,
  required ValueChanged<DateTime?> onChanged,
}) async {
  if (currentDate != null) {
    final action = await showModalBottomSheet<_EndDateAction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.lg),
        ),
      ),
      builder: (_) => _EndDateActionSheet(
        neverLabel: neverLabel,
        pickDateLabel: pickDateLabel,
      ),
    );
    if (action == null) return;
    if (action == _EndDateAction.never) {
      onChanged(null);
      return;
    }
    if (!context.mounted) return;
  }

  final initialDate = preferredInitialDate.isBefore(firstDate)
      ? firstDate
      : preferredInitialDate;
  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: DateTime(firstDate.year + 5),
  );
  if (picked != null) onChanged(picked);
}

enum _EndDateAction { never, pickDate }

class _EndDateActionSheet extends StatelessWidget {
  const _EndDateActionSheet({
    required this.neverLabel,
    required this.pickDateLabel,
  });

  final String neverLabel;
  final String pickDateLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: spacing.lg,
          horizontal: spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EndDateActionOption(
              icon: Icons.all_inclusive,
              title: neverLabel,
              onTap: () => Navigator.of(context).pop(_EndDateAction.never),
            ),
            SizedBox(height: spacing.sm),
            _EndDateActionOption(
              icon: Icons.event_outlined,
              title: pickDateLabel,
              onTap: () => Navigator.of(context).pop(_EndDateAction.pickDate),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndDateActionOption extends StatelessWidget {
  const _EndDateActionOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colorScheme;
    final borderRadius = context.radius.md;

    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            children: [
              Icon(icon, size: context.iconSize.md, color: colors.tertiary),
              SizedBox(width: spacing.md),
              Text(title, style: AppTextStyle.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

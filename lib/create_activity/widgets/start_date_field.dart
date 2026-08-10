import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// A tappable field that opens a date picker and displays the chosen date.
///
/// Used for both the habit "starts on" date and the task's single
/// occurrence date — [label] carries whichever wording applies.
class StartDateField extends StatelessWidget {
  /// Creates a [StartDateField].
  const StartDateField({
    required this.label,
    required this.date,
    required this.onChanged,
    super.key,
  });

  /// The field's label, e.g. "Starts on" or "Date".
  final String label;

  /// The currently selected date.
  final DateTime date;

  /// Called with the newly picked date.
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderRadius = context.radius.sm;
    final colors = context.colorScheme;
    final iconSize = context.iconSize.md;

    return Material(
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: colors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: () => _pickDate(context),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.md,
          ),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: iconSize,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: context.spacing.md),
                  Text(
                    DateFormat(
                      'd MMM yyyy',
                      context.locale.toString(),
                    ).format(date),
                    style: AppTextStyle.titleMedium,
                  ),
                ],
              ),
              Icon(
                Icons.keyboard_arrow_down_sharp,
                size: iconSize,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(date.year - 1),
      lastDate: DateTime(date.year + 5),
    );
    if (picked != null) onChanged(picked);
  }
}

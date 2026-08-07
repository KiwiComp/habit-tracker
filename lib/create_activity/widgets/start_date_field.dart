import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
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
    return Material(
      color: context.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(context.radius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.radius.md),
        onTap: () => _pickDate(context),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: context.iconSize.sm,
                color: context.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyle.labelSmall.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      DateFormat('d MMM yyyy').format(date),
                      style: AppTextStyle.titleMedium,
                    ),
                  ],
                ),
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

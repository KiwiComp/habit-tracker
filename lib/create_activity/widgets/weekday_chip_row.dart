import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reference Monday — used only to format each weekday's abbreviated,
/// locale-correct label (`DateFormat.E()` needs an actual date).
final DateTime _referenceMonday = DateTime(2024);

/// A row of toggleable chips for picking which weekdays a
/// `Frequency.weekdays` habit repeats on.
class WeekdayChipRow extends StatelessWidget {
  /// Creates a [WeekdayChipRow].
  const WeekdayChipRow({
    required this.selected,
    required this.onToggled,
    super.key,
  });

  /// The currently selected weekdays, using `DateTime.monday` (1) through
  /// `DateTime.sunday` (7).
  final Set<int> selected;

  /// Called with the weekday that was tapped.
  final ValueChanged<int> onToggled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.spacing.sm,
      runSpacing: context.spacing.sm,
      children: [
        for (
          var weekday = DateTime.monday;
          weekday <= DateTime.sunday;
          weekday++
        )
          _WeekdayChip(
            weekday: weekday,
            isSelected: selected.contains(weekday),
            onTap: () => onToggled(weekday),
          ),
      ],
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.weekday,
    required this.isSelected,
    required this.onTap,
  });

  final int weekday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? context.colorScheme.tertiary
        : context.colorScheme.surfaceContainerHigh;
    final foregroundColor = isSelected
        ? context.extendedColors.onAccent
        : context.colorScheme.onSurfaceVariant;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(context.radius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radius.full),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.sm,
          ),
          child: Text(
            DateFormat.E().format(
              _referenceMonday.add(Duration(days: weekday - DateTime.monday)),
            ),
            style: AppTextStyle.labelMedium.copyWith(color: foregroundColor),
          ),
        ),
      ),
    );
  }
}

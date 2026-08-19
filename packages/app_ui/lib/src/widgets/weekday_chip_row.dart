import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reference Monday — used only to format each weekday's abbreviated,
/// locale-correct label (`DateFormat.E()` needs an actual date).
final DateTime _referenceMonday = DateTime(2024);

class WeekdayChipRow extends StatelessWidget {
  const WeekdayChipRow({
    required this.weekdays,
    required this.onToggled,
    super.key,
  });

  final Set<int> weekdays;
  final ValueChanged<int>? onToggled;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.spacing.xs,
      children: [
        for (
          var weekday = DateTime.monday;
          weekday <= DateTime.sunday;
          weekday++
        )
          Expanded(
            child: _WeekdayChip(
              weekday: weekday,
              isSelected: weekdays.contains(weekday),
              onTap: onToggled != null ? () => onToggled!(weekday) : null,
            ),
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    final letter = MaterialLocalizations.of(
      context,
    ).narrowWeekdays[weekday % DateTime.daysPerWeek];

    final fullName = DateFormat.EEEE(Localizations.localeOf(context).toString())
        .format(
          _referenceMonday.add(Duration(days: weekday - DateTime.monday)),
        );

    return Semantics(
      label: fullName,
      selected: isSelected,
      container: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: Material(
          color: isSelected ? colors.tertiary : Colors.transparent,
          shape: CircleBorder(
            side: isSelected
                ? BorderSide.none
                : BorderSide(color: colors.outline),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Center(
              child: ExcludeSemantics(
                child: Text(
                  letter,
                  style: AppTextStyle.labelLarge.copyWith(
                    color: isSelected
                        ? context.extendedColors.onAccent
                        : colors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

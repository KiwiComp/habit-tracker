import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habits_repository/habits_repository.dart';

/// A single row in `HabitsListPage`.
///
/// Minimal, functional placeholder — no reference design for this list yet
/// (see `ScheduleList`'s doc comment for the same caveat). Shows just the
/// name, tappable to open [habit]'s detail page.
class HabitListTile extends StatelessWidget {
  /// Creates a [HabitListTile] for [habit].
  const HabitListTile({required this.habit, required this.onTap, super.key});

  /// The habit this row represents.
  final Habit habit;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final extColors = context.extendedColors;
    final spacing = context.spacing;
    final borderRadius = BorderRadius.circular(context.radius.md);
    final foregroundColor = colors.surfaceBright;

    return Material(
      color: extColors.habitTile,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            spacing: spacing.md,
            children: [
              Row(
                spacing: spacing.sm,
                children: [
                  Icon(
                    Icons.military_tech_outlined,
                    color: foregroundColor,
                  ),
                  Text(
                    habit.name,
                    style: AppTextStyle.bodyLarge.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
              WeekdayChipRow(
                weekdays: habit.weekdays,
                onToggled: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

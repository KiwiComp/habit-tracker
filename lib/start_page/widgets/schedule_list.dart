import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:intl/intl.dart';

/// The list of habits scheduled for the selected day.
///
/// Minimal, functional placeholder — there's no reference design for this
/// yet (unlike `EmptySchedule`/`DayChip`, which came from a screenshot).
/// Revisit once one exists.
class ScheduleList extends StatelessWidget {
  /// Creates a [ScheduleList] for the given [activities], all scheduled on
  /// [selectedDate].
  const ScheduleList({
    required this.activities,
    required this.selectedDate,
    super.key,
  });

  /// The habits to display, in the order they should be shown.
  final List<Habit> activities;

  /// The day [activities] are scheduled for.
  ///
  /// `Habit` has no time-of-day of its own, so this is shown for every row
  /// rather than a per-item time — see TODO.md's "ScheduleList items aren't
  /// tappable yet" for what's still placeholder here.
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.sm,
      ),
      itemCount: activities.length,
      separatorBuilder: (_, _) => SizedBox(height: context.spacing.sm),
      itemBuilder: (context, index) {
        final habit = activities[index];
        return _HabitTile(habit: habit, selectedDate: selectedDate);
      },
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({required this.habit, required this.selectedDate});

  final Habit habit;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final foregroundColor = habit.frequency == Frequency.once
        // ? colors.onSurface
        ? colors.onSurfaceVariant
        // : colors.onPrimary;
        : colors.surfaceBright;

    return Material(
      color: habit.frequency == Frequency.once
          ? colors.tertiary.withAlpha(40)
          : colors.tertiary.withAlpha(150),
      borderRadius: BorderRadius.circular(context.radius.md),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.md,
          vertical: context.spacing.md,
        ),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Row(
              spacing: context.spacing.sm,
              children: [
                Icon(
                  habit.frequency == Frequency.once
                      ? Icons.task_alt_outlined
                      : Icons.military_tech_outlined,
                  color: foregroundColor,
                ),
                Text(
                  habit.name,
                  style: AppTextStyle.titleMedium.copyWith(
                    color: foregroundColor,
                  ),
                ),
              ],
            ),
            // Text(
            //   DateFormat.Hm().format(selectedDate),
            //   style: AppTextStyle.bodyMedium.copyWith(
            //     // color: context.colorScheme.onSurfaceVariant,
            //     color: foregroundColor,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

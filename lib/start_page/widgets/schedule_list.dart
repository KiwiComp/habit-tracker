import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habits_repository/habits_repository.dart';

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
    required this.completedHabitIds,
    required this.selectedDate,
    required this.onActivityTap,
    super.key,
  });

  /// The habits to display, in the order they should be shown.
  final List<Habit> activities;

  /// List of existing Entries for selected date.
  final Set<String> completedHabitIds;

  /// The day [activities] are scheduled for.
  ///
  /// `Habit` has no time-of-day of its own, so this is shown for every row
  /// rather than a per-item time — see KNOWN_GAPS.md's "ScheduleList still has
  /// placeholder gaps" for what's still placeholder here.
  final DateTime selectedDate;

  /// Called with the tapped row's habit, to open its detail page.
  final ValueChanged<Habit> onActivityTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.sm,
      ),
      itemCount: activities.length,
      separatorBuilder: (_, _) => SizedBox(height: context.spacing.sm),
      itemBuilder: (context, index) {
        final habit = activities[index];
        return _HabitTile(
          habit: habit,
          completedHabitIds: completedHabitIds,
          selectedDate: selectedDate,
          onTap: () => onActivityTap(habit),
        );
      },
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.habit,
    required this.completedHabitIds,
    required this.selectedDate,
    required this.onTap,
  });

  final Habit habit;
  final Set<String> completedHabitIds;
  final DateTime selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final foregroundColor = habit.frequency == Frequency.once
        ? colors.onSurfaceVariant
        : colors.surfaceBright;

    return Material(
      color: habit.frequency == Frequency.once
          ? colors.tertiary.withAlpha(40)
          : colors.tertiary.withAlpha(150),
      borderRadius: BorderRadius.circular(context.radius.md),
      child: InkWell(
        onTap: onTap,
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
              Icon(
                completedHabitIds.contains(habit.id)
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

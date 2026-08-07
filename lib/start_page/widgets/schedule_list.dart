import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/start_page/models/models.dart';
import 'package:intl/intl.dart';

/// The list of activities scheduled for the selected day.
///
/// Minimal, functional placeholder — there's no reference design for this
/// yet (unlike `EmptySchedule`/`DayChip`, which came from a screenshot).
/// Revisit once one exists.
class ScheduleList extends StatelessWidget {
  /// Creates a [ScheduleList] for the given [activities].
  const ScheduleList({required this.activities, super.key});

  /// The activities to display, in the order they should be shown.
  final List<Activity> activities;

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
        final activity = activities[index];
        return Material(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(context.radius.md),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.md,
              vertical: context.spacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(activity.title, style: AppTextStyle.titleMedium),
                ),
                Text(
                  DateFormat.Hm().format(activity.date),
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

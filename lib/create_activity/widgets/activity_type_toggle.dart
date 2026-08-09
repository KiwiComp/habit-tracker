import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/create_activity/models/models.dart';
import 'package:habit_tracker/l10n/l10n.dart';

/// A segmented control for switching between creating a habit and a task.
///
/// Reuses the "Habit"/"Task" strings from the add-activity sheet — same
/// concept, same wording.
class ActivityTypeToggle extends StatelessWidget {
  /// Creates an [ActivityTypeToggle].
  const ActivityTypeToggle({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// The currently selected activity type.
  final ActivityType selected;

  /// Called when the user picks the other type.
  final ValueChanged<ActivityType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textStyle = AppTextStyle.titleMedium;

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ActivityType>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: context.colorScheme.tertiary,
          selectedForegroundColor: context.extendedColors.onAccent,
          padding: EdgeInsets.symmetric(vertical: context.spacing.md),
        ),
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: ActivityType.habit,
            label: Text(l10n.addActivityHabitTitle, style: textStyle),
          ),
          ButtonSegment(
            value: ActivityType.task,
            label: Text(
              l10n.addActivityTaskTitle,
              style: textStyle,
            ),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (values) => onChanged(values.first),
      ),
    );
  }
}

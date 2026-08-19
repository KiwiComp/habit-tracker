import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habits_repository/habits_repository.dart';

/// A single row in `TasksListPage`.

class TaskListTile extends StatelessWidget {
  /// Creates a [TaskListTile] for [task].
  const TaskListTile({required this.task, required this.onTap, super.key});

  /// The task this row represents.
  final Habit task;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final extColors = context.extendedColors;
    final borderRadius = BorderRadius.circular(context.radius.md);
    final spacing = context.spacing;
    final foregroundColor = colors.onSurfaceVariant;

    return Material(
      color: extColors.taskTile,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            spacing: spacing.sm,
            children: [
              Icon(
                Icons.task_alt_outlined,
                color: foregroundColor,
              ),
              Text(
                task.name,
                style: AppTextStyle.bodyLarge.copyWith(
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

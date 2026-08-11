import 'package:flutter/material.dart';
import 'package:habits_repository/habits_repository.dart';

/// A single row in `TasksListPage`.
///
/// Minimal, functional placeholder — no reference design for this list yet
/// (see `ScheduleList`'s doc comment for the same caveat). Shows just the
/// name, tappable to open [task]'s detail page.
class TaskListTile extends StatelessWidget {
  /// Creates a [TaskListTile] for [task].
  const TaskListTile({required this.task, required this.onTap, super.key});

  /// The task this row represents.
  final Habit task;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(task.name), onTap: onTap);
  }
}

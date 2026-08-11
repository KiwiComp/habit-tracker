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
    return ListTile(title: Text(habit.name), onTap: onTap);
  }
}

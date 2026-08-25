import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/habit_stats.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habits_repository/habits_repository.dart';

/// A single row in `HabitsListPage`.
///
/// Minimal, functional placeholder — no reference design for this list yet
/// (see `ScheduleList`'s doc comment for the same caveat). Shows just the
/// name, tappable to open [habit]'s detail page.
class HabitListTile extends StatelessWidget {
  /// Creates a [HabitListTile] for [habit].
  const HabitListTile({
    required this.habit,
    required this.stats,
    required this.onTap,
    super.key,
  });

  /// The habit this row represents.
  final Habit habit;

  /// [habit]'s completion/streak numbers. Not yet shown — display is still
  /// pending (see `_StatsSection`, currently unwired).
  final HabitStats stats;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      if (habit.endDate == null)
                        Icon(
                          Icons.all_inclusive,
                          color: foregroundColor,
                          size: context.iconSize.sm,
                        ),
                    ],
                  ),
                  _CompletionBadge(
                    stats: stats,
                  ),
                ],
              ),
              WeekdayChipRow(
                weekdays: habit.weekdays,
                onToggled: null,
              ),
              _StatsSection(
                stats: stats,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.stats, super.key});

  final HabitStats stats;

  @override
  Widget build(BuildContext context) {
    final borderRadius = context.radius.full;
    final spacing = context.spacing;
    final dimensions = spacing.xl + 4;
    final colors = context.colorScheme;
    final textStyle = AppTextStyle.labelSmall.copyWith(
      color: colors.onTertiaryContainer,
      fontWeight: .w800,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: const Color.fromARGB(255, 255, 209, 59),
        boxShadow: [
          BoxShadow(
            color: colors.onTertiaryContainer,
            offset: const Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
      height: dimensions,
      width: dimensions,
      child: Center(
        child: Text(
          stats.totalScheduled != null
              ? '${stats.completedCount}/${stats.totalScheduled}'
              : '${stats.completedCount}',
          style: textStyle,
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({
    required this.stats,
  });

  final HabitStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colorScheme;
    final textStyle = AppTextStyle.bodySmall.copyWith(
      color: colors.onPrimary,
    );
    final borderRadius = context.radius.xs;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: colors.tertiary.withAlpha(100),
        border: BoxBorder.all(color: colors.tertiary, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: context.spacing.md,
          children: [
            Text(
              l10n.habitsListTileCurrentStreak(stats.currentStreak),
              style: textStyle,
            ),
            Text(
              l10n.habitsListTileLongestStreak(stats.longestStreak),
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}

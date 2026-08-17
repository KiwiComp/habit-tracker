import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/start_page/widgets/slide_to_reveal_tile.dart';
import 'package:habits_repository/habits_repository.dart';

/// The list of habits scheduled for the selected day.
///
/// Minimal, functional placeholder — there's no reference design for this
/// yet (unlike `EmptySchedule`/`DayChip`, which came from a screenshot).
/// Revisit once one exists.
class ScheduleList extends StatefulWidget {
  /// Creates a [ScheduleList] for the given [activities], all scheduled on
  /// [selectedDate].
  const ScheduleList({
    required this.activities,
    required this.completedHabitIds,
    required this.selectedDate,
    required this.onActivityTap,
    required this.onOpenActivity,
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

  /// Called with the tapped row's habit, to toggle it done for
  /// [selectedDate].
  final ValueChanged<Habit> onActivityTap;

  /// Called with the habit whose slide-reveal action was tapped, to open
  /// its detail page.
  final ValueChanged<Habit> onOpenActivity;

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  /// The id of whichever row currently has its slide action open, if any.
  ///
  /// Only one row may be open at a time — this is ephemeral, presentation-
  /// only state specific to this widget, not app state, so it lives here
  /// rather than in `StartBloc`/`StartState` (same reasoning as
  /// `StartView`'s `_daySelectorKey`).
  String? _openHabitId;

  void _onRowOpenChanged(String habitId, {required bool open}) {
    final nextOpenId = open
        ? habitId
        : (_openHabitId == habitId ? null : _openHabitId);
    if (nextOpenId == _openHabitId) return;
    setState(() => _openHabitId = nextOpenId);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.sm,
      ),
      itemCount: widget.activities.length,
      separatorBuilder: (_, _) => SizedBox(height: context.spacing.sm),
      itemBuilder: (context, index) {
        final habit = widget.activities[index];
        return SlideToRevealTile(
          key: ValueKey(habit.id),
          revealWidth: context.spacing.xxxl,
          isDesignatedOpen: habit.id == _openHabitId,
          onOpenChanged: (open) => _onRowOpenChanged(habit.id, open: open),
          action: _OpenDetailAction(
            onTap: () => widget.onOpenActivity(habit),
          ),
          childBuilder: (context, revealFraction) => _HabitTile(
            habit: habit,
            completedHabitIds: widget.completedHabitIds,
            selectedDate: widget.selectedDate,
            revealFraction: revealFraction,
            onTap: () => widget.onActivityTap(habit),
          ),
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
    required this.revealFraction,
    required this.onTap,
  });

  final Habit habit;
  final Set<String> completedHabitIds;
  final DateTime selectedDate;

  /// How far the enclosing [SlideToRevealTile] is open, 0 (closed) to 1
  /// (fully open) — squares off the right corners as it opens, so the tile
  /// reads as flush with the revealed action instead of floating above it.
  final double revealFraction;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final extColors = context.extendedColors;
    final foregroundColor = habit.frequency == Frequency.once
        ? colors.onSurfaceVariant
        : colors.surfaceBright;
    final leftRadius = Radius.circular(context.radius.md);
    final rightRadius = Radius.circular(
      context.radius.md * (1 - revealFraction),
    );
    final borderRadius = BorderRadius.only(
      topLeft: leftRadius,
      bottomLeft: leftRadius,
      topRight: rightRadius,
      bottomRight: rightRadius,
    );

    return Material(
      color: habit.frequency == Frequency.once
          ? extColors.taskTile
          : extColors.habitTile,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
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
              //TODO(kb): Colours for icon below.
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

/// The action revealed by [SlideToRevealTile] — opens the habit's detail
/// page, the job the whole tile's tap used to do before it was repurposed
/// to toggle completion (see `StartPage`'s `onActivityTap`).
class _OpenDetailAction extends StatelessWidget {
  /// Creates an [_OpenDetailAction].
  const _OpenDetailAction({required this.onTap});

  /// Called when the action is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.horizontal(
        right: Radius.circular(context.radius.md),
      ),
      child: Material(
        color: context.extendedColors.taskTile.withAlpha(110),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Icon(
              Icons.chevron_right,
              color: colors.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/start_page/widgets/slide_to_reveal_tile.dart';
import 'package:habits_repository/habits_repository.dart';

/// The list of habits scheduled for the selected day.
///
/// Minimal, functional placeholder — there's no reference design for this
/// yet (unlike `EmptySchedule`/`DayChip`, which came from a screenshot).
/// Revisit once one exists.
class ScheduleList extends StatefulWidget {
  /// Creates a [ScheduleList] for the given [activities].
  const ScheduleList({
    required this.activities,
    required this.completedHabitIds,
    required this.onActivityTap,
    required this.onOpenActivity,
    super.key,
  });

  /// The habits to display, in the order they should be shown.
  final List<Habit> activities;

  /// The ids of the [activities] already logged for the selected day.
  final Set<String> completedHabitIds;

  /// Called with the tapped row's habit, to toggle it done for the selected
  /// day.
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
          // Excluded from semantics: it's a visual affordance for the drag
          // gesture, and an unlabelled chevron button on every row is noise
          // to a screen reader. The same navigation is offered as a named
          // custom action on the row itself (see [_HabitTile]), which
          // doesn't require performing the gesture at all.
          action: ExcludeSemantics(
            child: _OpenDetailAction(
              onTap: () => widget.onOpenActivity(habit),
            ),
          ),
          childBuilder: (context, revealFraction) => _HabitTile(
            habit: habit,
            completedHabitIds: widget.completedHabitIds,
            revealFraction: revealFraction,
            onTap: () => widget.onActivityTap(habit),
            onOpen: () => widget.onOpenActivity(habit),
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
    required this.revealFraction,
    required this.onTap,
    required this.onOpen,
  });

  final Habit habit;
  final Set<String> completedHabitIds;

  /// How far the enclosing [SlideToRevealTile] is open, 0 (closed) to 1
  /// (fully open) — squares off the right corners as it opens, so the tile
  /// reads as flush with the revealed action instead of floating above it.
  final double revealFraction;

  final VoidCallback onTap;

  /// Opens the habit's detail page.
  ///
  /// Same destination as the slide-reveal action, offered here as a named
  /// semantics action so it doesn't depend on the drag gesture.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDone = completedHabitIds.contains(habit.id);
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

    // One node per row, carrying the name, the done state, and both actions.
    // The subtree is excluded rather than merged: its own nodes would be an
    // unlabelled icon, the name, and a second unlabelled icon, which reads
    // as noise and loses the checkbox state entirely (an `Icon` without a
    // `semanticLabel` is invisible to a screen reader). Excluding it means
    // this node must supply `onTap` itself — the `InkWell` below still
    // handles real pointer taps, but its semantics no longer escape.
    return Semantics(
      container: true,
      checked: isDone,
      label: habit.name,
      onTap: onTap,
      onTapHint: l10n.startActivityToggleDoneHint,
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.startActivityOpenDetailsAction):
            onOpen,
      },
      child: ExcludeSemantics(
        child: _tile(context, borderRadius: borderRadius, isDone: isDone),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required BorderRadius borderRadius,
    required bool isDone,
  }) {
    final colors = context.colorScheme;
    final extColors = context.extendedColors;
    final foregroundColor = habit.frequency == Frequency.once
        ? colors.onSurfaceVariant
        : colors.surfaceBright;

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
              Icon(
                isDone ? Icons.check_box : Icons.check_box_outline_blank,
                color: foregroundColor,
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

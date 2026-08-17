import 'dart:async';

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
        return _SlideToRevealTile(
          key: ValueKey(habit.id),
          revealWidth: context.spacing.xxxl,
          action: _OpenDetailAction(onTap: () => onOpenActivity(habit)),
          childBuilder: (context, revealFraction) => _HabitTile(
            habit: habit,
            completedHabitIds: completedHabitIds,
            selectedDate: selectedDate,
            revealFraction: revealFraction,
            onTap: () => onActivityTap(habit),
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

  /// How far the enclosing [_SlideToRevealTile] is open, 0 (closed) to 1
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

/// Wraps the widget built by [childBuilder] in a horizontal-drag gesture
/// that shrinks it from the right — its left edge stays put — revealing
/// [action] underneath in the space that opens up, instead of the child
/// sliding out of frame.
///
/// A row's own `Slidable`-style "swipe to reveal" is usually done by
/// translating the row sideways (that's what `package:flutter_slidable`
/// does under the hood — see its `Slidable.build`, which always wraps its
/// child in a `SlideTransition`). There's no built-in widget for the
/// shrink-in-place variant, so this drives it directly off an
/// [AnimationController]: the controller's value (0 = closed, 1 = fully
/// open) is set straight from drag deltas while dragging, then animated to
/// whichever end is closer once the drag ends.
class _SlideToRevealTile extends StatefulWidget {
  /// Creates a [_SlideToRevealTile].
  const _SlideToRevealTile({
    required this.revealWidth,
    required this.action,
    required this.childBuilder,
    super.key,
  });

  /// How far the child can shrink, in logical pixels — also [action]'s
  /// width.
  final double revealWidth;

  /// Revealed underneath the child as it shrinks.
  final Widget action;

  /// Builds the row content that shrinks to reveal [action], given how far
  /// open it currently is (0 closed, 1 fully open) — a builder rather than
  /// a plain [Widget] so the content itself can react to the reveal
  /// progress (e.g. squaring off its corners as it opens), even though the
  /// [AnimationController] driving it lives inside this widget's state,
  /// not wherever the content is constructed.
  final Widget Function(BuildContext context, double revealFraction)
  childBuilder;

  @override
  State<_SlideToRevealTile> createState() => _SlideToRevealTileState();
}

class _SlideToRevealTileState extends State<_SlideToRevealTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = (details.primaryDelta ?? 0) / widget.revealWidth;
    // Dragging left is a negative delta; subtracting it opens the tile.
    _controller.value = (_controller.value - delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    final open = _controller.value > 0.5;
    unawaited(_controller.animateTo(open ? 1 : 0, curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        // Rebuilt every tick rather than passed as AnimatedBuilder's usual
        // static `child:` — the content itself now depends on the animated
        // value (see `childBuilder`'s doc comment), so it can't be built
        // once and reused across frames like `action` is.
        builder: (context, _) {
          return Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: widget.revealWidth,
                child: widget.action,
              ),
              // The only non-Positioned child, so it sets the Stack's size
              // — shrinking its right inset is what makes the tile itself
              // shrink rather than translate, while its left edge (the
              // Stack's own left edge) never moves.
              Padding(
                padding: EdgeInsets.only(
                  right: _controller.value * widget.revealWidth,
                ),
                child: widget.childBuilder(context, _controller.value),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The action revealed by [_SlideToRevealTile] — opens the habit's detail
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

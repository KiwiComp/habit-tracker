import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/l10n.dart';

/// The empty state shown when nothing is scheduled for the selected day.
class EmptySchedule extends StatelessWidget {
  /// Creates an [EmptySchedule].
  const EmptySchedule({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _EmptyScheduleIcon(),
          SizedBox(height: context.spacing.lg),
          Text(l10n.startEmptyScheduleTitle, style: AppTextStyle.titleLarge),
          SizedBox(height: context.spacing.xs),
          Text(
            l10n.startEmptyScheduleSubtitle,
            style: AppTextStyle.bodyMedium.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyScheduleIcon extends StatelessWidget {
  const _EmptyScheduleIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.edit_calendar_outlined,
          size: context.iconSize.xl,
          color: context.colorScheme.onSurface,
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            padding: EdgeInsets.all(context.spacing.xs / 2),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_circle,
              size: context.iconSize.md,
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

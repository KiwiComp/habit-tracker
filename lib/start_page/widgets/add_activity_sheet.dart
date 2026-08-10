import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/create_activity/models/models.dart';
import 'package:habit_tracker/l10n/l10n.dart';

/// The bottom sheet shown from the start page's FAB, letting the user choose
/// between adding a recurring habit or a one-off task.
///
/// Only responsible for the choice itself — tapping an option pops the
/// sheet with that [ActivityType]. [show] resolves with it, leaving what
/// happens next (opening a creation flow) up to the caller.
class AddActivitySheet extends StatelessWidget {
  /// Creates an [AddActivitySheet].
  const AddActivitySheet({super.key});

  /// Shows the [AddActivitySheet] as a modal bottom sheet.
  ///
  /// Resolves with the tapped [ActivityType], or `null` if the sheet was
  /// dismissed without a choice.
  static Future<ActivityType?> show(BuildContext context) {
    return showModalBottomSheet<ActivityType>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.lg),
        ),
      ),
      builder: (_) => const AddActivitySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: spacing.lg,
          horizontal: spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.addActivitySheetTitle, style: AppTextStyle.titleLarge),
            SizedBox(height: spacing.md),
            _AddActivityOption(
              icon: Icons.military_tech_outlined,
              title: l10n.addActivityHabitTitle,
              subtitle: l10n.addActivityHabitSubtitle,
              onTap: () => Navigator.of(context).pop(ActivityType.habit),
            ),
            SizedBox(height: spacing.sm),
            _AddActivityOption(
              icon: Icons.task_alt_outlined,
              title: l10n.addActivityTaskTitle,
              subtitle: l10n.addActivityTaskSubtitle,
              onTap: () => Navigator.of(context).pop(ActivityType.task),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddActivityOption extends StatelessWidget {
  const _AddActivityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colorScheme;
    final borderRadius = context.radius.md;

    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            children: [
              Icon(
                icon,
                size: context.iconSize.md,
                color: colors.tertiary,
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyle.titleMedium),
                    Text(
                      subtitle,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/add_activity/bloc/bloc.dart';
import 'package:habit_tracker/l10n/l10n.dart';

/// The bottom sheet shown from the start page's FAB, letting the user choose
/// between adding a recurring habit or a one-off task.
///
/// Tapping either option only records the choice in `AddActivityBloc` —
/// there's no habit/task creation flow to open yet (see root `TODO.md`).
class AddActivitySheet extends StatelessWidget {
  /// Creates an [AddActivitySheet].
  const AddActivitySheet({super.key});

  /// Shows the [AddActivitySheet] as a modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.lg),
        ),
      ),
      builder: (_) => BlocProvider(
        create: (_) => AddActivityBloc(),
        child: const AddActivitySheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.spacing.md,
          context.spacing.lg,
          context.spacing.md,
          context.spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.addActivitySheetTitle, style: AppTextStyle.titleLarge),
            SizedBox(height: context.spacing.md),
            _AddActivityOption(
              icon: Icons.military_tech_outlined,
              title: l10n.addActivityHabitTitle,
              subtitle: l10n.addActivityHabitSubtitle,
              onTap: () => context.read<AddActivityBloc>().add(
                const AddActivityHabitTapped(),
              ),
            ),
            SizedBox(height: context.spacing.sm),
            _AddActivityOption(
              icon: Icons.task_alt_outlined,
              title: l10n.addActivityTaskTitle,
              subtitle: l10n.addActivityTaskSubtitle,
              onTap: () => context.read<AddActivityBloc>().add(
                const AddActivityTaskTapped(),
              ),
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
    return Material(
      color: context.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(context.radius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radius.md),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.md),
          child: Row(
            children: [
              Icon(
                icon,
                size: context.iconSize.md,
                color: context.colorScheme.onSurface,
              ),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyle.titleMedium),
                    Text(
                      subtitle,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
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

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// A tappable field mirroring `StartDateField`'s look, for a habit's
/// optional end date.
///
/// Shows "Never" when there isn't one. Tapping opens a small choice sheet
/// ("Never" or a date) rather than jumping straight into a date picker —
/// see [_pick].
class EndDateField extends StatelessWidget {
  /// Creates an [EndDateField].
  const EndDateField({
    required this.date,
    required this.firstDate,
    required this.onChanged,
    super.key,
  });

  /// The currently selected end date, or `null` for "never".
  final DateTime? date;

  /// The earliest date the picker allows — the activity's start date.
  final DateTime firstDate;

  /// Called with the newly picked date, or `null` if the user chose
  /// "Never". Never called if the picker was dismissed without a choice —
  /// `null` here always means an explicit "Never", not "no change".
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderRadius = context.radius.sm;
    final colors = context.colorScheme;
    final iconSize = context.iconSize.md;
    final l10n = context.l10n;

    return Material(
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: colors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: () => _pick(context),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.md,
          ),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: iconSize,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: context.spacing.md),
                  Text(
                    date == null
                        ? l10n.createActivityEndsNever
                        : DateFormat(
                            'd MMM yyyy',
                            context.locale.toString(),
                          ).format(date!),
                    style: AppTextStyle.titleMedium,
                  ),
                ],
              ),
              Icon(
                Icons.keyboard_arrow_down_sharp,
                size: iconSize,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final action = await showModalBottomSheet<_EndDateAction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.lg),
        ),
      ),
      builder: (_) => const _EndDateActionSheet(),
    );
    if (action == null) return;

    if (action == _EndDateAction.never) {
      onChanged(null);
      return;
    }

    if (!context.mounted) return;
    final initial = date != null && !date!.isBefore(firstDate)
        ? date!
        : firstDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime(firstDate.year + 5),
    );
    if (picked != null) onChanged(picked);
  }
}

enum _EndDateAction { never, pickDate }

class _EndDateActionSheet extends StatelessWidget {
  const _EndDateActionSheet();

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
            _EndDateActionOption(
              icon: Icons.all_inclusive,
              title: l10n.createActivityEndsNever,
              onTap: () => Navigator.of(context).pop(_EndDateAction.never),
            ),
            SizedBox(height: spacing.sm),
            _EndDateActionOption(
              icon: Icons.event_outlined,
              title: l10n.createActivityEndsOnDate,
              onTap: () => Navigator.of(context).pop(_EndDateAction.pickDate),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndDateActionOption extends StatelessWidget {
  const _EndDateActionOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
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
              Icon(icon, size: context.iconSize.md, color: colors.tertiary),
              SizedBox(width: spacing.md),
              Text(title, style: AppTextStyle.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

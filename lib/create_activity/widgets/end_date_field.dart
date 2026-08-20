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
    final l10n = context.l10n;
    await pickEndDate(
      context,
      currentDate: date,
      firstDate: firstDate,
      preferredInitialDate: date ?? firstDate,
      neverLabel: l10n.createActivityEndsNever,
      pickDateLabel: l10n.createActivityEndsOnDate,
      onChanged: onChanged,
    );
  }
}

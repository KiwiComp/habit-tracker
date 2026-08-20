import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class DetailsActionTile extends StatelessWidget {
  const DetailsActionTile({
    required this.label,
    required this.leadingIcon,
    required this.onTap,
    this.trailingIcon,
    this.date,
    super.key,
  });

  final String label;
  final IconData leadingIcon;
  final IconData? trailingIcon;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(spacing.sm),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Row(
                spacing: spacing.sm,
                children: [
                  Icon(leadingIcon),
                  Text(label),
                ],
              ),
              Visibility(
                visible: date != null,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _TrailingBox(
                  dateLabel: '${date?.day}/${date?.month}/${date?.year}',
                  icon: null,
                ),
              ),
              if (trailingIcon != null && date == null)
                _TrailingBox(dateLabel: null, icon: trailingIcon),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrailingBox extends StatelessWidget {
  const _TrailingBox({required this.dateLabel, required this.icon});

  final String? dateLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final borderRadius = context.radius.xs;
    final spacing = context.spacing;
    final colors = context.colorScheme;
    final iconSize = context.iconSize.sm + 2;
    final horizontalPadding = dateLabel != null ? spacing.sm : spacing.xl;

    return Container(
      decoration: BoxDecoration(
        color: colors.tertiary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: spacing.sm,
          horizontal: horizontalPadding,
        ),
        child: dateLabel != null
            ? Text(
                dateLabel!,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: colors.onTertiary,
                ),
              )
            : Icon(
                icon,
                size: iconSize,
                color: colors.onTertiary,
              ),
      ),
    );
  }
}

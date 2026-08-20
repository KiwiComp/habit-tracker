import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class DetailsActionTile extends StatelessWidget {
  const DetailsActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.date,
    super.key,
  });

  final String label;
  final IconData icon;
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
                  Icon(icon),
                  Text(label),
                ],
              ),
              Visibility(
                visible: date != null,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _DateBox(
                  dateLabel: '${date?.day}/${date?.month}/${date?.year}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final borderRadius = context.radius.xs;
    final spacing = context.spacing;
    final colors = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.tertiary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.sm),
        child: Text(
          dateLabel,
          style: AppTextStyle.bodyMedium.copyWith(color: colors.onTertiary),
        ),
      ),
    );
  }
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class TaskAndHabitListEmptyView extends StatelessWidget {
  const TaskAndHabitListEmptyView({
    required this.title,
    required this.text,
    super.key,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Center(
      child: Column(
        mainAxisAlignment: .center,
        spacing: spacing.sm,
        children: [
          Text(
            title,
            textAlign: .center,
            style: AppTextStyle.headlineSmall,
          ),
          Text(
            text,
            textAlign: .center,
            style: AppTextStyle.bodyLarge,
          ),
        ],
      ),
    );
  }
}
